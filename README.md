# Inception

A complete Docker-based infrastructure project featuring WordPress with multiple services including database, caching, monitoring, and file management.

## Overview

Inception is a containerized web infrastructure built with Docker and Docker Compose. It provides a fully functional WordPress environment with advanced features like Redis caching, FTP server, database administration tools, monitoring with Grafana, and static site generation with Hugo.

### Core Services

- **Nginx** - Reverse proxy and web server (port 443 - HTTPS)
- **MariaDB** - Relational database with persistent storage
- **WordPress** - PHP-FPM based WordPress installation
- **Redis** - In-memory data store for caching (port 6379)

### Bonus Services

- **Adminer** - Web-based database management tool (port 8080)
- **FTP** - File transfer protocol server (port 21)
- **Grafana** - System monitoring and visualization dashboard (port 3000)
- **Hugo** - Static site generator for content management (port 1313)

## 🚀 Quick Start

### Prerequisites

- Docker Engine (latest version)
- Docker Compose
- Linux/macOS (or WSL2 on Windows)
- `sudo` access (for hosts file modification) / a VM
- OpenSSL (for certificate generation)

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd Inception
   ```

2. **Initialize the project (one-time setup):**
   ```bash
   cd srcs
   make init
   ```

   This command will:
   - Prompt you to generate required secrets (.secrets directory)
   - Add the domain to `/etc/hosts`
   - Build all Docker images
   - Start all containers

3. **Access the services:**

   | Service | URL | Default Access |
   |---------|-----|-----------------|
   | WordPress | https://mkling.42.fr | Admin dashboard at `/wp-admin` |
   | Adminer | http://localhost:8080 | Database management |
   | Grafana | http://localhost:3000 | Monitoring dashboard |
   | Hugo | http://localhost:1313 | Static site preview |
   | FTP | ftp://localhost:21 | File transfer |
   | Redis | localhost:6379 | In-memory cache |

## Setup Instructions

### 1. **Create Configuration Files**

Before starting, ensure you have:
- `.env` file with environment variables (create in `srcs/` directory)
- Proper domain configuration in docker-compose.yml

### 2. **Generate Secrets**

The `createsecrets.sh` script creates sensitive credentials:
```bash
make secrets
```

This promts you to input:
- MariaDB root password
- MariaDB user password
- WordPress admin password
- WordPress user password
- FTP user password

### 3. **Configure Hosts File**

Add your domain to the system hosts file:
```bash
make hosts
```

### 4. **Build and Start Services**

```bash
make build
make up
```

Or use the combined command:
```bash
make all
```

## Available Commands

### Build & Deployment

- `make all` - Build and start all services
- `make build` - Build all Docker images
- `make up` - Start all containers
- `make down` - Stop all containers
- `make restart` - Restart all services (down + up)

### Maintenance

- `make logs` - View container logs in real-time
- `make status` - Display container status
- `make clean` - Remove containers and networks, clean up unused resources
- `make fclean` - Full cleanup including volumes and images
- `make re` - Complete rebuild (fclean → build → up)

### Configuration

- `make init` - Complete initialization (secrets, hosts, build, start)
- `make secrets` - Generate required secret files
- `make hosts` - Add domain to /etc/hosts file

## Project Structure

```
srcs/
├── docker-compose.yml          # Service orchestration configuration
├── Makefile                     # Build and deployment commands
├── createsecrets.sh            # Secrets generation script
├── .env                        # Environment variables
├── requirements/
│   ├── nginx/                  # Web server configuration
│   ├── mariadb/                # Database configuration
│   └── wordpress/              # WordPress setup
└── bonus/
    ├── redis/                  # Caching layer
    ├── ftp/                    # File transfer server
    ├── adminer/                # Database UI
    ├── grafana/                # Monitoring
    └── hugo/                   # Static site generator

data/                          # Persistent data storage
├── wordpress/                 # WordPress files and uploads
└── mariadb/                   # Database files
```

## Security Features

- **SSL/TLS Encryption** - HTTPS-only communication via Nginx
- **Secrets Management** - Passwords stored in Docker secrets
- **Health Checks** - All services include health verification
- **Network Isolation** - Services communicate through internal bridge network
- **Restart Policies** - Automatic container recovery

## Data Persistence

The project uses named volumes with bind mounts for persistent data:

- **wordpress_data** - WordPress installation and user uploads
  - Location: `${HOME}/data/wordpress`
- **mariadb_data** - MariaDB databases
  - Location: `${HOME}/data/mariadb`
- **redis_data** - Redis persistent storage
- **adminer_data** - Adminer configuration

Data is preserved even after container removal (unless using `make fclean`).

## Health Checks

Each service includes health checks to ensure proper operation:

- **Nginx** - HTTPS endpoint verification
- **MariaDB** - MySQL ping test
- **WordPress** - PHP-FPM syntax validation
- **Redis** - Redis CLI ping test
- **FTP** - Port connectivity test
- **Adminer** - PHP-FPM syntax validation

View health status:
```bash
make status
```

## Monitoring and Logs

### View Real-Time Logs

```bash
make logs
```

### View Specific Service Logs

```bash
docker compose -f srcs/docker-compose.yml logs -f <service_name>
```

Examples:
```bash
docker compose -f srcs/docker-compose.yml logs -f nginx
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f mariadb
```

### Monitor with Grafana

Access Grafana at `http://localhost:3000` for system metrics and monitoring dashboards.

## Cleanup

### Remove Containers and Networks

```bash
make clean
```

### Full System Cleanup (includes volumes and images)

```bash
make fclean
```

**Note:** After `fclean`, you'll need to manually remove persistent data:
```bash
sudo rm -rf ~/data/*
```

## File Descriptions

### Core Configuration Files

- **docker-compose.yml** - Defines all services, volumes, networks, and environment configuration
- **Makefile** - Provides convenient commands for common operations
- **createsecrets.sh** - Generates random passwords and stores them securely
- **.env** - Environment variables for service configuration

### Service Dockerfiles

Each service has its own Dockerfile with specific configurations:
- `requirements/nginx/Dockerfile` - Nginx web server setup
- `requirements/wordpress/Dockerfile` - WordPress with PHP-FPM
- `requirements/mariadb/Dockerfile` - MariaDB database
- `bonus/redis/Dockerfile` - Redis caching layer
- `bonus/ftp/Dockerfile` - FTP server setup
- `bonus/adminer/Dockerfile` - Database management UI
- `bonus/grafana/Dockerfile` - Monitoring dashboard
- `bonus/hugo/Dockerfile` - Static site generator

## Accessing Services

### WordPress Admin Panel
- URL: https://mkling.42.fr/wp-admin
- Username: From your .env WP_ADMIN_USER
- Password: From secrets/wordpress/wordpress_root_password.txt

### Database (Adminer)
- URL: http://localhost:8080
- Server: mariadb
- Username: From your .env MYSQL_USER
- Password: From secrets/mariadb/mariadb_user_password.txt

### Grafana Dashboards
- URL: http://localhost:3000
- Default credentials: Check Grafana documentation

### FTP Client
- Host: localhost:21
- Username: From your .env FTP_USER
- Password: From secrets/ftp/ftp_password.txt

### Redis CLI
```bash
docker exec -it redis redis-cli
```
