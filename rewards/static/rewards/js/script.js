// =====================
// DUMMY DATA
// =====================
let hadiahData = [
  { kode: 'RWD-001', nama: 'Tiket Domestik PP',          miles: 15000, deskripsi: 'Tiket pulang-pergi rute domestik Indonesia via Garuda Indonesia',  mulai: '2024-01-01', akhir: '2025-12-31' },
  { kode: 'RWD-002', nama: 'Upgrade ke Business Class',  miles: 25000, deskripsi: 'Upgrade dari economy class ke business class via Garuda Indonesia', mulai: '2024-01-01', akhir: '2025-12-31' },
  { kode: 'RWD-003', nama: 'Voucher Hotel Rp 500.000',   miles: 8000,  deskripsi: 'Voucher menginap 1 malam di Hotel Indonesia Kempinski Jakarta',     mulai: '2024-06-01', akhir: '2025-06-30' },
  { kode: 'RWD-004', nama: 'Akses Lounge 1x',            miles: 3000,  deskripsi: 'Akses lounge seluruh bandara partner ShopeeTravel 1 kali masuk',    mulai: '2024-01-01', akhir: '2025-12-31' },
  { kode: 'RWD-005', nama: 'Diskon Hotel 30%',           miles: 5000,  deskripsi: 'Diskon 30% pemesanan hotel melalui Traveloka partner program',       mulai: '2024-03-01', akhir: '2025-12-31' },
  { kode: 'RWD-006', nama: 'Tiket Singapore Airlines',   miles: 20000, deskripsi: 'Tiket penerbangan Singapore Airlines rute Asia Tenggara',            mulai: '2024-01-01', akhir: '2026-01-31' },
  { kode: 'RWD-007', nama: 'Free Bagasi 10kg SQ',        miles: 6000,  deskripsi: 'Extra bagasi 10kg untuk penerbangan Singapore Airlines',             mulai: '2024-04-01', akhir: '2025-09-30' },
  { kode: 'RWD-008', nama: 'Voucher Agoda Rp 300.000',   miles: 4000,  deskripsi: 'Voucher pemesanan hotel melalui Agoda senilai Rp 300.000',           mulai: '2024-07-01', akhir: '2025-07-31' },
  { kode: 'RWD-009', nama: 'Tiket Pesawat TiketPartner', miles: 12000, deskripsi: 'Tiket pesawat domestik maupun internasional via Tiket.com',          mulai: '2024-01-01', akhir: '2025-12-31' },
  { kode: 'RWD-010', nama: 'Akses Lounge Premium MH',    miles: 7000,  deskripsi: 'Akses Malaysia Airlines Golden Lounge di Kuala Lumpur',              mulai: '2024-02-01', akhir: '2025-12-31' },
];

let editIndex = null;

// =====================
// HELPERS
// =====================
function getStatus(akhir) {
  return new Date(akhir) >= new Date() ? 'Aktif' : 'Expired';
}

function formatMiles(n) {
  return Number(n).toLocaleString('id-ID');
}

function generateKode() {
  const max = hadiahData.reduce((acc, h) => {
    const num = parseInt(h.kode.replace('RWD-', ''));
    return num > acc ? num : acc;
  }, 0);
  return 'RWD-' + String(max + 1).padStart(3, '0');
}

// =====================
// MODAL HELPERS (Tailwind)
// =====================
function showModal() {
  const m = document.getElementById('modalForm');
  m.classList.remove('hidden');
  m.classList.add('flex');
}

function closeModal() {
  const m = document.getElementById('modalForm');
  m.classList.add('hidden');
  m.classList.remove('flex');
}

document.getElementById('modalForm').addEventListener('click', function(e) {
  if (e.target === this) closeModal();
});

