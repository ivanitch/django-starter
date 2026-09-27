"""
Production settings (Fail-fast & secure).
"""
from django.core.exceptions import ImproperlyConfigured
from .base import *  # noqa

DEBUG = False

# 1. Security Checks (Fail-fast)
if not SECRET_KEY or SECRET_KEY.startswith("django-insecure"):
    raise ImproperlyConfigured("SECRET_KEY must be set securely in production.")
if not ALLOWED_HOSTS:
    raise ImproperlyConfigured("ALLOWED_HOSTS must not be empty in production.")
if not CSRF_TRUSTED_ORIGINS:
    raise ImproperlyConfigured("CSRF_TRUSTED_ORIGINS must be set in production for HTTPS.")

# 2. HTTPS & Proxy configuration
# Nginx terminates SSL, so we tell Django to trust the X-Forwarded-Proto header
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True

# Disable Django's HSTS check because Nginx handles it
SILENCED_SYSTEM_CHECKS = ["security.W004"]

# 3. Static Files (Cache busting)
STORAGES = {
    "default": {"BACKEND": "django.core.files.storage.FileSystemStorage"},
    "staticfiles": {
        "BACKEND": "django.contrib.staticfiles.storage.ManifestStaticFilesStorage"
    },
}
