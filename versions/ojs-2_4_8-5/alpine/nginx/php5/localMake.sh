#!/bin/bash

docker build -t local/ojs:"ojs-2_4_8-5" .

sed -i "s!pkpofficial/ojs:!local/ojs:!g" \
       "docker-compose.yml"
