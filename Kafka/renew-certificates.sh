#!/bin/sh

# Начальное создание сертификатов
certbot --nginx -d kafka.devspace-eterintekafka.com -d www.kafka.devspace-eterinte.com --non-interactive --agree-tos --email info@devspace-eterinte.com

# Обновление сертификатов
certbot renew --quiet

# Перезагрузка Nginx
nginx -s reload
