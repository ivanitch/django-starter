from django.conf import settings

def global_settings(request):
    """Returns a dictionary with variables that are needed in all templates"""
    return {
        'APP_VERSION': settings.APP_VERSION,
        'APP_NAME': settings.APP_NAME,
        'APP_TITLE': settings.APP_TITLE,
        'REPO_LINK': settings.REPO_LINK,
    }
