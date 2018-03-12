.PHONY: setup
setup: provision setup-smb-conf setup-fstab setup-backup

.PHONY: setup-backup
setup-backup: setup-backup-ssh-keys

.PHONY: setup-smb-conf
setup-smb-conf:
	sudo cp /etc/smb.conf /etc/smb.conf.bak
	sudo ln -sf $(shell pwd)/provison/smb.conf /etc/samba/smb.conf

.PHONY: setup-fstab
setup-fstab:
	sudo ln -sf $(shell pwd)/fstab /etc/fstab

.PHONY: provision
provision:
	. $(shell pwd)/provision.sh

.PHONY: ssl
ssl:
	docker-compose up ssl
	docker-compose exec nginx nginx -s reload

.PHONY:
up: up
	docker-compose up -d

.PHONY: stop
stop:
	docker-compose down

.PHONY: backup
backup:
	docker-compose run --rm backup /run_now.sh

.PHONY: setup-backup-ssh-keys
setup-backup-ssh-keys:
	docker-compose run --rm backup ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N "" || true
	docker-compose run --rm backup ssh-copy-id mhe@nas.hernrup.se:2222
	docker-compose run --rm backup ssh-copy-id mhe@mh.internal

.PHONY: clean
clean: reset-containers
	@echo "Clearing state..."

.PHONY: reset-containers
reset-containers:
	@echo "Stopping any running containers..."
	@if [ -n "`docker ps -q`" ]; then docker stop `docker ps -q`; fi

	@echo "Removing containers..."
	@if [ -n "`docker ps -qa`" ]; then docker rm `docker ps -a -q`; fi

	@echo "Removing dangling images..."
	@if [ -n "`docker images -qaf dangling=true`" ]; then docker rmi -f `docker images -q -a -f dangling=true`; fi
