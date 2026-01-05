#!/bin/sh

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
	
	chown -R mysql:mysql /var/lib/mysql

	mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm > /dev/null 2>&1

    echo "
    USE mysql;
    FLUSH PRIVILEGES;
    DELETE FROM mysql.user WHERE User='';
    DROP DATABASE test;
    DELETE FROM mysql.db WHERE Db='test';
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_PASS_ROOT';
    CREATE DATABASE \`$DB_NAME\` CHARACTER SET utf8 COLLATE utf8_general_ci;
    CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
    GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';
    FLUSH PRIVILEGES;
    " | mysqld --user=mysql --bootstrap 
fi

exec mysqld --user=mysql --console