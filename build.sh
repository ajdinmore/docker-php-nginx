#!/bin/bash

export DOCKER_BUILDKIT=1

## NGINX

REPO="${1-ajdinmore}/nginx"
docker pull nginx:alpine
printf "\n\n%s\n\n" "${REPO}"
docker build --tag "${REPO}" ./nginx/ || exit 1
docker push "${REPO}" || exit 2

## PHP

REPO="${1-ajdinmore}/php"
DEBIAN_RELEASE='bullseye'
PHP_VERSIONS=('7.3' '7.4' '8.0' '8.1')
TARGETS=('debug' 'dev' 'fpm')

docker pull "debian:${DEBIAN_RELEASE}-slim"

for PHP_VERSION in "${PHP_VERSIONS[@]}"; do
    for TARGET in "${TARGETS[@]}"; do

        TAG="${PHP_VERSION}-${TARGET}"
        IMAGE="${REPO}:${TAG}"

        printf "\n\n%s\n\n" "${IMAGE}"

        docker build \
            --target "${TARGET}" \
            --build-arg "DEBIAN_RELEASE=${DEBIAN_RELEASE}" \
            --build-arg "PHP_VERSION=${PHP_VERSION}" \
            --tag "${IMAGE}" \
            ./php/ \
            || exit 3

        docker push "${IMAGE}" || exit 2

    done

    docker tag "${REPO}:${PHP_VERSION}-fpm" "${REPO}:${PHP_VERSION}" || exit 4
    docker push "${REPO}:${PHP_VERSION}" || exit 2
done

docker tag "${REPO}:8.1" "${REPO}:latest" || exit 4
docker push "${REPO}:latest" || exit 2
