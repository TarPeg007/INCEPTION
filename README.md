# Inception

This is the 42 Inception project.

## Setup

1. Create the data directories:
   ```bash
   mkdir -p /workspaces/incep/data/wordpress /workspaces/incep/data/mariadb
   ```

2. Build and run the containers:
   ```bash
   make
   ```

3. Access the website at https://sfellahi.42.fr (add to /etc/hosts: 127.0.0.1 sfellahi.42.fr)

## Services

- NGINX: Reverse proxy with SSL on port 443
- WordPress: CMS with PHP-FPM
- MariaDB: Database

## Environment Variables

See `.env` file for configuration.