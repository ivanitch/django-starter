from django.contrib.auth.mixins import LoginRequiredMixin
from django.contrib.auth.views import LoginView, LogoutView
from django.core.mail import send_mail
from django.urls import reverse_lazy
from django.views.generic import CreateView, UpdateView, View
from django.contrib.auth.tokens import default_token_generator
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes, force_str
from django.contrib.sites.shortcuts import get_current_site
from django.template.loader import render_to_string
from django.shortcuts import redirect, render
from django.contrib import messages

from .forms import UserRegisterForm, UserLoginForm, UserProfileForm
from .models import User


class RegisterView(CreateView):
    model = User
    form_class = UserRegisterForm
    template_name = 'users/register.html'
    success_url = reverse_lazy('users:login')

    def form_valid(self, form):
        # Создаем пользователя, но запрещаем вход до подтверждения почты
        user = form.save(commit=False)
        user.is_active = False
        user.save()

        # Генерация токена и отправка email
        current_site = get_current_site(self.request)
        mail_subject = 'Activate your account.'
        message = render_to_string('users/acc_active_email.html', {
            'user': user,
            'domain': current_site.domain,
            'uid': urlsafe_base64_encode(force_bytes(user.pk)),
            'token': default_token_generator.make_token(user),
        })
        send_mail(mail_subject, message, None, [user.email])

        messages.success(self.request, 'Please confirm your email address to complete the registration.')
        return super().form_valid(form)


class ActivateAccountView(View):
    def get(self, request, uidb64, token):
        try:
            uid = force_str(urlsafe_base64_decode(uidb64))
            user = User.objects.get(pk=uid)
        except (TypeError, ValueError, OverflowError, User.DoesNotExist):
            user = None

        if user is not None and default_token_generator.check_token(user, token):
            user.is_active = True
            user.save()
            messages.success(request, 'Your account has been activated successfully. You can now log in.')
            return redirect('users:login')
        else:
            messages.error(request, 'Activation link is invalid or has expired.')
            return redirect('users:register')


class UserLoginView(LoginView):
    form_class = UserLoginForm
    template_name = 'users/login.html'

    def form_valid(self, form):
        messages.success(self.request, f"Welcome back, {form.get_user().email}!")
        return super().form_valid(form)


class UserLogoutView(LogoutView):
    next_page = reverse_lazy('main:home')


class UserProfileView(LoginRequiredMixin, UpdateView):
    model = User
    form_class = UserProfileForm
    template_name = 'users/profile.html'
    success_url = reverse_lazy('users:profile')

    def get_object(self, queryset=None):
        return self.request.user

    def form_valid(self, form):
        messages.success(self.request, 'Profile updated successfully.')
        return super().form_valid(form)
