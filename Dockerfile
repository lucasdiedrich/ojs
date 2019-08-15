# -----------------------------------------------------------------------------------------------------------------------------------
# BUILDING CONTAINER
# -----------------------------------------------------------------------------------------------------------------------------------
FROM php:7.2-alpine as builder
LABEL maintainer="Lucas G. Diedrich <lucas.diedrich@gmail.com>"
WORKDIR /tmp/
ENV COMPOSER_ALLOW_SUPERUSER=1 \
        OJS_VERSION="3_1_2-1" \
        PACKAGES="curl nodejs npm git" \
        EXCLUDE="dbscripts/xml/data/locale/en_US/sample.xml     \
        dbscripts/xml/data/sample.xml					\
        docs/dev										\
        tests											\
        tools/buildpkg.sh								\
        tools/genLocaleReport.sh						\
        tools/genTestLocale.php							\
        tools/test										\
        lib/pkp/tools/travis							\
        lib/pkp/plugins/*/*/tests						\
        plugins/*/*/tests								\
        plugins/auth/ldap								\
        plugins/generic/announcementFeed				\
        plugins/generic/backup							\
        plugins/generic/browse							\
        plugins/generic/coins							\
        plugins/generic/cookiesAlert					\
        plugins/generic/counter							\
        plugins/generic/customLocale					\
        plugins/generic/externalFeed					\
        plugins/generic/lucene							\
        plugins/generic/phpMyVisites					\
        plugins/generic/recommendBySimilarity			\
        plugins/generic/translator						\
        plugins/importexport/sample						\
        plugins/importexport/duracloud					\
        plugins/reports/subscriptions					\
        plugins/blocks/relatedItems						\
        plugins/oaiMetadataFormats/jats					\
        tests											\
        lib/pkp/tests									\
        .git											\
        .openshift										\
        .scrutinizer.yml								\
        .travis.yml										\
        lib/pkp/.git									\
        lib/pkp/lib/components/*.js						\
        lib/pkp/lib/components/*.css					\
        lib/pkp/js/lib/pnotify/build-tools				\
        lib/pkp/lib/vendor/alex198710/pnotify/.git		\
        lib/pkp/lib/vendor/sebastian					\
        lib/pkp/lib/vendor/oyejorge/less.php/test		\
        lib/pkp/tools/travis							\
        lib/pkp/lib/swordappv2/.git						\
        lib/pkp/lib/swordappv2/.git						\
        lib/pkp/lib/swordappv2/test						\
        plugins/paymethod/paypal/vendor/omnipay/common/tests/					\
        plugins/paymethod/paypal/vendor/omnipay/paypal/tests/					\
        plugins/paymethod/paypal/vendor/guzzle/guzzle/docs/					    \
        plugins/paymethod/paypal/vendor/guzzle/guzzle/tests/					\
        plugins/generic/citationStyleLanguage/lib/vendor/symfony/debug/			\
        plugins/generic/citationStyleLanguage/lib/vendor/symfony/console/Tests/	\
        plugins/paymethod/paypal/vendor/symfony/http-foundation/Tests/			\
        plugins/paymethod/paypal/vendor/symfony/event-dispatcher/				\
        plugins/paymethod/paypal/vendor/guzzle/guzzle/tests/Guzzle/Tests/		\
        plugins/generic/citationStyleLanguage/lib/vendor/symfony/filesystem/Tests/		        \
        plugins/generic/citationStyleLanguage/lib/vendor/symfony/stopwatch/Tests/		        \
        plugins/generic/citationStyleLanguage/lib/vendor/symfony/event-dispatcher/Tests/	    \
        plugins/generic/citationStyleLanguage/lib/vendor/symfony/config/Tests/			        \
        plugins/generic/citationStyleLanguage/lib/vendor/symfony/yaml/Tests/			        \
        plugins/generic/citationStyleLanguage/lib/vendor/guzzle/guzzle/tests/Guzzle/Tests/	    \
        plugins/generic/citationStyleLanguage/lib/vendor/symfony/config/Tests/			        \
        plugins/generic/citationStyleLanguage/lib/vendor/citation-style-language/locales/.git	\
        lib/pkp/lib/vendor/symfony/translation/Tests/		                            \
        lib/pkp/lib/vendor/symfony/process/Tests/			                            \
        lib/pkp/lib/vendor/pimple/pimple/src/Pimple/Tests/	                            \
        lib/pkp/lib/vendor/robloach/component-installer/tests/ComponentInstaller/Test/	\
        plugins/generic/citationStyleLanguage/lib/vendor/satooshi/php-coveralls/tests/	\
        plugins/generic/citationStyleLanguage/lib/vendor/guzzle/guzzle/tests/			\
        plugins/generic/citationStyleLanguage/lib/vendor/seboettg/collection/tests/		\
        plugins/generic/citationStyleLanguage/lib/vendor/seboettg/citeproc-php/tests/	\
        lib/pkp/lib/vendor/nikic/fast-route/test/						    \
        lib/pkp/lib/vendor/ezyang/htmlpurifier/tests/						\
        lib/pkp/lib/vendor/ezyang/htmlpurifier/smoketests/					\
        lib/pkp/lib/vendor/pimple/pimple/ext/pimple/tests/					\
        lib/pkp/lib/vendor/robloach/component-installer/tests/				\
        lib/pkp/lib/vendor/phpmailer/phpmailer/test/						\
        node_modules										\
        .babelrc							    			\
        .editorconfig										\
        .eslintignore										\
        .eslintrc.js										\
        .postcssrc.js										\
        package.json										\
        webpack.config.js									\
        lib/ui-library"

