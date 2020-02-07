#!/bin/bash

docker build -t local/ojs:"master" .

sed -i "s!pkpofficial/ojs:!local/ojs:!g" \
       "docker-compose.yml"
