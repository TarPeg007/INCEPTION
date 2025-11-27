FROM alpine:3.17

RUN apk update && apk upgrade && \
    apk add --no-cache nginx openssl && \
    mkdir -p /var/run/nginx /etc/nginx/ssl

COPY conf/nginx.conf /etc/nginx/http.d/default.conf
COPY tools/ssl.sh /usr/local/bin/ssl.sh

RUN chmod +x /usr/local/bin/ssl.sh && \
    /usr/local/bin/ssl.sh


CMD ["nginx", "-g", "daemon off;"]