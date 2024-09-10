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
KAFKA_HEAP_OPTS="-Xmx512M -Xms1G"
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



Если у вас возникнут вопросы или проблемы, дайте знать!


