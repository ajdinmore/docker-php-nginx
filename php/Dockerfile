ARG PHP_VERSION=8.1
ARG DEBIAN_RELEASE=bullseye

FROM debian:${DEBIAN_RELEASE}-slim as fpm

ARG WWW_USER_ID=1000
ARG WWW_GROUP_ID=1000

ARG PHP_VERSION
ARG PHP_EXTENSIONS='\
    php-curl \
    php-zip \
    php-xml \
    php-mbstring \
    php-intl \
    php-mysql \
    php-pgsql \
    php-redis \
    php-imagick \
    php-gd \
'
ARG DEV_TOOLS='\
    postgresql-client \
    default-mysql-client \
    iputils-ping \
    dnsutils \
    unzip \
    nano \
    less \
    git \
    man \
'

ENV PHP_VERSION=${PHP_VERSION} \
    COMPOSER_HOME=/composer

## Container config
ENTRYPOINT ["docker-entry"]
CMD php-fpm${PHP_VERSION} --fpm-config /etc/php/${PHP_VERSION}/fpm/php-fpm.conf
WORKDIR /app
EXPOSE 9000
STOPSIGNAL SIGQUIT

## Update default user/group IDs to match Ubuntu defaults
RUN usermod -u ${WWW_USER_ID} www-data && groupmod -g ${WWW_GROUP_ID} www-data

## Install build dependencies
RUN apt-get -qy update && apt-get -qy install \
    apt-transport-https \
    lsb-release \
    ca-certificates \
    curl \
\
## Add PHP repo
 && curl -sSLo /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
 && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
\
## Install PHP
 && apt-get -qy update && apt-get -qy install php${PHP_VERSION}-fpm ${PHP_EXTENSIONS} \
\
## Remove default config
 && rm -r /etc/php/${PHP_VERSION}/fpm/pool.d/ \
\
## Clean up
 && apt-get -qy autoremove \
 && apt-get -qy clean all \
 && rm -rf /var/lib/apt/lists/*

## Add entryopoint & config
COPY entrypoint.sh /usr/local/bin/docker-entry
COPY php-fpm.conf /etc/php/${PHP_VERSION}/fpm/
COPY cli.ini /etc/php/${PHP_VERSION}/cli/conf.d/
COPY fpm.ini /etc/php/${PHP_VERSION}/fpm/conf.d/

# Create directory for COMPOSER_HOME (full access so works with any user)
RUN mkdir -m 777 $COMPOSER_HOME \
\
## Install Composer
 && curl -sSLo /tmp/composer-setup.php https://getcomposer.org/installer \
 && curl -sSLo /tmp/composer-setup.sig https://composer.github.io/installer.sig \
 && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
 && php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer \
 && rm /tmp/*

## Set default user
USER www-data

#########
## DEV ##
#########
FROM fpm as dev

ARG SHELL_EDITOR=nano
ARG SHELL_PAGER='less -R'

ENV EDITOR=${SHELL_EDITOR} \
    PAGER=${SHELL_PAGER}

USER root

RUN apt-get update -qy && apt-get install -qy ${DEV_TOOLS} \
 && apt-get -qy autoremove \
 && apt-get -qy clean all \
 && rm -rf /var/lib/apt/lists/*

RUN cp /usr/lib/php/${PHP_VERSION}/php.ini-development /etc/php/${PHP_VERSION}/fpm/php.ini \
 && cp /usr/lib/php/${PHP_VERSION}/php.ini-development /etc/php/${PHP_VERSION}/cli/php.ini \
 && echo "alias ll='ls -lAhF --color=auto'" >> /etc/bash.bashrc

USER www-data

###########
## DEBUG ##
###########
FROM dev as debug

ARG PHP_VERSION

USER root

RUN apt-get -qy update && apt-get -qy install php-pear php${PHP_VERSION}-dev \
 && pecl channel-update pecl.php.net && pecl install xdebug \
 && echo "zend_extension=$(find /usr/lib/php/ -name xdebug.so)" > /etc/php/${PHP_VERSION}/mods-available/xdebug.ini \
 && echo 'xdebug.mode=debug' >> /etc/php/${PHP_VERSION}/mods-available/xdebug.ini \
 && phpenmod xdebug \
\
 && apt-get -qy autoremove \
 && apt-get -qy clean all \
 && rm -rf /var/lib/apt/lists/* \

USER www-data
