# syntax=docker/dockerfile:1

# ==========================================
# BASE STAGE: Common dependencies
# ==========================================
FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/opt/venv \
    PATH="/opt/venv/bin:$PATH"

# Install runtime dependencies (e.g., for psycopg3)
RUN apt-get update && apt-get install -y --no-install-recommends libpq5 \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir uv

# Create a non-root user for production
RUN groupadd --system djangogroup \
    && useradd --system --gid djangogroup --home-dir /home/djangouser --create-home djangouser

WORKDIR /app
COPY pyproject.toml uv.lock ./

# ==========================================
# DEV STAGE: Local Development (includes Node & Dev tools)
# ==========================================
FROM base AS dev

ENV DJANGO_SETTINGS_MODULE=config.settings.development

# Install Node.js for Tailwind watcher
RUN apt-get update && apt-get install -y --no-install-recommends nodejs npm \
    && rm -rf /var/lib/apt/lists/*

# Sync all dependencies including 'dev'
RUN uv sync --locked --no-install-project

# Code is mounted via bind mount in docker-compose.yml locally,
# but we copy it anyway as a fallback.
COPY . .

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

# ==========================================
# CSS STAGE: Build Tailwind for Production
# ==========================================
FROM node:22-slim AS css
WORKDIR /app
COPY . .
# Build CSS payload
RUN cd theme/static_src && npm ci && npm run build

# ==========================================
# PROD STAGE: Final Production Image
# ==========================================
FROM base AS prod

ENV DJANGO_SETTINGS_MODULE=config.settings.production \
    WEB_CONCURRENCY=3

# Sync strictly production dependencies
RUN uv sync --locked --no-dev --no-install-project

# Copy application code (owned by root, read-only for djangouser)
COPY . .

# Copy compiled CSS from the CSS stage
COPY --from=css /app/theme/static/css/dist/ /app/theme/static/css/dist/

# Pre-create media and staticfiles directories and assign permissions.
# Docker named volumes inherit these permissions upon creation.
RUN mkdir -p /app/staticfiles /app/media \
    && chown djangouser:djangogroup /app/staticfiles /app/media

USER djangouser

EXPOSE 8000

CMD ["gunicorn", "config.wsgi:application", \
     "--bind", "0.0.0.0:8000", \
     "--worker-tmp-dir", "/dev/shm", \
     "--access-logfile", "-", \
     "--error-logfile", "-", \
     "--timeout", "30", \
     "--graceful-timeout", "30"]
