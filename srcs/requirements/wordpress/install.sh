#!/bin/bash

# 1. Wait for MariaDB
echo "Waiting for MariaDB..."
while ! mariadb -h mariadb -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE --silent; do
    echo "MariaDB not ready..."
    sleep 2
done
echo "MariaDB is ready!"

# 2. Configure WordPress (wp-config.php)
if [ ! -f wp-config.php ]; then
    echo "Generating wp-config.php..."
    wp config create \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$MYSQL_PASSWORD \
        --dbhost=mariadb \
        --dbprefix=wp_ \
        --skip-check \
        --allow-root

    wp config shuffle-salts --allow-root
    wp config set WP_DEBUG false --raw --allow-root
fi

# 3. Install WordPress
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

    # Create Second User (if variables exist)
    if [ -n "$WP_USER" ] && [ -n "$WP_PASSWORD" ]; then
        echo "Creating additional user: $WP_USER"
        wp user create $WP_USER $WP_EMAIL --user_pass=$WP_PASSWORD --role=author --allow-root
    fi
    echo "WordPress installed successfully!"
fi

# 4. Fix Permissions & Start PHP-FPM
chown -R www-data:www-data /var/www/html
echo "Starting PHP-FPM 8.2..."
exec /usr/sbin/php-fpm8.2 -F