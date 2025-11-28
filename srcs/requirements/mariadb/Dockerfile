FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server 

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

COPY tools/mariadbscript.sh /mariadbscript.sh
RUN chmod +x /mariadbscript.sh

ENTRYPOINT ["/mariadbscript.sh"]