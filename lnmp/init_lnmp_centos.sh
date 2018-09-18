yum update -y

cd ~/software
wget http://nginx.org/download/nginx-1.14.0.tar.gz
wget http://cn2.php.net/distributions/php-7.2.7.tar.gz
wget http://pecl.php.net/get/redis-4.0.2.tgz
wget https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.23.tar.gz --no-check-certificate

# 安装依赖包
yum -y install pcre-devel openssl openssl-devel \
    libxml2-devel curl-devel libpng-devel  freetype-devel \
    autoconf ncurses ncurses-devel

wget https://cmake.org/files/v3.12/cmake-3.12.2.tar.gz
tar xzvf cmake-3.12.2.tar.gz
cd cmake-3.12.2

# ==============================
# start install nginx
# ==============================
tar xzvf nginx-1.14.0.tar.gz

groupadd www
useradd www -g www -s /sbin/nologin -M

cd ~/software/nginx-1.14.0
./configure  --user=www --group=www --with-pcre --with-mail --with-mail_ssl_module --with-http_ssl_module --with-http_realip_module --with-http_stub_status_module
make
make install

mkdir /usr/local/nginx/conf/vhost
mkdir /var/log/nginx

cp /tmp/nginx.conf /usr/local/nginx/conf/nginx.conf
cp /tmp/localhost.conf /usr/local/nginx/conf/vhost/localhost.conf

# ==============================
# start install php
# ==============================

cd ~/software
tar xvzf php-7.2.7.tar.gz
cd ~/software/php-7.2.7

./configure --prefix=/usr/local/php7 --enable-fpm --enable-mbstring --with-curl=/usr/bin/curl --with-gd --with-pdo_mysql --with-freetype-dir --enable-opcache  --enable-bcmath --with-openssl=shared
make
make install

cp php.ini-development /usr/local/php7/lib/php.ini
cp /usr/local/php7/etc/php-fpm.conf.default /usr/local/php7/etc/php-fpm.conf
cp /tmp/php-fpm.conf /usr/local/php7/etc/php-fpm.d/www.conf


# ==============================
# start install php extensions
# ==============================

cd ~/software
tar zvxf redis-4.0.2.tgz
cd ~/software/redis-4.0.2/
/usr/local/php7/bin/phpize
./configure --with-php-config=/usr/local/php7/bin/php-config
make
make install
echo 'extension="redis.so"' | tee -a /usr/local/php7/lib/php.ini


# ==============================
# start install mysql
# ==============================
cd ~/software
tar -zxvf mysql-5.7.23.tar.gz
cd mysql-5.7.23

#编译安装MySQL
#DCMAKE_INSTALL_PREFIX：安装路径
#DMYSQL_DATADIR：数据存放目录
#DWITH_BOOST：boost源码路径
#DSYSCONFDIR：my.cnf配置文件目录
#DEFAULT_CHARSET：数据库默认字符编码
#DDEFAULT_COLLATION：默认排序规则
#DENABLED_LOCAL_INFILE：允许从本文件导入数据
#DEXTRA_CHARSETS：安装所有字符集
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
    -DWITH_BOOST=boost/boost_1_59_0/ \
    -DENABLED_LOCAL_INFILE=1 \
    -DEXTRA_CHARSETS=all \
    -DDEFAULT_CHARSET=utf8mb4 \
    -DDEFAULT_COLLATION=utf8mb4_general_ci \
    -DCURSES_LIBRARY=/usr/lib/libncurses.so -DCURSES_INCLUDE_PATH=/usr/include


#配置
groupadd mysql
useradd -g mysql mysql
chown -R mysql:mysql /usr/local/mysql
chown -R mysql:mysql /data/mysql_data
##添加软链接将mysql加入系统环境变量



# 启动服务
ln -s /usr/local/mysql/bin/mysql /usr/local/bin/mysql
ln -s /usr/local/nginx/sbin/nginx /usr/local/bin/nginx
ln -s /usr/local/php7/sbin/php-fpm /usr/local/bin/php-fpm
ln -s /usr/local/php7/bin/php /usr/local/bin/php



