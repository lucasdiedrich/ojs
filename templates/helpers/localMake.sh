#!/bin/bash

version=%%OJS_VERSION%%

docker build -t local/ojs:"$version" .

sed -i "s!pkpofficial/$version!local/$version!g" \
       "docker-compose.yml"
