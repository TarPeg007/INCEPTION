#!/bin/bash

# 1. Fix Permissions (Always run this)
# Ensures that even if the volume mount messes up permissions, we fix them.
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

# 2. Initialize Data Directory (Only if missing)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db > /dev/null
fi

# 3. Start Temporary Server (Always)
# We start the server in the background so we can run SQL commands against it.
echo "Starting temporary MariaDB server..."
/usr/bin/mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
PID="$!"

# Wait for the server to be ready
until mysqladmin ping >/dev/null 2>&1; do
    sleep 1
done

# 4. Create User & Database (Always)
# We use 'IF NOT EXISTS' so this is safe to run on every restart.
# This fixes the "Host not allowed" error by ensuring the user always exists.
echo "Ensuring database user and permissions exist..."
mariadb <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF

# 5. Stop Temporary Server
mysqladmin -u root shutdown
wait "$PID"

# 6. Start Main Server
echo "Starting MariaDB Server..."
# bind-address=0.0.0.0 is crucial to allow connections from other containers
exec mysqld --user=mysql --bind-address=0.0.0.0