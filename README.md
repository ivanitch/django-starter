# Ultimate Django Starter Kit

Documentation [in Russian](docs/ru/README.md)

---

<p align="left">
  <img src="https://img.shields.io/badge/python-3.14-blue?logo=python&logoColor=white" alt="Python">
  <img src="https://img.shields.io/badge/django-6.x-092E20?logo=django&logoColor=white" alt="Django">
  <img src="https://img.shields.io/badge/postgres-18-316192?logo=postgresql&logoColor=white" alt="PostgreSQL">
  <img src="https://img.shields.io/badge/redis-8-DC382D?logo=redis&logoColor=white" alt="Redis">
  <img src="https://img.shields.io/badge/docker--compose-2496ED?logo=docker&logoColor=white" alt="Docker">
  <img src="https://img.shields.io/badge/tailwindcss-38B2AC?logo=tailwind-css&logoColor=white" alt="TailwindCSS">
  <img src="https://img.shields.io/badge/uv-manager-8A2BE2?logo=python&logoColor=white" alt="uv">
</p>

Production-ready Django 6.x starter template featuring Docker Compose, Postgres, Redis, Celery, and TailwindCSS
integrated with DaisyUI.

## Tech Stack

- **Core:** Python 3.14, Django 6.x
- **Database & Cache:** PostgreSQL 18, Redis 8
- **Infrastructure:** Docker Compose, Gunicorn + Nginx
- **Frontend:** TailwindCSS, DaisyUI
- **Tooling:** `uv` (package management), pytest, ruff, mypy
- **CI/CD:** GitHub Actions, strict local/prod environment split (`django-environ`)

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

```shell
cp .env.example .env
```

3. **Start the project using Makefile:**

```bash
make up
```

This builds images, starts the database, and launches Django + Tailwind watcher.

4. **Apply migrations and create a superuser:**

```bash
make migrate
make bash
# Inside container:
python manage.py createsuperuser
````

5. **View local Logs:**

```bash
make logs

make logs db
```

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

Make sure to generate a secure `SECRET_KEY`, set `DEBUG=False`, update `ALLOWED_HOSTS`, and set the exact `URL` in
`CSRF_TRUSTED_ORIGINS`. Add your domains (`DOMAIN`, `WWW_DOMAIN`), `CERTBOT_EMAIL`, configure PostgreSQL credentials (
`POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`), and set up your `SMTP email variables`.

3. **🔒 SSL via Certbot (First Time Setup):**

```bash
make prod-init-ssl
```

This command will build the prod image, apply migrations, run collectstatic into the Docker volume, and safely restart
the web and nginx containers

4. **Deploy (Zero Downtime)**

```bash
make prod-deploy
````

This command will build the `prod image`, apply `migrations`, run `collectstatic` into the Docker volume, and safely
restart the `web` and `nginx` containers.

5. **View Production Logs:**

```bash
make prod-logs
```

---

## CI/CD Setup (GitHub Actions)

[Detailed information on CI/CD settings](docs/ci-cd.md)

[Detailed deployment instructions for production](docs/production.md)

---

## Additional

- [Make commands cheat sheet](docs/make.md)
- [Cheat sheet: Tailwind + Django (uv)](docs/tailwind.md)
- [Production Deployment](docs/production.md)

