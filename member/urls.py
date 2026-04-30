from django.urls import path
from member.views import *

app_name = 'member'

urlpatterns = [
    #path('', show_main, name='show_main'),
    #path('login', login)
    path('register/', register_view, name='register'),
    path('login/', login_view, name='login'),
    path('staf/kelola/', kelola_member, name='kelola_member'),
    path('member/identitas/', identitas, name='identitas')
]