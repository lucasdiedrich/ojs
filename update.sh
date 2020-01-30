#!/usr/bin/env bash

# ===============================================================================
#          FILE:  update.sh
#
#         USAGE:  update [<versionNum>]
#
#   DESCRIPTION:  A script to generate Dockerfiles based on Dockertemplates.
#
#    PARAMETERS:
#  <versionNum>:  (optional) The release version that you like to generate.
#                 If you don't specify any, all the existing versions will be generated.
#  REQUIREMENTS:  sed
#     TODO/BUGS:  Parameters are positional (I don't like getopt or getopts)
#         NOTES:  ---
#        AUTHOR:  Dulip Withanage, David Cormier, Marc Bria.
#  ORGANIZATION:  Public Knowledge Project (PKP)
#       LICENSE:  GPL 3
#       CREATED:  30/01/2020 02:01:15 CEST
#       UPDATED:  30/01/2020 02:01:15 CEST
#      REVISION:  1.0
#===============================================================================

set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

# You can pass the specific version you like to recreate.
ojsversions=( "$@" )

# Otherwise, all the existing versions will be recreated (recommened).
if [ ${#ojsversions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

# MBR: Won't be better if we define the versions?
#    ojsversions=(   "3_1_2-0" \
#                    "3_1_2-1" \
#                    "3_1_2-2" \
#                    "3_1_2-3" \
#                    "3_1_2-4" )


# The webservers and phpversions that will be supported:
webservers=( apache nginx )
phpversions=( php5 php7 )

for version in "${ojsversions[@]}"; do
    for server in "${webservers[@]}"; do
        for php in "${phpversions[@]}"; do
            # We don't want all the combinations, just existing folders:
            [ -f "$version/alpine/$server/$php/Dockerfile" ] || continue

            # Replace OJS_VERSION:
            sed -e "s!%%OJS_VERSION%%!$version!g" \
                "Dockerfile-alpine-$server-$php.template" \
                > "$version/alpine/$server/$php/Dockerfile"
            echo "[$server] $version: $php"
        done
    done	
done
