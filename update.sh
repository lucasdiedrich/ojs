#!/usr/bin/env bash

# ===============================================================================
#          FILE:  update.sh
#
#         USAGE:  update [<versionNum>]
#
#   DESCRIPTION:  A script to update the Dockerfiles and docker-composes.yml,
#                 based templates.
#
#    PARAMETERS:
#  <versionNum>:  (optional) The release version that you like to generate.
#                 If any, all the existing versions will be updated.
#  REQUIREMENTS:  ---
#     TODO/BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Dulip Withanage, David Cormier, Marc Bria.
#  ORGANIZATION:  Public Knowledge Project (PKP)
#       LICENSE:  GPL 3
#       CREATED:  30/01/2020 02:01:15 CEST
#       UPDATED:  04/02/2020 23:50:00 CEST
#      REVISION:  1.0
#===============================================================================

set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

# You can pass the specific version of the Dockerfile and
# the docker-compose.yml you like to recreate.
ojsVersions=( "$@" )

# Otherwise, all the versions for the existing folders will be recreated.
if [ ${#ojsVersions[@]} -eq 0 ]; then
	ojsVersions=( "versions/*" )
fi
ojsVersions=( "${ojsVersions[@]%/}" )

# MBR: Won't be better if we define manually the versions?
#    ojsVersions=(   "3_1_2-0" \
#                    "3_1_2-1" \
#                    "3_1_2-2" \
#                    "3_1_2-3" \
#                    "3_1_2-4" )


# The OS, web servers and php versions that will be supported:
osVersions=( alpine )
webServers=( apache nginx )
phpVersions=( php5 php7 )

printf "\nUpdating Docker stacks for: \n\n"

for ojs in "${ojsVersions[@]}"; do
    for os in "${osVersions[@]}"; do
        for server in "${webServers[@]}"; do
            for php in "${phpVersions[@]}"; do
                # We don't want all the combinations, just existing folders:
                [ -f "versions/$ojs/$os/$server/$php/Dockerfile" ] || continue
#                # Remove folder's prefix to get the version number:
                version=( "${ojs/'versions/'/}" )
                # Replace OJS_VERSION in templates:
                sed -e "s!%%OJS_VERSION%%!$version!g" \
                    "templates/dockerFiles/Dockerfile-$os-$server-$php.template" \
                    > "versions/$ojs/$os/$server/$php/Dockerfile"
                sed -e "s!%%OJS_VERSION%%!$version!g" \
                    "templates/dockerComposes/docker-compose-$server.template" \
                    > "versions/$ojs/$os/$server/$php/docker-compose.yml"
                echo "> $version: [$server] $php (over $os)"
            done
        done
    done
done
