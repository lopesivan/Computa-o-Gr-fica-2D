VERSION   = 0.1
NAME      = vg

include docker.mk

DOCKER_COMPOSE= docker-compose
DOCKER        = docker

all: ${NAME}

${NAME}:
	$(DOCKER_COMPOSE) run --rm $@

