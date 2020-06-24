FROM alpine:3.8

LABEL maintainer="Public Knowledge Project <marc.bria@gmail.com>"

WORKDIR /var/www/html

ENV COMPOSER_ALLOW_SUPERUSER=1  \
    SERVERNAME="localhost"      \
    HTTPS="on"                  \
    OJS_VERSION=ojs-2_3_2-1 \
    OJS_CLI_INSTALL="0"         \
    OJS_DB_HOST="localhost"     \
    OJS_DB_USER="ojs"           \
    OJS_DB_PASSWORD="ojs"       \
    OJS_DB_NAME="ojs"           \
    OJS_WEB_CONF="/etc/apache2/conf.d/ojs.conf"	\
    OJS_CONF="/var/www/html/config.inc.php"


# PHP_INI_DIR to be symmetrical with official php docker image
ENV PHP_INI_DIR /etc/php/5.6

# When using Composer, disable the warning about running commands as root/super user
ENV COMPOSER_ALLOW_SUPERUSER=1

# Basic packages
ENV PACKAGES 		\
	apache2 		\
	apache2-ssl 	\
	apache2-utils 	\
	ca-certificates \
	curl 			\
	ttf-freefont	\
	dcron 			\
	php5			\
	php5-cli		\
	php5-apache2	\
	runit 			\
	supervisor

#	php5-fpm 		\

# PHP extensions
ENV PHP_EXTENSIONS	\
	php5-bcmath		\
	php5-bz2		\
	php5-calendar	\
	php5-ctype		\
	php5-curl		\
	php5-dom		\
	php5-exif		\
	php5-ftp		\
	php5-gd 		\
	php5-gettext	\
	php5-iconv		\
	php5-json		\
	php5-mcrypt		\
	php5-mysql		\
	php5-opcache	\
	php5-openssl	\
	php5-pdo_mysql	\
	php5-phar		\
	php5-posix		\
	php5-shmop		\
	php5-sockets	\
	php5-sysvmsg	\
	php5-sysvsem	\
	php5-sysvshm	\
	php5-xml		\
	php5-xmlreader	\
	php5-zip		\
	php5-zlib

# Required to build OJS:
ENV BUILDERS 		\
	git 			\
	nodejs 			\
	npm

# To make a smaller image, we start with the copy.
# This let us joining runs in a single layer.
COPY exclude.list /tmp/exclude.list

RUN set -xe \
	&& apk add --no-cache --virtual .build-deps $BUILDERS \
 	&& apk add --no-cache $PACKAGES \
	&& apk add --no-cache $PHP_EXTENSIONS \
# Building OJS:
	# Configure and download code from git
	&& git config --global url.https://.insteadOf git:// \
	&& git config --global advice.detachedHead false \
	&& git clone --depth 1 --single-branch --branch $OJS_VERSION --progress https://github.com/pkp/ojs.git . \
	&& git submodule update --init --recursive >/dev/null \
	&& ln -s /usr/bin/php5 /usr/bin/php \
	# Composer vudu:
	&& curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer.phar \
# Create directories
 	&& mkdir -p /var/www/files /run/apache2  /run/supervisord/ \
	&& cp config.TEMPLATE.inc.php config.inc.php \
	&& chown -R apache:apache /var/www/* \
# Prepare freefont for captcha 
	&& ln -s /usr/share/fonts/TTF/FreeSerif.ttf /usr/share/fonts/FreeSerif.ttf \
# Prepare crontab
	&& echo "0 * * * *   ojs-run-scheduled" | crontab - \
# Prepare httpd.conf
	&& sed -i -e '\#<Directory />#,\#</Directory>#d' /etc/apache2/httpd.conf \
	&& sed -i -e "s/^ServerSignature.*/ServerSignature Off/" /etc/apache2/httpd.conf \
# Clear the image (list of files to be deleted in exclude.list).
 	&& rm -rf $(cat /tmp/exclude.list) \
	&& apk del --no-cache .build-deps \
	&& rm -rf /tmp/* \
	&& find . \( -name .gitignore -o -name .gitmodules -o -name .keepme \) -exec rm '{}' \;

COPY root/ /

EXPOSE 80 443

VOLUME [ "/var/www/files", "/var/www/html/public" ]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
