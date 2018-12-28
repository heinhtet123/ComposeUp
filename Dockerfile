FROM justckr/ubuntu-nginx:latest

# Xdebug Remote Host IP
ENV XDEBUG_REMOTE_HOST_IP 192.168.65.1

# Install packages
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y

RUN apt-get install -y software-properties-common \
python-software-properties \
language-pack-en-base

RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php

RUN apt-get update

RUN apt-get upgrade -y

RUN apt-get install -y php7.2-cli \
php7.2-fpm \
php7.2-curl \ 
php7.2-gd \ 
php7.2-mysql \
php7.2-mbstring \
php7.2-gd \
php7.2-dev \
php7.2-json \
zip \
build-essential \
libaio1 \
alien \
php-pear \
unzip 

RUN apt-get remove --purge -y software-properties-common \
python-software-properties

RUN apt-get autoremove -y
RUN apt-get clean
RUN apt-get autoclean

RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.2/fpm/php.ini
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php/7.2/fpm/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php/7.2/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.2/fpm/php-fpm.conf
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/7.2/fpm/pool.d/www.conf
RUN sed -i -e "s/pm.max_children = 5/pm.max_children = 9/g" /etc/php/7.2/fpm/pool.d/www.conf
RUN sed -i -e "s/pm.start_servers = 2/pm.start_servers = 3/g" /etc/php/7.2/fpm/pool.d/www.conf
RUN sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" /etc/php/7.2/fpm/pool.d/www.conf
RUN sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" /etc/php/7.2/fpm/pool.d/www.conf
RUN sed -i -e "s/pm.max_requests = 500/pm.max_requests = 200/g" /etc/php/7.2/fpm/pool.d/www.conf
RUN sed -i -e "/listen\s*=\s*\/run\/php\/php7.2-fpm.sock/c\listen = 127.0.0.1:9100" /etc/php/7.2/fpm/pool.d/www.conf
RUN sed -i -e "/pid\s*=\s*\/run/c\pid = /run/php7.2-fpm.pid" /etc/php/7.2/fpm/php-fpm.conf

#fix ownership of sock file
RUN sed -i -e "s/;listen.mode = 0660/listen.mode = 0750/g" /etc/php/7.2/fpm/pool.d/www.conf
RUN find /etc/php/7.2/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# # Supervisor Config
# ADD conf/supervisord.conf /supervisord.conf
# RUN cat /supervisord.conf >> /etc/supervisord.conf

# # Start Supervisord
# ADD scripts/start.sh /start.sh
# RUN chmod 755 /start.sh

# Setup Volume
VOLUME ["/app"]

# add test PHP file
RUN touch app/src/public/index.php
RUN echo "<?php phpinfo(); " > index.php
RUN chown -Rf www-data.www-data /app
RUN chown -Rf www-data.www-data /var/www/html

RUN service php7.2-fpm start
RUN apt-get install -y composer

RUN apt-get install -y git

RUN git clone https://github.com/heinhtet123/OHCL.git

EXPOSE 80

CMD ["/bin/bash", "/start.sh"]
