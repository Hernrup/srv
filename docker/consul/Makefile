DOCKER_IMAGE = docker.hernup.se/consul
SWARM := $(shell docker system info 2>/dev/null|grep -i swarm|awk -F\: '{print $$NF}'|tr -d '[:space:]')


.PHONY: help
help:
	@# Print a help text
	@./make-help.py $(MAKEFILE_LIST)


.PHONY: up
up:
	@# Run the service locally
	docker-compose up -d


.PHONY: swarm_up
swarm_up:
	@# Run consul cluster in a local docker swarm
# SWARM=$(shell docker node ls > /dev/null && )

ifeq ($(SWARM), active)
	docker stack deploy -c ./docker-cloud.yml consul
else
	@echo "host is not configured for docker swarm"
endif


.PHONY: build
build:
	@# Build a new image for this service
ifeq ($(shell git rev-parse --abbrev-ref HEAD),master)
	@docker build --pull -t $(DOCKER_IMAGE):latest --build-arg GIT_REF=`git rev-parse --short HEAD` .
else
	@docker build --pull -t $(DOCKER_IMAGE):latest --build-arg GIT_REF=`git rev-parse --abbrev-ref HEAD` .
endif


.PHONY: publish
publish: build
	@# Publish this image to our docker repository

ifeq ($(shell git rev-parse --abbrev-ref HEAD),master)
	@# If we're on master, and there's no image with the current version
	@# published, publish the image and tag this commit in git.
	@export VERSION=`git rev-parse --short HEAD` \
	&& docker pull $(DOCKER_IMAGE):$$VERSION > /dev/null 2>&1 \
		|| (docker tag $(DOCKER_IMAGE):latest $(DOCKER_IMAGE):$$VERSION \
				&& docker tag $(DOCKER_IMAGE):$$VERSION $(DOCKER_IMAGE):latest \
				&& docker push  $(DOCKER_IMAGE):latest \
				&& docker push  $(DOCKER_IMAGE):$$VERSION  \
				&& echo "Published $(DOCKER_IMAGE):$$VERSION" \
		)
else
	@# If we're not on master, publish the image with the current branch name
	@# as tag.
	@export IMAGE_TAG=`git rev-parse --abbrev-ref HEAD` \
	&& docker tag $(DOCKER_IMAGE):latest $(DOCKER_IMAGE):$$IMAGE_TAG \
	&& docker push $(DOCKER_IMAGE):$$IMAGE_TAG \
	&& echo "Published $(DOCKER_IMAGE):$$IMAGE_TAG"
endif


.PHONY: purge
purge: down
	@# Tear down everything

.PHONY: swarm_down
swarm_down:
	@# Run consul cluster in a local docker swarm

ifeq ($(SWARM), active)
	docker stack rm consul
else
	@echo "host is not configured for docker swarm"
endif


.PHONY: down
down:
	@# Remove containers, volumes, networks, and dangling images.
	@echo "Removing containers..."
	docker-compose down --volumes

	@echo "Removing dangling images..."
	@if [ -n "`docker images -qaf dangling=true`" ]; then docker rmi -f `docker images -q -a -f dangling=true`; fi
