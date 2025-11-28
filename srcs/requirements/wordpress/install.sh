#!/bin/bash


if [ ! -f wp-config.php ]; then
    echo "Generating wp-config.php..."
    wp config create \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$MYSQL_PASSWORD \
        --dbhost=mariadb \
        --skip-check \
        --allow-root

fi

echo "Waiting for MariaDB..."
sleep 10

if ! wp core is-installed --allow-root; then
    echo "Installing WordPress Core..."
    wp core install \
        --url=$DOMAIN_NAME \
        --title="$WP_TITLE" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --skip-email \
        --allow-root

    echo "Creating additional user: $WP_USER"

    wp user create $WP_USER $WP_USER_EMAIL --user_pass=$WP_USER_PASSWORD --allow-root

    echo "WordPress installed successfully!"
fi


echo "Starting PHP-FPM 8.2..."
exec /usr/sbin/php-fpm8.2 -F