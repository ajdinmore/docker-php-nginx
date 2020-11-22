#!/bin/bash

export DOCKER_BUILDKIT=1

REPO=ajdinmore/lighttpd-php-dev
PHP_VERSIONS=(7.4 7.3 7.2)
declare -A TYPES=([base]='' [debug]='-debug')

for PHP_VERSION in ${PHP_VERSIONS[@]}
do
  for TARGET in ${!TYPES[@]}
  do
    printf "\n\n${PHP_VERSION}${TYPES[$TARGET]}\n\n"
    docker build \
      --target ${TARGET} \
      --build-arg PHP_VERSION=${PHP_VERSION} \
      --tag ${REPO}:${PHP_VERSION}${TYPES[$TARGET]} \
      . \
      || exit 1
      docker push ${REPO}:${PHP_VERSION}${TYPES[$TARGET]}
  done
done

docker tag ${REPO}:7.4 ${REPO}:latest
docker push ${REPO}:latest
