#!/bin/bash

# Create secrets directory
mkdir -p .secrets
mkdir -p .secrets/devvm

# Interactive input for secrets
read -p "Enter username [devuser]: " username
username=${username:-devuser}

read -s -p "Enter user password [devpass]: " userpass
userpass=${userpass:-devpass}
echo ""

read -s -p "Enter root password [rootpass]: " rootpass
rootpass=${rootpass:-rootpass}
echo ""

echo "$username" > .secrets/devvm/devuser_name
echo "$userpass" > .secrets/devvm/devuser_password
echo "$rootpass" > .secrets/devvm/root_password

# # Set secure permissions
# chmod 600 .secrets/*
# chmod 700 .secrets

echo ""
echo "Secrets created successfully!"
echo "Files created in .secrets/ directory"

# Add to .gitignore if it exists
if [ -f .gitignore ]; then
    if ! grep -q ".secrets" .gitignore; then
        echo ".secrets/" >> .gitignore
        echo "📝 Added .secrets/ to .gitignore"
    fi
else
    echo ".secrets/" > .gitignore
    echo "📝 Created .gitignore with .secrets/"
fi
