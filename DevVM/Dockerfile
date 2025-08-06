FROM alpine:3.18

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
    xeyes \
    firefox-esr \
    ca-certificates \
    pciutils \
    libx11 \
    gtk+3.0 \
    cairo \
    pango \
    fontconfig \
    mesa-gl \
    dbus \
    glib \
    ttf-dejavu \
    gcompat \
    libstdc++

# Install VS Code
RUN wget -O vscode.tar.gz "https://update.code.visualstudio.com/latest/linux-x64/stable" && \
    mkdir -p /opt/vscode && \
    tar -xzf vscode.tar.gz -C /opt/vscode --strip-components=1 && \
    rm vscode.tar.gz && \
    ln -s /opt/vscode/bin/code /usr/local/bin/code && \
    chmod +x /opt/vscode/bin/code

# Create root and set paswords
RUN --mount=type=secret,id=root_password \
    ROOT_PASSWORD=$(cat /run/secrets/root_password) && \
    echo "root:$ROOT_PASSWORD" | chpasswd

# Create user, set passwords, add to sudo
RUN --mount=type=secret,id=devuser_password \
    --mount=type=secret,id=devuser_name \
    DEVUSER_NAME=$(cat /run/secrets/devuser_name) && \
    DEVUSER_PASSWORD=$(cat /run/secrets/devuser_password) && \
    adduser -D -s /bin/bash $DEVUSER_NAME && \
    echo "$DEVUSER_NAME:$DEVUSER_PASSWORD" | chpasswd && \
    echo "$DEVUSER_NAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Generate SSH host keys
RUN ssh-keygen -A

# Configure SSH daemon
RUN sed -i 's/#Port 22/Port 4242/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config && \
    sed -i 's/#X11DisplayOffset 10/X11DisplayOffset 10/' /etc/ssh/sshd_config && \
    sed -i 's/#X11UseLocalhost yes/X11UseLocalhost yes/' /etc/ssh/sshd_config && \
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
    "I'm trying to keep it tidy in here so I prepared lighter versions:" \
    "Firefox: firefox-esr" \
    "VS Code: code --no-sandbox" \
    > /etc/motd

# Create directories and set permissions
RUN --mount=type=secret,id=devuser_name \
    DEVUSER_NAME=$(cat /run/secrets/devuser_name) && \
    mkdir -p /home/$DEVUSER_NAME/workspace \
             /home/$DEVUSER_NAME/.ssh \
             /etc/ssh/keys && \
    chown -R $DEVUSER_NAME:$DEVUSER_NAME /home/$DEVUSER_NAME && \
    chmod 700 /home/$DEVUSER_NAME/.ssh && \
    touch /home/$DEVUSER_NAME/.Xauthority && \
    chown $DEVUSER_NAME:$DEVUSER_NAME /home/$DEVUSER_NAME/.Xauthority

# Generate startup script
RUN --mount=type=secret,id=devuser_name \
    DEVUSER_NAME=$(cat /run/secrets/devuser_name) && \
    echo '#!/bin/bash' > /start.sh && \
    echo '/usr/sbin/sshd -D -e' >> /start.sh && \
    chmod +x /start.sh

# Expose SSH port
EXPOSE 4242

# Start SSH daemon
CMD ["/start.sh"]
