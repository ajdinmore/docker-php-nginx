ARG SERVER=nginx
ARG PHP_VERSION=8.0

## some bullseye repos not ready yet - 2021-08-18
FROM debian:buster-slim as system

#ARG TINI_VERSION=v0.19.0

## Set working directory & startup command
WORKDIR /app
CMD [ "/start.sh" ]

## Install Tini
#ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
#ENTRYPOINT ["/tini", "--"]
#RUN chmod +x /tini \

## Install things that'll be the same for all builds
RUN apt-get -qy update && apt-get -qy install \
    apt-transport-https \
    lsb-release \
    ca-certificates \
    postgresql-client \
    default-mysql-client \
    iputils-ping \
    dnsutils \
    curl \
    unzip \
    nano \
    less \
    git \
    man \
    && rm -rf /var/lib/apt/lists/* \

## ll shortcut
 && echo "alias ll='ls -lAhF --color=auto'" >> /etc/bash.bashrc \

## Add PHP repo
 && curl -sSLo /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
 && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

## Fallback index file
COPY index.php /app/public/index.php


###########
## NGINX ##
###########
FROM system as nginx

## Install server
RUN apt-get -qy update && apt-get -qy install \
    nginx \
    && rm -rf /var/lib/apt/lists/* \

## Set server user & group to 1000 to match Ubuntu-based workstations so we save messing with permissions so much
 && usermod -u 1000 www-data && groupmod -g 1000 www-data



## Copy NGINX site config & start script
COPY start-nginx.sh /start.sh
COPY nginx.conf /etc/nginx/sites-available/default


##############
## LIGHTTPD ##
##############
FROM system as lighttpd

## Copy Lighttpd config & start script
COPY lighttpd.conf /etc/lighttpd/default.conf
COPY start-lighttpd.sh /start.sh

## Install server
RUN apt-get -qy update && apt-get -qy install \
    lighttpd \
    && rm -rf /var/lib/apt/lists/* \

## Disable Lighttpd unconfigured mod
 && lighty-disable-mod unconfigured


#########
## PHP ##
#########
FROM $SERVER as php

ARG PHP_VERSION
ENV PHP_VERSION=${PHP_VERSION} \
    COMPOSER_HOME=/composer \
    EDITOR=nano \
    PAGER='less -R'

## Install PHP
RUN apt-get -qy update && apt-get -qy install \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-pgsql \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-imagick \
    php${PHP_VERSION}-gd \
    && rm -rf /var/lib/apt/lists/* \

## Update PHP config
 && sed -ie "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/" /etc/php/${PHP_VERSION}/fpm/php.ini \
 && sed -ie "s/zlib.output_compression = Off/zlib.output_compression = On/" /etc/php/${PHP_VERSION}/fpm/php.ini \
 && sed -ie "s/;clear_env = no/clear_env = no/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf \
 && sed -ie "s/listen = \/run\/php\/php${PHP_VERSION}-fpm.sock/listen = \/run\/php-fpm.sock/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf \
 && sed -ie "s/pid = \/run\/php\/php${PHP_VERSION}-fpm.pid/pid = \/run\/php-fpm.pid/" /etc/php/${PHP_VERSION}/fpm/php-fpm.conf \
 && sed -ie "s/;date.timezone =/date.timezone = UTC/" /etc/php/${PHP_VERSION}/fpm/php.ini \
 && sed -ie "s/;date.timezone =/date.timezone = UTC/" /etc/php/${PHP_VERSION}/cli/php.ini \

# Why does this file exist?
# && rm /etc/php/${PHP_VERSION}/fpm/pool.d/www.confe \

# Create directory for COMPOSER_HOME (full access so works with any user)
 && mkdir -m 777 $COMPOSER_HOME \

## Install Composer
 && curl -sSLo /tmp/composer-setup.php https://getcomposer.org/installer \
 && curl -sSLo /tmp/composer-setup.sig https://composer.github.io/installer.sig \
 && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
 && php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer \
 && rm /tmp/*


############
## XDEBUG ##
############
FROM php as debug

ARG PHP_VERSION

RUN apt-get -qy update && apt-get -qy install \
    php-pear \
    php${PHP_VERSION}-dev \
    && rm -rf /var/lib/apt/lists/* \
 && pecl channel-update pecl.php.net && pecl install xdebug \
 && echo "zend_extension=$(find /usr/lib/php/ -name xdebug.so)" > /etc/php/${PHP_VERSION}/mods-available/xdebug.ini \
 && echo 'xdebug.remote_enable=1' >> /etc/php/${PHP_VERSION}/mods-available/xdebug.ini \
 && phpenmod xdebug
