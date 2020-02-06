#!/bin/bash

version=master 

docker build -t local/ojs:"$version" .

sed -e "s!pkpofficial/$version!local/$version!g" \
       "docker-compose.yml" \
       > "docker-compose.yml"
