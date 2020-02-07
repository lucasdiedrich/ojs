#!/bin/bash

docker build -t local/ojs:"3_1_2-1" .

sed -i "s!pkpofficial/ojs:!local/ojs:!g" \
       "docker-compose.yml"
