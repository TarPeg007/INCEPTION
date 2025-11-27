NAME = inception
# Path for data volumes - Make sure your .env file matches this path!
DATA_PATH = /home/saad/data

all: dirs build up

dirs:
	mkdir -p $(DATA_PATH)/mariadb
	mkdir -p $(DATA_PATH)/wordpress

build: dirs
	docker compose -f docker-compose.yml build

up: dirs
	docker compose -f docker-compose.yml up 
down:
	docker compose -f docker-compose.yml down

clean: down
	docker system prune -af
	docker volume prune -f

fclean: clean
	docker rmi $$(docker images -q) 2>/dev/null || true
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true
	# Optional: Remove data directories (Be careful with this!)
	# sudo rm -rf $(DATA_PATH)

re: fclean all

.PHONY: all dirs build up down clean fclean re