RUN apk add --update --no-cache $PACKAGES && \
        ln -s /usr/bin/php7 /usr/bin/php && \
        curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
        # Configure and download code from git
        git config --global url.https://.insteadOf git:// && \
        git config --global advice.detachedHead false && \
        git clone --depth 1 --single-branch --branch $OJS_VERSION --progress https://github.com/pkp/ojs.git . && \
        git submodule update --init --recursive >/dev/null && \
        # Install Composer Deps and NPM
        composer update -d lib/pkp --no-dev && \
        composer install -d plugins/paymethod/paypal --no-dev && \
        composer install -d plugins/generic/citationStyleLanguage --no-dev && \
        npm install -y && npm run build && \
        # Clear the base project
        cp config.TEMPLATE.inc.php config.inc.php && \    
        rm -rf $EXCLUDE && \
        find . \( -name .gitignore -o -name .gitmodules -o -name .keepme \) -exec rm '{}' \;

# -----------------------------------------------------------------------------------------------------------------------------------
# RUNNING CONTAINER
# -----------------------------------------------------------------------------------------------------------------------------------
FROM php:7.2-alpine
LABEL maintainer="Lucas G. Diedrich <lucas.diedrich@gmail.com>"
WORKDIR /var/www/html
COPY --from=builder /tmp/ /var/www/html/

ENV OJS_VERSION="3_1_2-1"       \
        OJS_CLI_INSTALL="0"         \
        OJS_DB_HOST="localhost"     \
        OJS_DB_USER="ojs"           \
        OJS_DB_PASSWORD="ojs"       \
        OJS_DB_NAME="ojs"           \
        OJS_WEB_CONF="/etc/apache2/conf.d/ojs.conf" \
        OJS_CONF="/var/www/html/config.inc.php" \
        SERVERNAME="localhost" \
        HTTPS="on" \
        PACKAGES="supervisor dcron apache2 apache2-ssl apache2-utils file \
        php7-apache2 php7-zlib php7-json php7-phar php7-openssl \
        php7-curl php7-mcrypt php7-pdo_mysql php7-ctype php7-zip \
        php7-gd php7-xml php7-dom php7-iconv php7-mysqli php7-mbstring \
        php7-session php7-xml php7-simplexml"   

RUN echo ${PACKAGES}; apk add --update --no-cache $PACKAGES && \
        mkdir -p /var/www/files /run/apache2 /run/supervisord/ && \
        chown -R apache:apache /var/www/* && \
        sed -i -e '\#<Directory />#,\#</Directory>#d' /etc/apache2/httpd.conf && \
        sed -i -e "s/^ServerSignature.*/ServerSignature Off/" /etc/apache2/httpd.conf && \
        docker-php-ext-install mysqli && docker-php-ext-enable mysqli 

COPY files/ /
EXPOSE 80 443
VOLUME [ "/var/www/files", "/var/www/html/public" ]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

