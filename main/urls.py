from django.urls import path
from main.views import *

app_name = 'main'

urlpatterns = [
    #path('', show_main, name='show_main'),
    #path('login', login)
    path('register/', register_view, name='register'),
    path('login/', login_view, name='login')
]