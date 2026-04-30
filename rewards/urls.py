from django.urls import path
from . import views

app_name = "rewards"

urlpatterns = [
    path("", views.member_redeem_hadiah, name="home"),
    path("guest/", views.guest_home, name="guest_home"),
    path("member/redeem-hadiah/", views.member_redeem_hadiah, name="member_redeem_hadiah"),
    path("member/beli-package/", views.member_beli_package, name="member_beli_package"),
    path("member/info-tier/", views.member_info_tier, name="member_info_tier"),
    path("staff/laporan-transaksi/", views.staff_laporan_transaksi, name="staff_laporan_transaksi"),
]
