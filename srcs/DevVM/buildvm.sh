#!/bin/bash

# Build the DevVM Docker image
echo "Building DevVM Docker image..."
docker build -t devvm ./DevVM

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo ""
    echo "To run the container, use:"
    echo "docker run -d -p 4243:4242 --name development_vm devvm"
    echo ""
    echo "To connect via SSH:"
    echo "ssh devuser@localhost -p 4243"
    echo "Password: devpass"
    echo ""
    echo "To stop the container:"
    echo "docker stop development_vm"
    echo ""
    echo "To remove the container:"
    echo "docker rm development_vm"
else
    echo "Build failed!"
    exit 1
fi

