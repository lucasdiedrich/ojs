#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

for version in "${versions[@]}"; do
    for server in apache nginx; do
        for php in php5 php7; do
            [ -f "$version/alpine/$server/$php/Dockerfile" ] || continue
            sed -e "s!%%OJS_VERSION%%!$version!g" \
                "Dockerfile-alpine-$server-$php.template" \
                > "$version/alpine/$server/$php/Dockerfile"
            echo "[$server] $version: $php"
        done
    done	
done
