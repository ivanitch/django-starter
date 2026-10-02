.PHONY: help ps build up down restart logs shell bash migrate makemigrations startapp collectstatic tailwind destroy prod-build prod-up prod-down prod-deploy prod-logs prod-shell prod-bash prod-migrate prod-collectstatic db-backup prod-db-backup prod-init-ssl

# ==========================================
# VARIABLES
# ==========================================
DC = UID=$$(id -u) GID=$$(id -g) docker compose
TAG ?= $$(git rev-parse --short HEAD 2>/dev/null || echo "latest")
DC_PROD = TAG=$(TAG) docker compose -f docker-compose.prod.yml --env-file .env.prod

EXEC = $(DC) exec web
LOGS = $(DC) logs -f

# Значения по умолчанию для логов (если переменная service не передана)
service ?= web tailwind
prod_service ?= web nginx

# ==========================================
# HELP MENU
# ==========================================
help:
	@echo "=========================================================="
	@echo "           Django Starter Kit - Makefile                  "
	@echo "=========================================================="
	@echo "LOCAL COMMANDS:"
	@echo "  make build              - Build local containers"
	@echo "  make up                 - Start local environment"
	@echo "  make down               - Stop local environment"
	@echo "  make restart            - Restart local environment"
	@echo "  make logs               - View logs (default: web tailwind)"
	@echo "  make logs service=X     - View specific logs (e.g., make logs service=\"web db\")"
	@echo "  make shell              - Access Django shell"
	@echo "  make bash               - Access container bash"
	@echo "  make migrate            - Apply migrations"
	@echo "  make makemigrations     - Generate new migrations"
	@echo "  make startapp name=X    - Create a new app (e.g., make startapp name=users)"
	@echo "  make db-backup          - Create a database backup (local)"
	@echo "  make destroy            - Destroy local containers & volumes"
	@echo "----------------------------------------------------------"
	@echo "PRODUCTION COMMANDS:"
	@echo "  make prod-build         - Build production images"
	@echo "  make prod-up            - Start production environment"
	@echo "  make prod-down          - Stop production environment"
	@echo "  make prod-migrate       - Apply migrations on production"
	@echo "  make prod-collectstatic - Run collectstatic on production"
	@echo "  make prod-deploy        - Full Zero-downtime deploy"
	@echo "  make prod-logs          - View prod logs (default: web nginx)"
	@echo "  make prod-shell         - Access production Django shell"
	@echo "  make prod-bash          - Access production bash"
	@echo "  make prod-db-backup     - Create a database backup (prod)"
	@echo "  make prod-init-ssl      - Initialize SSL certificates"
	@echo "=========================================================="

# ==========================================
# LOCAL DEVELOPMENT
# ==========================================
ps:
	$(DC) ps

build:
	$(DC) build

up:
	@mkdir -p media staticfiles backups
	$(DC) up -d

down:
	$(DC) down

restart:
	$(DC) restart

logs:
	$(LOGS) $(service)

shell:
	$(EXEC) python manage.py shell

bash:
	$(EXEC) bash

migrate:
	$(EXEC) python manage.py migrate

makemigrations:
	$(EXEC) python manage.py makemigrations

startapp:
	@if [ -z "$(name)" ]; then \
		echo "Used: make startapp name=<app_name>"; \
		exit 1; \
	fi
	$(EXEC) python manage.py startapp $(name) apps/$(name)

collectstatic:
	$(EXEC) python manage.py collectstatic --noinput

tailwind:
	$(EXEC) python manage.py tailwind start

db-backup:
	@mkdir -p backups
	$(DC) exec -T db sh -c 'pg_dump -U "$$POSTGRES_USER" -d "$$POSTGRES_DB" -F c' > backups/local_backup_$$(date +%Y%m%d_%H%M%S).dump
	@echo "Local backup saved in backups/ folder."

destroy:
	@if [ -f .env.prod ]; then \
		echo "ERROR: .env.prod found. Prevented destroy in production!"; exit 1; \
	fi
	$(DC) down -v --remove-orphans

# ==========================================
# PRODUCTION COMMANDS
# ==========================================
prod-build:
	$(DC_PROD) build

prod-up:
	$(DC_PROD) up -d

prod-down:
	$(DC_PROD) down

prod-migrate:
	$(DC_PROD) run --rm web python manage.py migrate --noinput

prod-collectstatic:
	$(DC_PROD) run --rm web python manage.py collectstatic --noinput

prod-deploy:
	@echo "Deploying version $(TAG)..."
	$(MAKE) prod-build
	$(DC_PROD) up -d db redis
	$(MAKE) prod-migrate
	$(MAKE) prod-collectstatic
	$(DC_PROD) up -d --remove-orphans
	@echo "Deploy successful!"

prod-logs:
	$(DC_PROD) logs -f $(prod_service)

prod-shell:
	$(DC_PROD) exec web python manage.py shell

prod-bash:
	$(DC_PROD) exec web bash

prod-db-backup:
	@mkdir -p backups
	$(DC_PROD) exec -T db sh -c 'pg_dump -U "$$POSTGRES_USER" -d "$$POSTGRES_DB" -F c' > backups/prod_backup_$$(date +%Y%m%d_%H%M%S).dump
	@echo "Production backup saved in backups/ folder."

prod-init-ssl:
	@echo "Initializing SSL certificates for domain $$DOMAIN"
	$(DC_PROD) run --rm -p 80:80 --entrypoint 'sh -c "certbot certonly --standalone -d $$DOMAIN -d $$WWW_DOMAIN --agree-tos --no-eff-email -m $$CERTBOT_EMAIL"' certbot
	@echo "Restoring access permissions without sudo..."
	docker run --rm -v $$(pwd)/docker/certbot:/certbot alpine chown -R $$(id -u):$$(id -g) /certbot
	@echo "Done! Now you can run make prod-deploy"
