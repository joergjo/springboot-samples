#!/bin/bash
curl -k \
    --header "Content-Type: application/json" \
    --request POST \
    --data '{"description":"configuration","details":"congratulations, you have set up JPA correctly!","done": "true"}' \
    ${1}

curl -k \
    --header "Content-Type: application/json" \
    --request POST \
    --data '{"description":"test","details":"check if this is working","done": "false"}'  \
    ${1}

curl -k \
    --header "Content-Type: application/json" \
    --request POST \
    --data '{"description":"demo","details":"show to friends and family","done": "false"}' \
    ${1}
        