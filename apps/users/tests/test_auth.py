import pytest
from django.contrib.auth import get_user_model
from django.contrib.auth.tokens import default_token_generator
from django.core import mail
from django.urls import reverse
from django.utils.encoding import force_bytes
from django.utils.http import urlsafe_base64_encode

User = get_user_model()


@pytest.mark.django_db
class TestUserModel:
    def test_create_user_success(self):
        user = User.objects.create_user(email="test@example.com", password="password123")
        assert user.email == "test@example.com"
        assert user.is_active is True
        assert user.is_staff is False
        assert user.is_superuser is False
        assert user.check_password("password123") is True

    def test_create_superuser_success(self):
        admin = User.objects.create_superuser(email="admin@example.com", password="password123")
        assert admin.is_active is True
        assert admin.is_staff is True
        assert admin.is_superuser is True

    def test_create_user_without_email_fails(self):
        with pytest.raises(ValueError, match="The Email field must be set"):
            User.objects.create_user(email="", password="password123")


@pytest.mark.django_db
class TestAuthenticationFlow:
    def test_register_creates_inactive_user_and_sends_email(self, client):
        url = reverse("users:register")
        data = {
            "email": "newuser@example.com",
            "phone": "+1234567890",
            "country": "UK",
            "password1": "StrongPass123!",
            "password2": "StrongPass123!",
        }
        response = client.post(url, data)

        assert response.status_code == 302
        assert response.url == reverse("users:login")

        user = User.objects.get(email="newuser@example.com")
        assert user.is_active is False

        assert len(mail.outbox) == 1
        assert "Activate your account" in mail.outbox[0].subject
        assert user.email in mail.outbox[0].to

    def test_activate_account_success(self, client):
        user = User.objects.create_user(email="inactive@example.com", password="password123")
        user.is_active = False
        user.save()

        uidb64 = urlsafe_base64_encode(force_bytes(user.pk))
        token = default_token_generator.make_token(user)

        url = reverse("users:activate", kwargs={"uidb64": uidb64, "token": token})
        response = client.get(url)

        assert response.status_code == 302
        assert response.url == reverse("users:login")

        user.refresh_from_db()
        assert user.is_active is True

    def test_activate_account_invalid_token(self, client):
        user = User.objects.create_user(email="invalid@example.com", password="password123")
        user.is_active = False
        user.save()

        uidb64 = urlsafe_base64_encode(force_bytes(user.pk))

        url = reverse("users:activate", kwargs={"uidb64": uidb64, "token": "bad-token"})
        response = client.get(url)

        assert response.status_code == 302
        assert response.url == reverse("users:register")

        user.refresh_from_db()
        assert user.is_active is False

    def test_activate_account_already_active(self, client):
        user = User.objects.create_user(email="active@example.com", password="password123")
        # is_active=True по умолчанию
        uidb64 = urlsafe_base64_encode(force_bytes(user.pk))
        token = default_token_generator.make_token(user)

        url = reverse("users:activate", kwargs={"uidb64": uidb64, "token": token})
        response = client.get(url)

        assert response.status_code == 302
        assert response.url == reverse("users:login")
        user.refresh_from_db()
        assert user.is_active is True

    def test_user_login_success(self, client):
        User.objects.create_user(email="login@example.com", password="password123")
        url = reverse("users:login")

        response = client.post(url, {"username": "login@example.com", "password": "password123"})

        assert response.status_code == 302
        assert "_auth_user_id" in client.session

    def test_user_login_inactive_fails(self, client):
        user = User.objects.create_user(email="inactive_login@example.com", password="password123")
        user.is_active = False
        user.save()

        url = reverse("users:login")
        response = client.post(url, {"username": "inactive_login@example.com", "password": "password123"})

        assert response.status_code == 200
        assert "_auth_user_id" not in client.session

    def test_profile_access_requires_login(self, client):
        url = reverse("users:profile")
        response = client.get(url)
        assert response.status_code == 302
        assert reverse("users:login") in response.url

    def test_profile_update_success(self, client):
        user = User.objects.create_user(email="profile@example.com", password="password123")
        client.force_login(user)

        url = reverse("users:profile")
        data = {
            "email": "newemail@example.com",
            "phone": "+987654321",
            "country": "CA",
        }
        response = client.post(url, data)

        assert response.status_code == 302
        user.refresh_from_db()
        assert user.email == "newemail@example.com"
        assert user.country == "CA"

    def test_profile_update_duplicate_email_fails(self, client):
        # Создаем стороннего пользователя для конфликта email
        User.objects.create_user(email="taken@example.com", password="password123")

        # Авторизуемся под текущим пользователем
        user = User.objects.create_user(email="myprofile@example.com", password="password123")
        client.force_login(user)

        url = reverse("users:profile")
        data = {
            "email": "taken@example.com",  # Пытаемся занять чужой email
            "phone": "+987654321",
            "country": "CA",
        }
        response = client.post(url, data)

        # Форма возвращает ошибку (status code 200, а не 302 редирект)
        assert response.status_code == 200
        assert "A user with that email already exists." in response.content.decode()

        # Проверяем, что email в БД не изменился
        user.refresh_from_db()
        assert user.email == "myprofile@example.com"

    def test_user_login_wrong_password(self, client):
        User.objects.create_user(email="wrongpass@example.com", password="correctpass")
        url = reverse("users:login")
        response = client.post(url, {"username": "wrongpass@example.com", "password": "wrongpass"})
        assert response.status_code == 200
        assert "_auth_user_id" not in client.session

    def test_activate_account_malformed_uidb64(self, client):
        url = reverse("users:activate", kwargs={"uidb64": "invalid-base64-!!!", "token": "any-token"})
        response = client.get(url)
        assert response.status_code == 302
        assert response.url == reverse("users:register")
