from django.shortcuts import render, redirect
from django.contrib import messages
from .models import Pengguna, Member, Staf, ClaimMissingMiles, Redeem, Transfer, MemberAwardMilesPackage

def get_current_user(request):
    email = request.session.get('user_email')
    if not email:
        return None
    try:
        return Pengguna.objects.get(pk=email)
    except Pengguna.DoesNotExist:
        return None

def get_role(email):
    if Member.objects.filter(email_id=email).exists():
        return 'member'
    if Staf.objects.filter(email_id=email).exists():
        return 'staff'
    return None

# =====================
# LOGIN
# =====================
def login_view(request):
    if request.method == 'POST':
        email    = request.POST.get('email', '').strip()
        password = request.POST.get('password', '').strip()
        try:
            user = Pengguna.objects.get(email=email, password=password)
            request.session['user_email'] = user.email
            return redirect('dashboard')
        except Pengguna.DoesNotExist:
            messages.error(request, 'Email atau password salah.')
    return render(request, 'login.html')

# =====================
# LOGOUT
# =====================
def logout_view(request):
    request.session.flush()
    return redirect('login')

# =====================
# DASHBOARD
# =====================
def dashboard(request):
    user = get_current_user(request)
    if not user:
        return redirect('login')

    role = get_role(user.email)
    context = {'user': user}

    if role == 'member':
        member = Member.objects.select_related('id_tier').get(email_id=user.email)

        transaksi = []

        redeems = Redeem.objects.select_related('kode_hadiah').filter(email_member_id=user.email).order_by('-timestamp')[:5]
        for r in redeems:
            transaksi.append({
                'tipe': 'Redeem',
                'tanggal': r.timestamp.strftime('%Y-%m-%d %H:%M'),
                'miles': -r.kode_hadiah.miles,
            })

        transfers = Transfer.objects.filter(email_member_1_id=user.email).order_by('-timestamp')[:5]
        for t in transfers:
            transaksi.append({
                'tipe': 'Transfer',
                'tanggal': t.timestamp.strftime('%Y-%m-%d %H:%M'),
                'miles': -t.jumlah,
            })

        packages = MemberAwardMilesPackage.objects.select_related('id_award_miles_package').filter(email_member_id=user.email).order_by('-timestamp')[:5]
        for p in packages:
            transaksi.append({
                'tipe': 'Package',
                'tanggal': p.timestamp.strftime('%Y-%m-%d %H:%M'),
                'miles': p.id_award_miles_package.jumlah_award_miles,
            })

        transaksi = sorted(transaksi, key=lambda x: x['tanggal'], reverse=True)[:5]

        context.update({
            'member': member,
            'tier_nama': member.id_tier.nama,
            'transaksi': transaksi,
        })

    elif role == 'staff':
        staf = Staf.objects.select_related('kode_maskapai').get(email_id=user.email)
        klaim_menunggu  = ClaimMissingMiles.objects.filter(status_penerimaan='Menunggu').count()
        klaim_disetujui = ClaimMissingMiles.objects.filter(email_staf_id=user.email, status_penerimaan='Diterima').count()
        klaim_ditolak   = ClaimMissingMiles.objects.filter(email_staf_id=user.email, status_penerimaan='Ditolak').count()

        context.update({
            'staf': staf,
            'maskapai': staf.kode_maskapai.nama_maskapai,
            'klaim_menunggu': klaim_menunggu,
            'klaim_disetujui': klaim_disetujui,
            'klaim_ditolak': klaim_ditolak,
        })

    return render(request, 'dashboard.html', context)

# =====================
# KELOLA HADIAH
# =====================
def kelola_hadiah(request):
    user = get_current_user(request)
    if not user or get_role(user.email) != 'staff':
        return redirect('login')
    return render(request, 'kelola_hadiah.html', {'user': user})

# =====================
# KELOLA MITRA
# =====================
def kelola_mitra(request):
    user = get_current_user(request)
    if not user or get_role(user.email) != 'staff':
        return redirect('login')
    return render(request, 'kelola_mitra.html', {'user': user})