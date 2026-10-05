# Ultimate Django Starter Kit

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

Готовый к продакшену стартовый шаблон Django 6.x с Docker Compose, Postgres, Redis, Celery и TailwindCSS,
интегрированным с DaisyUI.

## Технологический стек

- **Ядро:** Python 3.14, Django 6.x
- **База данных и кэш:** PostgreSQL 18, Redis 8
- **Инфраструктура:** Docker Compose, Gunicorn + Nginx
- **Фронтенд:** TailwindCSS, DaisyUI
- **Инструменты:** `uv` (управление пакетами), pytest, ruff, mypy
- **CI/CD:** GitHub Actions, строгое разделение локального и продакшен-окружения (`django-environ`)

## Возможности

- **Строгое разделение окружений:** Изолированная логика для локальной разработки и продакшена.
- **Безупречный Docker:** Никаких конфликтов прав root на Linux/Mac. `uv` для молниеносного управления пакетами.
- **Fail-Fast безопасность:** Продакшен-сервер отказывается запускаться при неверной конфигурации `.env`.
- **Готовность к Nginx и HTTPS:** Самодостаточный прокси, кэш-бастинг статики и лёгкое продление сертификатов через Certbot.
- **Hot-Reload Tailwind:** Нативная интеграция внутри локального контейнера, без лишних локальных зависимостей.

---

## 💻 Локальная разработка

1. **Клонируйте репозиторий:**

```bash
git clone git@github.com:ivanitch/django-starter.git django-project
cd django-project
```

2. **Настройте переменные окружения:**

```shell
cp .env.example .env
```

3. **Запустите проект с помощью Makefile:**

```bash
make up
```

Эта команда соберёт образы, запустит базу данных и запустит Django + наблюдатель Tailwind.

4. **Примените миграции и создайте суперпользователя:**

```bash
make migrate
make bash
# Внутри контейнера:
python manage.py createsuperuser
````

5. **Просмотр локальных логов:**

```bash
make logs

make logs db
```

Приложение доступно по адресу: http://localhost:8000

---

## 🌍 Продакшен-развёртывание (VPS)

Продакшен работает в строгой изоляции. Он не зависит от локального docker-compose.yml. Node.js и dev-пакеты
удалены из финального образа.

1. **Клонируйте на ваш VPS:**

```bash
git clone git@github.com:ivanitch/django-starter.git django-project
cd django-project
````

2. **Настройте продакшен-параметры:**

```bash
cp .env.prod.example .env.prod
nano .env.prod
````

Убедитесь, что сгенерирован надёжный `SECRET_KEY`, установлен `DEBUG=False`, обновлён `ALLOWED_HOSTS` и указан точный `URL` в
`CSRF_TRUSTED_ORIGINS`. Добавьте ваши домены (`DOMAIN`, `WWW_DOMAIN`), `CERTBOT_EMAIL`, настройте учётные данные PostgreSQL (
`POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`) и настройте переменные SMTP-почты.

3. **🔒 SSL через Certbot (первоначальная настройка):**

```bash
make prod-init-ssl
```

Эта команда соберёт продакшен-образ, применит миграции, выполнит collectstatic в Docker-том и безопасно перезапустит
контейнеры web и nginx

4. **Деплой (без простоя)**

```bash
make prod-deploy
````

Эта команда соберёт `prod-образ`, применит `миграции`, выполнит `collectstatic` в Docker-том и безопасно
перезапустит контейнеры `web` и `nginx`.

5. **Просмотр продакшен-логов:**

```bash
make prod-logs
```

---

## Настройка CI/CD (GitHub Actions)

[Подробная информация о настройках CI/CD](ci-cd.md)

[Подробные инструкции по развёртыванию в продакшене](production.md)

---

## Дополнительно

- [Шпаргалка по командам Make](make.md)
- [Шпаргалка: Tailwind + Django (uv)](tailwind.md)
- [Продакшен-развёртывание](production.md)
