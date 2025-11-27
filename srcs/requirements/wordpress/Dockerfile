FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-cli \
    php8.2-curl \
    php8.2-xml \
    php8.2-mbstring \
    php8.2-zip \
    wget \
    curl \
    unzip \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php

WORKDIR /var/www/html

RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz --strip-components=1 && \
    rm latest.tar.gz

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY install.sh /usr/local/bin/install.sh
RUN chmod +x /usr/local/bin/install.sh

EXPOSE 9000

CMD ["/usr/local/bin/install.sh"]