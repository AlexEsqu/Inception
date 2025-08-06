FROM alpine:latest

# Update package list and install required packages
RUN apk update && apk add --no-cache \
    openssh \
    git \
    vim \
    bash \
    sudo \
    shadow \
    xauth \
    xorg-server \
    curl \
    wget \
    gcompat \
    libstdc++ \
    tree \
    xclock \
    xeyes \
    ca-certificates

# Create root and set paswords
RUN --mount=type=secret,id=root_password \
    ROOT_PASSWORD=$(cat /run/secrets/root_password) && \
    echo "root:$ROOT_PASSWORD" | chpasswd

# Create user and set passwords and sudo using secrets
RUN --mount=type=secret,id=devuser_password \
    --mount=type=secret,id=devuser_name \
    DEVUSER_NAME=$(cat /run/secrets/devuser_name) && \
    DEVUSER_PASSWORD=$(cat /run/secrets/devuser_password) && \
    adduser -D -s /bin/bash $DEVUSER_NAME && \
    echo "$DEVUSER_NAME:$DEVUSER_PASSWORD" | chpasswd && \
    echo "$DEVUSER_NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install VS Code
RUN wget -O vscode.tar.gz "https://update.code.visualstudio.com/latest/linux-x64/stable" && \
    mkdir -p /opt/vscode && \
    tar -xzf vscode.tar.gz -C /opt/vscode --strip-components=1 && \
    rm vscode.tar.gz && \
    ln -s /opt/vscode/bin/code /usr/local/bin/code && \
    chmod +x /opt/vscode/bin/code

# Generate SSH host keys
RUN ssh-keygen -A

# Configure SSH daemon
RUN sed -i 's/#Port 22/Port 4242/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config && \
    sed -i 's/#X11DisplayOffset 10/X11DisplayOffset 10/' /etc/ssh/sshd_config && \
    sed -i 's/#X11UseLocalhost yes/X11UseLocalhost no/' /etc/ssh/sshd_config && \
    sed -i 's/#AddressFamily any/AddressFamily inet/' /etc/ssh/sshd_config && \
    sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/' /etc/ssh/sshd_config

RUN printf '%s\n' \
    "" \
    "" \
    " _ .-') _     ('-.        (\`-.               (\`-.   _   .-')" \
    "( (  OO) )  _(  OO)     _(OO  )_           _(OO  )_( '.( OO )_" \
    " \     .'_ (,------.,--(_/   ,. \      ,--(_/   ,. \,--.   ,--." \
    " ,\`'--..._) |  .---'\   \   /(__/      \   \   /(__/|   \`.'   |" \
    " |  |  \  ' |  |     \   \ /   /        \   \ /   / |         |" \
    " |  |   ' |(|  '--.   \   '   /,         \   '   /, |  |'.'|  |" \
    " |  |   / : |  .--'    \     /__)         \     /__)|  |   |  |" \
    " |  '--'  / |  \`---.    \   /              \   /    |  |   |  |" \
    " \`-------'  \`------'     \`-'                \`-'     \`--'   \`--'" \
    "" \
    "~~ Welcome to my super dev VM ! ~~" \
    "" \
    "SSH: ssh -X devuser@localhost -p 4243" \
    "VS Code: code --no-sandbox" \
    > /etc/motd

# Create directories and set permissions
RUN --mount=type=secret,id=devuser_name \
    DEVUSER_NAME=$(cat /run/secrets/devuser_name) && \
    mkdir -p /home/$DEVUSER_NAME/workspace \
             /home/$DEVUSER_NAME/.vscode-server \
             /home/$DEVUSER_NAME/.ssh \
             /tmp/.X11-unix \
             /etc/ssh/keys && \
    chown -R $DEVUSER_NAME:$DEVUSER_NAME /home/$DEVUSER_NAME && \
    chmod 700 /home/$DEVUSER_NAME/.ssh && \
    chmod 1777 /tmp/.X11-unix && \
    touch /home/$DEVUSER_NAME/.Xauthority && \
    chown $DEVUSER_NAME:$DEVUSER_NAME /home/$DEVUSER_NAME/.Xauthority

# Generate startup script
RUN --mount=type=secret,id=devuser_name \
    DEVUSER_NAME=$(cat /run/secrets/devuser_name) && \
    echo '#!/bin/bash' > /start.sh && \
    echo 'echo "🚀 Starting DevVM SSH daemon..."' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Create required directories' >> /start.sh && \
    echo 'mkdir -p /var/run/sshd' >> /start.sh && \
    echo 'mkdir -p /tmp/.X11-unix' >> /start.sh && \
    echo 'chmod 1777 /tmp/.X11-unix' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Show SSH config for debugging' >> /start.sh && \
    echo 'echo "📝 SSH Config:"' >> /start.sh && \
    echo 'grep -E "(Port|X11|AllowTcp)" /etc/ssh/sshd_config' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Start SSH daemon in foreground with debugging' >> /start.sh && \
    echo 'echo "✅ SSH daemon starting on port 4242..."' >> /start.sh && \
    echo '/usr/sbin/sshd -D -e' >> /start.sh && \
    chmod +x /start.sh

# Expose SSH port
EXPOSE 4242

# Start SSH daemon
CMD ["/start.sh"]
