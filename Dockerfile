FROM rabbitmq:management-alpine
LABEL maintainer="Mikhail Fedorov" email="jwvsol@yandex.ru"
LABEL version="latest"

ARG TIMEZONE
ENV TIMEZONE=${TIMEZONE:-Europe/Moscow}
ENV SCRIPT=run.sh
ENV CONFIGFILE=rabbitmq.conf

ENV RABBITDB_ZBXUSER ${RABBITDB_ZBXUSER:-zbx_monitor}
ENV RABBITDB_ZBXPASS ${RABBITDB_ZBXPASS:-zbx_monitor}
ENV RABBITMQ_PID_FILE ${RABBITMQ_PID_FILE:-/var/lib/rabbitmq/mnesia/rabbitmq}

# ENV HTTP_PROXY="http://192.168.93.1:3128"
# ENV HTTPS_PROXY="https://192.168.93.1:3128"

RUN set -eux \
    && ln -snf /usr/share/zoneinfo/$TIMEZONE \
        /etc/localtime && echo $TIMEZONE > /etc/timezone \
    && apk update \
    && apk add --no-cache netcat-openbsd tzdata

RUN rabbitmq-plugins enable --offline rabbitmq_management

ADD ${CONFIGFILE} /etc/rabbitmq/${CONFIGFILE}
ADD ${SCRIPT} /opt/rabbitmq/sbin/${SCRIPT}
RUN chmod +x /opt/rabbitmq/sbin/${SCRIPT}

HEALTHCHECK --start-period=3s \
            --timeout=2s \
            --interval=60s \
            --retries=3 \
            CMD ["nc", "-zv", "localhost", "5672"] || kill 1

CMD ["run.sh"]
