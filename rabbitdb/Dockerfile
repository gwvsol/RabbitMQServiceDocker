# FROM rabbitmq
FROM rabbitmq:management-alpine
LABEL maintainer="Mikhail Fedorov" email="jwvsol@yandex.ru"
LABEL version="latest"

ENV RABBITDB_ZBXUSER ${RABBITDB_ZBXUSER}
ENV RABBITDB_ZBXPASS ${RABBITDB_ZBXPASS}
ENV RABBITMQ_PID_FILE ${RABBITMQ_PID_FILE}

# Используется в некоторых случаях если не возможно 
# собрать образ и в системе используется Proxy
# ENV HTTP_PROXY="http://192.168.93.1:3128"
# ENV HTTPS_PROXY="https://192.168.93.1:3128"

# Включаем расширения для Rabbit
RUN rabbitmq-plugins enable --offline rabbitmq_management

# Добавляем файл настроек базы Rabbit
ADD rabbitdb/rabbitmq.conf /etc/rabbitmq/rabbitmq.conf
ADD rabbitdb/init.sh /opt/rabbitmq/sbin/init.sh
RUN chmod +x /opt/rabbitmq/sbin/init.sh

# Define default command
CMD ["init.sh"]
