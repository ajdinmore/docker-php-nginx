ARG BASE

FROM debian:buster-slim as base
ARG TINI_VERSION=v0.19.0
ARG PHP_VERSION

## Set working directory & startup command
WORKDIR /app
CMD [ "/start.sh" ]

## Install Tini
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
ENTRYPOINT ["/tini", "--"]
RUN chmod +x /tini \

## Install things that'll be the same for all builds
 && apt-get -qy update && apt-get -qy install \
    apt-transport-https \
    lsb-release \
    ca-certificates \
    curl \
    unzip \
    nano \
    less \
    && rm -rf /var/lib/apt/lists/* \

## Add PHP repo
 && curl -sSLo /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
 && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

## Introduce PHP version as late as possible
ENV PHP_VERSION=${PHP_VERSION} \
    COMPOSER_ALLOW_SUPERUSER=1

## Install PHP
RUN apt-get -qy update && apt-get -qy install \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-json \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-intl \
    && rm -rf /var/lib/apt/lists/* \

## Update PHP config
 && sed -ie "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/" /etc/php/${PHP_VERSION}/fpm/php.ini \
 && sed -ie "s/zlib.output_compression = Off/zlib.output_compression = On/" /etc/php/${PHP_VERSION}/fpm/php.ini \
 && sed -ie "s/;clear_env = no/clear_env = no/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf \
 && sed -ie "s/listen = \/run\/php\/php${PHP_VERSION}-fpm.sock/listen = \/run\/php-fpm.sock/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf \
 && sed -ie "s/pid = \/run\/php\/php${PHP_VERSION}-fpm.pid/pid = \/run\/php-fpm.pid/" /etc/php/${PHP_VERSION}/fpm/php-fpm.conf \
# Why does this file exist?
#RUN rm /etc/php/${PHP_VERSION}/fpm/pool.d/www.confe

## Install Composer
 && curl -sSLo /tmp/composer-setup.php https://getcomposer.org/installer \
 && curl -sSLo /tmp/composer-setup.sig https://composer.github.io/installer.sig \
 && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
 && php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer \
 && composer config -g cache-dir /composer_cache \
 && rm /tmp/*

## Fallback index file
COPY index.php /app/public/index.php


############
## XDEBUG ##
############
FROM base as debug
ARG PHP_VERSION

RUN apt-get -qy update && apt-get -qy install \
    php-pear \
    php${PHP_VERSION}-dev \
    && rm -rf /var/lib/apt/lists/* \
 && pecl channel-update pecl.php.net && pecl install xdebug \
 && echo 'zend_extension=/usr/lib/php/20180731/xdebug.so' > /etc/php/${PHP_VERSION}/mods-available/xdebug.ini \
 && echo 'xdebug.remote_enable=1' >> /etc/php/${PHP_VERSION}/mods-available/xdebug.ini \
 && phpenmod xdebug


##############
## LIGHTTPD ##
##############
FROM $BASE as lighttpd

## Copy Lighttpd config & start script
COPY lighttpd.conf /etc/lighttpd/default.conf
COPY start-lighttpd.sh /start.sh

## Install server
RUN apt-get -qy update && apt-get -qy install \
    lighttpd \
    && rm -rf /var/lib/apt/lists/* \

## Disable Lighttpd unconfigured mod
 && lighty-disable-mod unconfigured \

## Set execution flag
 && chmod +x /start.sh


###########
## NGINX ##
###########
FROM $BASE as nginx

COPY start-nginx.sh /start.sh

RUN apt-get -qy update && apt-get -qy install \
    nginx \
    && rm -rf /var/lib/apt/lists/* \

 && chmod +x /start.sh

COPY nginx.conf /etc/nginx/sites-available/default
