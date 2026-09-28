# users/forms.py
from django import forms
from django.contrib.auth import get_user_model
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from django.core.exceptions import ValidationError

User = get_user_model()

# Единый стиль для всех инпутов DaisyUI
DAISY_INPUT_CLASS = ('input w-full bg-base-200 border-none focus:outline-none focus:ring-2'
                     ' focus:ring-primary/30 rounded-sm transition-shadow')


class UserRegisterForm(UserCreationForm):
    class Meta(UserCreationForm.Meta):
        model = User
        fields = ('email', 'phone', 'country')

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for field in self.fields.values():
            field.widget.attrs['class'] = DAISY_INPUT_CLASS


class UserLoginForm(AuthenticationForm):
    username = forms.EmailField(widget=forms.EmailInput(attrs={
        'class': DAISY_INPUT_CLASS,
        'placeholder': 'john@example.com'
    }))
    password = forms.CharField(widget=forms.PasswordInput(attrs={
        'class': DAISY_INPUT_CLASS,
        'placeholder': '••••••••'
    }))


class UserProfileForm(forms.ModelForm):
    class Meta:
        model = User
        fields = ('email', 'phone', 'country', 'avatar')

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for field in self.fields.values():
            field.widget.attrs['class'] = DAISY_INPUT_CLASS

    def clean_email(self):
        email = self.cleaned_data.get('email')
        if User.objects.filter(email=email).exclude(pk=self.instance.pk).exists():
            raise ValidationError('A user with that email already exists.')
        return email
