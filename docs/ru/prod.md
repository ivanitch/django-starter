# Развертывание в Production (Debian/Ubuntu)

Данное руководство описывает процесс первичного развертывания проекта на чистом сервере Debian/Ubuntu с
предустановленными Docker и Docker Compose. Инфраструктура работает в строгой изоляции и не требует установки локальных
зависимостей на хосте, кроме Docker и Git.

## Подготовка сервера

Убедись, что на сервере установлены `git` и актуальная версия Docker с плагином `docker-compose-plugin`. К этому моменту
A-запись твоего домена (и поддомена www) должна быть направлена на IP-адрес сервера.

Проверить Docker и Docker Compose:

```bash
docker -v

docker compose version
```

Добавляем текущегго пользователя в группу Docker:

```bash
sudo usermod -aG docker $USER && newgrp docker
````

---

## Клонирование и настройка окружения

Загрузи проект и подготовь боевой конфигурационный файл.

```bash
git clone git@github.com:ivanitch/django-starter.git django-project
cd django-project
cp .env.prod.example .env.prod
nano .env.prod
```

> Для генерации секретного ключа прямо на сервере выполнить и записать ключ в `.env.prod`

```bash
python3 -c "import secrets, string; alphabet = string.ascii_letters + string.digits + '-_'; print(''.join(secrets.choice(alphabet) for _ in range(64)))"
```

---

## Выпуск SSL-сертификата (Certbot)

Nginx настроен на работу с HTTPS. Чтобы контейнер Nginx успешно стартовал, необходимо первично получить сертификаты до
запуска всей инфраструктуры. Запусти временный standalone-контейнер для валидации домена:

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod run --rm -p 80:80 \
  --entrypoint certbot certbot certonly --standalone \
  -d yourdomain.com -d www.yourdomain.com --agree-tos --no-eff-email
```

Если во время дальнейшей сборки возникнет ошибка прав доступа (`permission denied` к
папке `docker/certbot/conf/accounts`), необходимо добавить `docker/certbot/` в `.dockerignore` и выполнить:

```bash
sudo chown -R $USER:$USER docker/certbot/
```

---

## Раскомментирование HTTPS в Nginx

После успешного получения сертификата откройте файл конфигурации Nginx:

```bash
micro docker/nginx/prod.conf
```

Раскомментируйте блоки `listen 443 ssl` и настройки путей к сертификатам.

5. **Сборка и Деплой (Zero Downtime)**

Запустите процесс развертывания одной командой с помощью подготовленного Makefile:

```bash
make prod-deploy
```

Эта команда выполняет весь жизненный цикл деплоя автоматически:

1. Собирает оптимизированный Docker-образ (`web`) без `dev-зависимостей` и `Node.js`.
2. Поднимает `PostgreSQL` и `Redis`.
3. Накатывает миграции (`manage.py migrate`).
4. Собирает статику в volume (`manage.py collectstatic`), откуда её будет раздавать Nginx.
5. Запускает основные контейнеры web и nginx, автоматически удаляя старые зависшие образы.

---

## Создание администратора

Чтобы зайти в админ-панель Django, создайте суперпользователя внутри работающего контейнера:

```bash
make prod-bash
python manage.py createsuperuser
exit
```

---

## Мониторинг, логи и управление

Инфраструктура полностью управляется через `Makefile`:

- **Логи сервисов:** `make prod-logs` (выводит объединенные логи Django и Nginx). Логи ротируются автоматически (
  максимум 3 файла по 10MB).
- **Бэкап БД:** `make db-backup` (создает дамп PostgreSQL и сохраняет его в папку `backups/` на хосте).
- **Консоль Django:** `make prod-shell` (открывает интерактивный shell приложения).
- **Прямой доступ к БД:** Порт `5432` умышленно не проброшен наружу ради безопасности. Для подключения через программы
  вроде DBeaver используйте SSH-туннель. В DBeaver укажите хост `127.0.0.1`, а во вкладке SSH введите IP сервера и путь к
  вашему приватному ключу.
