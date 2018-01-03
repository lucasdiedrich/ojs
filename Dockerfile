FROM alpine:3.7

LABEL maintainer="Lucas G. Diedrich <lucas.diedrich@gmail.com>"

WORKDIR /var/www/html

ENV COMPOSER_ALLOW_SUPERUSER=1  \
    SERVERNAME="localhost"      \
    OJS_VERSION="ojs-2_4_8-2"   \
    OJS_CLI_INSTALL="0"         \
    OJS_DB_HOST="localhost"     \
    OJS_DB_USER="ojs"           \
    OJS_DB_PASSWORD="ojs"       \
    OJS_DB_NAME="ojs"           \
    OJS_WEB_CONF="/etc/apache2/conf.d/ojs.conf" \
    OJS_CONF="/var/www/html/config.inc.php" \
    PACKAGES="dcron apache2 apache2-ssl apache2-utils php5 php5-fpm php5-cli php5-apache2 php5-zlib \
             php5-json php5-phar php5-openssl php5-mysql php5-curl php5-mcrypt php5-pdo_mysql php5-ctype \
             php5-gd php5-xml php5-dom php5-iconv curl git" \
    EXCLUDE="dbscripts/xml/data/locale/en_US/sample.xml		\
            dbscripts/xml/data/sample.xml					\
            docs/dev							            \
            locale/te_ST							        \
            plugins/importexport/duracloud/lib/DuraCloud-PHP/.git		\
            tests								            \
            tools/buildpkg.sh						        \
            tools/genLocaleReport.sh					    \
            tools/genTestLocale.php						    \
            tools/startSubmodulesTRAVIS.sh					\
            tools/test							            \
            lib/pkp/tests							        \
            .git								            \
            .travis.yml							            \
            lib/pkp/.git							        \
            lib/pkp/tools/travis						\
            lib/pkp/tools/mergePullRequest.sh			\
            lib/password_compat/.git					\
            lib/pkp/lib/swordappv2/.git					\
            lib/pkp/lib/swordappv2/test					\
            plugins/reports/counter/classes/COUNTER/.git	\
            plugins/generic/pdfJsViewer/.git				\
            .babelrc							    		\
            .editorconfig									\
            .eslintignore									\
            .eslintrc.js									\
            .postcssrc.js									\
            package.json									\
            webpack.config.js								\
            lib/ui-library                                  \
            /var/cache/apk/* "

RUN apk add --update --no-cache $PACKAGES && \
    ln -s /usr/bin/php5 /usr/bin/php && \
    # Configure and download code from git
    git config --global url.https://.insteadOf git:// && \
    git config --global advice.detachedHead false && \
    git clone --depth 1 --single-branch --branch $OJS_VERSION --progress https://github.com/pkp/ojs.git . && \
    git submodule update --init --recursive >/dev/null && \
    # Create directories
    mkdir /var/www/html/files /run/apache2 && \
    cp config.TEMPLATE.inc.php config.inc.php && \
    chown -R apache:apache /var/www/* && \
    # Prepare crontab
    echo "0 * * * *   ojs-run-scheduled" | crontab - && \
    # Prepare httpd.conf
    sed -i -e '\#<Directory />#,\#</Directory>#d' /etc/apache2/httpd.conf && \
    sed -i -e "s/^ServerSignature.*/ServerSignature Off/" /etc/apache2/httpd.conf && \
    # Clear the image
    apk del --no-cache git && rm -rf $EXCLUDE && \
    find . \( -name .gitignore -o -name .gitmodules -o -name .keepme \) -exec rm '{}' \;

COPY files/ojs.conf $OJS_WEB_CONF
COPY files/php.ini /etc/php5/conf.d/0-ojs.ini
COPY files/bin/* /usr/local/bin/

EXPOSE 80 443

VOLUME [ "/var/www/html/files", "/var/www/html/public" ]

CMD ["/bin/sh", "/usr/local/bin/ojs-start"]
