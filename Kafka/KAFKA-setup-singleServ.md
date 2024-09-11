https://hostman.com/tutorials/install-apache-kafka-on-ubuntu-22-04/




TUNUNG
### 51.195.102.141 

 SSL Key pass:

dev-orc777 

``
 scp -i /home/volodymyr-didukh/.ssh/kafka-serv -P 50105 /home/volodymyr-didukh/work/kafka/SSL-keys/Ca-devspace.crt kafka@51.195.102.141:/home/kafka/kafka/ssl/
``
*copy all certs


Хорошо, давайте продолжим с предоставленными вами данными и создадим необходимые хранилища.

### **1. Создание Keystore и Truststore для Kafka и Zookeeper**

#### **Для Kafka**


1. **Создание Truststore для Kafka:**

   Используем сертификат CA `Ca-devspace.pem`. *mv to PEM ! 

   ```
   # Введите пароль при запросе
   keytool -import -alias ca -file /home/kafka/kafka/ssl/CA-devspace.pem -keystore /home/kafka/kafka/ssl/kafka.truststore.jks -storepass dev-orc777
   ```

2. **Создание Keystore для Kafka:**

   Вы используете `kafka-server-0.pfx`, который преобразуем в формат JKS для Kafka.

   ```
   # Введите пароль при запросе
   keytool -importkeystore -deststorepass dev-orc777 -destkeypass dev-orc777 -destkeystore /home/kafka/kafka/ssl/kafka.keystore.jks -srckeystore /home/kafka/kafka/ssl/kafka-server-0.pfx -srcstoretype PKCS12 -srcstorepass dev-orc777 -alias kafka-server-0
   ```

#### **Для Zookeeper**



1. **Создание Truststore для Zookeeper:**

   Используем сертификат CA Ca-devspace.crt.


   ```
   # Введите пароль при запросе
   keytool -import -alias ca -file /home/kafka/kafka/ssl/CA-devspace.crt -keystore /home/kafka/kafka/ssl/zookeeper.truststore.jks -storepass dev-orc777
   ```

2. **Создание Keystore для Zookeeper:**

   Вы используете тот же файл `kafka-server-0.pfx`, который преобразуем в формат JKS для Zookeeper.

```
   # Введите пароль при запросе
   keytool -importkeystore -deststorepass dev-orc777 -destkeypass dev-orc777 -destkeystore /home/kafka/kafka/ssl/zookeeper.keystore.jks -srckeystore /home/kafka/kafka/ssl/kafka-zookeeper-0.pfx -srcstoretype PKCS12 -srcstorepass dev-orc777 -alias kafka-zookeeper-0
 ```

### **2. Настройка Конфигурации**

#### **Конфигурация Kafka (`server.properties`):**

[server.properties](server.properties)

#### **Конфигурация Zookeeper (`zookeeper.properties`):**

[zookeepre.properties](zookeepre.properties)

### **3. Проверка и Перезапуск**

Проверьте, что все файлы находятся в нужной директории:

```
ls -l /home/kafka/kafka/ssl/
```

kafka-run-class.sh найти и увеличить размер кучи (по умолчанию 256Мб):

```
# Memory options
if [ -z "$KAFKA_HEAP_OPTS" ]; then
KAFKA_HEAP_OPTS="-512M -512M"
fi
```


Перезапустите Kafka и Zookeeper, чтобы применить новые конфигурации:

```
# Перезапуск Kafka, Zookeeper: 

sudo systemctl stop zookeeper
sudo systemctl stop kafka
sudo systemctl start zookeeper
sudo systemctl start kafka
sudo systemctl status zookeeper
sudo systemctl status kafka
```


```cat /home/kafka/kafka/logs/server.log```

### EXAMPLE of new TOPIC:
```
# Создаем топик с параметрами:
# - retention.ms=300000 (5 минут)
# - max.message.bytes=104857600 (100 КБ)
# - max.topic.size=52428800 (50 МБ)
# Пример команды с описанием параметров
./kafka-topics.sh --bootstrap-server localhost:9093 --create \
--topic test-topic \
--partitions 2 \
--replication-factor 1 \
--config retention.ms=300000 \
--config max.message.bytes=104857600 \
--config segment.bytes=52428800
```



