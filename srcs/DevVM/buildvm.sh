#!/bin/bash

# Load environment variables from .env file
if [ -f ../.env ]; then
    echo ""
    echo "Loading configuration from .env file..."
    export $(grep -v '^#' ../.env | xargs)
else
    echo "Error: .env file not found!"
    exit 1
fi

echo ""
echo "Building DevVM Docker image with secure secrets..."
echo "👤 User: $DEVUSER_NAME"
echo "🔒 Password: $(echo $DEVUSER_PASSWORD | sed 's/./*/g')"
echo ""

# Create temporary directory for secrets
TEMP_DIR=$(mktemp -d)
echo "Using temporary secrets directory: $TEMP_DIR"

# Create secret files
echo -n "$DEVUSER_PASSWORD" > "$TEMP_DIR/devuser_password"
echo -n "$ROOT_PASSWORD" > "$TEMP_DIR/root_password"
echo -n "$DEVUSER_NAME" > "$TEMP_DIR/devuser_name"

# Set secure permissions on secret files
chmod 600 "$TEMP_DIR"/*

export DOCKER_BUILDKIT=1

# Build the DevVM Docker image
docker build \
    --secret id=devuser_password,src="$TEMP_DIR/devuser_password" \
    --secret id=root_password,src="$TEMP_DIR/root_password" \
    --secret id=devuser_name,src="$TEMP_DIR/devuser_name" \
    -t devvm_image \
    .

BUILD_EXIT_CODE=$?

echo ""
echo "Cleaning up temporary secret files..."
rm -rf "$TEMP_DIR"
echo ""

if [ $BUILD_EXIT_CODE -eq 0 ]; then
   echo "Build successful!"
else
    echo "Build failed!"
    exit 1
fi

