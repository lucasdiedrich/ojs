#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

for version in "${versions[@]}"; do
    for php in php5 php7; do
        [ -f "$version/alpine/apache/$php/Dockerfile" ] || continue
        sed -e "s!%%OJS_VERSION%%!$version!g" \
            "Dockerfile-alpine-apache-$php.template" \
            > "$version/alpine/apache/$php/Dockerfile"
        echo "$version: $php"
    done
done
