#!/bin/bash

export DOCKER_BUILDKIT=1

PHP_VERSION=${PHP_VERSION:-7.4}
TARGET=${TARGET:-php}
SERVER=${SERVER:-nginx}
REPO="ajdinmore/php-dev-test"
TAG="${SERVER}-${PHP_VERSION}-${TARGET}"
IMAGE="${REPO}:${TAG}"

docker build \
  --target "${TARGET}" \
  --build-arg "SERVER=${SERVER}" \
  --build-arg "PHP_VERSION=${PHP_VERSION}" \
  --tag "${IMAGE}" \
  content ||
  exit 1

if [ -z "$*" ]; then
  docker run --rm -itp 80:80 "${IMAGE}"
else
  # shellcheck disable=SC2086
  # shellcheck disable=SC2048
  docker run --rm -it "${IMAGE}" $*
fi

docker image rm "${IMAGE}"
