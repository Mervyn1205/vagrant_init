sudo cp /tmp/sources.list /etc/apt/sources.list

sudo apt-get update

cd ~
wget http://nginx.org/download/nginx-1.14.0.tar.gz
wget http://cn2.php.net/distributions/php-7.2.7.tar.gz
wget http://cn2.php.net/distributions/php-5.6.36.tar.gz
wget http://pecl.php.net/get/redis-4.0.2.tgz
wget http://pecl.php.net/get/redis-3.1.6.tgz
wget https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.23.tar.gz --no-check-certificate
wget http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.gz
wget https://cmake.org/files/v3.12/cmake-3.12.2.tar.gz


tar xzvf nginx-1.14.0.tar.gz
tar xvzf php-7.2.7.tar.gz
tar xvzf php-5.6.36.tar.gz
tar zvxf redis-4.0.2.tgz
tar zvxf redis-3.1.6.tgz
tar xzvf mysql-5.7.23.tar.gz
tar xzvf boost_1_59_0.tar.gz
tar xzvf cmake-3.12.2.tar.gz


apt-get install build-essential libexpat1-dev libgeoip-dev libpng-dev libpcre3-dev libssl-dev libxml2-dev rcs zlib1g-dev libmcrypt-dev libcurl4-openssl-dev libjpeg-dev libpng-dev libwebp-dev pkg-config
sudo apt install libncurses5-dev


sudo ln -s /lib/x86_64-linux-gnu/libssl.so /usr/lib

cd ~/cmake-3.12.2
./bootstrap
sudo make
sudo make install

cd ~
sudo mv boost_1_59_0 /usr/local/

# ==============================
# start install nginx
# ==============================

sudo groupadd www
sudo useradd www -g www -s /sbin/nologin -M

cd ~/nginx-1.14.0
./configure  --user=www --group=www --with-pcre --with-mail --with-mail_ssl_module --with-http_ssl_module --with-http_realip_module --with-http_stub_status_module
sudo make
sudo make install

sudo mkdir /usr/local/nginx/conf/vhost
sudo mkdir /var/log/nginx

sudo cp /tmp/nginx.conf /usr/local/nginx/conf/nginx.conf
sudo cp /tmp/localhost.conf /usr/local/nginx/conf/vhost/localhost.conf


# ==============================
# start install php
# ==============================

cd ~/php-7.2.7


./configure --prefix=/usr/local/php7 --enable-fpm --enable-mbstring --with-curl=/usr/bin/curl --with-gd --with-pdo_mysql --with-freetype-dir --enable-opcache  --enable-bcmath --with-openssl=shared
sudo make
sudo make install


sudo cp php.ini-development /usr/local/php7/lib/php.ini
sudo cp /usr/local/php7/etc/php-fpm.conf.default /usr/local/php7/etc/php-fpm.conf
sudo cp /tmp/php-fpm.conf /usr/local/php7/etc/php-fpm.d/www.conf

# 安装php redis扩展
cd ~/redis-4.0.2/
/usr/local/php7/bin/phpize
./configure --with-php-config=/usr/local/php7/bin/php-config
sudo make
sudo make install
echo 'extension="redis.so"' | sudo tee -a /usr/local/php7/lib/php.ini


cd ~/php-5.6.36/
./configure --prefix=/usr/local/php56 --enable-fpm --enable-mbstring --with-curl=/usr/bin/curl --with-gd --with-pdo_mysql --with-freetype-dir --enable-opcache  --enable-bcmath --with-openssl=shared --with-zlib
sudo make
sudo make install

sudo cp php.ini-development /usr/local/php56/lib/php.ini
sudo cp /usr/local/php56/etc/php-fpm.conf.default /usr/local/php56/etc/php-fpm.conf
sudo cp /tmp/php-fpm.conf /usr/local/php56/etc/php-fpm.d/www.conf

# 安装php redis扩展
cd ~/redis-3.1.6/
/usr/local/php56/bin/phpize
./configure --with-php-config=/usr/local/php56/bin/php-config
sudo make
sudo make install
echo 'extension="redis.so"' | sudo tee -a /usr/local/php56/lib/php.ini

# 安装 mysql

cd ~/mysql-5.7.23/

sudo mkdir -p /data/mysql_data

cmake \
    -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
    -DMYSQL_DATADIR=/data/mysql_data \
    -DSYSCONFDIR=/etc \
    -DWITH_MYISAM_STORAGE_ENGINE=1 \
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_MEMORY_STORAGE_ENGINE=1 \
    -DWITH_READLINE=1 \
    -DMYSQL_UNIX_ADDR=/usr/local/mysql/run/mysql.sock \
    -DMYSQL_TCP_PORT=3306 \
    -DDOWNLOAD_BOOST=1 \
    -DWITH_BOOST=/usr/local/boost_1_59_0/ \
    -DENABLED_LOCAL_INFILE=1 \
    -DEXTRA_CHARSETS=all \
    -DDEFAULT_CHARSET=utf8mb4 \
    -DDEFAULT_COLLATION=utf8mb4_general_ci \
    -DCURSES_LIBRARY=/usr/lib/x86_64-linux-gnu/libncurses.so -DCURSES_INCLUDE_PATH=/usr/include

sudo make && make install

sudo groupadd mysql
sudo useradd -g mysql mysql
sudo chown -R mysql:mysql /usr/local/mysql
sudo chown -R mysql:mysql /data/mysql_data

sudo mkdir /usr/local/mysql/run/
sudo chown -R mysql:mysql /usr/local/mysql/run/


sudo ln -s /usr/local/mysql/bin/mysql /usr/local/bin/mysql
sudo ln -s /usr/local/nginx/sbin/nginx /usr/local/bin/nginx
sudo ln -s /usr/local/php7/sbin/php-fpm /usr/local/bin/php-fpm
sudo ln -s /usr/local/php7/bin/php /usr/local/bin/php


# 启动服务
sudo /usr/local/nginx/sbin/nginx -s stop
ps aux|grep php-fpm | grep -v grep  |awk '{print $2}'|xargs sudo kill -9

sudo /usr/local/nginx/sbin/nginx
sudo /usr/local/php7/sbin/php-fpm
sudo /usr/local/php56/sbin/php-fpm


