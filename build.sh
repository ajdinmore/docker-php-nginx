#!/bin/bash

export DOCKER_BUILDKIT=1

## NGINX

docker pull nginx:alpine
printf "\n\n%s\n\n" "NGINX"
docker-compose build nginx
docker-compose push nginx

## PHP

REPO="${1-ajdinmore}/php"
DEBIAN_RELEASE='bullseye'
PHP_VERSIONS=('8.2' '8.1' '8.0')
TARGETS=('debug' 'dev' 'fpm')

docker pull "debian:${DEBIAN_RELEASE}-slim"

for PHP_VERSION in "${PHP_VERSIONS[@]}"; do
    for TARGET in "${TARGETS[@]}"; do

        export DEBIAN_RELEASE PHP_VERSION TARGET \
            TAG="${PHP_VERSION}-${TARGET}" \
            IMAGE="${REPO}:${TAG}"

        printf "\n\n%s\n\n" "PHP $PHP_VERSION $TARGET"

        docker-compose build php || exit 3
        docker-compose push php || exit 2

    done

    docker tag "${REPO}:${PHP_VERSION}-fpm" "${REPO}:${PHP_VERSION}" || exit 4
    docker push "${REPO}:${PHP_VERSION}" || exit 2
done

docker tag "${REPO}:${PHP_VERSIONS[0]}" "${REPO}:latest" || exit 4
docker push "${REPO}:latest" || exit 2
