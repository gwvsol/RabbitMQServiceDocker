.PHONY: help pre build start stop log remove

#ID=$(shell id -u `whoami`)
DOCKER=$(shell which docker)
COMPOSE=$(shell which docker-compose)
PWD=$(shell pwd)
RELEASE=release
DOCKERFILE=Dockerfile
COMPOSE_FILE=docker-compose.yml
MAKEFILE=Makefile
#=============================================
# RabbitMQ
RABBITDB=rabbitdb
# Где располагаются данные RabbitMQ на машине хоста
RABBITDBHOSTDIR=/var/data/rabbitdb
DOCKERFILE_REBBITDB=${RABBITDB}/${DOCKERFILE}
#=============================================

.DEFAULT: help

help:
	@echo "make build	- Building Redis in Docker"
	@echo "make start	- Start Redis in Docker"
	@echo "make stop	- Stopping Redis in Docker"
	@echo "make log	- Output of logs for Redis in Docker"
	@echo "make remove	- Deleting a Redis in Docker"

#=============================================
# Релиз сервиса RabbitMQ
release: clean ${MAKEFILE} ${COMPOSE_FILE} ${RABBITDB}
	mkdir ${RELEASE}
	zip -r ${RELEASE}/${RABBITDB}-$(shell date '+%Y-%m-%d').zip \
	${RABBITDB}	${MAKEFILE} ${COMPOSE_FILE}

# Очистка мусора и удаление старого релиза
clean:
	rm -fr ${RELEASE}

#=============================================

# Сборка RabbitMQ в Docker
build-rabbit: ${DOCKER} ${DOCKERFILE_REBBITDB}
	# make release
	docker build \
	--file ./${DOCKERFILE_REBBITDB} \
	--tag ${RABBITDB}:latest ./

# Стоп RabbitMQ в Docker, используется для отладки
stop-rabbit: ${DOCKER} ${DOCKERFILE_REBBITDB}
	! [ `${DOCKER} ps | grep ${RABBITDB} | wc -l` -eq 1 ] || \
	${DOCKER} stop ${RABBITDB}


# Удаление RabbitMQ в Docker, используется для отладки
remove-rabbit: ${DOCKER} ${DOCKERFILE_REBBITDB}
	make stop-rabbit
	${DOCKER} rmi ${RABBITDB}:latest


# Логирование RabbitMQ в Docker, используется для отладки
log-rabbit: ${DOCKER} ${DOCKERFILE_REBBITDB}
	! [ `${DOCKER} ps | grep ${RABBITDB} | wc -l` -eq 1 ] || \
	${DOCKER} logs --follow --tail 500 ${RABBITDB}

#=============================================
# Проверка наличия необходимых дирректорий для работы приложений
check-dir:
	[ -d ${RABBITDBHOSTDIR} ] || sudo mkdir -p ${RABBITDBHOSTDIR}


# Сборка RabbitMQ в Docker
build: ${DOCKER} ${COMPOSE} ${DOCKERFILE_REBBITDB} ${COMPOSE_FILE}
	make release
	make check-dir
	make build-rabbit


# Старт RabbitMQ в Docker с использованием Docker Compose
start: ${DOCKER} ${COMPOSE} ${DOCKERFILE_REBBITDB} ${COMPOSE_FILE}
	make check-dir
	${COMPOSE} -f ${COMPOSE_FILE} up -d


# Остановка RabbitMQ в Docker с использованием Docker Compose
stop: ${DOCKER} ${COMPOSE} ${DOCKERFILE_REBBITDB} ${COMPOSE_FILE}
	${COMPOSE} -f ${COMPOSE_FILE} down


# Логирование RabbitMQ в Docker с использованием Docker Compose
log: ${DOCKER} ${COMPOSE} ${DOCKERFILE_REBBITDB} ${COMPOSE_FILE}
	${COMPOSE} -f ${COMPOSE_FILE} logs --follow --tail 500


# Рестарт RabbitMQ в Docker с использованием Docker Compose
restart: ${DOCKER} ${COMPOSE} ${DOCKERFILE_REBBITDB} ${COMPOSE_FILE}
	make stop
	sleep 3
	make start


# Удаление RabbitMQ в Docker
remove: ${DOCKER} ${COMPOSE} ${DOCKERFILE_REBBITDB} ${COMPOSE_FILE}
	make stop
	make remove-rabbit

#=============================================