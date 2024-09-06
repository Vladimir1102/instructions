  GNU nano 6.2                                                  /opt/docker/kafka/setup_certificates.sh
#!/bin/bash

# Проверяем, существуют ли уже сертификаты
if [ ! -d "./certs/live/kafka.devspace-eterinte.com" ]; then
  echo "Certificates not found, creating them..."

  # Запуск Certbot в неинтерактивном режиме
  docker-compose run --rm certbot certonly \
    --standalone \
    --non-interactive \
    --agree-tos \
    --email info@devspace-eterinte.com \
    -d kafka.devspace-eterinte.com \
    -d www.kafka.devspace-eterinte.com
else
  echo "Certificates already exist, skipping creation..."
fi

# Запуск Docker Compose
docker-compose up -d

