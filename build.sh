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
#  REQUIREMENTS:  mapfile
#     TODO/BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Dulip Withanage, David Cormier, Marc Bria.
#  ORGANIZATION:  Public Knowledge Project (PKP)
#       LICENSE:  GPL 3
#       CREATED:  04/02/2020 23:50:15 CEST
#       UPDATED:  07/03/2020 01:06:25 CEST
#      REVISION:  1.1
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
	mapfile -t ojsVersions < versions.list

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

# All the OJS versions:
ojsVersions=( "${ojsVersions[@]%/}" )

# All the OS:
osVersions=( 'alpine' )

# All the Webservers:
webServers=(  'apache' )
# webServers=(  'apache' 'nginx' )

# All PHP versions:
phpVersions=( 'php5' 'php7' 'php73' )
# phpVersions=( 'php5' 'php7' 'php73' )

# PHP support for each ojs version:
php5=(  'ojs-2_0_0-0' \
		'ojs-2_0_1-0' \
		'ojs-2_0_2-0' \
		'ojs-2_0_2-1' \
		'ojs-2_1_0-0' \
		'ojs-2_1_0-1' \
		'ojs-2_1_1-0' \
		'ojs-2_1_1rc4' \
		'ojs-2_1b' \
		'ojs-2_2_0-0' \
		'ojs-2_2_0-b1' \
		'ojs-2_2_0-b2' \
		'ojs-2_2_1-0' \
		'ojs-2_2_1-b1' \
		'ojs-2_2_2-0' \
		'ojs-2_2_3-0' \
		'ojs-2_2_3-0rc1'	\
		'ojs-2_2_4-0' \
		'ojs-2_3_0-0' \
		'ojs-2_3_0-0rc1'	\
		'ojs-2_3_1-0' \
		'ojs-2_3_1-1' \
		'ojs-2_3_1-2' \
		'ojs-2_3_2-0' \
		'ojs-2_3_2-1' \
		'ojs-2_3_3-0' \
		'ojs-2_3_3-1' \
		'ojs-2_3_3-2' \
		'ojs-2_3_3-3' \
		'ojs-2_3_4-0' \
		'ojs-2_3_5-0' \
		'ojs-2_3_6-0' \
		'ojs-2_3_7-0' \
		'ojs-2_3_8-0' \
		'ojs-2_4_0-0' \
		'ojs-2_4_1-0' \
		'ojs-2_4_2-0' \
		'ojs-2_4_3-0' \
		'ojs-2_4_3rc1' \
		'ojs-2_4_4-0' \
		'ojs-2_4_4-1' \
		'ojs-2_4_5-0' \
		'ojs-2_4_6-0' \
		'ojs-2_4_7-0' \
		'ojs-2_4_7-1' \
		'ojs-2_4_8-0' \
		'ojs-2_4_8-1' \
		'ojs-2_4_8-2' \
		'ojs-2_4_8-3' \
		'ojs-2_4_8-4' \
		'ojs-2_4_8-5' \
		'ojs-2.3.2-1' \
		'ojs-3_0_2-0' \
		'ojs-3_0_1-0' \
		'ojs-3_0_0-0' \
		'ojs-3_0b1'   \
		'ojs-3_0a1' )

php7=(  'ojs-3_0a1'   \
		'ojs-3_0b1'   \
		'ojs-3_0_0-0' \
		'ojs-3_0_1-0' \
		'ojs-3_0_2-0' \
		'ojs-3_1_0-0' \
		'ojs-3_1_0-1' \
		'ojs-3_1_1-0' \
		'ojs-3_1_1-1' \
		'ojs-3_1_1-2' \
		'ojs-3_1_1-4' \
			'3_1_2-0' \
			'3_1_2-1' \
			'3_1_2-2' \
			'3_1_2-3' \
			'3_1_2-4' )

php73=( 'master'  \
		'3_2_0-0' \
		'3_1_2-4' )

printf "\n\nBUILDING OJS OFFICIAL DOCKER STACKS\n"
printf "===================================\n\n"

