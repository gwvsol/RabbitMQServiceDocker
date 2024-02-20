#===========================================================
export ARCHIVE=archive
export COMPOSE_FILE=docker-compose.yml
export DOCKERFILE=Dockerfile
export DRONE=.drone.yml
export README=README.md
export RELEASE=release
export LICENSE=LICENSE
export MAKEFILE=Makefile
# export MAKEFILE_DOCKER=Makefile.Docker
export PLAYBOOK=playbook.yml
#
export REGISTRY_USER=kab
export REGISTRY_PASSWORD=Let90nc23
export REGISTRY_TAG=2024-02-20-01
export REGISTRY_HOST=registry.svc.1ckab.ru
#
export RABBITDB_RUN=run.sh
export RABBITDB_IMAGE=rabbitmq-db
export RABBITDB_CONF=rabbitmq.conf
export RABBITDB_ZBXUSER=zbx_monitor
export RABBITDB_ZBXPASS="TNu*&VT345N"
export RABBITMQ_PID_FILE=/var/lib/rabbitmq/mnesia/rabbitmq
#
export DOCKER=$(shell which docker)
export COMPOSE=$(shell which docker-compose)
export TIMEZONE=$(shell timedatectl status | awk '$$1 == "Time" && $$2 == "zone:" { print $$3 }')
export PWD=$(shell pwd)

#===========================================================

# ifneq ("$(wildcard $(PWD)/$(MAKEFILE_DOCKER))","")
#     include ${MAKEFILE_DOCKER}
# endif

#===========================================================
# Создание релиза приложения
.PHONY: release
release: ${COMPOSE_FILE} ${DOCKERFILE} ${RABBITDB_RUN} ${LICENSE} ${MAKEFILE} \
		 ${MAKEFILE_DOCKER} ${RABBITDB_CONF} ${DRONE} ${PLAYBOOK} ${README}
	@make clean
	@printf "\033[0m"
	@printf "\033[34m"
	@echo "================================ CREATE RELEASE ===================================="
	@tar -cvzf ${RELEASE}/${RABBITDB_IMAGE}-$(shell date '+%Y-%m-%d-%H-%M-%S').tar.gz \
		${COMPOSE_FILE} ${DOCKERFILE} ${RABBITDB_RUN} ${LICENSE} ${MAKEFILE} \
		${MAKEFILE_DOCKER} ${RABBITDB_CONF} ${DRONE} ${PLAYBOOK} ${README}
	@printf "\033[32m"
	@echo "================================ CREATE RELEASE OK! ================================"
	@printf "\033[0m"

#===========================================================
# Очистка мусора
.PHONY: clean
clean:
	@printf "\033[0m"
	@printf "\033[33m"
	@echo "====================================== CLEAN ======================================="
	@[ -d $(RELEASE) ] || mkdir ${RELEASE}
	@[ -d $(ARCHIVE) ] || mkdir ${ARCHIVE}
	@find . '(' -path ./$(ARCHIVE) ')' \
		-prune -o '(' -name '*.tar.gz' -o -name '*.tar.xz' -o -name '*.zip' ')' \
		-type f -exec mv -v -t "$(ARCHIVE)" {} +
	@printf "\033[36m"
	@echo "==================================== CLEAN OK! ====================================="
	@printf "\033[0m"

#===========================================================
# ################### Сборка RABBITDB ######################
#===========================================================

.PHONY: build
build: ${DOCKER} ${DOCKERFILE}
	@printf "\033[0m"
	@printf "\033[34m"
	@echo "================================= BUILD RABBITDB ==================================="
	@${DOCKER} build \
	--build-arg TIMEZONE=${TIMEZONE} \
	--build-arg RABBITDB_ZBXUSER=${RABBITDB_ZBXUSER} \
	--build-arg RABBITDB_ZBXPASS=${RABBITDB_ZBXPASS} \
	--build-arg RABBITMQ_PID_FILE=${RABBITMQ_PID_FILE} \
	--file ./${DOCKERFILE} \
	--tag ${RABBITDB_IMAGE}:${REGISTRY_TAG} ./
	@printf "\033[32m"
	@echo "========================= BUILD ${RABBITDB_IMAGE}:${REGISTRY_TAG} ========================"
	@echo "=============================== BUILD RABBITDB OK! ================================="
	@printf "\033[0m"

#===========================================================
# ########### Публикация GEOSERVICEDB в REGISTRY ###########
#===========================================================
.PHONY: deploy
deploy: ${DOCKER}
	@printf "\033[0m"
	@printf "\033[34m"
	@echo "============================== DEPLOY IMAGE RABBITDB ==============================="
	@${DOCKER} login -u ${REGISTRY_USER} -p ${REGISTRY_PASSWORD} ${REGISTRY_HOST}
	@${DOCKER} tag ${RABBITDB_IMAGE}:${REGISTRY_TAG} ${REGISTRY_HOST}/${RABBITDB_IMAGE}:${REGISTRY_TAG}
	@${DOCKER} push ${REGISTRY_HOST}/${RABBITDB_IMAGE}:${REGISTRY_TAG}
	@${DOCKER} rmi ${REGISTRY_HOST}/${RABBITDB_IMAGE}:${REGISTRY_TAG} ${RABBITDB_IMAGE}:${REGISTRY_TAG}
	@${DOCKER} logout
	@printf "\033[32m"
	@echo "============================ DEPLOY IMAGE RABBITDB OK! ============================="
	@printf "\033[0m"

#===========================================================