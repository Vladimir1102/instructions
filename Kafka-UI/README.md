Как загрузить и запустить Kafka UI из Docker Hub:
Запустите команду для загрузки и запуска образа:

```
docker run -d \
-p 8080:8080 \
-e KAFKA_CLUSTERS_0_NAME=local \
-e KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=localhost:9092 \
provectuslabs/kafka-ui
```
Docker автоматически скачает образ Kafka UI с Docker Hub и запустит его на вашем компьютере.

После этого, интерфейс Kafka UI будет доступен по адресу:



```http://localhost:8080```

Если вам нужно дополнительно настроить конфигурации, их можно передавать через переменные среды. 

Полный список переменных и инструкции можно найти на странице Kafka UI на Docker Hub.
```
services:
kafka-ui:
container_name: kafka-ui
image: provectuslabs/kafka-ui:latest
ports:
- 8080:8080
environment:
DYNAMIC_CONFIG_ENABLED: true
volumes:
- ~/kui/config.yml:/etc/kafkaui/dynamic_config.yaml 
```
Run the compose via:

```docker-compose -f <your-file>.yml up -d```
