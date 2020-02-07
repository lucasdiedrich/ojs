#!/bin/bash

docker build -t local/ojs:"3_2_0-0" .

sed -i "s!pkpofficial/ojs:!local/ojs:!g" \
       "docker-compose.yml"
