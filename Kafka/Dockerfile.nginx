# Используем официальный образ Nginx
FROM nginx:stable

# Копируем конфигурационный файл Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Копируем файлы сайта
COPY html /usr/share/nginx/html

# Открываем порты 80 и 443
EXPOSE 80
EXPOSE 443
