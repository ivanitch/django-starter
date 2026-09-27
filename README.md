# Ultimate Django Starter Kit

Production-ready Django 6.x starter template featuring Docker Compose, Postgres, Redis, Celery, and TailwindCSS
integrated with DaisyUI.

## Tech Stack

- Python 3.12+
- Django 6.x
- PostgreSQL
- Redis
- Docker Compose
- Gunicorn + Nginx
- uv
- pytest, ruff, mypy
- GitHub Actions
- django-environ
- settings: local / prod

## Features

- **Strict Environment Separation:** Isolated logic for Local and Production.
- **Flawless Docker:** No root permission conflicts on Linux/Mac. `uv` for blazing-fast package management.
- **Fail-Fast Security:** Production server refuses to start if `.env` is misconfigured.
- **Nginx & HTTPS Ready:** Self-contained proxy, static files cache busting, and easy Certbot renewal.
- **Tailwind Hot-Reload:** Native integration inside the local container, without messy local dependencies.

---

## 💻 Local Development

1. **Clone the repository:**

```bash
git clone git@github.com:ivanitch/django-starter.git django-project
cd django-project
```

2. **Setup environment variables:**

```bsah
cp .env.example .env
```

3. **Start the project using Makefile:**

```bash
make up
```

This builds images, starts the database, and launches Django + Tailwind watcher.

4. **Apply migrations and create a superuser::**

```bash
make migrate
make bash
# Inside container:
python manage.py createsuperuser
````

App runs at: http://localhost:8000

---

## 🌍 Production Deployment (VPS)

Production operates in strict isolation. It does not rely on the local docker-compose.yml. Node.js and dev packages are
stripped from the final image.

1. **Clone to your VPS:**

```bash
git clone git@github.com:ivanitch/django-starter.git django-project
cd django-project
````

2. **Configure Production Settings:**

```bash
cp .env.prod.example .env.prod
nano .env.prod
````

Make sure to generate a secure `SECRET_KEY`, set `DEBUG=False`, update `ALLOWED_HOSTS`, and set the exact URL
in `CSRF_TRUSTED_ORIGINS`.

3. **Deploy (Zero Downtime):**

```bash
make prod-deploy
````

This command will build the `prod image`, apply `migrations`, run `collectstatic` into the Docker volume, and safely
restart the `web` and `nginx` containers.

4. **View Production Logs:**

```bash
make prod-logs
```

## 🔒 SSL via Certbot (First Time Setup)

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod run --rm -p 80:80 \
  --entrypoint certbot certbot certonly --standalone \
  -d yourdomain.com -d [www.yourdomain.com](https://www.yourdomain.com) --agree-tos --no-eff-email
```

Then uncomment the HTTPS blocks in `docker/nginx/prod.conf` and re-run `make prod-deploy`.

---

## Additional

- [Make commands cheat sheet](docs/make.md)
- [Cheat sheet: Tailwind + Django (uv)](docs/tailwind.md)

