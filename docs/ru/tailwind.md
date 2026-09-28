## Шпаргалка: Tailwind + Django (uv)

### 0. Предварительно
Нужен установленный **Node.js** (npm) в системе — сам Tailwind собирается через npm, django-tailwind просто оборачивает эти команды.

### 1. Установка пакета

```bash
uv add django-tailwind "django-tailwind[reload]" cookiecutter
```

### 2. Настройка `settings.py`

```python
INSTALLED_APPS = [
    # ...
    "tailwind",
    "theme", # обслуживает CSS
    "main",  # реальные страницы
]

TAILWIND_APP_NAME = "theme"

INTERNAL_IPS = [
    "127.0.0.1",
]
```

### 3. Создать Tailwind-приложение

```bash
uv run python manage.py tailwind init
```

Спросит имя приложения — вводи `theme` (должно совпадать с `TAILWIND_APP_NAME`). Команда сама создаст папку `theme/` с нужной структурой (`theme/static_src/` и т.д.) — руками ничего создавать не нужно.

Выбрать шаблон:

```bash
$ uv run python manage.py tailwind init
Enter Tailwind app name [theme]: theme
Choose template:
1 - Tailwind v4 Standalone - Simple and doesn't require Node.js
2 - Tailwind v4 Full - All the bells and whistles, requires Node.js
3 - Tailwind v3 Full - Legacy template for Tailwind v3 projects, requires Node.js
Enter choice [1-3]: 2
Include DaisyUI component library? (y/n): y
Tailwind application 'theme' has been successfully created. Please add 'theme' to INSTALLED_APPS in settings.py, and declare TAILWIND_APP_NAME = 'theme' in settings.py, then run the following command to install Tailwind CSS dependencies: `python manage.py tailwind install`
````

### 4. Установить npm-зависимости Tailwind

```bash
uv run python manage.py tailwind install
```

Это и есть замена ручного `cd theme/static_src && npm install` — команда сама зайдёт в нужную папку и поставит зависимости.

### 5. Миграции БД

```bash
uv run python manage.py migrate
```

### 6. Подключить Tailwind в шаблон

В `base.html` (или где у тебя `<head>`):

```django
{% load tailwind_tags %}
<!DOCTYPE html>
<html>
<head>
    {% tailwind_css %}
</head>
```

### 7. Собрать CSS в первый раз

```bash
uv run python manage.py tailwind build
```

### 8. Запустить сервер

```bash
uv run python manage.py runserver
```

Открывай `http://127.0.0.1:8000/` — уже со стилями.

---

### Во время разработки

Держи **второй терминал** с watch-режимом — CSS будет пересобираться на лету:

```bash
uv run python manage.py tailwind start
```

(при первом запуске `tailwind start` тоже установит недостающие npm-пакеты, если что-то забыл на шаге 4)

### Если стили не применились после правки шаблона/классов

Почти всегда причина — не пересобран CSS (или не запущен `tailwind start`). Проверка:

```bash
ls -la theme/static/css/dist/styles.css   # есть ли файл вообще
uv run python manage.py tailwind build     # пересобрать вручную
```

### Перед коммитом/деплоем — финальная минифицированная сборка

```bash
uv run python manage.py tailwind build
```

Обязательно перед деплоем — `runserver` в проде не используется, а `collectstatic` должен видеть готовый `styles.css`:

```bash
uv run python manage.py collectstatic
```


## Структура `theme`

```
theme/
├── static_src/              # npm-проект: package.json, tailwind.config.js, input.css
│   ├── src/styles.css       # исходный файл с @tailwind директивами
│   └── package.json
├── static/
│   └── css/dist/styles.css  # сгенерированый итоговый CSS (не трогать руками)
├── templates/
├── apps.py
└── ...
```

## Куда класть кастомные `CSS/JS`?

Кастомный CSS, который должен пройти через Tailwind (например свои `@layer`, кастомные классы, `@apply`)

Пиши прямо в исходник `Tailwind`:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer components {
  .btn-primary {
    @apply px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700;
  }
}
```

После изменений — пересборка (`tailwind build` или запущенный `tailwind start` сам подхватит).

Обычный JS, картинки, свои CSS-файлы, не связанные с Tailwind кладёшь их в статику своего приложения, например:

```
main/
└── static/
    └── main/
        ├── js/
        │   └── script.js
        └── css/
            └── custom.css
```

---

- [Tailwind CSS](https://tailwindcss.com/)
- [Tailwind CSS русская локументация](https://tailwindcss.ru/)
- [DaisyUI](https://daisyui.com/)
- [django-tailwind](https://django-tailwind.readthedocs.io/en/latest/installation.html)
