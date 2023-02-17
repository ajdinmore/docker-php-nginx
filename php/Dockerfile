ARG PHP_VERSION
#=8.2
ARG DEBIAN_RELEASE
#=bullseye

FROM debian:${DEBIAN_RELEASE}-slim as base

ARG WWW_USER_ID=1000
ARG WWW_GROUP_ID=1000
ARG WWW_HOME_DIR=/home/www-data
ARG COMPOSER_HOME=/composer

ARG PHP_VERSION

ARG PHP_EXTENSIONS="\
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
"
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
    COMPOSER_HOME=${COMPOSER_HOME}

## Container config
ENTRYPOINT ["docker-entry"]
CMD php-fpm${PHP_VERSION} --fpm-config /etc/php/${PHP_VERSION}/fpm/php-fpm.conf
WORKDIR /app
EXPOSE 9000
STOPSIGNAL SIGQUIT

## Update default user/group IDs to match Ubuntu defaults
RUN usermod --uid ${WWW_USER_ID} www-data \
    && groupmod --gid ${WWW_GROUP_ID} www-data \
    && mkdir --parents ${WWW_HOME_DIR} \
    && chown www-data:www-data ${WWW_HOME_DIR} \
    && usermod --home ${WWW_HOME_DIR} www-data

## Install base dependencies (unzip for Composer, others for adding/using PHP repo)
RUN apt-get -qy update && apt-get -qy install \
    apt-transport-https \
    lsb-release \
    ca-certificates \
    curl \
    unzip \
\
## Add PHP repo
 && curl -sSLo /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
 && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
\
## Install PHP
 && apt-get -qy update && apt-get -qy install php${PHP_VERSION}-fpm ${PHP_EXTENSIONS} \
\
## Clean up
 && apt-get -qy autoremove \
 && apt-get -qy clean all \
 && rm -rf /var/lib/apt/lists/*

FROM base as fpm

## Remove default config
RUN  rm -r /etc/php/${PHP_VERSION}/fpm/pool.d/

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
FROM fpm as dev-base

ARG SHELL_EDITOR=nano
ARG SHELL_PAGER='less -R'

ENV EDITOR=${SHELL_EDITOR} \
    PAGER=${SHELL_PAGER} \
    IS_DEV_IMAGE=1

USER root

RUN apt-get update -qy && apt-get install -qy ${DEV_TOOLS} \
 && apt-get -qy autoremove \
 && apt-get -qy clean all \
 && rm -rf /var/lib/apt/lists/* \
 && echo "alias ll='ls -lAhF --color=auto'" >> /etc/bash.bashrc

FROM dev-base as dev

## Add entryopoint & config
COPY entrypoint.sh /usr/local/bin/docker-entry
COPY php-fpm.conf /etc/php/${PHP_VERSION}/fpm/
COPY cli.ini /etc/php/${PHP_VERSION}/cli/conf.d/
COPY fpm.ini /etc/php/${PHP_VERSION}/fpm/conf.d/

RUN cp /usr/lib/php/${PHP_VERSION}/php.ini-development /etc/php/${PHP_VERSION}/fpm/php.ini \
 && cp /usr/lib/php/${PHP_VERSION}/php.ini-development /etc/php/${PHP_VERSION}/cli/php.ini

USER www-data

###########
## DEBUG ##
###########
FROM dev-base as debug

## Add entryopoint & config
COPY entrypoint.sh /usr/local/bin/docker-entry
COPY php-fpm.conf /etc/php/${PHP_VERSION}/fpm/
COPY cli.ini /etc/php/${PHP_VERSION}/cli/conf.d/
COPY fpm.ini /etc/php/${PHP_VERSION}/fpm/conf.d/
COPY xdebug.ini /etc/php/${PHP_VERSION}/mods-available/

RUN apt-get -qy update && apt-get -qy install php-pear php${PHP_VERSION}-dev \
 && pecl channel-update pecl.php.net && pecl install xdebug \
 && phpenmod xdebug \
\
 && apt-get -qy autoremove \
 && apt-get -qy clean all \
 && rm -rf /var/lib/apt/lists/* \
\
 && cp /usr/lib/php/${PHP_VERSION}/php.ini-development /etc/php/${PHP_VERSION}/fpm/php.ini \
 && cp /usr/lib/php/${PHP_VERSION}/php.ini-development /etc/php/${PHP_VERSION}/cli/php.ini

USER www-data
