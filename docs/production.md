# Deployment to Production (Debian/Ubuntu)

This guide describes the initial deployment process of the project on a clean Debian/Ubuntu server with Docker and
Docker Compose preinstalled. The infrastructure operates in strict isolation and does not require installing local
dependencies on the host, except for Docker and Git.

## Server Preparation

Make sure that git and the latest version of Docker with the docker-compose-plugin are installed on the server. By this
point, the A record of your domain (and the www subdomain) must point to the server's IP address.

Check Docker and Docker Compose:

```bash
docker -v && docker compose version
```

Add the current user to the Docker group:

```bash
sudo usermod -aG docker $USER && newgrp docker
```

---

## Cloning and Environment Setup

Clone the project and prepare the production configuration file.

```bash
git clone git@github.com:ivanitch/django-starter.git django-project
cd django-project
cp .env.prod.example .env.prod
nano .env.prod
```

> To generate a secret key directly on the server, run the following and write the key to `.env.prod`

```bash
python3 -c "import secrets, string; safe_punct = '!^*()-_=+'; alphabet = string.ascii_letters + string.digits + safe_punct; print(''.join(secrets.choice(alphabet) for _ in range(64)))"
```

Required variables to configure in `.env.prod`:

- **Domains and SSL:** Set the `DOMAIN`, `WWW_DOMAIN`, and `CERTBOT_EMAIL` variables. The Nginx infrastructure
  automatically uses
  them via built-in `.template` templates, eliminating the need to hardcode domains in the configuration.
- **Database:** Be sure to specify `POSTGRES_DB`, `POSTGRES_USER`, and `POSTGRES_PASSWORD`, since the official
  PostgreSQL Docker
  image requires them to pass the healthcheck successfully. Also set the same data in `DATABASE_URL`.
  You can use the following command:
  ```bash
  python3 -c "import secrets, string; alphabet = string.ascii_letters + string.digits; print(''.join(secrets.choice(alphabet) for _ in range(20)))"
  ```
- **Email sending (SMTP):** For account activation to work, add SMTP settings and be sure to specify the "App password"
  in `EMAIL_HOST_PASSWORD`.

---

## Issuing an SSL Certificate (Certbot)

```bash
make prod-init-ssl
```

This command starts a temporary standalone container to validate the domain, and then automatically restores access
permissions to the `docker/certbot/` folder for the local user.

---

## Build and Deploy (Zero Downtime)

Run the deployment process with a single command using the prepared Makefile:

```bash
make prod-deploy
```

This command performs the entire deployment lifecycle automatically:

- Builds an optimized Docker image (`web`) without dev dependencies and `Node.js`.
- Starts PostgreSQL and Redis.
- Applies migrations (`manage.py migrate`).
- Collects static files into a volume (`manage.py collectstatic`), from where Nginx will serve them.
- Starts the main web and nginx containers, automatically removing old dangling images.

---

## Creating an Administrator

To log in to the Django admin panel, create a superuser inside the running container:

```bash
make prod-bash
python manage.py createsuperuser
exit
```

---

## Monitoring, Logs, and Management

The infrastructure is fully managed via the Makefile:

- **Service logs:** `make prod-logs` (outputs combined Django and Nginx logs). Logs are rotated automatically (maximum 3
  files
  of 10MB each).
- **DB backup:** `make db-backup` (creates a PostgreSQL dump and saves it to the backups/ folder on the host).
- **Django console:** `make prod-shell` (opens an interactive application shell).
- **Direct DB access:** Port `5432` is intentionally not exposed externally for security reasons. To connect using
  programs
  like DBeaver, use an SSH tunnel. In DBeaver, specify the host `127.0.0.1`, and in the SSH tab enter the server IP and
  the path to your private key.
