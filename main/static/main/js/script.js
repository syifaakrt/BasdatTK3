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
  { kode: 'RWD-007', nama: 'Free Bagasi 10kg SQ',        miles: 6000,  deskripsi: 'Extra bagasi 10kg untuk penerbangan Singapore Airlines',            mulai: '2024-04-01', akhir: '2025-09-30' },
  { kode: 'RWD-008', nama: 'Voucher Agoda Rp 300.000',   miles: 4000,  deskripsi: 'Voucher pemesanan hotel melalui Agoda senilai Rp 300.000',          mulai: '2024-07-01', akhir: '2025-07-31' },
  { kode: 'RWD-009', nama: 'Tiket Pesawat TiketPartner', miles: 12000, deskripsi: 'Tiket pesawat domestik maupun internasional via Tiket.com',         mulai: '2024-01-01', akhir: '2025-12-31' },
  { kode: 'RWD-010', nama: 'Akses Lounge Premium MH',    miles: 7000,  deskripsi: 'Akses Malaysia Airlines Golden Lounge di Kuala Lumpur',             mulai: '2024-02-01', akhir: '2025-12-31' },
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
// RENDER TABLE
// =====================
function renderTable(data) {
  const source = data || hadiahData;
  const tbody = document.getElementById('hadiahTable');
  tbody.innerHTML = '';

  let aktif = 0, expired = 0, totalMiles = 0;

  // Always compute stats from full hadiahData (not filtered)
  hadiahData.forEach(h => {
    const s = getStatus(h.akhir);
    if (s === 'Aktif') aktif++; else expired++;
    totalMiles += Number(h.miles);
  });

  document.getElementById('totalHadiah').textContent  = hadiahData.length;
  document.getElementById('hadiahAktif').textContent  = aktif;
  document.getElementById('hadiahExpired').textContent = expired;
  document.getElementById('totalMiles').textContent   = formatMiles(totalMiles);

  if (source.length === 0) {
    tbody.innerHTML = `<tr><td colspan="7" style="text-align:center;color:#aab4c8;padding:24px;">Tidak ada data ditemukan.</td></tr>`;
    return;
  }

  source.forEach((h, i) => {
    const status = getStatus(h.akhir);
    const realIndex = hadiahData.indexOf(h);
    tbody.innerHTML += `
      <tr>
        <td class="td-kode">${h.kode}</td>
        <td>
          <div class="td-nama">${h.nama}</div>
          <div class="td-desc">${h.deskripsi}</div>
        </td>
        <td class="td-miles">${formatMiles(h.miles)}</td>
        <td class="td-date">${h.mulai}</td>
        <td class="td-date">${h.akhir}</td>
        <td>
          <span class="badge ${status === 'Aktif' ? 'badge-active' : 'badge-expired'}">${status}</span>
        </td>
        <td>
          <div class="aksi">
            <button class="btn-edit" onclick="openEdit(${realIndex})" title="Edit">✎</button>
            <button class="btn-delete" onclick="deleteHadiah(${realIndex})" title="Hapus">✕</button>
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
// MODAL
// =====================
function openCreate() {
  editIndex = null;
  document.getElementById('modalTitle').textContent = 'Tambah Hadiah';
  document.getElementById('nama').value = '';
  document.getElementById('miles').value = '';
  document.getElementById('deskripsi').value = '';
  document.getElementById('mulai').value = '';
  document.getElementById('akhir').value = '';
  document.getElementById('modalForm').classList.add('show');
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
  document.getElementById('modalForm').classList.add('show');
}

function closeModal() {
  document.getElementById('modalForm').classList.remove('show');
}

// Close modal when clicking outside
document.getElementById('modalForm').addEventListener('click', function(e) {
  if (e.target === this) closeModal();
});

// =====================
// SAVE (Create / Update)
// =====================
function saveHadiah() {
  const nama = document.getElementById('nama').value.trim();
  const miles = document.getElementById('miles').value.trim();
  const deskripsi = document.getElementById('deskripsi').value.trim();
  const mulai = document.getElementById('mulai').value;
  const akhir = document.getElementById('akhir').value;

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