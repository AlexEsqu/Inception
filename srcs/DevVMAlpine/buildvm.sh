#!/bin/bash

# Build the DevVM Docker image
echo "Building DevVM Docker image..."
docker build -t devvm ./DevVM

if [ $? -eq 0 ]; then
    echo "Build successful!"
    echo ""
    echo "To run the container, use:"
    echo "docker run -d -p 4243:4242 --name devvm devvm"
    echo "or ./DevVM/runvm.sh"
else
    echo "Build failed!"
    exit 1
fi

