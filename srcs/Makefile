
COMPOSE_FILE = docker-compose.yml
PROJECT_NAME = inception
DOMAIN = mkling.42.fr
DOCKER_COMPOSE = docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME)

all: build up

build:
	@echo "Building Docker images..."
	$(DOCKER_COMPOSE) build

up:
	@echo "Starting services..."
	mkdir -p ${HOME}/data/mariadb ${HOME}/data/wordpress
	sudo chmod 777 ${HOME}/data/mariadb ${HOME}/data/wordpress
	$(DOCKER_COMPOSE) up -d

down:
	@echo "Stopping services..."
	$(DOCKER_COMPOSE) down

restart: down up

logs:
	$(DOCKER_COMPOSE) logs -f

status:
	$(DOCKER_COMPOSE) ps

clean:
	@echo "Cleaning up containers and networks..."
	$(DOCKER_COMPOSE) down --remove-orphans
	docker system prune -f

fclean:
	@echo "Full cleanup - removing containers, networks, volumes, and images..."
	$(DOCKER_COMPOSE) down --volumes --remove-orphans
	docker system prune -af
	docker volume prune -f

re: fclean build up

secrets:
	@echo "Creating secrets directory..."
	@mkdir -p srcs/secrets
	@if [ ! -f srcs/secrets/mysql_root_password.txt ]; then \
		echo "Creating mysql_root_password.txt..."; \
		openssl rand -base64 32 > srcs/secrets/mysql_root_password.txt; \
	fi
	@if [ ! -f srcs/secrets/mysql_password.txt ]; then \
		echo "Creating mysql_password.txt..."; \
		openssl rand -base64 32 > srcs/secrets/mysql_password.txt; \
	fi
	@if [ ! -f srcs/secrets/wordpress_admin_password.txt ]; then \
		echo "Creating wordpress_admin_password.txt..."; \
		openssl rand -base64 32 > srcs/secrets/wordpress_admin_password.txt; \
	fi
	@if [ ! -f srcs/secrets/wordpress_user_password.txt ]; then \
		echo "Creating wordpress_user_password.txt..."; \
		openssl rand -base64 32 > srcs/secrets/wordpress_user_password.txt; \
	fi
	@chmod 600 srcs/secrets/*.txt
	@echo "Secrets created successfully!"

hosts:
	@echo "Adding domain to /etc/hosts..."
	@sudo grep -q "$(DOMAIN)" /etc/hosts || echo "127.0.0.1 $(DOMAIN)" | sudo tee -a /etc/hosts

unhosts:
	@echo "Removing domain from /etc/hosts..."
	@sudo sed -i '/$(DOMAIN)/d' /etc/hosts

shell-nginx:
	$(DOCKER_COMPOSE) exec nginx /bin/sh

shell-wordpress:
	$(DOCKER_COMPOSE) exec wordpress /bin/bash

shell-mariadb:
	$(DOCKER_COMPOSE) exec mariadb /bin/bash

db-backup:
	@echo "Creating database backup..."
	@mkdir -p backups
	$(DOCKER_COMPOSE) exec mariadb mysqldump -u root -p$$(cat srcs/secrets/mysql_root_password.txt) --all-databases > backups/backup_$$(date +%Y%m%d_%H%M%S).sql

db-restore:
	@echo "Available backups:"
	@ls -la backups/*.sql 2>/dev/null || echo "No backups found"
	@echo "Usage: docker exec -i inception-mariadb-1 mysql -u root -p < backups/your_backup.sql"

health:
	@echo "Checking service health..."
	@$(DOCKER_COMPOSE) ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

stats:
	docker stats $$($(DOCKER_COMPOSE) ps -q)

init: secrets hosts build up
	@echo "Inception project initialized successfully!"
	@echo "Access your site at: https://$(DOMAIN)"

deploy: secrets hosts build
	@echo "Deploying to production..."
	$(DOCKER_COMPOSE) up -d --no-deps --build

debug:
	@echo "=== Docker Info ==="
	docker info | head -20
	@echo ""
	@echo "=== Network Info ==="
	docker network ls | grep $(PROJECT_NAME)
	@echo ""
	@echo "=== Volume Info ==="
	docker volume ls | grep $(PROJECT_NAME)
	@echo ""
	@echo "=== Service Status ==="
	$(MAKE) health

test:
	@echo "Testing NGINX connectivity..."
	@curl -k -s -o /dev/null -w "%{http_code}" https://$(DOMAIN) || echo "Failed to connect"
	@echo ""
	@echo "Testing internal connectivity..."
	$(DOCKER_COMPOSE) exec nginx ping -c 1 wordpress > /dev/null && echo "NGINX -> WordPress: OK" || echo "NGINX -> WordPress: FAILED"
	$(DOCKER_COMPOSE) exec wordpress ping -c 1 mariadb > /dev/null && echo "WordPress -> MariaDB: OK" || echo "WordPress -> MariaDB: FAILED"
