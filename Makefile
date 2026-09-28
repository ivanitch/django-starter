.PHONY: help ps up down restart logs shell bash migrate startapp collectstatic tailwind destroy prod-deploy prod-logs prod-shell db-backup

# Environment Variables
DC = UID=$$(id -u) GID=$$(id -g) docker compose
TAG ?= $$(git rev-parse --short HEAD 2>/dev/null || echo "latest")
DC_PROD = TAG=$(TAG) docker compose -f docker-compose.prod.yml --env-file .env.prod
EXEC = $(DC) exec web
LOGS = $(DC) logs -f

help:
	@echo "=========================================================="
	@echo "           Django Starter Kit - Makefile                  "
	@echo "=========================================================="
	@echo "LOCAL COMMANDS:"
	@echo "  make up               - Build & start local dev environment"
	@echo "  make down             - Stop local environment"
	@echo "  make logs             - View logs"
	@echo "  make shell            - Access Django shell"
	@echo "  make bash             - Access container bash"
	@echo "  make migrate          - Apply migrations"
	@echo "  make startapp name=X  - Create a new application in the apps/ folder (example: make startapp name=users)"
	@echo "  make destroy          - Destroy local containers & volumes"
	@echo "----------------------------------------------------------"
	@echo "PRODUCTION COMMANDS:"
	@echo "  make prod-deploy      - Zero-downtime deploy on server"
	@echo "  make prod-logs        - View production logs"
	@echo "  make prod-shell       - Access production Django shell"
	@echo "  make db-backup        - Create a database backup (prod)"
	@echo "=========================================================="

# ==========================================
# LOCAL DEVELOPMENT
# ==========================================
ps:
	$(DC) ps

up:
	@mkdir -p media staticfiles backups
	$(DC) up -d --build

down:
	$(DC) down

restart:
	$(DC) restart

logs:
	$(LOGS) web tailwind

shell:
	$(EXEC) python manage.py shell

bash:
	$(EXEC) bash

migrate:
	$(EXEC) python manage.py migrate

startapp:
	@if [ -z "$(name)" ]; then \
		echo "Used: make startapp name=<app_name>"; \
		exit 1; \
	fi
	$(EXEC) python manage.py startapp $(name) apps/$(name)

makemigrations:
	$(EXEC) python manage.py makemigrations

collectstatic:
	$(EXEC) python manage.py collectstatic --noinput

tailwind:
	$(EXEC) python manage.py tailwind start

destroy:
	@if [ -f .env.prod ]; then \
		echo "ERROR: .env.prod found. Prevented destroy in production!"; exit 1; \
	fi
	$(DC) down -v --remove-orphans

# ==========================================
# PRODUCTION COMMANDS
# ==========================================
prod-deploy:
	@echo "Deploying version $(TAG)..."
	$(DC_PROD) build
	$(DC_PROD) up -d db redis
	$(DC_PROD) run --rm web python manage.py migrate --noinput
	$(DC_PROD) run --rm web python manage.py collectstatic --noinput
	$(DC_PROD) up -d --remove-orphans
	@echo "Deploy successful!"

prod-logs:
	$(DC_PROD) logs -f web nginx

prod-shell:
	$(DC_PROD) exec web python manage.py shell

prod-bash:
	$(DC_PROD) exec web bash

db-backup:
	@mkdir -p backups
	$(DC_PROD) exec -T db sh -c 'pg_dump -U "$$POSTGRES_USER" -d "$$POSTGRES_DB" -F c' > backups/prod_backup_$$(date +%Y%m%d_%H%M%S).dump
	@echo "Backup saved in backups/ folder."
