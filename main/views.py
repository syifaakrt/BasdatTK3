from decimal import Decimal
from django.shortcuts import render


def member_nav_items():
    return [
        {"label": "Dashboard", "href": "#"},
        {"label": "Identitas Saya", "href": "#"},
        {"label": "Klaim Miles", "href": "#"},
        {"label": "Transfer Miles", "href": "#"},
        {"label": "Redeem Hadiah", "href": "/member/redeem-hadiah/"},
        {"label": "Beli Package", "href": "/member/beli-package/"},
        {"label": "Info Tier", "href": "/member/info-tier/"},
        {"label": "Pengaturan Profil", "href": "#"},
        {"label": "Logout", "href": "#"},
    ]


def staff_nav_items():
    return [
        {"label": "Dashboard", "href": "#"},
        {"label": "Kelola Member", "href": "#"},
        {"label": "Kelola Klaim", "href": "#"},
        {"label": "Kelola Hadiah & Penyedia", "href": "#"},
        {"label": "Kelola Mitra", "href": "#"},
        {"label": "Laporan Transaksi", "href": "/staff/laporan-transaksi/"},
        {"label": "Pengaturan Profil", "href": "#"},
        {"label": "Logout", "href": "#"},
    ]


def base_context(role, current_page, page_title):
    if role == "staff":
        nav_items = staff_nav_items()
        user_name = "Yasmin Omar"
        user_code = "S0001"
    else:
        nav_items = member_nav_items()
        user_name = "Citra Dewi"
        user_code = "M0003"

    return {
        "role": role,
        "current_page": current_page,
        "page_title": page_title,
        "nav_items": nav_items,
        "user_name": user_name,
        "user_code": user_code,
    }


def member_redeem_hadiah(request):
    hadiah_list = [
        {
            "kode": "RWD-001",
            "nama": "Tiket Domestik PP",
            "penyedia": "Garuda Indonesia",
            "miles": 15000,
            "deskripsi": "Tiket pulang-pergi rute domestik Indonesia via Garuda Indonesia",
            "valid_start_date": "2024-01-01",
            "program_end": "2025-12-31",
            "is_featured": True,
        },
        {
            "kode": "RWD-002",
            "nama": "Upgrade ke Business Class",
            "penyedia": "Garuda Indonesia",
            "miles": 25000,
            "deskripsi": "Upgrade dari economy class ke business class via Garuda Indonesia",
            "valid_start_date": "2024-01-01",
            "program_end": "2025-12-31",
            "is_featured": False,
        },
        {
            "kode": "RWD-004",
            "nama": "Akses Lounge 1x",
            "penyedia": "ShopeeTravel",
            "miles": 3000,
            "deskripsi": "Akses lounge seluruh bandara partner ShopeeTravel 1 kali masuk",
            "valid_start_date": "2024-01-01",
            "program_end": "2025-12-31",
            "is_featured": False,
        },
        {
            "kode": "RWD-005",
            "nama": "Diskon Hotel 30%",
            "penyedia": "TravelokaPartner",
            "miles": 5000,
            "deskripsi": "Diskon 30% pemesanan hotel melalui Traveloka partner program",
            "valid_start_date": "2024-03-01",
            "program_end": "2025-12-31",
            "is_featured": False,
        },
        {
            "kode": "RWD-006",
            "nama": "Tiket Singapore Airlines",
            "penyedia": "Singapore Airlines",
            "miles": 20000,
            "deskripsi": "Tiket penerbangan Singapore Airlines rute Asia tenggara",
            "valid_start_date": "2024-01-01",
            "program_end": "2026-01-31",
            "is_featured": False,
        },
    ]

    redeem_history = [
        {
            "hadiah": "Akses Lounge 1x",
            "kode_hadiah": "RWD-004",
            "timestamp": "2024-02-05 09:15:00",
            "miles": 3000,
            "status": "Berhasil",
        },
        {
            "hadiah": "Diskon Hotel 30%",
            "kode_hadiah": "RWD-005",
            "timestamp": "2024-06-03 10:00:00",
            "miles": 5000,
            "status": "Berhasil",
        },
    ]

    selected_hadiah = hadiah_list[2]
    member_award_miles = 5000

    context = base_context(
        role="member",
        current_page="Redeem Hadiah",
        page_title="Redeem Hadiah",
    )
    context.update(
        {
            "member_award_miles": member_award_miles,
            "hadiah_list": hadiah_list,
            "redeem_history": redeem_history,
            "selected_hadiah": selected_hadiah,
            "remaining_miles_after_redeem": member_award_miles - selected_hadiah["miles"],
        }
    )
    return render(request, "member/redeem_hadiah.html", context)


