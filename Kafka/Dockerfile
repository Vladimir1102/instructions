# Используем официальный образ Nginx
FROM nginx:stable

# Устанавливаем Certbot
RUN apt-get update && \
    apt-get install -y certbot python3-certbot-nginx

# Копируем конфигурационный файл Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Копируем файлы сайта
COPY html /usr/share/nginx/html

# Открываем порты 80 и 443
EXPOSE 80
EXPOSE 443

# Добавляем скрипт для обновления сертификатов
COPY renew-certificates.sh /usr/local/bin/renew-certificates.sh
RUN chmod +x /usr/local/bin/renew-certificates.sh

# Запускаем скрипт обновления сертификатов и Nginx
CMD ["/bin/sh", "-c", "trap : TERM INT; (while true; do /usr/local/bin/renew-certificates.sh; sleep 1200h & wait $${!}; done) & exec nginx -g 'daemon off;'"]
