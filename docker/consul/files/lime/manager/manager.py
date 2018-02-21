#!/usr/bin/python3
import consul
import subprocess as sp
import logging
import sys
import click
import datetime
import os
import boto3
import botocore

import consul_handler as ch

logger = logging.getLogger(__name__)


class Node(object):
    """Node carries around consul client and backup path.

    The Node contains a consul client and the path for consul backups.

    Args:
        backup_path (optional): Path to save database backups to.
            Defaults to '/var/lime/backup_files'.
        backup_toggle_key (optional): Consul key for toggling backup.
            Defaults to 'backup_consul'.
        devmode (optional): Boolean indicating if we are running in `DEVMODE`.
            Defaults to False.
        bucket (optional): Bucket to use when fetching restores from S3.

    Attributes:
        consul: Consul client.
        backup_path: Path for backups.
        backup_toggle_key: Consul key used for toggling backup.
        devmode: Boolean indicating if the service is running in `DEVMODE`.
        bucket: S3 bucket name for restores.  Not available in `DEVMODE`.
    """
    def __init__(self, backup_path='/var/lime/backup_files',
                 backup_toggle_key='backup_consul', devmode=False,
                 auto_restore=False, bucket=None):
        self.consul = consul.Consul()
        self.backup_path = backup_path
        self.backup_toggle_key = backup_toggle_key
        self.devmode = devmode
        self.auto_restore = auto_restore
        self.bucket = bucket


def _setup_logging():
    global_log = logging.getLogger()
    global_log.setLevel(logging.INFO)

    handler = logging.StreamHandler()

    formatter = logging.Formatter(
        '%(asctime)s: %(levelname)s: %(message)s')
    handler.setFormatter(formatter)

    global_log.addHandler(handler)


@click.group()
@click.pass_context
def cli(ctx):
    pass


@cli.command()
@click.pass_context
def try_auto_restore(ctx):
    """Check whether auto restore is enabled and restore if it is."""
    node = ctx.obj

    if node.auto_restore:
        logger.info('Automatic restore is enabled, trying to restore consul.')
        ctx.invoke(restore_consul_kv_data, force=True)
    else:
        logger.info('Automatic restore is disabled, skipping restore.')


@cli.command()
@click.pass_context
def enable_consul_backups(ctx):
    """Enable consul backups by setting the toggle key to true."""
    node = ctx.obj

    logger.info('Enabling consul backups.')
    node.consul.kv.put(node.backup_toggle_key, 'true')


@cli.command()
@click.pass_context
@click.option('--force', '-f', default=False, is_flag=True, help="Force")
def restore_consul_kv_data(ctx, force):
    """Get consul KV data backup from S3 and restore from it."""
    node = ctx.obj

    if node.devmode:
        logger.info('Restoring KV store...')
        restore_file = os.path.join(node.backup_path, 'consul_kv_backup.bak')
        _restore_consul_kv_store(restore_file, node)
        return

    if not node.bucket:
        logger.warn('Environment variable BACKUP_BUCKET not set.')
        return

    s3 = boto3.resource('s3')
    bucket = s3.Bucket(node.bucket)

    try:
        backup = bucket.Object('consul_kv_backup.bak')

        logger.info('Found backup with timestamp {}.'
                    .format(backup.last_modified))

        if not force:
            really = input(
                'Do you really want to restore this backup? (y/N) ')
            if really.lower() != 'y':
                logger.info('Skipping restore.')
                return

        restore_file = os.path.join('/tmp', 'consul_kv_backup.bak')

        logger.info('Downloading file from s3...')
        backup.download_file(restore_file)
        logger.info('Restoring KV store...')
        _restore_consul_kv_store(restore_file, node)
        logger.info('Removing temporary restore file...')
        os.remove(restore_file)

    except botocore.exceptions.ClientError as e:
        logger.error('Error getting consul kv backup from S3: {}'.format(e))


@cli.command()
@click.pass_context
def backup_consul_data(ctx):
    """Backup both consul raft database and kv store"""
    node = ctx.obj

    if not _should_backup(node):
        logger.info('Backup for consul is currently disabled. Set consul key '
                    '"{}" to "true" to enable backup.'
                    .format(node.backup_toggle_key))
        return

    time_start = datetime.datetime.now()
    _backup_consul_kv_store(node.backup_path, node)
    _backup_consul_raft_database(node.backup_path, node)
    elapsed_time = (datetime.datetime.now() - time_start).total_seconds()
    logger.info('Total backup time: {}'.format(elapsed_time))
    try:
        sp.check_call(['containerpilot', '-putmetric',
                      'consul_database_backup_time={}'.format(elapsed_time)])
    except sp.CalledProcessError:
        logger.error('Failed to putmetric to containerpilot.')


def _restore_consul_kv_store(restore_path, node):
    if not os.path.isfile(restore_path):
        logger.info('No consul kv backup file found, skipping restore.')
        return

    try:
        with ch.consul_lock('kv_restore', node):
            _, entries = node.consul.kv.get('', recurse=True)
            _, events = node.consul.kv.get('events/', recurse=True)

            node.consul.kv.delete('', recurse=True)
            try:
                sp.check_call(['consul', 'kv', 'import',
                               '@{}'.format(restore_path)])

            except sp.CalledProcessError:
                if entries:
                    for entry in entries:
                        node.consul.kv.put(key=entry.get('Key'),
                                           value=entry.get('Value').decode())
                logger.error('Failed to restore kv store...')
                return

            node.consul.kv.delete('events/', recurse=True)

            if events:
                for event in events:
                    node.consul.kv.put(key=event.get('Key'),
                                       value=event.get('Value').decode())

            node.consul.kv.delete('lock/', recurse=True)

    except ch.ConsulUnLockError:
        logger.info('Consul lock removed and can thus not be released.')
        pass


def _backup_consul_kv_store(backup_path, node):
    with ch.consul_lock('kv_backup', node):
        filename = 'consul_kv_backup.bak'
        file_path = os.path.join(node.backup_path, filename)
        tmp_file_path = os.path.join(node.backup_path,
                                     '{}.tmp'.format(filename))
        try:
            with open(tmp_file_path, 'wb') as tmp_file:
                sp.check_call(['consul', 'kv',
                               'export'], stdout=tmp_file)

            os.rename(tmp_file_path, file_path)

        except sp.CalledProcessError:
            logger.error('Failed to backup kv store...')


def _backup_consul_raft_database(backup_path, node):
    with ch.consul_lock('raft_backup', node):
        filename = 'consul_raft_backup.bak'
        file_path = os.path.join(node.backup_path, filename)
        tmp_file_path = os.path.join(node.backup_path,
                                     '{}.tmp'.format(filename))
        try:
            sp.check_call(['consul', 'snapshot', 'save', tmp_file_path])
            os.rename(tmp_file_path, file_path)
        except sp.CalledProcessError:
            logger.error('Failed to backup raft database...')


def _should_backup(node):
    try:
        toggle_key = ch.get_consul_value(node.backup_toggle_key, node)
        return toggle_key.lower() == 'true'
    except ch.ConsulKeyError as e:
        logger.info(e)
        return False


def main():
    _setup_logging()

    devmode = os.environ.get('DEVMODE', 'False').lower() == 'true'
    auto_restore = os.environ.get('AUTO_RESTORE', 'False').lower() == 'true'

    node = Node(devmode=devmode,
                auto_restore=auto_restore,
                bucket=os.environ.get('BACKUP_BUCKET'))

    return cli(obj=node)


if __name__ == '__main__':
    sys.exit(main())
