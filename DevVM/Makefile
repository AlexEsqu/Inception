
#############################
#		VARIABLES			#
#############################

NAME			= Inception
SSH_HOST		= [localhost]:4243

#############################
#		RECIPES				#
#############################

all:
	@echo "Starting DevVM with Docker Compose..."
	@export DISPLAY=$$(echo $$DISPLAY) && \
	DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 docker-compose up -d --build

build:
	@echo "Building DevVM..."
	DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 docker-compose build

up:
	@echo "Starting DevVM..."
	DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 docker-compose up -d

down:
	@echo "Stopping DevVM..."
	DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 docker-compose down

clean: cleanup_ssh
	@echo "Cleaning DevVM containers..."
	docker-compose down --remove-orphans

clean_images: cleanup_ssh
	@echo "Removing DevVM containers and images..."
	docker-compose down --rmi all --remove-orphans

fclean: cleanup_ssh
	@echo "Complete cleanup - removing containers, networks, images, and volumes..."
	docker-compose down -v --rmi all --remove-orphans
	@echo "Pruning unused Docker resources..."
	docker system prune -f

fclean_all: cleanup_ssh
	@echo "Nuclear cleanup - removing EVERYTHING..."
	docker-compose down -v --rmi all --remove-orphans
	docker system prune -af --volumes
	@echo "Complete cleanup finished!"

rebuild: cleanup_ssh
	@echo "Rebuilding DevVM from scratch..."
	docker-compose down --rmi all
	docker-compose build --no-cache
	docker-compose up -d

status:
	@echo "DevVM Status:"
	docker-compose ps
	@echo ""
	@echo "Connect with: ssh -X devuser@localhost -p 4243"

cleanup_ssh:
	@echo "Cleaning up SSH known hosts..."
	@if [ -f "$$HOME/.ssh/known_hosts" ]; then \
		ssh-keygen -f "$$HOME/.ssh/known_hosts" -R "$(SSH_HOST)" 2>/dev/null || true; \
		echo "SSH known hosts cleaned"; \
	fi

setup_x11:
	@chmod +x setup_x11.sh
	@./setup_x11.sh

.PHONY: all build up down clean clean_images fclean fclean_all rebuild status cleanup_ssh
