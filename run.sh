#!/bin/sh

# Create Rabbitmq zbx_monitor user
( rabbitmqctl wait --timeout 60 $RABBITMQ_PID_FILE ; \
rabbitmqctl add_user $RABBITDB_ZBXUSER $RABBITDB_ZBXPASS ; \
rabbitmqctl set_user_tags $RABBITDB_ZBXUSER monitoring ; \
rabbitmqctl set_permissions -p / $RABBITDB_ZBXUSER  "" "" ".*" ; \
echo "*** User '$RABBITDB_ZBXUSER' with password '$RABBITDB_ZBXPASS' completed. ***" ) &

rabbitmq-server $@
