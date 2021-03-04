# FROM rabbitmq
FROM rabbitmq:3-management
LABEL maintainer="Mikhail Fedorov" email="jwvsol@yandex.ru"
LABEL version="latest"

# Используется в некоторых случаях если не возможно 
# собрать образ и в системе используется Proxy
# ENV HTTP_PROXY="http://192.168.93.1:3128"
# ENV HTTPS_PROXY="https://192.168.93.1:3128"

# Включаем расширения для Rabbit
RUN rabbitmq-plugins enable --offline rabbitmq_management

# Добавляем файл настроек базы Rabbit
# ADD rabbitdb/rabbitmq.conf /etc/rabbitmq/rabbitmq.conf

# Какие порты открываем
# EXPOSE 15671 15672