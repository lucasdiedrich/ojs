#!/bin/bash

version=ojs-2_4_8-5 

docker build -t local/ojs:"$version" .

sed -e "s!pkpofficial/$version!local/$version!g" \
       "docker-compose.yml" \
       > "docker-compose.yml"
