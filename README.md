# OJS (Open Journal Systems) - PKP - Container/Docker

| **IMPORTANT: This repostitoy is still pre-alpha, so it can't be used in testing or production evironments.** |
|:------------------------------------------------------------------------------------------------------------:|

Open Journal Systems (OJS) is a journal management and publishing system that has been developed by the [Public Knowledge Project](https://pkp.sfu.ca/) through its federally funded efforts to expand and improve access to research.

The images in this repository are built on top of [Alpine Linux](https://alpinelinux.org/) and come in several variants, see [Versions](#versions).
This repository is a fork of the work formerly done by [Lucas Dietrich](https://github.com/lucasdiedrich/ojs).

## How to use

For all available versions, this project provides a [docker-compose](https://docs.docker.com/compose/) configuration file so you can start OJS together with the required database container with a single command.

1. Go to the directory of your OJS version and software stack of your choice
   ```bash
   cd versions/3_1_2-4/alpine/apache/php7
   ```
1. Run 
   ```bash
   docker-compose up`
   ```
1. Access **http://127.0.0.1:8080/index/install** and continue through web installation and finish your installation procedure and configurations.
   Note that the database connection needs the following options unless you make changes through the [environment variables](#environment-variables):
  - **URL**: `db` (which is the name of the container in the internal Docker network)

To go through the OJS installation process automatically, set the environment variable `OJS_CLI_INSTALL=1`, and use the other environment variables to automatize the process.

## How to use local image builds

Each software stack and version also has a file `docker-compose-local.yml`.
It can be used to build the OJS image locally, e.g. when specific configuration files are added to the image.
You can tell `docker-compose` to use this configuration file with the `-f`/`--file` option:

```bash
docker-compose --file docker-compose-local.yml up
```

## Versions

Different OJS versions are combined with different versions of PHP (5 and 7), and different web servers ([Apache HTTP Server](https://httpd.apache.org/), [nginx](https://nginx.org/)).
_Currently, not all these combinations work!_

All version tags can be found at [Docker Hub Tags tab](https://hub.docker.com/r/pkpofficial/ojs/tags/).
If no webserver is mentioned in the tag, then Apache is used.

## Environment Variables

| NAME            | Default   | Info                                                   |
|:---------------:|:---------:|:------------------------------------------------------:|
| SERVERNAME      | localhost | Used to generate httpd.conf and certificate            |
| OJS_CLI_INSTALL | 0         | Used to install ojs automatically when start container |
| OJS_DB_HOST     | localhost | Database host                                          |
| OJS_DB_USER     | ojs       | Database username                                      |
| OJS_DB_PASSWORD | ojs       | Database password                                      |
| OJS_DB_NAME     | ojs       | Database name                                          |

## Special Volumes

You can add the following volume mounts to the container configuration in the `docker-compose.yml` files to share specific files from your host with the container.

| Volume                               | Info                                      |
|:------------------------------------:|:-----------------------------------------:|
| /var/www/html/public                 | All public files                          |
| /var/www/html/config.inc.php         | If not provided a new one will be created |
| /var/www/files                       | All uploaded files                        |
| /etc/ssl/apache2/server.pem          | SSL **crt** certificate                   |
| /etc/ssl/apache2/server.key          | SSL **key** certificate                   |
| /var/log/apache2                     | Apache2 Logs                              |
| /var/www/html/.htaccess              | Apache2 HTAccess                          |
| /usr/local/etc/php/conf.d/custom.ini | PHP5 custom.init                          |
| /etc/localtime                       | To set container clock as the host clock  |

## Upgrading OJS

The update process is easy and straightforward.

1. Stop the container with the old OJS version.
1. Start the container with the new OJS version.
1. Note the name of the OJS container using `docker ps`, e.g. `ojs_app_journalname`
1. Connect to the new OJS container with [`docker exec`](https://docs.docker.com/engine/reference/commandline/exec/) and run the `ojs-upgrade` command to upgrade the OJS database and files:
   ```bash
   docker exec -it <name of the OJS container> /usr/local/bin/ojs-upgrade
   ```
1. After the upgrade [diff](https://linux.die.net/man/1/diff) your `config.inc.php` with the version of the new OJS version to learn about new configuration variables.

## Update the compose configurations and Dockerfiles

The files for the different OJS versions and software stacks are generated based on a number of template files, see directory `templates`.
You can re-generate all `Dockerfile`, `docker-compose(-local).yml`, configuration files, etc. with the `build.sh` script.

```bash
# generate a specific version
./build.sh 3_1_2-4

# generate _all_ versions
./build.sh
```

## Add image for a new OJS version and stack

1. Create the specific directory structure (e.g. ``3_1_2-1/alpine/apache/php7``).
2. Generate the Dockerfile from the appropriate Dockerfile template
3. Run update.sh

## SSL

By default at the start of Apache one script will check if the SSL certificate is valid and its CN matches your SERVERNAME, if don't it will generate a new one. The certificate can be overwritten using a volume mount (see `docker-compose.yml` file).

## index.php

By default the restful_url are enabled and Apache is already configured, so there is no need to use index.php over url.

## php.ini

Any custom PHP configuration can be made in the file */etc/php{5,7}/conf.d/0-ojs.ini*.
There are some optimized variables already, you can check them within each version directory, e.g. `versions/<your version>/alpine/apache/php7/root/etc/php7/conf.d/0-ojs.ini`.
Note that this file is copied into the Docker image at build time and if you change it you must rebuild the image for changes to take effect.

## License

GPL3 © [PKP](https://github.com/pkp)
