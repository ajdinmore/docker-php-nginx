#!/bin/bash

export DOCKER_BUILDKIT=1

REPO="${1-ajdinmore/php-dev}"
PHP_VERSIONS=('8.0' '7.4' '7.3' '7.2')
SERVERS=('nginx' 'lighttpd')
declare -A TARGETS=(['php']='' ['debug']='-debug')

for PHP_VERSION in "${PHP_VERSIONS[@]}"; do
  for TARGET in "${!TARGETS[@]}"; do

    VERSION="${PHP_VERSION}${TARGETS[$TARGET]}"

    for SERVER in "${SERVERS[@]}"; do

      TAG="${VERSION}-${SERVER}"
      IMAGE="${REPO}:${TAG}"

      printf "\n\n%s\n\n" "${TAG}"

      docker build \
        --target "${TARGET}" \
        --build-arg "SERVER=${SERVER}" \
        --build-arg "PHP_VERSION=${PHP_VERSION}" \
        --tag "${IMAGE}" \
        content ||
        exit 1

      docker push "${IMAGE}"

    done

    docker tag "${REPO}:nginx-${VERSION}" "${REPO}:${VERSION}"
    docker push "${REPO}:${VERSION}"

  done
done

docker tag "${REPO}:7.4" "${REPO}:latest"
docker push "${REPO}:latest"
