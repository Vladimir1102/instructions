#!/bin/bash
#
# DON'T FORGET to set:   chmod +x
#
SERVICE_NAME="kafka"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
WORKING_DIR="/home/volodymyr/docker_files/kafka"
DOCKER_COMPOSE_PATH="/usr/local/bin/docker-compose"


sudo bash -c "cat > ${SERVICE_FILE} <<EOF
[Unit]
Description=Docker Compose Application Service
Requires=docker.service
After=docker.service

[Service]
WorkingDirectory=${WORKING_DIR}
ExecStart=${DOCKER_COMPOSE_PATH} up -d
ExecStop=${DOCKER_COMPOSE_PATH} down
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF"

# Перезагрузите конфигурацию systemd и активируйте сервис
sudo systemctl daemon-reload
sudo systemctl enable ${SERVICE_NAME}
sudo systemctl start ${SERVICE_NAME}

echo "Service file created and service started: ${SERVICE_NAME}"

