# Cheat Sheet: Tailwind + Django (uv)

### 0. Prerequisites
You need **Node.js** (npm) installed on your system — Tailwind itself is built via npm, and django-tailwind simply wraps these commands.

### 1. Install the package

```bash
uv add django-tailwind "django-tailwind[reload]" cookiecutter
```

### 2. Configure `settings.py`

```python
INSTALLED_APPS = [
    # ...
    "tailwind",
    "theme",  # serves CSS
    "main",  # actual pages
]

TAILWIND_APP_NAME = "theme"

INTERNAL_IPS = [
    "127.0.0.1",
]
```

### 3. Create the Tailwind app

```bash
uv run python manage.py tailwind init
```

It will ask for the app name — enter `theme` (must match `TAILWIND_APP_NAME`). The command will create the `theme/` folder with the required structure (`theme/static_src/`, etc.) on its own — you don't need to create anything manually.

Choose a template:

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

### 4. Install Tailwind npm dependencies

```bash
uv run python manage.py tailwind install
```

This replaces the manual `cd theme/static_src && npm install` — the command will navigate to the right folder itself and install the dependencies.

### 5. DB migrations

```bash
uv run python manage.py migrate
```

### 6. Hook up Tailwind in your template

In `base.html` (or wherever your `<head>` is):

```django
{% load tailwind_tags %}
<!DOCTYPE html>
<html>
<head>
    {% tailwind_css %}
</head>
```

### 7. Build CSS for the first time

```bash
uv run python manage.py tailwind build
```

### 8. Start the server

```bash
uv run python manage.py runserver
```

Open `http://127.0.0.1:8000/` — now with styles.

---

### During development

Keep a **second terminal** running in watch mode — CSS will be rebuilt on the fly:

```bash
uv run python manage.py tailwind start
```

(on first run, `tailwind start` will also install any missing npm packages, in case you forgot something in step 4)

### If styles didn't apply after editing a template/classes

Almost always the cause is that CSS wasn't rebuilt (or `tailwind start` isn't running). Check:

```bash
ls -la theme/static/css/dist/styles.css   # does the file even exist
uv run python manage.py tailwind build     # rebuild manually
```

### Before commit/deploy — final minified build

```bash
uv run python manage.py tailwind build
```

Mandatory before deploy — `runserver` isn't used in prod, and `collectstatic` must see the finished `styles.css`:

```bash
uv run python manage.py collectstatic
```


## `theme` structure

```
theme/
├── static_src/              # npm project: package.json, tailwind.config.js, input.css
│   ├── src/styles.css       # source file with @tailwind directives
│   └── package.json
├── static/
│   └── css/dist/styles.css  # generated final CSS (don't touch by hand)
├── templates/
├── apps.py
└── ...
```

## Where to put custom `CSS/JS`?

Custom CSS that should go through Tailwind (e.g. your own `@layer`, custom classes, `@apply`)

Write it directly in the Tailwind source:

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

After changes — rebuild (`tailwind build`, or a running `tailwind start` will pick it up automatically).

Regular JS, images, your own CSS files that aren't related to Tailwind — put them in your app's static folder, e.g.:

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

## Additional

- [Tailwind CSS](https://tailwindcss.com/)
- [Tailwind CSS Russian documentation](https://tailwindcss.ru/)
- [DaisyUI](https://daisyui.com/)
- [django-tailwind](https://django-tailwind.readthedocs.io/en/latest/installation.html)
