// =====================
// DUMMY DATA
// =====================

const dataMember = {
  role: 'member',
  salutation: 'Ms.',
  firstName: 'Alice',
  midName: '',
  lastName: 'Smith',
  email: 'alice.smith@email.com',
  countryCode: '+62',
  noHp: '81234567890',
  kewarganegaraan: 'Indonesia',
  tanggalLahir: '1992-03-22',
  // Member fields
  nomorMember: 'M0001',
  tanggalBergabung: '2020-01-15',
  tier: 'T003', // Gold
  totalMiles: 62000,
  awardMiles: 15000,
  transaksi: [
    { tipe: 'Transfer', tanggal: '2025-01-15 10:30', miles: -5000 },
    { tipe: 'Redeem',   tanggal: '2025-01-20 16:00', miles: -3000 },
    { tipe: 'Package',  tanggal: '2025-03-01 08:00', miles: +10000 },
    { tipe: 'Klaim',    tanggal: '2025-03-10 14:15', miles: +2500 },
    { tipe: 'Transfer', tanggal: '2025-04-05 09:45', miles: -1000 },
  ],
};

const dataStaff = {
  role: 'staff',
  salutation: 'Ms.',
  firstName: 'Yasmin',
  midName: '',
  lastName: 'Omar',
  email: 'yasmin.omar@email.com',
  countryCode: '+62',
  noHp: '87800111111',
  kewarganegaraan: 'Indonesia',
  tanggalLahir: '1988-07-10',
  // Staff fields
  idStaf: 'S0021',
  maskapai: 'Garuda Indonesia',
  klaimMenunggu: 2,
  klaimDisetujui: 1,
  klaimDitolak: 1,
};

// =====================
// HELPERS
// =====================
function namaLengkap(d) {
  return [d.salutation, d.firstName, d.midName, d.lastName].filter(Boolean).join(' ');
}

function formatMiles(n) {
  return Number(n).toLocaleString('id-ID');
}

function getTierLabel(id) {
  const map = { T001: 'Bronze', T002: 'Silver', T003: 'Gold', T004: 'Platinum' };
  return map[id] || id;
}

function getTierClass(id) {
  const map = { T001: 'tier-bronze', T002: 'tier-silver', T003: 'tier-gold', T004: 'tier-platinum' };
  return map[id] || '';
}

function getTipeClass(tipe) {
  const map = { Transfer: 'type-transfer', Redeem: 'type-redeem', Package: 'type-package', Klaim: 'type-klaim' };
  return map[tipe] || '';
}

// =====================
// RENDER
// =====================
function render(data) {
  // Navbar
  document.getElementById('navbar-member').style.display = data.role === 'member' ? 'flex' : 'none';
  document.getElementById('navbar-staff').style.display  = data.role === 'staff'  ? 'flex' : 'none';

  // Sub navbar
  const subRole = data.role === 'member' ? 'Member' : 'Staff';
  document.getElementById('subNavbar').innerHTML =
    `Masuk sebagai <span class="user-highlight">${namaLengkap(data)}</span> · ${subRole}`;

  // Welcome
  document.getElementById('dashWelcome').textContent = `Selamat datang, ${namaLengkap(data)}`;

  // Info pribadi
  document.getElementById('infoNama').textContent     = namaLengkap(data);
  document.getElementById('infoEmail').textContent    = data.email;
  document.getElementById('infoTelepon').textContent  = `${data.countryCode} ${data.noHp}`;
  document.getElementById('infoWarga').textContent    = data.kewarganegaraan;
  document.getElementById('infoLahir').textContent    = data.tanggalLahir;

  // Tanggal bergabung hanya untuk member
  const tBergabungWrap = document.getElementById('infoTanggalBergabungWrap');
  if (data.role === 'member') {
    tBergabungWrap.style.display = '';
    document.getElementById('infoTanggalBergabung').textContent = data.tanggalBergabung;
  } else {
    tBergabungWrap.style.display = 'none';
  }

  // Member stats
  const memberStats = document.getElementById('memberStats');
  const staffStats  = document.getElementById('staffStats');

  if (data.role === 'member') {
    memberStats.style.display = '';
    staffStats.style.display  = 'none';

    document.getElementById('statNomorMember').textContent = data.nomorMember;

    const tierLabel = getTierLabel(data.tier);
    document.getElementById('statTier').innerHTML =
      `<span class="tier-badge ${getTierClass(data.tier)}">${tierLabel}</span>`;

    document.getElementById('statTotalMiles').textContent = formatMiles(data.totalMiles);
    document.getElementById('statAwardMiles').textContent = formatMiles(data.awardMiles);

    // Transaksi
    const list = document.getElementById('transaksiList');
    list.innerHTML = '';
    data.transaksi.forEach(t => {
      const plus = t.miles > 0;
      list.innerHTML += `
        <div class="transaksi-item">
          <div class="transaksi-left">
            <span class="transaksi-type ${getTipeClass(t.tipe)}">${t.tipe}</span>
            <span class="transaksi-date">${t.tanggal}</span>
          </div>
          <span class="transaksi-miles ${plus ? 'miles-plus' : 'miles-minus'}">
            ${plus ? '+' : ''}${formatMiles(t.miles)} miles
          </span>
        </div>
      `;
    });

  } else {
    memberStats.style.display = 'none';
    staffStats.style.display  = '';

    document.getElementById('statIdStaf').textContent        = data.idStaf;
    document.getElementById('statMaskapai').textContent      = data.maskapai;
    document.getElementById('statKlaimMenunggu').textContent = data.klaimMenunggu;
    document.getElementById('statKlaimDisetujui').textContent = data.klaimDisetujui;
    document.getElementById('statKlaimDitolak').textContent  = data.klaimDitolak;
  }
}

// =====================
// ROLE SWITCHER
// =====================
let currentRole = 'member';

function setRole(role) {
  currentRole = role;
  document.getElementById('btn-member').classList.toggle('active', role === 'member');
  document.getElementById('btn-staff').classList.toggle('active', role === 'staff');
  render(role === 'member' ? dataMember : dataStaff);
}

// =====================
// INIT
// =====================
setRole('member');