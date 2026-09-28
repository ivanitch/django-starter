from django.shortcuts import render
from django.conf import settings


def home_page(request):
    context = {
        'title': settings.APP_NAME,
    }

    return render(request, 'main/home.html', context)
