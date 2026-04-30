from django.urls import path
from . import views

app_name = "rewards"

urlpatterns = [
    path("guest/", views.guest_home, name="guest_home"),
    path("member/redeem-hadiah/", views.member_redeem_hadiah, name="member_redeem_hadiah"),
    path("member/beli-package/", views.member_beli_package, name="member_beli_package"),
    path("member/info-tier/", views.member_info_tier, name="member_info_tier"),
    path("staf/laporan-transaksi/", views.staff_laporan_transaksi, name="staff_laporan_transaksi"),
    path("staf/kelola-mitra", views.kelola_mitra, name='kelola_mitra'),
    path("staf/kelola-hadiah", views.kelola_hadiah, name='kelola_hadiah'),
]


