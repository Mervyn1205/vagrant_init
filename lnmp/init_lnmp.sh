sudo cp /tmp/sources.list /etc/apt/sources.list

apt-get update

cd ~
wget http://nginx.org/download/nginx-1.14.0.tar.gz
wget http://cn2.php.net/distributions/php-7.2.7.tar.gz
wget http://pecl.php.net/get/redis-4.0.2.tgz

tar xzvf nginx-1.14.0.tar.gz
tar xzf php-7.2.7.tar.gz
tar zvxf redis-4.0.2.tgz


# 安装nginx
sudo apt-get install -y build-essential libpcre3 libpcre3-dev libssl-dev

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
sudo apt-get install -y libxml2 libxml2-dev libcurl3  libcurl3-dev libpng3  libpng3-dev  libfreetype6 libfreetype6-dev  libmcrypt-dev  libmcrypt4 autoconf
./configure --prefix=/usr/local/php7 --enable-fpm --enable-mbstring --with-curl=/usr/bin/curl --with-gd --with-pdo_mysql --with-freetype-dir --enable-opcache
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

# 启动服务
sudo /usr/local/nginx/sbin/nginx
sudo /usr/local/php7/sbin/php-fpm

 