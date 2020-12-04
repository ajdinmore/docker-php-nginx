#!/bin/bash

## Turn on Bash job control so container will terminate correctly
set -m

## Make globally writable stdout/stderr links for www-data user
#exec 3>&1 4>&2 && chmod a+w /dev/fd/3 /dev/fd/4

## Start PHP
/usr/sbin/php-fpm${PHP_VERSION} -D --fpm-config /etc/php/${PHP_VERSION}/fpm/php-fpm.conf

service nginx start

tail -f /var/log/nginx/access.log -f /var/log/nginx/error.log
