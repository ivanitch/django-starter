# syntax=docker/dockerfile:1

# Define arguments before the first FROM (with safe fallbacks)
ARG PYTHON_VERSION=3.14-slim
ARG NODE_VERSION=26-slim

# ==========================================
# NODE STAGE: Fetch Node.js for reuse
# ==========================================
# We extract Node.js into a separate alias to reuse it
# in both 'dev' and 'css' stages cleanly without apt-get.
FROM node:${NODE_VERSION} AS node_base

# ==========================================
# BASE STAGE: Common dependencies
# ==========================================
FROM python:${PYTHON_VERSION} AS base

# Set environment variables for Python and uv
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/opt/venv \
    PATH="/opt/venv/bin:$PATH"

# Install runtime system dependencies (e.g., libpq5 for psycopg)
RUN apt-get update && apt-get install -y --no-install-recommends libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Install uv package manager
RUN pip install --no-cache-dir uv

# Create a non-root user for production security
RUN groupadd --system djangogroup \
    && useradd --system --gid djangogroup --home-dir /home/djangouser --create-home djangouser

WORKDIR /app
COPY pyproject.toml uv.lock ./

# ==========================================
# DEV STAGE: Local Development
# ==========================================
FROM base AS dev

ENV DJANGO_SETTINGS_MODULE=config.settings.development

# Elegantly copy Node.js binaries directly from the official image
COPY --from=node_base /usr/local/bin/node /usr/local/bin/
COPY --from=node_base /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# Sync all dependencies including 'dev' group
RUN uv sync --locked --no-install-project

# Code is mounted via bind mount in local docker-compose.yml,
# but we copy it anyway as a fallback.
COPY . .

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

# ==========================================
# CSS STAGE: Build Tailwind for Production
# ==========================================
FROM node_base AS css
WORKDIR /app
COPY . .
# Build CSS payload for production
RUN cd theme/static_src && npm ci && npm run build

# ==========================================
# PROD STAGE: Final Production Image
# ==========================================
FROM base AS prod

ENV DJANGO_SETTINGS_MODULE=config.settings.production \
    WEB_CONCURRENCY=3

# Sync strictly production dependencies (without 'dev' group)
RUN uv sync --locked --no-dev --no-install-project

# Copy application code (owned by root, read-only for djangouser)
COPY . .

# Copy compiled CSS from the CSS stage
COPY --from=css /app/theme/static/css/dist/ /app/theme/static/css/dist/

# Pre-create media and staticfiles directories and assign permissions.
# Docker named volumes inherit these permissions upon creation.
RUN mkdir -p /app/staticfiles /app/media \
    && chown djangouser:djangogroup /app/staticfiles /app/media

# Switch to non-root user
USER djangouser

EXPOSE 8000

# Run Gunicorn with optimal settings for Docker
CMD ["gunicorn", "config.wsgi:application", \
     "--bind", "0.0.0.0:8000", \
     "--worker-tmp-dir", "/dev/shm", \
     "--access-logfile", "-", \
     "--error-logfile", "-", \
     "--timeout", "30", \
     "--graceful-timeout", "30"]
