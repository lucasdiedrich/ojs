FROM alpine:3.7

LABEL maintainer="Lucas G. Diedrich <lucas.diedrich@gmail.com>"

WORKDIR /var/www/html

ENV COMPOSER_ALLOW_SUPERUSER=1  \
    SERVERNAME="localhost"      \
    HTTPS="on" \
    OJS_VERSION="ojs-3_1_1-4"       \
    OJS_CLI_INSTALL="0"         \
    OJS_DB_HOST="localhost"     \
    OJS_DB_USER="ojs"           \
    OJS_DB_PASSWORD="ojs"       \
    OJS_DB_NAME="ojs"           \
    OJS_WEB_CONF="/etc/apache2/conf.d/ojs.conf" \
    OJS_CONF="/var/www/html/config.inc.php" \
    PACKAGES="supervisor dcron apache2 apache2-ssl apache2-utils php5 php5-fpm php5-cli php5-apache2 php5-zlib \
             php5-json php5-phar php5-openssl php5-mysql php5-curl php5-mcrypt php5-pdo_mysql php5-ctype \
             php5-gd php5-xml php5-dom php5-iconv curl nodejs git" \
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
            lib/ui-library                                      \
            /usr/local/bin/composer         					\
            /root/.composer                    					\
            /root/.npm                                          \
            /var/cache/apk/* "

RUN apk add --update --no-cache $PACKAGES && \
    ln -s /usr/bin/php5 /usr/bin/php && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    # Configure and download code from git
    git config --global url.https://.insteadOf git:// && \
    git config --global advice.detachedHead false && \
    git clone --depth 1 --single-branch --branch $OJS_VERSION --progress https://github.com/pkp/ojs.git . && \
    git submodule update --init --recursive >/dev/null && \
    # Install NPM and Composer Deps
    composer update -d lib/pkp --no-dev && \
    composer install -d plugins/paymethod/paypal --no-dev && \
    composer install -d plugins/generic/citationStyleLanguage --no-dev && \
    npm install -y && npm run build && \
    # Create directories
    mkdir -p /var/www/files /run/apache2  /run/supervisord/ && \
    cp config.TEMPLATE.inc.php config.inc.php && \
    chown -R apache:apache /var/www/* && \
    # Prepare crontab
    echo "0 * * * *   ojs-run-scheduled" | crontab - && \
    # Prepare httpd.conf
    sed -i -e '\#<Directory />#,\#</Directory>#d' /etc/apache2/httpd.conf && \
    sed -i -e "s/^ServerSignature.*/ServerSignature Off/" /etc/apache2/httpd.conf && \
    # Clear the image
    apk del --no-cache nodejs git && rm -rf $EXCLUDE && \
    find . \( -name .gitignore -o -name .gitmodules -o -name .keepme \) -exec rm '{}' \;

COPY files/ /

EXPOSE 80 443

VOLUME [ "/var/www/files", "/var/www/html/public" ]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
