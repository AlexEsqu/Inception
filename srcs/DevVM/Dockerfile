FROM alpine:latest

# Update package list and install required packages
RUN apk update && apk add --no-cache \
    openssh \
    git \
    vim \
    bash \
    sudo \
    shadow

# Create a non-root user for SSH access
RUN adduser -D -s /bin/bash devuser && \
    echo "devuser:devpass" | chpasswd

# Add devuser to sudoers (optional, for admin tasks)
RUN echo "devuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Generate SSH host keys
RUN ssh-keygen -A

# Configure SSH daemon
RUN sed -i 's/#Port 22/Port 4242/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

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
    echo 'echo "Starting SSH daemon on port 4242..."' >> /start.sh && \
    echo 'echo "Connect with: ssh devuser@localhost -p 4243"' >> /start.sh && \
    echo 'echo "Default password: devpass"' >> /start.sh && \
    echo '/usr/sbin/sshd -D' >> /start.sh && \
    chmod +x /start.sh

# Expose SSH port
EXPOSE 4242

# Start SSH daemon
CMD ["/start.sh"]
