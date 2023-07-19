#! /usr/bin/bash

sudo apt update

# Firewall install & conf
sudod apt install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 3022
sudo ufw enable
sudo ufw allow http
sudo ufw allow https
## sudo ufw status verbose - see the rules

# Nginx install & conf
sudo apt install nginx
sudo ufw allow 'Nginx HTTP'
## sudo ufw status - verify the change

# MariaDB installation
sudo apt install mariadb-server
sudo mysql_secure_installation

sudo mariadb
CREATE DATABASE wp_database;
GRANT ALL ON *.* TO 'wp-user'@'localhost' IDENTIFIED BY 'root' WITH GRANT OPTION;
FLUSH PRIVILEGES;
exit
sudo systemctl start mariadb

# PHP install & conf
sudo apt install php-fpm php-mysql

sudo mkdir /var/www/wpsite.loc
sudo chown -R $USER:$USER /var/www/wpsite.loc
sudo echo 'server { listen 80; listen [::]:80; root /var/www/wpsite.loc; index index.php index.html index.htm; server_name wpsite.loc; location / {try_files $uri $uri/ =404;} location ~ \.php$ {include snippets/fastcgi-php.conf; fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;} }' >> /etc/nginx/sites-available/wpsite.loc
sudo ln -s /etc/nginx/sites-available/wpsite.loc /etc/nginx/sites-enabled
## sudo nginx -t - test configuration for syntax errors
sudo systemctl reload nginx

# Wordpress
cd /var/www/wpsite.loc
wget https://wordpress.org/latest.zip
unzip latest.zip
mv wordpress wpsite.loc
cd wpsite.loc
cp wp-config-sample.php wp-config.php
sed -i -e 's/DB_NAME/wp_database/g' /var/www/wpsite.loc
sed -i -e 's/DB_USER/wp-user/g' /var/www/wpsite.loc
sed -i -e 's/DB_PASSWORD/root/g' /var/www/wpsite.loc
chown -R www-data:www-data /var/www/wpsite.loc
