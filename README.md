# Docker images for local PHP dev work
> Use anywhere else at your own risk

- Official PHP repository for up-to-date builds
- Includes Composer, Git and other common tools (curl, ping, less, etc.)
- Server user and group IDs configurable on build (default 1000:1000)
- Easily mountable project and Composer paths
- Optional Xdebug

## Paths

Path | Purpose
--- | ---
`/app` | Project root
`/app/public` | Web root
`/composer` | Composer "home" directory
`/composer/cache` | Composer cache
`/composer/auth.json` | Composer OAuth tokens

## Compose File Example

```yaml
services:
  web:
    image: ajdinmore/php-dev:8.0-debug
    volumes:
    - ./:/app
    - ${COMPOSER_HOME:-${HOME}/.composer}:/composer
    ports:
    - ${HTTP_PORT:-80}:80
```

## Command Examples

```shell
# Install dependencies
docker run --rm -tv $(pwd):/app -u www-data ajdinmore/php-dev composer install

# Install dependencies (protect against accidental edits)
docker run --rm -tv $(pwd):/app ajdinmore/php-dev composer install

# Run web server on port 8080 (interactive for clean exit)
docker run --rm -itv $(pwd):/app -p 8080:80 ajdinmore/php-dev
```

## Available Tags

`${PHP_VERSION}`

`${PHP_VERSION}-${SERVER}`

`${PHP_VERSION}-debug`

`${PHP_VERSION}-debug-${SERVER}`

Default server is NGINX

### PHP Versions

`8.0` `7.4` `7.3` `7.2`

### Servers

`nginx` `lighttpd`

## Build

### Targets

Target | Content
---|---
`system` | Base system: latest stable Debian with utilities & PHP repo
`nginx` | Base system with NGINX
`lighttpd` | Base system with Lighttpd
`php` | Base system with server and PHP
`debug` | Base system with server, PHP, and Xdebug

### Arguments

Argument | Default
---|---
`PHP_VERSION` | `8.0`
`SERVER` | `nginx`
`WWW_USER_ID` | `1000`
`WWW_GROUP_ID` | `1000`
