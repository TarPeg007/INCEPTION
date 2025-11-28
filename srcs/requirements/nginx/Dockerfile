FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx openssl 

RUN mkdir -p /etc/nginx/ssl

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf
COPY tools/ssl.sh /usr/local/bin/ssl.sh

RUN chmod +x /usr/local/bin/ssl.sh && \
    /usr/local/bin/ssl.sh

CMD ["nginx", "-g", "daemon off;"]