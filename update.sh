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
ojsVersions=( "$@" )

# Otherwise, all the existing versions will be recreated (recommened).
if [ ${#ojsVersions[@]} -eq 0 ]; then
	ojsVersions=( versions/* )
fi
ojsVersions=( "${ojsVersions[@]%/}" )

# MBR: Won't be better if we define the manually the versions?
#    ojsVersions=(   "3_1_2-0" \
#                    "3_1_2-1" \
#                    "3_1_2-2" \
#                    "3_1_2-3" \
#                    "3_1_2-4" )


# The OS, web servers and php versions that will be supported:
osVersions=( alpine )
webServers=( apache nginx )
phpVersions=( php5 php7 )

echo "Building Docker stacks for:"

for os in "${osVersions[@]}"; do
    for version in "${ojsVersions[@]}"; do
        for server in "${webServers[@]}"; do
            for php in "${phpVersions[@]}"; do
                # We don't want all the combinations, just existing folders:
                [ -f "$version/$os/$server/$php/Dockerfile" ] || continue
                # Replace OJS_VERSION in templates:
                sed -e "s!%%OJS_VERSION%%!$version!g" \
                    "templates/dockerFiles/Dockerfile-$os-$server-$php.template" \
                    > "$version/$os/$server/$php/Dockerfile"
                sed -e "s!%%OJS_VERSION%%!$version!g" \
                    "templates/dockerComposes/docker-compose-$server.template" \
                    > "$version/$os/$server/$php/docker-compose.yml"
		echo "$version: [$server] $php (over $os)"
            done
        done	
    done
done
