from django.shortcuts import render


def components_page(request):
    return render(request, 'demo/components.html')
