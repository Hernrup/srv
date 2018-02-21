import contextlib
import logging

logger = logging.getLogger(__name__)


class Error(Exception):
    """ Base error class. """


class ConsulLockError(Error):
    """ Error when trying to acquire consul lock. """
    pass


class ConsulUnLockError(Error):
    """ Error when trying to release consul lock. """
    pass


class ConsulKeyError(Error):
    """ Error when accessing key in consul. """
    pass


def get_consul_value(key, node):
    """ Returns the value of the consul key `key`.

    Args:
        key: The key whose value to retrieve.

    Returns:
        The value for the given key.

    Raises:
        ConsulKeyError: If the key does not exist or has no value.
    """

    _, item = node.consul.kv.get(key)

    if item is None or not item.get('Value'):
        raise ConsulKeyError('The key "{}" does not exist in consul.'
                             .format(key))

    return item.get('Value').decode()


@contextlib.contextmanager
def consul_lock(lock_name, node):
    """ Acquire consul lock to only allow one server to restore or backup.

    Args:
        lock_name: The name of the lock to acquire.

    Raises:
        ConsulLockError: If it fails to acquire the lock.
        ConsulUnLockError: If it fails to release the lock.
    """
    session_id = node.consul.session.create('consul-lock',
                                            behavior='release',
                                            ttl=120)
    lock = False

    try:
        logger.info('Acquiring consul lock for {}'.format(lock_name))
        lock = node.consul.kv.put(
            'lock/consul/{}'.format(lock_name), None, acquire=session_id)

        if not lock:
            raise ConsulLockError('Failed to acquire lock. Backup may be '
                                  'running somewhere else. Skipping...')

        yield

    finally:
        if lock:
            logger.info('Releasing consul lock for {}'.format(lock_name))
            if not node.consul.kv.put(
                'lock/consul/{}'.format(lock_name),
                    '', release=session_id):
                raise ConsulUnLockError('Failed to release lock')
        node.consul.session.destroy(session_id)
