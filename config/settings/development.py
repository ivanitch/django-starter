"""
Local development settings.
"""

import socket

from .base import *  # noqa: F403
from .base import INSTALLED_APPS, MAILERS, MIDDLEWARE, SECRET_KEY

DEBUG = True
ALLOWED_HOSTS = ["*"]

# Provide a fallback key for local dev if missing
if not SECRET_KEY:
    SECRET_KEY = "django-insecure-local-only-not-for-production"

INSTALLED_APPS += ["debug_toolbar"]  # noqa
MIDDLEWARE += ["debug_toolbar.middleware.DebugToolbarMiddleware"]  # noqa

# Allow debug_toolbar to work inside Docker (where requests come from the gateway IP)
_host, _aliases, _ips = socket.gethostbyname_ex(socket.gethostname())
INTERNAL_IPS = ["127.0.0.1"] + [ip.rsplit(".", 1)[0] + ".1" for ip in _ips]

MAILERS["default"]["BACKEND"] = "django.core.mail.backends.console.EmailBackend"
MAILERS["default"]["OPTIONS"] = {}
