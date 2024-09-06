#!/bin/sh

while true; do
    echo "Attempting to renew certificates..."
    certbot renew
    echo "Certificates renewed. Reloading Nginx..."
    nginx -s reload
    sleep 1200h
done
