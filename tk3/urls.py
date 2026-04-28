from django.contrib import admin
from django.urls import path
from django.views.generic import TemplateView
from main import views

urlpatterns = [
    path('admin/', admin.site.urls),

    # Auth
    path('login/',   views.login_view,  name='login'),
    path('logout/',  views.logout_view, name='logout'),

    # Halaman utama
    path('dashboard/',     views.dashboard,     name='dashboard'),
    path('kelola-hadiah/', views.kelola_hadiah, name='kelola_hadiah'),
    path('kelola-mitra/',  views.kelola_mitra,  name='kelola_mitra'),

    # Placeholder — belum dibuat, biar navbar ga error
    path('kelola-member/',    TemplateView.as_view(template_name='coming_soon.html'), name='kelola_member'),
    path('kelola-klaim/',     TemplateView.as_view(template_name='coming_soon.html'), name='kelola_klaim'),
    path('laporan/',          TemplateView.as_view(template_name='coming_soon.html'), name='laporan_transaksi'),
    path('profil/',           TemplateView.as_view(template_name='coming_soon.html'), name='pengaturan_profil'),
    path('identitas/',        TemplateView.as_view(template_name='coming_soon.html'), name='identitas_saya'),
    path('klaim-miles/',      TemplateView.as_view(template_name='coming_soon.html'), name='klaim_miles'),
    path('transfer/',         TemplateView.as_view(template_name='coming_soon.html'), name='transfer_miles'),
    path('redeem/',           TemplateView.as_view(template_name='coming_soon.html'), name='redeem_hadiah'),
    path('package/',          TemplateView.as_view(template_name='coming_soon.html'), name='beli_package'),
    path('tier/',             TemplateView.as_view(template_name='coming_soon.html'), name='info_tier'),
]