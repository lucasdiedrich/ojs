#!/bin/bash

version=3_1_2-0 

docker build -t local/ojs:"$version" .

sed -e "s!pkpofficial/$version!local/$version!g" \
       "docker-compose.yml" \
       > "docker-compose.yml"
