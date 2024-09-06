#!/bin/sh

# Обновление сертификатов
certbot renew

# Перезагрузка Nginx, если сертификаты обновились
if [ $? -eq 0 ]; then
    nginx -s reload
fi
