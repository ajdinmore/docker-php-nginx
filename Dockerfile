FROM debian:buster-slim as base
ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /app

## Add PHP repo
RUN apt-get -qy update
RUN apt-get -qy install apt-transport-https lsb-release ca-certificates curl
RUN curl -sSLo /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

## Install Lighttpd
RUN apt-get -qy install lighttpd
RUN lighty-disable-mod unconfigured

## Copy Lighttpd config and fallback index file
COPY lighttpd.conf /etc/lighttpd/default.conf
COPY index.php /app/public/index.php

## Download Composer installer
RUN curl -sSLo /tmp/composer-setup.php https://getcomposer.org/installer
RUN curl -sSLo /tmp/composer-setup.sig https://composer.github.io/installer.sig

## Load PHP package lists
RUN apt-get -qy update

ARG PHP_VERSION
ENV PHP_VERSION=${PHP_VERSION}

## Install PHP
RUN apt-get -qy install \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-json \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-intl

## Update PHP config
RUN sed -ie "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/" /etc/php/${PHP_VERSION}/fpm/php.ini
RUN sed -ie "s/zlib.output_compression = Off/zlib.output_compression = On/" /etc/php/${PHP_VERSION}/fpm/php.ini
RUN sed -ie "s/;clear_env = no/clear_env = no/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
RUN sed -ie "s/listen = \/run\/php\/php${PHP_VERSION}-fpm.sock/listen = \/run\/php-fpm.sock/" /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
RUN sed -ie "s/pid = \/run\/php\/php${PHP_VERSION}-fpm.pid/pid = \/run\/php-fpm.pid/" /etc/php/${PHP_VERSION}/fpm/php-fpm.conf
# Why does this file exist?
RUN rm /etc/php/${PHP_VERSION}/fpm/pool.d/www.confe

## Install Composer
RUN php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"
RUN php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN composer config -g cache-dir /composer_cache
RUN rm /tmp/*

## On run, create file descriptors 3 & 4 as aliases for stdout and stderr, allow all to write to it,
## then launch the PHP process manager as a daemon and Lighttpd in the foreground
CMD exec 3>&1 4>&2 && chmod a+w /dev/fd/3 /dev/fd/4 \
 && /usr/sbin/php-fpm${PHP_VERSION} -D --fpm-config /etc/php/${PHP_VERSION}/fpm/php-fpm.conf \
 && lighttpd -D -f /etc/lighttpd/default.conf

###########
## DEBUG ##
###########
FROM base as debug
ARG PHP_VERSION

RUN apt-get -qy install php-pear php${PHP_VERSION}-dev
RUN pecl channel-update pecl.php.net && pecl install xdebug
RUN echo 'zend_extension=/usr/lib/php/20180731/xdebug.so' > /etc/php/${PHP_VERSION}/mods-available/xdebug.ini
RUN echo 'xdebug.remote_enable=1' >> /etc/php/${PHP_VERSION}/mods-available/xdebug.ini
RUN phpenmod xdebug