// =====================
// RENDER TABLE
// =====================
function renderTable(data) {
  const source = data || hadiahData;
  const tbody = document.getElementById('hadiahTable');
  tbody.innerHTML = '';

  let aktif = 0, expired = 0, totalMiles = 0;
  hadiahData.forEach(h => {
    const s = getStatus(h.akhir);
    if (s === 'Aktif') aktif++; else expired++;
    totalMiles += Number(h.miles);
  });

  document.getElementById('totalHadiah').textContent   = hadiahData.length;
  document.getElementById('hadiahAktif').textContent   = aktif;
  document.getElementById('hadiahExpired').textContent = expired;
  document.getElementById('totalMiles').textContent    = formatMiles(totalMiles);

  if (source.length === 0) {
    tbody.innerHTML = `<tr><td colspan="7" class="text-center text-gray-400 py-6 text-sm">Tidak ada data ditemukan.</td></tr>`;
    return;
  }

  source.forEach((h) => {
    const status = getStatus(h.akhir);
    const realIndex = hadiahData.indexOf(h);
    const badgeClass = status === 'Aktif'
      ? 'bg-green-100 text-green-800'
      : 'bg-red-100 text-red-800';

    tbody.innerHTML += `
      <tr class="border-b border-gray-100 last:border-0 hover:bg-gray-50">
        <td class="px-3.5 py-2.5 text-xs text-gray-400">${h.kode}</td>
        <td class="px-3.5 py-2.5">
          <div class="text-sm font-medium text-[#1a2540]">${h.nama}</div>
          <div class="text-[11px] text-gray-400 mt-0.5">${h.deskripsi}</div>
        </td>
        <td class="px-3.5 py-2.5 text-sm font-semibold text-[#1a2540]">${formatMiles(h.miles)}</td>
        <td class="px-3.5 py-2.5 text-xs text-gray-500">${h.mulai}</td>
        <td class="px-3.5 py-2.5 text-xs text-gray-500">${h.akhir}</td>
        <td class="px-3.5 py-2.5">
          <span class="text-[11px] font-medium px-2.5 py-1 rounded-full ${badgeClass}">${status}</span>
        </td>
        <td class="px-3.5 py-2.5">
          <div class="flex gap-1.5 items-center">
            <button onclick="openEdit(${realIndex})" title="Edit"
              class="text-blue-500 hover:bg-blue-50 text-base px-1.5 py-0.5 rounded transition">✎</button>
            <button onclick="deleteHadiah(${realIndex})" title="Hapus"
              class="text-red-500 hover:bg-red-50 text-base px-1.5 py-0.5 rounded transition">✕</button>
          </div>
        </td>
      </tr>
    `;
  });
}

// =====================
// FILTER
// =====================
function filterTable() {
  const search = document.getElementById('searchInput').value.toLowerCase();
  const status = document.getElementById('filterStatus').value;

  const filtered = hadiahData.filter(h => {
    const matchSearch = h.nama.toLowerCase().includes(search) || h.deskripsi.toLowerCase().includes(search);
    const matchStatus = status === '' || getStatus(h.akhir) === status;
    return matchSearch && matchStatus;
  });

  renderTable(filtered);
}

// =====================
// MODAL OPEN
// =====================
function openCreate() {
  editIndex = null;
  document.getElementById('modalTitle').textContent = 'Tambah Hadiah';
  document.getElementById('nama').value = '';
  document.getElementById('miles').value = '';
  document.getElementById('deskripsi').value = '';
  document.getElementById('mulai').value = '';
  document.getElementById('akhir').value = '';
  showModal();
}

function openEdit(index) {
  editIndex = index;
  const h = hadiahData[index];
  document.getElementById('modalTitle').textContent = 'Edit Hadiah';
  document.getElementById('nama').value = h.nama;
  document.getElementById('miles').value = h.miles;
  document.getElementById('deskripsi').value = h.deskripsi;
  document.getElementById('mulai').value = h.mulai;
  document.getElementById('akhir').value = h.akhir;
  showModal();
}

// =====================
// SAVE
// =====================
function saveHadiah() {
  const nama      = document.getElementById('nama').value.trim();
  const miles     = document.getElementById('miles').value.trim();
  const deskripsi = document.getElementById('deskripsi').value.trim();
  const mulai     = document.getElementById('mulai').value;
  const akhir     = document.getElementById('akhir').value;

  if (!nama || !miles || !deskripsi || !mulai || !akhir) {
    alert('Harap lengkapi semua field!');
    return;
  }

  const data = { kode: '', nama, miles: parseInt(miles), deskripsi, mulai, akhir };

  if (editIndex === null) {
    data.kode = generateKode();
    hadiahData.push(data);
  } else {
    data.kode = hadiahData[editIndex].kode;
    hadiahData[editIndex] = data;
  }

  closeModal();
  filterTable();
}

// =====================
// DELETE
// =====================
function deleteHadiah(index) {
  if (confirm(`Hapus hadiah "${hadiahData[index].nama}"?`)) {
    hadiahData.splice(index, 1);
    filterTable();
  }
}

// =====================
// INIT
// =====================
renderTable();