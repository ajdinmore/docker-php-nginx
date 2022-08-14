FROM nginx:alpine

WORKDIR /app

COPY default.conf.template /etc/nginx/templates/

ENV NGINX_PORT=80 \
    NGINX_HOST=_ \
    NGINX_ROOT=/app/public \
    PHP_HOST=php \
    PHP_PORT=9000 \
    PHP_TIMEOUT=300
