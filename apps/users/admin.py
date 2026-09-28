from django.contrib import admin
from .models import User


@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    exclude = ('password',)
    readonly_fields = ('last_login', 'date_joined')
    search_fields = ('email',)
