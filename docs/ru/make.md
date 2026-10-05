# Шпаргалка по командам `Make`

```bash
make                            # Вызов `make help`
make help                       # Просмотр всех команд
```

## - Контейнеры - ##

```bash
make build                      # Собрать/Пересобрать образы
make up                         # Запустить проект в фоне
make down                       # Остановить контейнеры (данные в БД сохраняются)
make destroy                    # Остановить и полностью удалить контейнеры и данные БД
make logs                       # Смотреть логи всех сервисов
make logs-web                   # Смотреть логи только Django
make logs-db                    # Смотреть логи только PostgreSQL
```

## - Django - ##

```bash
make shell                      # Зайти внутрь контейнера с Django (bash)
make db-shell                   # Зайти внутрь контейнера с PostgreSQL
make makemigrations             # Создать миграции БД
make migrate                    # Применить миграции БД
make superuser                  # Новый супер-пользователь
```

## - Рабочий процесс - ##

```bash
# Зайти внутрь контейнера с Django
make shell

# Команды внутри контейнера с Django
python manage.py shell          # Запустить интерактивную оболочку Django
python manage.py makemigrations # Создать миграции БД
python manage.py migrate        # Применить миграции БД
```