Если каждый микросервис должен иметь доступ только к своему собственному топику, использование SSL в сочетании с аутентификацией на основе логина и пароля (SASL/PLAIN или SASL/SCRAM) может быть достаточно для обеспечения безопасного доступа к Kafka. В этом случае вам не нужно управлять сложными ACL, если:

1. **Каждый микросервис имеет свои собственные учетные данные.**
2. **Каждый микросервис взаимодействует только с определенными топиками.**

### Как это настроить:

1. **Настройте SSL и SASL для Kafka:**

   Убедитесь, что Kafka настроен для использования как SSL (для шифрования), так и SASL (для аутентификации). В конфигурации Kafka это будет выглядеть примерно так:

   **Конфигурация Kafka брокера (`server.properties`):**

   ```properties
   listeners=SSL://localhost:9093
   advertised.listeners=SSL://localhost:9093
   security.protocol=SSL
   ssl.keystore.location=/path/to/broker-keystore.p12
   ssl.keystore.password=your_keystore_password
   ssl.key.password=your_key_password
   ssl.truststore.location=/path/to/broker-truststore.p12
   ssl.truststore.password=your_truststore_password

   # Для SASL
   sasl.enabled.mechanisms=PLAIN
   sasl.mechanism.inter.broker.protocol=PLAIN
   security.protocol=SASL_SSL
   ```

   **Конфигурация клиента (например, для микросервиса):**

   ```properties
   security.protocol=SASL_SSL
   sasl.mechanism=PLAIN
   sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="user" password="password";
   ssl.keystore.location=/path/to/client-keystore.p12
   ssl.keystore.password=your_keystore_password
   ssl.key.password=your_key_password
   ssl.truststore.location=/path/to/client-truststore.p12
   ssl.truststore.password=your_truststore_password
   ```

2. **Настройка пользователей и их прав:**

   Используйте `kafka-acls.sh` для создания ACL, которые будут обеспечивать доступ только к нужным топикам для каждого пользователя. Например:

   ```bash
   kafka-acls.sh --bootstrap-server localhost:9093 --add --allow-principal User:producer1 --operation Write --topic producer1-topic
   kafka-acls.sh --bootstrap-server localhost:9093 --add --allow-principal User:consumer1 --operation Read --topic consumer1-topic
   ```

3. **Проверка конфигураций и безопасности:**

   - Убедитесь, что конфигурации SSL и SASL правильно настроены и протестированы.
   - Проверьте, что каждый микросервис может подключаться к Kafka только с указанными учетными данными и доступен только к определенным топикам.

4. **Тестирование доступа:**

   Запустите тесты для проверки, что каждый микросервис может только выполнять разрешенные операции на назначенных топиках, и не имеет доступа к другим топикам.

### Заключение

Использование SSL и SASL для управления доступом и шифрованием является хорошей практикой и может значительно упростить управление безопасностью, особенно в небольших и средних развертываниях. Это уменьшает необходимость в сложной настройке ACL, если доступ к топикам строго контролируется через аутентификацию и конфигурацию клиентов.

Library for SSL clients: 

https://github.com/confluentinc/librdkafka

```sudo apt-get update
sudo apt-get install libssl-dev
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

```


Configure librdkafka client
For each client copy its key files (client_${CLIENT}_*) and the public CA-cert to the client node and configure your librdkafka application with the following properties:


```
metadata.broker.list=at_least_one_of_the_brokers
security.protocol=ssl

# CA certificate file for verifying the broker's certificate.
ssl.ca.location=ca-cert

# Client's certificate
ssl.certificate.location=client_?????_client.pem

# Client's key
ssl.key.location=client_?????_client.key

# Key password, if any.
ssl.key.password=abcdefgh
```


