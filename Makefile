.PHONY: setup start stop clean

setup: setup-dependecies setup-smb-conf setup-fstab setup-backup

setup-backup: setup-backup-ssh-keys

setup-smb-conf:
	sudo ln -sf $(shell pwd)/smb.conf /etc/samba/smb.conf

setup-fstab:
	sudo ln -sf $(shell pwd)/fstab /etc/fstab

setup-dependencies:
	. ../provision.sh

ssl:
	docker-compose up ssl
	docker-compose exec nginx nginx -s reload

ssl-standalone:
	docker-compose up ssl-standalone

start:
	docker-compose up -d plex sonarr nzb potatoe registry nginx backup

stop:
	docker-compose down

logs:
	docker-compose logs -f --tail 50

backup:
	docker-compose run --rm backup /run_now.sh

setup-backup-ssh-keys:
	docker-compose run --rm backup ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N "" || true
	docker-compose run --rm backup ssh-copy-id mhe@nas.hernrup.se:2222
	docker-compose run --rm backup ssh-copy-id mhe@mh.internal

clean: reset-containers
	@echo "Clearing state..."

reset-containers:
	@echo "Stopping any running containers..."
	@if [ -n "`docker ps -q`" ]; then docker stop `docker ps -q`; fi

	@echo "Removing containers..."
	@if [ -n "`docker ps -qa`" ]; then docker rm `docker ps -a -q`; fi

	@echo "Removing dangling images..."
	@if [ -n "`docker images -qaf dangling=true`" ]; then docker rmi -f `docker images -q -a -f dangling=true`; fi
