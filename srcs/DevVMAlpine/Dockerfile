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
    ca-certificates

# Create a non-root user for SSH access
RUN adduser -D -s /bin/bash devuser && \
    echo "devuser:devpass" | chpasswd

# Add devuser to sudoers (optional, for admin tasks)
RUN echo "devuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

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
    sed -i 's/#X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config && \
    sed -i 's/#X11DisplayOffset 10/X11DisplayOffset 10/' /etc/ssh/sshd_config && \
    sed -i 's/#X11UseLocalhost yes/X11UseLocalhost no/' /etc/ssh/sshd_config

# Create SSH directory for the user
RUN mkdir -p /home/devuser/.ssh && \
    chown devuser:devuser /home/devuser/.ssh && \
    chmod 700 /home/devuser/.ssh

# Create a working directory for the user
RUN mkdir -p /home/devuser/workspace && \
    chown devuser:devuser /home/devuser/workspace

# Set up vim configuration for better experience
RUN echo 'set number' > /home/devuser/.vimrc && \
    echo 'set autoindent' >> /home/devuser/.vimrc && \
    echo 'set tabstop=4' >> /home/devuser/.vimrc && \
    echo 'set shiftwidth=4' >> /home/devuser/.vimrc && \
    echo 'set expandtab' >> /home/devuser/.vimrc && \
    chown devuser:devuser /home/devuser/.vimrc

# Create startup script
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'echo "Development VM with VS Code Starting..."' >> /start.sh && \
    echo 'echo "SSH Connection: ssh -X devuser@localhost -p 4243"' >> /start.sh && \
    echo 'echo "Password: devpass"' >> /start.sh && \
    echo 'echo ""' >> /start.sh && \
    echo 'echo "To open VS Code with GUI:"' >> /start.sh && \
    echo 'echo "1. Connect with X11 forwarding: ssh -X devuser@localhost -p 4243"' >> /start.sh && \
    echo 'echo "2. Run: code"' >> /start.sh && \
    echo 'echo ""' >> /start.sh && \
    echo 'echo "Tools available: vim, git, code"' >> /start.sh && \
    echo '/usr/sbin/sshd -D' >> /start.sh && \
    chmod +x /start.sh

# Expose SSH port
EXPOSE 4242

# Start SSH daemon
CMD ["/start.sh"]
