# OJS (Open Journal Systems) - PKP - Container/Docker

Open Journal Systems (OJS) is a journal management and publishing system that has been developed by the Public Knowledge Project through its federally funded efforts to expand and improve access to research.

This container was built based on [buildpkg.sh](https://github.com/pkp/ojs/blob/ojs-3_1_0-1/tools/buildpkg.sh) from own pkp-ojs, so all the dependencies are already included and the software is ready to run. Also is built on top of [Alpine Linux](https://alpinelinux.org/) which is incredible lightweight.

## How to use this image

```bash
docker run --name ojs \
           -p 80:80 -p 443:443 \
           -e SERVERNAME=... \
           -v /etc/localtime:/etc/localtime \
           -d lucasdiedrich/ojs
```

Now just access 127.0.0.1/index/install and continue trough web installation and finish your install and configs. To install automatically when the container init you can use **OJS_CLI_INSTALL=1**, and use the others environment variables to automatize the process.

### Environment Variables

|  NAME  | Default |
|:------:|:-------:|
|   SERVERNAME  |   localhost   |
| OJS_CLI_INSTALL |  0   |
|   OJS_DB_HOST  |   localhost    |
|   OJS_DB_USER  |   ojs   |
|   OJS_DB_PASSWORD  |   ojs   |
|   OJS_DB_NAME  |   ojs   |

### Special Volumes

|  Volume  | Info |
|:------:|:-------:|
| /var/www/html/files  | All uploaded files |
| /var/www/html/public | All public files |
| /var/www/html/config.inc.php  | If not provided a new one will be created |
| /etc/localtime  | To set container clock as the host clock |

## Upgrading OJS

The update process is easy and straightforward, once the container running the new version of OJS just run the exec command below, and it will upgrade the OJS database and files.

```bash
docker exec -it ojs /usr/local/bin/ojs-upgrade
```

After the upgrade diff your **config.inc.php** with the version of the new OJS version, in some new version new variables can be added to the file.

## Important points

Below are some useful information about this container usage and default configuration.

### SSL

By default at the start of Apache one script will check if the SSL certificate is valid and its CN matches your SERVERNAME, if don't it will generate a new one. The certificate can be overwrite using the volume mount point.

### index.php

By default the restful_url are enable and apache its also configured, so there is no need to use index.php over url.

### php.ini

Any custom php configuration can be made at */etc/php5/conf.d/0-ojs.ini*, upload file and other stuff its already made there.

### Docker-compose

There is an example docker-compose file at the base_dir of this project, this compose file enable 

## License

MIT © [Lucas Diedrich](https://github.com/lucasdiedrich)