def member_beli_package(request):
    packages = [
        {"id": "AMP-001", "jumlah_award_miles": 5000, "harga_paket": Decimal("150000.00")},
        {"id": "AMP-002", "jumlah_award_miles": 10000, "harga_paket": Decimal("280000.00")},
        {"id": "AMP-003", "jumlah_award_miles": 20000, "harga_paket": Decimal("500000.00")},
        {"id": "AMP-004", "jumlah_award_miles": 40000, "harga_paket": Decimal("900000.00")},
        {"id": "AMP-005", "jumlah_award_miles": 75000, "harga_paket": Decimal("1500000.00")},
    ]

    purchase_history = [
        {
            "id": "AMP-003",
            "timestamp": "2024-02-01 10:15:00",
            "jumlah_award_miles": 20000,
            "harga_paket": Decimal("500000.00"),
        },
    ]

    selected_package = packages[2]
    member_award_miles = 5000

    context = base_context(
        role="member",
        current_page="Beli Package",
        page_title="Beli Award Miles Package",
    )
    context.update(
        {
            "member_award_miles": member_award_miles,
            "packages": packages,
            "purchase_history": purchase_history,
            "selected_package": selected_package,
            "total_after_purchase": member_award_miles + selected_package["jumlah_award_miles"],
        }
    )
    return render(request, "member/beli_package.html", context)


def member_info_tier(request):
    tier_list = [
        {"id_tier": "T001", "nama": "Blue", "minimal_frekuensi_terbang": 0, "minimal_tier_miles": 0},
        {"id_tier": "T002", "nama": "Silver", "minimal_frekuensi_terbang": 10, "minimal_tier_miles": 25000},
        {"id_tier": "T003", "nama": "Gold", "minimal_frekuensi_terbang": 25, "minimal_tier_miles": 50000},
        {"id_tier": "T004", "nama": "Platinum", "minimal_frekuensi_terbang": 50, "minimal_tier_miles": 100000},
    ]

    current_member = {
        "nama": "Citra Dewi",
        "nomor_member": "M0003",
        "current_tier": "Silver",
        "tier_miles": 30000,
        "flight_frequency": 14,
        "next_tier": "Gold",
        "miles_to_next_tier": 20000,
    }

    context = base_context(
        role="member",
        current_page="Info Tier",
        page_title="Informasi Tier & Keuntungan",
    )
    context.update(
        {
            "tier_list": tier_list,
            "current_member": current_member,
        }
    )
    return render(request, "member/info_tier.html", context)


def staff_laporan_transaksi(request):
    transactions = [
        {
            "tipe": "Transfer",
            "member": "alice.smith@email.com",
            "jumlah_miles": 2000,
            "timestamp": "2024-01-10 10:30:00",
            "dapat_dihapus": True,
        },
        {
            "tipe": "Redeem",
            "member": "citra.dewi@email.com",
            "jumlah_miles": 3000,
            "timestamp": "2024-02-05 09:15:00",
            "dapat_dihapus": True,
        },
        {
            "tipe": "Pembelian Package",
            "member": "citra.dewi@email.com",
            "jumlah_miles": 20000,
            "timestamp": "2024-02-01 10:15:00",
            "dapat_dihapus": True,
        },
        {
            "tipe": "Klaim Disetujui",
            "member": "alice.smith@email.com",
            "jumlah_miles": 4500,
            "timestamp": "2024-01-10 09:00:00",
            "dapat_dihapus": False,
        },
        {
            "tipe": "Transfer",
            "member": "bob.jones@email.com",
            "jumlah_miles": 1500,
            "timestamp": "2024-03-18 13:30:00",
            "dapat_dihapus": True,
        },
        {
            "tipe": "Redeem",
            "member": "queen.park@email.com",
            "jumlah_miles": 5000,
            "timestamp": "2024-06-03 10:00:00",
            "dapat_dihapus": True,
        },
    ]

    top_total_miles = [
        {"member": "peter.parker@email.com", "total_miles": 130000},
        {"member": "frank.ocean@email.com", "total_miles": 120000},
        {"member": "bob.jones@email.com", "total_miles": 115000},
    ]

    top_activity = [
        {"member": "citra.dewi@email.com", "aktivitas": "Redeem", "jumlah": 1},
        {"member": "alice.smith@email.com", "aktivitas": "Transfer", "jumlah": 1},
        {"member": "bob.jones@email.com", "aktivitas": "Transfer", "jumlah": 1},
    ]

    context = base_context(
        role="staff",
        current_page="Laporan Transaksi",
        page_title="Laporan & Riwayat Transaksi Miles",
    )
    context.update(
        {
            "transactions": transactions,
            "top_total_miles": top_total_miles,
            "top_activity": top_activity,
            "stats": {
                "total_miles_beredar": 875000,
                "total_redeem_bulan_ini": 16,
                "total_klaim_disetujui": 12,
            },
            "filters": {
                "selected_type": "Semua",
                "selected_member": "Semua Member",
                "date_start": "2024-01-01",
                "date_end": "2024-08-31",
            },
        }
    )
    return render(request, "staff/laporan_transaksi.html", context)
