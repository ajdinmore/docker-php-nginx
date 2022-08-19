#!/bin/sh
set -e

if [ "$IS_DEV_IMAGE" = 1 ] && [ "$HOME" = / ]; then
    export HOME=/tmp/home
    mkdir -pm 777 "$HOME"
fi

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
    # todo: remove default --fpm-config if one is provided
    set -- "php-fpm${PHP_VERSION}" '--fpm-config' "/etc/php/${PHP_VERSION}/fpm/php-fpm.conf" "$@"
fi

exec "$@"
