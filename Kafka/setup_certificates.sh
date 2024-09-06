#!/bin/bash

# Проверяем, существуют ли уже сертификаты
if [ ! -d "./certs/live/yourdomain.com" ]; then
  echo "Certificates not found, creating them..."
  docker-compose run --rm certbot certonly --standalone -d kafka.devspace-eterinte.com -d www.kafka.devspace-eterinte.com
else
  echo "Certificates already exist, skipping creation..."
fi

# Запуск Docker Compose
docker-compose up -d
