#!/bin/bash

docker build -t local/ojs:"%%OJS_VERSION%%" .

sed -i "s!pkpofficial/ojs:!local/ojs:!g" \
       "docker-compose.yml"
