FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install packages including VS Code dependencies
RUN apt-get update && apt-get install -y \
    openssh-server \
    git \
    vim \
    bash \
    sudo \
    curl \
    wget \
    ca-certificates \
    xauth \
    x11-apps \
    software-properties-common \
    apt-transport-https \
    gpg \
    libasound2 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libgbm1 \
    libnss3 \
    libxss1 \
    libdrm2 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    && rm -rf /var/lib/apt/lists/*

# Create user
RUN useradd -m -s /bin/bash devuser && \
    echo "devuser:devpass" | chpasswd && \
    usermod -aG sudo devuser && \
    echo "devuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install VS Code
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
    apt-get update && \
    apt-get install -y code && \
    rm -rf /var/lib/apt/lists/*

# Configure SSH with X11 settings
RUN mkdir /var/run/sshd && \
    sed -i 's/#Port 22/Port 4242/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config && \
    sed -i 's/#X11DisplayOffset 10/X11DisplayOffset 10/' /etc/ssh/sshd_config && \
    sed -i 's/#X11UseLocalhost yes/X11UseLocalhost no/' /etc/ssh/sshd_config && \
    echo "X11UseLocalhost no" >> /etc/ssh/sshd_config

# Setup user environment
RUN mkdir -p /home/devuser/.ssh /home/devuser/workspace && \
    chown -R devuser:devuser /home/devuser && \
    chmod 700 /home/devuser/.ssh

# Vim config
RUN echo 'set number\nset autoindent\nset tabstop=4\nset shiftwidth=4\nset expandtab' > /home/devuser/.vimrc && \
    chown devuser:devuser /home/devuser/.vimrc

# Startup script
RUN echo '#!/bin/bash\necho "Development VM Ready!"\necho "SSH: ssh -X devuser@localhost -p 4243"\necho "Password: devpass"\necho "VS Code: code"\n/usr/sbin/sshd -D' > /start.sh && \
    chmod +x /start.sh

EXPOSE 4242
CMD ["/start.sh"]
