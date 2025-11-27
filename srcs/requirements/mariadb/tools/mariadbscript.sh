#!/bin/bash

# 1. Fix Permissions
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

# 2. Initialize Data (if missing)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db > /dev/null
fi

# 3. Start Temp Server
echo "Starting temporary server..."
mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking &
PID="$!"

until mysqladmin ping >/dev/null 2>&1; do
    sleep 1
done

# 4. Create Users
echo "Updating SQL users..."
mariadb <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF

# 5. Stop Temp Server & Start Real Server oep
mysqladmin -u root shutdown
wait "$PID"

echo "Starting MariaDB Server..."
exec mariadbd --user=mysql --bind-address=0.0.0.0 