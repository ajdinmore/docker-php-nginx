#!/bin/bash

export DOCKER_BUILDKIT=1

PHP_VERSIONS=(7.4 7.3 7.2)
SERVERS=(nginx lighttpd)
declare -A TYPES=([base]='' [debug]='-debug')

for TARGET in "${SERVERS[@]}"; do
  NAME="ajdinmore/${TARGET}-php-dev"

  for PHP_VERSION in "${PHP_VERSIONS[@]}"; do
    for BASE in "${!TYPES[@]}"; do

      TAG="${PHP_VERSION}${TYPES[$TARGET]}"
      REPO="${NAME}:${TAG}"

      printf "\n\n%s\n\n" "${REPO}"

      docker build \
        --target "${TARGET}" \
        --build-arg "BASE=${BASE}" \
        --build-arg "PHP_VERSION=${PHP_VERSION}" \
        --tag "${REPO}" \
        . ||
        exit 1

      docker push "${REPO}"

    done
  done

  docker tag "${NAME}:7.4" "${NAME}:latest"
  docker push "${NAME}:latest"
done
