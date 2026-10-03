from django.urls import path

from .views import components_page

app_name = "demo"

urlpatterns = [
    path("components/", components_page, name="components-page"),
]