# Remove EVERY existing stack: Start from clean.
rm -Rf versions/*

for ojs in "${ojsVersions[@]}"; do
	for os in "${osVersions[@]}"; do
		for server in "${webServers[@]}"; do
			for php in "${phpVersions[@]}"; do

				# OJS tagging changed it syntax between versions.
				# To keep a single criteria, in Docker the syntax is
				# unified and we always use the version number (without prefix).
				# Ie: "ojs-3_1_1-4 will" be tagged as "3_1_1-4"
				ojsNum=${ojs#"ojs-"}

				build=0
				case $php in
					php5 )
						[[ " ${php5[@]} " =~ " ${ojs} " ]] && build=1
					;;
					php7 )
						[[ " ${php7[@]} " =~ " ${ojs} " ]] && build=1
					;;
					php72 )
						[[ " ${php72[@]} " =~ " ${ojs} " ]] && build=1
					;;
					php73 )
					    [[ " ${php73[@]} " =~ " ${ojs} " ]] && build=1
					;;
				esac

				if [ ${build} -eq 1 ]; then

					if [[ -d "templates/webServers/$server/$php" ]]; then
						# Build the folder structure:
						mkdir -p "versions/$ojsNum/$os/$server/$php/root"
						cp -a "templates/webServers/$server/$php" "versions/$ojsNum/$os/$server"
						cp -a "templates/common/ojs/usr" "versions/$ojsNum/$os/$server/$php/root"
						cp "templates/common/env" "versions/$ojsNum/$os/$server/$php/.env"
						cp "templates/exclude.list" "versions/$ojsNum/$os/$server/$php/exclude.list"

						# Create persistent folders (with right permissions):
						mkdir -p "versions/$ojsNum/$os/$server/$php/volumes/private"
						echo "Folder to keep persistent your PRIVATE files \
							  (uncomment the volume in docker-compose.yml)" \
							  > "versions/$ojsNum/$os/$server/$php/volumes/private/README"
						mkdir -p "versions/$ojsNum/$os/$server/$php/volumes/public"
						echo "Folder to keep persistent your PUBLIC files \
							  (uncomment the volume docker-compose.yml)" \
							  > "versions/$ojsNum/$os/$server/$php/volumes/public/README"
						mkdir -p "versions/$ojsNum/$os/$server/$php/volumes/logs"
						echo "Folder to map and keep persistent your web logs \
							  (uncomment the volume docker-compose.yml)" \
							  > "versions/$ojsNum/$os/$server/$php/volumes/logs/README"
						chown 100:101 "versions/$ojsNum/$os/$server/$php/volumes" -Rf
						mkdir -p "versions/$ojsNum/$os/$server/$php/volumes/db"
						echo "Folder to keep persistent your DB files \
							  (uncomment the volume docker-compose.yml)" \
							  > "versions/$ojsNum/$os/$server/$php/volumes/db/README"
						chown 999:999 "versions/$ojsNum/$os/$server/$php/volumes/db" -Rf

						# Here we can uncomment the volumes in docker-compose
						# but probably is better keeping different docker-composes
						# for production or development... so "do nothing".

						# Variable substitutions in Dockerfile and docker-compose.yml:
						sed -e "s!%%OJS_VERSION%%!$ojs!g" \
						"templates/dockerFiles/Dockerfile-$os-$server-$php.template" \
						> "versions/$ojsNum/$os/$server/$php/Dockerfile"

						# docker-compose with remote images
						sed -e "s!%%OJS_VERSION%%!$ojsNum!g" -e "s!%%OJS_IMAGE%%!pkpofficial/ojs!g" \
						    "templates/dockerComposes/docker-compose-$server.template" \
						    > "versions/$ojsNum/$os/$server/$php/docker-compose.yml"
						# docker-compose with local images
						cp "versions/$ojsNum/$os/$server/$php/docker-compose.yml" \
							"versions/$ojsNum/$os/$server/$php/docker-compose-local.yml" -a
						sed -i "s!pkpofficial/ojs:!local/ojs:!g" \
							"versions/$ojsNum/$os/$server/$php/docker-compose-local.yml"
						printf "BUILT:    $ojsNum: [$server] $php (over $os)\n"
					else
						printf "\nERROR when building $ojs: [$server] $php (over $os)\n"
						printf "Missing template for: templates/webservers/$server/$php\n\n"
						exit 0
					fi
				else
					printf "DISABLED: $ojsNum: [$server] $php (over $os)\n"
				fi
			done
		done
		printf "\n"
	done
done
