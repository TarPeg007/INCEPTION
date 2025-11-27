#!/bin/sh

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=MA/ST=State/L=City/O=Organization/CN=sfellahi.42.fr"