#!/usr/bin/env bash

# ===============================================================================
#          FILE:  build.sh
#
#         USAGE:  build [<ojs>]
#
#   DESCRIPTION:  A script to generate the folder structure and required
#                 files to run a full ojs stack.
#
#    PARAMETERS:
#  <ojs>:  (optional) The release version that you like to generate.
#                 If any, all the existing versions will be created.
#  REQUIREMENTS:  ---
#     TODO/BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Dulip Withanage, David Cormier, Marc Bria.
#  ORGANIZATION:  Public Knowledge Project (PKP)
#       LICENSE:  GPL 3
#       CREATED:  04/02/2020 23:50:15 CEST
#       UPDATED:  05/02/2020 19:52:25 CEST
#      REVISION:  1.0
#===============================================================================

set -Eeuo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

# You can pass the specific version of the stack you like to create.
ojsVersions=( "$@" )

# Otherwise, all the versions for the existing folders will be recreated.
if [ ${#ojsVersions[@]} -eq 0 ]; then
    printf "Warning: This action is destructive. ALL former version folders will be removed.\n"
    [[ "$(read -e -p 'Are you sure you want to continue? [y/N]> '; echo $REPLY)" == [Yy]* ]]

    # Warning: Versions need to fit with OJS tag names:
    ojsVersions=(        'master' \
                    'ojs-2_4_8-5' \
                    'ojs-3_1_1-4' \
                        '3_1_2-0' \
                        '3_1_2-1' \
                        '3_1_2-2' \
                        '3_1_2-3' \
                        '3_1_2-4' )
else
    if [ ${#ojsVersions[@]} -eq 1 ]; then
        if [[ -d "versions/$ojsVersions" ]]; then
            printf "Warning: This action is destructive. Existing version $ojsVersions will be removed.\n"
            [[ "$(read -e -p 'Are you sure you want to continue? [y/N]> '; echo $REPLY)" == [Yy]* ]]
        fi
        mkdir -p "versions/$ojsVersions"
    else
        printf "Only one param is accepted.\n"
        exit 0
    fi
fi
ojsVersions=( "${ojsVersions[@]%/}" )

# The OS, web servers and php versions that will be supported:
osVersions=( 'alpine' )
webServers=( 'apache' 'nginx' )
phpVersions=( 'php5' 'php7' )

# PHP support:
php5=( 'ojs-2_4_8-5' 'ojs-3_1_1-4' )
php7=( 'ojs-3_1_1-4' '3_1_2-0' '3_1_2-1' '3_1_2-2' '3_1_2-3' '3_1_2-4' 'master')

printf "\n\nBUILDING OJS OFFICIAL DOCKER STACKS\n"
printf "===================================\n\n"

for ojs in "${ojsVersions[@]}"; do
    for os in "${osVersions[@]}"; do
        for server in "${webServers[@]}"; do
            for php in "${phpVersions[@]}"; do
                build=0
                case $php in
                    php5 )
                        [[ " ${php5[@]} " =~ " ${ojs} " ]] && build=1
                    ;;
                    php7 )
                        [[ " ${php7[@]} " =~ " ${ojs} " ]] && build=1
                    ;;
                esac

                # Remover EVERY existing stack: Start from clean.
                rm -Rf "versions/*"

                if [ ${build} -eq 1 ]; then

                    if [[ -d "templates/webServers/$server/$php" ]]; then
                        # Build the folder structure:
                        mkdir -p "versions/$ojs/$os/$server/$php/root"
                        cp -a "templates/webServers/$server/$php" "versions/$ojs/$os/$server"
                        cp -a "templates/common/ojs/usr" "versions/$ojs/$os/$server/$php/root"
                        cp "templates/common/env" "versions/$ojs/$os/$server/$php/.env"

                        # Variable substitutions in Dockerfile and docker-compose.yml:
                        sed -e "s!%%OJS_VERSION%%!$ojs!g" \
                        "templates/dockerFiles/Dockerfile-$os-$server-$php.template" \
                        > "versions/$ojs/$os/$server/$php/Dockerfile"
                        sed -e "s!%%OJS_VERSION%%!$ojs!g" \
                            "templates/dockerComposes/docker-compose-$server.template" \
                            > "versions/$ojs/$os/$server/$php/docker-compose.yml"
                        # Helper script to build and run containers locally:
                        sed -e "s!%%OJS_VERSION%%!$ojs!g" \
                        "templates/helpers/localMake.sh" \
                        > "versions/$ojs/$os/$server/$php/localMake.sh"
                        chmod +x "versions/$ojs/$os/$server/$php/localMake.sh"
                        printf "BUILT:    $ojs: [$server] $php (over $os)\n"
                    else
                        printf "\nERROR when building $ojs: [$server] $php (over $os)\n"
                        printf "Missing template for: templates/webservers/$server/$php\n\n"
                        exit 0
                    fi
                else
                    printf "DISABLED: $ojs: [$server] $php (over $os)\n"
                fi
            done
        done
        printf "\n"
    done
done
