NAME = inception
DATA_PATH = /home/sfellahi/data

all: dirs build up

dirs:
	sudo mkdir -p $(DATA_PATH)/mariadb
	sudo mkdir -p $(DATA_PATH)/wordpress

build: dirs
	docker compose -f srcs/docker-compose.yml build

up: dirs
	docker compose -f srcs/docker-compose.yml up -d

down:
	docker compose -f srcs/docker-compose.yml down

clean: down
	docker system prune -af
	docker volume prune -f

fclean: clean
	docker rmi $$(docker images -q) 2>/dev/null || true
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true
	sudo rm -rf $(DATA_PATH)

re: fclean all

.PHONY: all dirs build up down clean fclean re