### RABBITMQ-SERVICE    
---      

* Установка    

```bash
ansible-playbook -i astersvc-dev-01, playbook.yml
```    

```bash
rabbitmqadmin --username=${RABBITMQ_DEFAULT_USER} --password=${RABBITMQ_DEFAULT_PASS} -f tsv -q list queues name consumers |  awk '$2 == 0 {print $1}' | while read queue; do rabbitmqadmin --username=${RABBITMQ_DEFAULT_USER} --password=${RABBITMQ_DEFAULT_PASS} -q delete queue name=${queue}; done
```
