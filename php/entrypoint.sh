#!/bin/sh
set -e

"php-fpm${PHP_VERSION}" --version | grep fpm-fcgi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
    # todo: remove default --fpm-config if one is provided
	set -- "php-fpm${PHP_VERSION}" '--fpm-config' "/etc/php/${PHP_VERSION}/fpm/php-fpm.conf" "$@"
fi

exec "$@"
