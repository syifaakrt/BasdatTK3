from .models import Pengguna, Member, Staf

def user_context(request):
    """
    Auto-inject 'role' dan 'nama_lengkap' ke semua template.
    Taruh ini di TEMPLATES > OPTIONS > context_processors di settings.py.
    """
    email = request.session.get('user_email')
    if not email:
        return {'role': None, 'nama_lengkap': ''}

    try:
        user = Pengguna.objects.get(pk=email)
    except Pengguna.DoesNotExist:
        return {'role': None, 'nama_lengkap': ''}

    nama_lengkap = f"{user.salutation} {user.first_mid_name} {user.last_name}".strip()

    if Member.objects.filter(email_id=email).exists():
        role = 'member'
    elif Staf.objects.filter(email_id=email).exists():
        role = 'staff'
    else:
        role = None

    return {
        'role': role,
        'nama_lengkap': nama_lengkap,
    }