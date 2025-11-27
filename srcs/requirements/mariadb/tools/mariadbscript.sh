#!/bin/bash

# 1. Permissions Check
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

# 2. Initialize Database (Run only if data is missing)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db > /dev/null
fi

# 3. Start temp server to configure users (ALWAYS run this part)
# We move this outside the 'if' block so we can fix permissions on every restart
echo "Starting temporary MariaDB server..."
/usr/bin/mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
PID="$!"

# Wait for startup
until mysqladmin ping >/dev/null 2>&1; do
    sleep 1
done

# 4. Create Users & Database (ALWAYS run this)
echo "Running SQL setup..."
mariadb <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF

# Shutdown temp server
mysqladmin -u root shutdown
wait "$PID"

# 5. Start Server
echo "Starting MariaDB..."
exec mysqld --user=mysql --bind-address=0.0.0.0