from django.shortcuts import render, redirect
from django.contrib import messages
from django.contrib.auth.hashers import check_password, make_password

def get_session(request):
    email = request.session.get('email', 'alice.smith@email.com')
    role = request.session.get('role', 'member')
    return email, role

# =====================
# FITUR 8 - CLAIM MISSING MILES (MEMBER)
# =====================

def claim_list(request):
    email, role = get_session(request)

    status_filter = request.GET.get('status', '')

    # HARDCODE sementara
    all_claims = [
        (1, 'GA', 'CGK', 'DPS', '2024-10-01', 'GA404', 'Business', 'Disetujui', '2024-10-05 18:45:00', 'TKT-001', 'PNR001'),
        (2, 'SQ', 'SIN', 'NRT', '2024-11-15', 'SQ12', 'Economy', 'Menunggu', '2024-11-20 18:45:00', 'TKT-002', 'PNR002'),
        (3, 'GA', 'CGK', 'SUB', '2024-12-01', 'GA310', 'Economy', 'Ditolak', '2024-12-05 18:45:00', 'TKT-003', 'PNR003'),
    ]

    if status_filter:
        claims = [c for c in all_claims if c[7] == status_filter]
    else:
        claims = all_claims

    maskapai_list = [('GA', 'Garuda Indonesia'), ('SQ', 'Singapore Airlines'), ('MH', 'Malaysia Airlines'), ('QG', 'Citilink')]
    bandara_list = [('CGK', 'Soekarno-Hatta', 'Jakarta'), ('DPS', 'Ngurah Rai', 'Bali'), ('SIN', 'Changi', 'Singapore'), ('NRT', 'Narita', 'Tokyo'), ('SUB', 'Juanda', 'Surabaya')]

    return render(request, 'miles/claim_list.html', {
        'claims': claims,
        'maskapai_list': maskapai_list,
        'bandara_list': bandara_list,
        'status_filter': status_filter,
        'email': email,
    })


def claim_create(request):
    email, role = get_session(request)
    if request.method == 'POST':
        messages.success(request, 'Klaim berhasil diajukan!')
    return redirect('claim_list')


def claim_edit(request, id):
    email, role = get_session(request)
    if request.method == 'POST':
        messages.success(request, 'Klaim berhasil diperbarui!')
    return redirect('claim_list')


def claim_delete(request, id):
    email, role = get_session(request)
    if request.method == 'POST':
        messages.success(request, 'Klaim berhasil dibatalkan.')
    return redirect('claim_list')


# =====================
# FITUR 9 - CLAIM MISSING MILES (STAF)
# =====================

def staf_claim_list(request):
    email, role = get_session(request)

    status_filter = request.GET.get('status', '')
    maskapai_filter = request.GET.get('maskapai', '')
    tanggal_dari = request.GET.get('tanggal_dari', '')
    tanggal_sampai = request.GET.get('tanggal_sampai', '')

    # HARDCODE sementara
    all_claims = [
        (1, 'M0001', 'John W. Doe', 'john@example.com', 'GA', 'CGK → DPS', '2024-10-01', 'GA404', 'Business', '2024-10-05 18:45:00', 'Disetujui', 'CGK', 'DPS'),
        (2, 'M0001', 'John W. Doe', 'john@example.com', 'SQ', 'SIN → NRT', '2024-11-15', 'SQ12', 'Economy', '2024-11-20 18:45:00', 'Menunggu', 'SIN', 'NRT'),
        (3, 'M0002', 'Jane Smith', 'jane@example.com', 'GA', 'CGK → SUB', '2024-12-01', 'GA310', 'Economy', '2024-12-05 18:45:00', 'Ditolak', 'CGK', 'SUB'),
        (4, 'M0003', 'Budi A. Santoso', 'budi@example.com', 'MH', 'KUL → BKK', '2025-01-10', 'MH780', 'Premium Economy', '2025-01-15 18:45:00', 'Menunggu', 'KUL', 'BKK'),
    ]

    claims = all_claims
    if status_filter:
        claims = [c for c in claims if c[10] == status_filter]
    if maskapai_filter:
        claims = [c for c in claims if c[4] == maskapai_filter]

    maskapai_list = [('GA', 'Garuda Indonesia'), ('SQ', 'Singapore Airlines'), ('MH', 'Malaysia Airlines'), ('QG', 'Citilink')]

    return render(request, 'miles/staf_claim_list.html', {
        'claims': claims,
        'maskapai_list': maskapai_list,
        'status_filter': status_filter,
        'maskapai_filter': maskapai_filter,
        'tanggal_dari': tanggal_dari,
        'tanggal_sampai': tanggal_sampai,
        'email': email,
    })


def staf_claim_update(request, id):
    email, role = get_session(request)
    if request.method == 'POST':
        status_baru = request.POST.get('status')
        messages.success(request, f'Status klaim berhasil diubah menjadi {status_baru}.')
    return redirect('staf_claim_list')


# =====================
# FITUR 10 - TRANSFER MILES (MEMBER)
# =====================

def transfer_list(request):
    email, role = get_session(request)

    # HARDCODE sementara
    transfers = [
        ('2025-01-15 10:30', 'Peter Parker', 'peter.parker@gmail.com', 5000, 'Hadiah ulang tahun', 'Kirim'),
        ('2025-02-01 14:00', 'Olivia Brown', 'olivia.brown@gmail.com', 2000, '-', 'Terima'),
    ]
    award_miles = 32000

    return render(request, 'miles/transfer_list.html', {
        'transfers': transfers,
        'award_miles': award_miles,
        'email': email,
    })


def transfer_create(request):
    email, role = get_session(request)
    if request.method == 'POST':
        jumlah = request.POST.get('jumlah')
        messages.success(request, f'Transfer {jumlah} miles berhasil!')
    return redirect('transfer_list')


# =====================
# PENGATURAN PROFIL
# =====================

def pengaturan_profile(request):
    email, role = get_session(request)

    if role == 'member':
        profil = (
            'ryland.grace@email.com', 'Mr.', 'Ryland', 'Grace',
            '+65', '9123456001', '1997-04-25', 'Singaporean',
            'M0001', '2020-01-15'
        )
    else:
        profil = (
            'admin@aeromiles.com', 'Mr.', 'Admin', 'Aero',
            '+62', '81111111111', '1988-01-01', 'Indonesian',
            'S0001', 'GA'
        )

    maskapai_list = [('GA', 'Garuda Indonesia'), ('SQ', 'Singapore Airlines'), ('MH', 'Malaysia Airlines')]

    return render(request, 'pengaturan_profile.html', {
        'profil': profil,
        'role': role,
        'maskapai_list': maskapai_list,
    })


def update_profile(request):
    email, role = get_session(request)
    if request.method == 'POST':
        messages.success(request, 'Profil berhasil diperbarui!')
    return redirect('pengaturan_profile')


def update_password(request):
    email, role = get_session(request)
    if request.method == 'POST':
        messages.success(request, 'Password berhasil diubah!')
    return redirect('pengaturan_profile')