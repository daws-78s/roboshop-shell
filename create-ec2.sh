#!/bin/bash

instances=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "web")


for name in ${instances[@]}; do
    echo "Creating instance for: $name"
done