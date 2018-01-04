# OJS (Open Journal Systems) - PKP - Container/Docker

Open Journal Systems (OJS) is a journal management and publishing system that has been developed by the Public Knowledge Project through its federally funded efforts to expand and improve access to research.

This container was built based on [buildpkg.sh](https://github.com/pkp/ojs/blob/ojs-3_1_0-1/tools/buildpkg.sh) from own pkp-ojs, so all the dependencies are already included and the software is ready to run. Also is built on top of [Alpine Linux](https://alpinelinux.org/) which is incredible lightweight.

## How to use

```bash
docker run --name ojs \
           -p 80:80 -p 443:443 \
           -e SERVERNAME=... \
           -v /etc/localtime:/etc/localtime \
           -d lucasdiedrich/ojs
```

Now just access 127.0.0.1/index/install and continue through web installation and finish your install and configs.
To install automatically when the container init you can use **OJS_CLI_INSTALL=1**, and use the others environment variables to automatize the process.

## Versions

All version tags can be found at [Docker Hub Tags tab](https://hub.docker.com/r/lucasdiedrich/ojs/tags/).

## Environment Variables

|  NAME  | Default | Info |
|:------:|:-------:|:-------:|
|   SERVERNAME  | localhost | Used to generate httpd.conf and certificate |
| OJS_CLI_INSTALL |  0  | Used to install ojs automatically when start container |
|   OJS_DB_HOST  | localhost | Database host |
|   OJS_DB_USER  | ojs | Database username |
|   OJS_DB_PASSWORD  | ojs | Database password |
|   OJS_DB_NAME  | ojs | Database name |

## Special Volumes

|  Volume  | Info |
|:------:|:-------:|
| /var/www/html/files  | All uploaded files |
| /var/www/html/public | All public files |
| /var/www/html/config.inc.php  | If not provided a new one will be created |
| /etc/ssl/apache2/server.pem  | SSL **crt** certificate |
| /etc/ssl/apache2/server.key  | SSL **key** certificate |
| /etc/localtime  | To set container clock as the host clock |

## Upgrading OJS

The update process is easy and straightforward, once the container running the new version just run the exec command below, and it will upgrade the OJS database and files.

```bash
docker exec -it ojs /usr/local/bin/ojs-upgrade
```

After the upgrade diff your **config.inc.php** with the version of the new OJS version, in some new version new variables can be added to the file.

## Docker-compose

There is an example docker-compose [docker-compose](./docker-compose.yml), to run it download the raw file to an folder and exec the command below:

```bash
docker-compose up
```

## SSL

By default at the start of Apache one script will check if the SSL certificate is valid and its CN matches your SERVERNAME, if don't it will generate a new one. The certificate can be overwrite using the volume mount.

## index.php

By default the restful_url are enable and apache its already configured, so there is no need to use index.php over url.

## php.ini

Any custom php configuration can be made at */etc/php5/conf.d/0-ojs.ini*, there are some optimized variables already, you can check at [php.ini](./files/php.ini).

## License

MIT © [Lucas Diedrich](https://github.com/lucasdiedrich)
