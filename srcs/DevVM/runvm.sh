#!/bin/bash

# Check if container already exists
if [ "$(docker ps -aq -f name=devvm)" ]; then
    echo "Container 'devvm' already exists."
    if [ "$(docker ps -q -f name=devvm)" ]; then
        echo "Container is running."
    else
        echo "Starting existing container..."
        docker start devvm
    fi
else
    echo "Creating and running new container..."
    # Allow X11 forwarding from Docker containers
    xhost +local:docker 2>/dev/null || echo "Warning: Could not run xhost command"
    docker run -d \
        -p 4243:4242 \
        --name devvm \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
        -v devvm_workspace:/home/devuser/workspace \
        devvm
fi

echo ""
echo "Container is running!"
echo "Connect via SSH with:"
echo "ssh devuser@localhost -p 4243"
echo "Password: devpass"
echo ""
echo "To stop: docker stop devvm"
echo "To remove: docker rm devvm"
