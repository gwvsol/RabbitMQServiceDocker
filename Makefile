.PHONY: help pre build start stop log remove

#ID=$(shell id -u `whoami`)
DOCKER=$(shell which docker)
COMPOSE=$(shell which docker-compose)
PWD=$(shell pwd)
ENV=.env
DOCKERIGNORE=.dockerignore
include ${ENV}
#=============================================

.DEFAULT: help

help:
	@echo "make build - Building Redis in Docker"
	@echo "make start - Start Redis in Docker"
	@echo "make stop - Stopping Redis in Docker"
	@echo "make log - Output of logs for Redis in Docker"
	@echo "make remove - Deleting a Redis in Docker"

#=============================================
# Релиз сервиса RabbitMQ
release: clean ${MAKEFILE} ${COMPOSE_FILE} ${RABBITDB}
	mkdir ${RELEASE}
	zip -r ${RELEASE}/${RABBITDB}-$(shell date '+%Y-%m-%d').zip \
	${RABBITDB}	${MAKEFILE} ${COMPOSE_FILE} ${ENV} ${DOCKERIGNORE}

# Очистка мусора и удаление старого релиза
clean:
	rm -fr ${RELEASE}

#=============================================

# Сборка RabbitMQ в Docker
build-rabbit: ${DOCKER} ${RABBITDB_DOCKERFILE}
	# make release
	${DOCKER} build \
	--file ./${RABBITDB_DOCKERFILE} \
	--tag ${RABBITDB_RELEASE} ./

# Стоп RabbitMQ в Docker, используется для отладки
stop-rabbit: ${DOCKER} ${RABBITDB_DOCKERFILE}
	! [ `${DOCKER} ps | grep ${RABBITDB} | wc -l` -eq 1 ] || \
	${DOCKER} stop ${RABBITDB}

# Удаление RabbitMQ в Docker, используется для отладки
remove-rabbit: ${DOCKER} ${RABBITDB_DOCKERFILE}
	make stop-rabbit
	${DOCKER} rmi ${RABBITDB_RELEASE}

# Логирование RabbitMQ в Docker, используется для отладки
log-rabbit: ${DOCKER} ${RABBITDB_DOCKERFILE}
	! [ `${DOCKER} ps | grep ${RABBITDB} | wc -l` -eq 1 ] || \
	${DOCKER} logs --follow --tail 500 ${RABBITDB}

#=============================================
# Проверка наличия необходимых дирректорий для работы приложений
# check-dir:
# 	[ -d ${RABBITDBHOSTDIR} ] || sudo mkdir -p ${RABBITDBHOSTDIR}

# Сборка RabbitMQ в Docker
build: ${DOCKER} ${COMPOSE} ${RABBITDB_DOCKERFILE} ${COMPOSE_FILE}
	make release
#	make check-dir
	make build-rabbit

# Старт RabbitMQ в Docker с использованием Docker Compose
start: ${DOCKER} ${COMPOSE} ${RABBITDB_DOCKERFILE} ${COMPOSE_FILE}
#	make check-dir
	${COMPOSE} -f ${COMPOSE_FILE} up -d

# Остановка RabbitMQ в Docker с использованием Docker Compose
stop: ${DOCKER} ${COMPOSE} ${RABBITDB_DOCKERFILE} ${COMPOSE_FILE}
	${COMPOSE} -f ${COMPOSE_FILE} down

# Логирование RabbitMQ в Docker с использованием Docker Compose
log: ${DOCKER} ${COMPOSE} ${RABBITDB_DOCKERFILE} ${COMPOSE_FILE}
	${COMPOSE} -f ${COMPOSE_FILE} logs --follow --tail 500

# Рестарт RabbitMQ в Docker с использованием Docker Compose
restart: ${DOCKER} ${COMPOSE} ${RABBITDB_DOCKERFILE} ${COMPOSE_FILE}
	make stop
	sleep 3
	make start

# Удаление RabbitMQ в Docker
remove: ${DOCKER} ${COMPOSE} ${RABBITDB_DOCKERFILE} ${COMPOSE_FILE}
	make stop
	make remove-rabbit

#=============================================