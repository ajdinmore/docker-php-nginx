# Andy's PHP & NGINX Docker Images

## `ajdinmore/nginx`
🔗 [Docker Hub](https://hub.docker.com/r/ajdinmore/nginx)

Tweaked version of [standard Docker NGINX Image](https://hub.docker.com/_/nginx) for PHP applications.

Currently, no SSL support; handle it in your load balancer.

## Paths

| Path                  | Purpose                   |
|-----------------------|---------------------------|
| `/app`                | Project root              |
| `/app/public`         | Web root                  |

### Runtime Environment Variables

| Variable     | Purpose                      | Default         |
|--------------|------------------------------|-----------------|
| `NGINX_PORT` | Port NGINX will listen on    | `80`            |
| `NGINX_HOST` | Web server host              | `_` (all hosts) |
| `NGINX_ROOT` | Web server root path         | `/app/public`   |
| `PHP_HOST`   | Network host name of PHP-FPM | `php`           |
| `PHP_PORT`   | Port to access PHP-FPM       | `9000`          |

---

## `ajdinmore/php`
🔗 [Docker Hub](https://hub.docker.com/r/ajdinmore/php)

PHP-FPM and some standard extensions, installed from official PHP Debian repository.

Includes globally accessible Composer "binary".

Listens on port `9000`.

Worker user will match the user the container runs under. Default user `www-data`, ID `1000`.

## Tag Structure

`${PHP_VERSION}-${BUILD_TARGET}`

E.g. `8.1-dev`

### Available PHP Versions
- `8.1`
- `8.0`
- `7.4`
- `7.3`

### Available Build Targets
- `fpm` - standard/production
- `dev` - dev config & tools
- `debug` - as dev, with Xdebug (untested)

## Available Build Args

| Arg              | Purpose                                                                          | Default                                                                                           |
|------------------|----------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| `PHP_VERSION`    | Version of PHP-FPM to install                                                    | `8.1`                                                                                             |
| `DEBIAN_RELEASE` | Debian release to base the image on                                              | `bullseye`                                                                                        |
| `WWW_USER_ID`    | ID of the default `www-data` user                                                | `1000`                                                                                            |
| `WWW_GROUP_ID`   | ID of the default user's `www-data` group                                        | `1000`                                                                                            |
| `PHP_EXTENSIONS` | PHP extensions to install                                                        | `php-curl php-zip php-xml php-mbstring php-intl php-mysql php-pgsql php-redis php-imagick php-gd` |
| `DEV_TOOLS`      | Utilities to install in the `dev` image                                          | `postgresql-client default-mysql-client iputils-ping dnsutils unzip nano less git man`            |
| `COMPOSER_HOME`  | Path of the Composer "home" directory (location of cache & OAuth tokens)         | `/composer`                                                                                       |
| `SHELL_EDITOR`   | Default editor to use in Bash on the `dev` image (environment variable `EDITOR`) | `nano`                                                                                            |
| `SHELL_PAGER`    | Pager to use in Bash on the `dev` image (environment variable `PAGER`)           | `less -R`                                                                                         |
