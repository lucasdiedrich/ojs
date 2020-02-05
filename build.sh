#!/usr/bin/env bash

# ===============================================================================
#          FILE:  build.sh
#
#         USAGE:  build [<versionNum>]
#
#   DESCRIPTION:  A script to generate the folder structure and files to
#									run and keep an ojs stack.
#
#    PARAMETERS:
#  <versionNum>:  (optional) The release version that you like to generate.
#                 If any, all the existing versions will be created.
#  REQUIREMENTS:  sed
#     TODO/BUGS:  Parameters are positional (I don't like getopt or getopts)
#         NOTES:  ---
#        AUTHOR:  Dulip Withanage, David Cormier, Marc Bria.
#  ORGANIZATION:  Public Knowledge Project (PKP)
#       LICENSE:  GPL 3
#       CREATED:  04/02/2020 23:50:15 CEST
#       UPDATED:  04/02/2020 23:50:15 CEST
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
		ojsVersions=(   "3_1_1-4" \
		                "3_1_2-0" \
		                "3_1_2-1" \
		                "3_1_2-2" \
		                "3_1_2-3" \
		                "3_1_2-4" )
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
osVersions=( alpine )
webServers=( apache nginx )
phpVersions=( php5 php7 )

printf "\nBuilding Docker stacks for: $ojsVersions\n"
printf "===================================\n\n"

for versionNum in "${ojsVersions[@]}"; do
		for os in "${osVersions[@]}"; do
        for server in "${webServers[@]}"; do
            for php in "${phpVersions[@]}"; do
                # If exists, remove the existing version folder:
								# MBR: Better remove or just overwrite it's content?
                rm -Rf "versions/$versionNum"

								if [[ -d "templates/webServers/$server/$php" ]]; then
									  # Build the folder structure:
										mkdir -p "versions/$versionNum/$os/$server/$php/root"
										cp -a "templates/webServers/$server/$php" "versions/$versionNum/$os/$server"
										cp -a "templates/common/ojs" "versions/$versionNum/$os/$server/$php/root"
										cp "templates/common/env" "versions/$versionNum/$os/$server/$php/.env"
										# Variable substitutions in Dockerfile and docker-compose.yml:
										sed -e "s!%%OJS_VERSION%%!$versionNum!g" \
		                    "templates/dockerFiles/Dockerfile-$os-$server-$php.template" \
		                    > "versions/$versionNum/$os/$server/$php/Dockerfile"
		                sed -e "s!%%OJS_VERSION%%!$versionNum!g" \
		                    "templates/dockerComposes/docker-compose-$server.template" \
		                    > "versions/$versionNum/$os/$server/$php/docker-compose.yml"
										printf "> $versionNum: [$server] $php (over $os)\n"
								else
  									printf "\nERROR when building $versionNum: [$server] $php (over $os)\n"
									  printf "Missing template for: templates/webservers/$server/$php\n\n"
										exit 0
								fi
            done
        done
    done
done
