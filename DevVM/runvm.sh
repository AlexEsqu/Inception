#!/bin/bash

# Check if container already exists
if [ "$(docker ps -aq -f name=alex_vm)" ]; then
    echo "Container 'alex_vm' already exists."
    if [ "$(docker ps -q -f name=alex_vm)" ]; then
        echo "Container is already running."
    else
        echo "Starting existing container."
        docker start alex_vm
    fi
else
    echo "Creating and running new container..."
    docker run -d -p 4243:4242 --name alex_vm devvm_image
fi

echo "Connect via SSH with:"
echo "ssh devuser@localhost -p 4243"
echo "Reminder : VSCode is only accessible in --no-sandbox mode"
