sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup

echo "deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list


apt-get update

wget http://nginx.org/download/nginx-1.14.0.tar.gz
tar xzvf nginx-1.14.0.tar.gz
sudo apt-get install -y build-essential
sudo apt-get install -y libpcre3 libpcre3-dev
sudo apt-get install  -y libssl-dev

cd nginx-1.14.0
./configure  --user=www --group=www --with-pcre --with-mail --with-mail_ssl_module --with-http_ssl_module --with-http_realip_module --with-http_stub_status_module
sudo make
sudo make install

sudo groupadd www
sudo useradd www -g www -s /sbin/nologin -M

sudo mkdir /var/log/nginx

cd /usr/local/nginx/conf

cat > nginx.conf <<EOF
user  www www;
worker_processes  2;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    include vhost/*.conf;
}

EOF

sudo mkdir vhost

cd vhost

cat > localhost.conf <<EOF
server {
    listen 80;
    server_name localhost;
    root /workspace/www/localhost;

    access_log      /var/log/nginx/localhost_access.log main ;
    error_log       /var/log/nginx/localhost_error.log ;

    # add_header X-Frame-Options "SAMEORIGIN";
    # add_header X-XSS-Protection "1; mode=block";
    # add_header X-Content-Type-Options "nosniff";

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    error_page   500 502 503 504  /50x.html;

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass  127.0.0.1:9000;
        fastcgi_index index.php;
    }
}
EOF

# ==============================
# start install php
# ==============================
cd ~
wget http://cn2.php.net/distributions/php-7.2.7.tar.gz

tar xzf php-7.2.7.tar.gz

cd php-7.2.7
sudo apt-get install -y libxml2 libxml2-dev
sudo apt-get install -y libcurl3  libcurl3-dev
sudo apt-get install -y libpng3  libpng3-dev  libfreetype6 libfreetype6-dev  libmcrypt-dev  libmcrypt4 
./configure --prefix=/usr/local/php7 --enable-fpm --enable-mbstring --with-curl=/usr/bin/curl --with-gd --with-pdo_mysql --with-freetype-dir --enable-opcache
sudo make
sudo make install
sudo cp php.ini-development /usr/local/php7/php.ini
sudo cp /usr/local/php7/etc/php-fpm.conf.default /usr/local/php7/etc/php-fpm.conf
sudo cp /usr/local/php7/etc/php-fpm.d/www.conf.default /usr/local/php7/etc/php-fpm.d/www.conf

cd ~

sudo cat > www.conf <<EOF
[www]
user = www
group = www
listen = 127.0.0.1:9000
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
EOF

sudo mv www.conf /usr/local/php7/etc/php-fpm.d/www.conf
sudo /usr/local/php7/sbin/php-fpm

cd ~

wget http://pecl.php.net/get/redis-4.0.2.tgz

tar zvxf redis-4.0.2.tgz
cd redis-4.0.2/
sudo apt-get install -y autoconf
/usr/local/php7/bin/phpize

./configure --with-php-config=/usr/local/php7/bin/php-config
sudo make
sudo make install
echo 'extension="redis.so"' | sudo tee -a /usr/local/php7/php.ini



sudo /usr/local/nginx/sbin/nginx
ps -ef |grep php | awk '{print $2}' | xargs sudo kill -9
sudo /usr/local/php7/sbin/php-fpm -c /usr/local/php7/php.ini

 