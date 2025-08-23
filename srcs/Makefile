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
	@echo "Self reminder : removing local volumes requires sudo rm -rf data/*"
	$(DOCKER_COMPOSE) down --volumes --remove-orphans
	docker system prune -af
	docker volume prune -f

re: fclean build up

secrets:
	@echo "Creating secrets directory..."
	@mkdir -p srcs/secrets
	@if [ ! -f ../../.secrets/mariadb/mariadb_user_password.txt ]; then \
		echo "Creating mariadb_user_password.txt..."; \
		openssl rand -base64 32 > ../../.secrets/mariadb/mariadb_user_password.txt; \
	fi
	@if [ ! -f ../../.secrets/mariadb_root_password.txt ]; then \
		echo "Creating mariadb_root_password.txt..."; \
		openssl rand -base64 32 > ../../.secrets/mariadb/mariadb_root_password.txt; \
	fi
	@if [ ! -f ../../.secrets/wordpress/wordpress_admin_password.txt ]; then \
		echo "Creating wordpress_admin_password.txt..."; \
		openssl rand -base64 32 > ../../.secrets/wordpress/wordpress_root_password.txt; \
	fi
	@if [ ! -f ../../.secrets/wordpress/wordpress_user_password.txt ]; then \
		echo "Creating wordpress_user_password.txt..."; \
		openssl rand -base64 32 > ../../.secrets/wordpress/wordpress_user_password.txt; \
	fi
	@if [ ! -f ../../.secrets/ftp/ftp_password.txt ]; then \
		echo "Creating ftp_password.txt..."; \
		openssl rand -base64 32 > ../../.secrets/ftp/ftp_password.txt; \
	fi
	@echo "Secrets created successfully!"

hosts:
	@echo "Adding domain to /etc/hosts..."
	@sudo grep -q "$(WORDPRESS_DOMAIN)" /etc/hosts || echo "127.0.0.1 $(WORDPRESS_DOMAIN)" | sudo tee -a /etc/hosts

init: secrets hosts build up
	@echo "Inception project initialized successfully!"
	@echo "Access wordpress at: https://$(DOMAIN)"
	@echo "Access wordpress admin panel at: https://$(DOMAIN)/admin"
	@echo "Access adminer at: https://$(DOMAIN)/adminer or https://$(DOMAIN)/adminer/index.php"
	@echo "Access grafana at: https://$(DOMAIN):3000"

.PHONY: all build up down restart logs status clean fclean re secrets hosts init
