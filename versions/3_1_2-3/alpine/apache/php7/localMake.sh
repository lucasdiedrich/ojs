#!/bin/bash

version=3_1_2-3

docker build -t local/ojs:"$version" .

sed -i "s!pkpofficial/$version!local/$version!g" \
       "docker-compose.yml"
