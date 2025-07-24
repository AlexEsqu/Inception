#!/bin/bash

echo ""
echo "-- Cleaning up DevVM containers and images --"
echo ""

# Stop and remove containers with 'devvm_image' in the name
echo "Stopping and removing DevVM containers..."
CONTAINERS=$(docker ps -aq --filter "name=devvm_image" --filter "name=alex_vm")
if [ ! -z "$CONTAINERS" ]; then
    echo "Found containers: $CONTAINERS"
    docker stop $CONTAINERS 2>/dev/null
    docker rm $CONTAINERS 2>/dev/null
    echo "Containers removed"
else
    echo "No DevVM containers found"
fi
echo ""

# Remove images with 'devvm_image' in the name or tag
echo "Removing DevVM images..."
IMAGES=$(docker images --filter "reference=*devvm_image*" -q)
if [ ! -z "$IMAGES" ]; then
    echo "Found images: $IMAGES"
    docker rmi -f $IMAGES 2>/dev/null
    echo "Images removed"
else
    echo "No DevVM images found"
fi
echo ""

# Remove any dangling images
echo "Removing dangling images..."
DANGLING=$(docker images -f "dangling=true" -q)
if [ ! -z "$DANGLING" ]; then
    docker rmi $DANGLING 2>/dev/null
    echo "Dangling images removed"
else
    echo "No dangling images found"
fi
echo ""

# # Remove DevVM volumes (optional)
# echo "Checking for DevVM volumes..."
# VOLUMES=$(docker volume ls --filter "name=devvm_image" -q)
# if [ ! -z "$VOLUMES" ]; then
#     echo "Found volumes: $VOLUMES"
#     read -p "Do you want to remove DevVM volumes? This will delete all data! (y/N): " -n 1 -r
#     echo ""
#     if [[ $REPLY =~ ^[Yy]$ ]]; then
#         docker volume rm $VOLUMES 2>/dev/null
#         echo "Volumes removed"
#     else
#         echo "Volumes kept"
#     fi
# else
#     echo "No DevVM volumes found"
# fi
# echo ""

# Clean up SSH known hosts entry
echo "Cleaning up SSH known hosts..."
if [ -f "$HOME/.ssh/known_hosts" ]; then
    ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:4243" 2>/dev/null
    echo "SSH known hosts cleaned"
else
    echo "No SSH known hosts file found"
fi

echo ""
echo "DevVM cleanup complete!"
