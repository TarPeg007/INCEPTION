#!/bin/sh

# 1. Wait for MariaDB
echo "Waiting for MariaDB to be ready..."
while ! mariadb -h mariadb -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE --silent; do
    echo "MariaDB is not ready yet..."
    sleep 2
done
echo "MariaDB is ready!"

# 2. Configure PHP-FPM (Auto-generate config)
# This replaces the need for copying a local www.conf file
echo "Configuring PHP-FPM..."
mkdir -p /etc/php/8.2/fpm/pool.d
cat > /etc/php/8.2/fpm/pool.d/www.conf <<EOF
[www]
user = www-data
group = www-data
listen = 9000
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
EOF

# 3. Configure WordPress
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

# 4. Install WordPress
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

    if [ -n "$WP_USER" ] && [ -n "$WP_PASSWORD" ]; then
        echo "Creating additional user..."
        wp user create $WP_USER $WP_EMAIL --user_pass=$WP_PASSWORD --role=author --allow-root
    fi
    echo "WordPress installed successfully!"
fi

# 5. Start PHP-FPM
# Fix permissions so www-data can write
chown -R www-data:www-data /var/www/html
echo "Starting PHP-FPM 8.2..."
exec /usr/sbin/php-fpm8.2 -F