#!/bin/bash

export DOCKER_BUILDKIT=1

PHP_VERSION=${PHP_VERSION:-7.4}
BASE=${BASE:-base}
TARGET=${TARGET:-nginx}

NAME="ajdinmore/${TARGET}-php-dev"
TAG="${PHP_VERSION}-${BASE}-test"
REPO="${NAME}:${TAG}"

docker build \
  --target "${TARGET}" \
  --build-arg "BASE=${BASE}" \
  --build-arg "PHP_VERSION=${PHP_VERSION}" \
  --tag "${REPO}" \
  . ||
  exit 1

if [ -z "$*" ]; then
  docker run --rm -itp 80:80 "${REPO}"
else
  docker run --rm -it "${REPO}" "$*"
fi
