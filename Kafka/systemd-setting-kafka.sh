#!/bin/bash
#
# DON'T FORGET to set:   chmod +x system-setting-kafka.sh
#
SERVICE_NAME="kafka"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
WORKING_DIR="/opt/docker/kafka"
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
Restart=on-failure
RestartSec=5s


[Install]
WantedBy=multi-user.target
EOF"
sudo mkdir -p /opt/docker/${SERVICE_NAME}
sudo chown -R root:root /opt/docker/${SERVICE_NAME}
sudo chmod -R 700 /srv/docker/${SERVICE_NAME}

# Перезагрузите конфигурацию systemd и активируйте сервис
sudo systemctl daemon-reload
sudo systemctl enable ${SERVICE_NAME}
sudo systemctl start ${SERVICE_NAME}

echo "Service file created and service started: ${SERVICE_NAME}"


#CERT-BOT file
chmod +x /opt/docker/kafka/renew-certificates.sh
chmod +x /opt/docker/kafka/setup-certificates.sh