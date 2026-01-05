#!/bin/bash
set -eu

if [ -f /run/secrets/db_password ]; then
  MYSQL_PASSWORD=$(cat /run/secrets/db_password)
else
  echo "db_password secret file not found!"
  exit 1
fi

if [ -f /run/secrets/wp_admin_password ]; then
  WP_ADMIN_PWD=$(cat /run/secrets/wp_admin_password)
else
  echo "WP_ADMIN_PASSWORD secret file not found!"
  exit 1
fi


if [ -f /run/secrets/wp_user_password ]; then
  WP_USER_PWD=$(cat /run/secrets/wp_user_password)
else
  echo "WP_USER_PASSWORD secret file not found!"
  exit 1
fi


chown -R www-data:www-data /var/www/html/



echo "Starting WordPress setup..."
if [ ! -f wp-config.php ]; then
  echo "Downloading WordPress..."
  wget https://wordpress.org/latest.tar.gz && \
  tar -xzvf latest.tar.gz --strip-components=1 && \
  rm latest.tar.gz

  echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>downloading wp cli... <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
chmod +x wp-cli.phar && \
mv wp-cli.phar /usr/local/bin/wp
  echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Creating wp-config.php..."
  wp config create --dbhost="${MARIADB_HOST}" --dbname="${DB_NAME}" --dbuser="${DB_USER}" --dbpass="${MYSQL_PASSWORD}" --allow-root --extra-php <<EOF

EOF

  echo "Installing WordPress..."
  wp core install \
    --url="${WP_URL}" \
    --title="${WP_TITLE}" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PWD}" \
    --admin_email="${WP_ADMIN_EMAIL}" \
    --skip-email \
    --allow-root

  echo "Creating additional WordPress user..."
  wp user create "${WP_USER}" "${WP_USER_EMAIL}" --role=author --user_pass="${WP_USER_PWD}" --allow-root
fi



exec php-fpm8.2 -F
