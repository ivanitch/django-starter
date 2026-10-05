
# Make Commands Cheat Sheet

```bash
make                            # Calls `make help`
make help                       # View all commands
```

## - Containers - ##

```bash
make build                      # Build/Rebuild images
make up                         # Start the project in background
make down                       # Stop containers (DB data is preserved)
make destroy                    # Stop and completely remove containers and DB data
make logs                       # View logs of all services
make logs-web                   # View Django logs only
make logs-db                    # View PostgreSQL logs only
```

## - Django - ##

```bash
make shell                      # Access Django container (bash)
make db-shell                   # Access PostgreSQL container
make makemigrations             # Create DB migrations
make migrate                    # Apply DB migrations
make superuser                  # Create new superuser
```

## - Workflow - ##

```bash
# Access Django container
make shell

# Commands inside Django container
python manage.py shell          # Start Django interactive shell
python manage.py makemigrations # Create DB migrations
python manage.py migrate        # Apply DB migrations
```
