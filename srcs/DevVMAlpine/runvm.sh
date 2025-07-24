#!/bin/bash

# Check if container already exists
if [ "$(docker ps -aq -f name=development_vm)" ]; then
    echo "Container 'development_vm' already exists."
    if [ "$(docker ps -q -f name=development_vm)" ]; then
        echo "Container is running."
    else
        echo "Starting existing container..."
        docker start development_vm
    fi
else
    echo "Creating and running new container..."
    docker run -d -p 4243:4242 --name development_vm devvm
fi

echo ""
echo "Container is running!"
echo "Connect via SSH with:"
echo "ssh devuser@localhost -p 4243"
echo "Password: devpass"
echo ""
echo "To stop: docker stop development_vm"
echo "To remove: docker rm development_vm"
