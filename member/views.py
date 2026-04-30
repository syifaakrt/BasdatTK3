from django.shortcuts import render

def register_view(request):
    return render(request, 'register.html')

def login_view(request):
    return render(request, 'main/login.html')

def kelola_member(request):
    return render(request,'main/kelola_member.html')

def identitas(request):
    return render(request, 'main/identitas.html')