// =====================
// DUMMY DATA
// =====================
let mitraData = [
  { emailMitra: 'partner@traveloka.com',      idPenyedia: 6,  namaMitra: 'TravelokaPartner',         tanggalKerjaSama: '2022-01-15' },
  { emailMitra: 'partner@hotelindonesia.com', idPenyedia: 7,  namaMitra: 'Hotel Indonesia Kempinski', tanggalKerjaSama: '2021-06-01' },
  { emailMitra: 'partner@shopeetravel.com',   idPenyedia: 8,  namaMitra: 'ShopeeTravel',              tanggalKerjaSama: '2023-03-10' },
  { emailMitra: 'partner@agoda.com',          idPenyedia: 9,  namaMitra: 'AgodaPartner',              tanggalKerjaSama: '2022-09-20' },
  { emailMitra: 'partner@tiket.com',          idPenyedia: 10, namaMitra: 'TiketPartner',              tanggalKerjaSama: '2023-07-05' },
];

let editIndex = null;

// =====================
// HELPERS
// =====================
function getDurasi(tanggal) {
  const start = new Date(tanggal);
  const now = new Date();
  const diffMs = now - start;
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
  const years = Math.floor(diffDays / 365);
  const months = Math.floor((diffDays % 365) / 30);
  if (years > 0) return `${years} thn ${months} bln`;
  return `${months} bulan`;
}

function populatePenyediaFilter() {
  const select = document.getElementById('filterPenyedia');
  const ids = [...new Set(mitraData.map(m => m.idPenyedia))].sort((a, b) => a - b);
  // Clear existing options except the first
  while (select.options.length > 1) select.remove(1);
  ids.forEach(id => {
    const opt = document.createElement('option');
    opt.value = id;
    opt.textContent = `Penyedia #${id}`;
    select.appendChild(opt);
  });
}

// =====================
// RENDER TABLE
// =====================
function renderTable(data) {
  const source = data || mitraData;
  const tbody = document.getElementById('mitraTable');
  tbody.innerHTML = '';

  // Stats always from full data
  const uniquePenyedia = new Set(mitraData.map(m => m.idPenyedia)).size;
  const earliestYear = mitraData.length
    ? Math.min(...mitraData.map(m => new Date(m.tanggalKerjaSama).getFullYear()))
    : '-';

  document.getElementById('totalMitra').textContent    = mitraData.length;
  document.getElementById('mitraAktif').textContent    = mitraData.length; // all active since no status field
  document.getElementById('totalPenyedia').textContent = uniquePenyedia;
  document.getElementById('kerjasamaTerlama').textContent = earliestYear !== '-' ? earliestYear : '-';

  if (source.length === 0) {
    tbody.innerHTML = `<tr><td colspan="6" style="text-align:center;color:#aab4c8;padding:24px;">Tidak ada data ditemukan.</td></tr>`;
    return;
  }

  source.forEach((m) => {
    const realIndex = mitraData.indexOf(m);
    const durasi = getDurasi(m.tanggalKerjaSama);
    tbody.innerHTML += `
      <tr>
        <td class="td-id">#${m.idPenyedia}</td>
        <td class="td-email">${m.emailMitra}</td>
        <td class="td-nama-mitra">${m.namaMitra}</td>
        <td class="td-date">${m.tanggalKerjaSama}</td>
        <td class="td-durasi"><span class="durasi-badge">${durasi}</span></td>
        <td>
          <div class="aksi">
            <button class="btn-edit" onclick="openEdit(${realIndex})" title="Edit">✎</button>
            <button class="btn-delete" onclick="deleteMitra(${realIndex})" title="Hapus">✕</button>
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
  const penyedia = document.getElementById('filterPenyedia').value;

  const filtered = mitraData.filter(m => {
    const matchSearch = m.namaMitra.toLowerCase().includes(search) || m.emailMitra.toLowerCase().includes(search);
    const matchPenyedia = penyedia === '' || String(m.idPenyedia) === penyedia;
    return matchSearch && matchPenyedia;
  });

  renderTable(filtered);
}

// =====================
// MODAL
// =====================
function openCreate() {
  editIndex = null;
  document.getElementById('modalTitle').textContent = 'Tambah Mitra';
  document.getElementById('emailMitra').value = '';
  document.getElementById('idPenyedia').value = '';
  document.getElementById('namaMitra').value = '';
  document.getElementById('tanggalKerjaSama').value = '';
  document.getElementById('modalForm').classList.add('show');
}

function openEdit(index) {
  editIndex = index;
  const m = mitraData[index];
  document.getElementById('modalTitle').textContent = 'Edit Mitra';
  document.getElementById('emailMitra').value = m.emailMitra;
  document.getElementById('idPenyedia').value = m.idPenyedia;
  document.getElementById('namaMitra').value = m.namaMitra;
  document.getElementById('tanggalKerjaSama').value = m.tanggalKerjaSama;
  document.getElementById('modalForm').classList.add('show');
}

function closeModal() {
  document.getElementById('modalForm').classList.remove('show');
}

document.getElementById('modalForm').addEventListener('click', function(e) {
  if (e.target === this) closeModal();
});

// =====================
// SAVE (Create / Update)
// =====================
function saveMitra() {
  const emailMitra = document.getElementById('emailMitra').value.trim();
  const idPenyedia = document.getElementById('idPenyedia').value.trim();
  const namaMitra = document.getElementById('namaMitra').value.trim();
  const tanggalKerjaSama = document.getElementById('tanggalKerjaSama').value;

  if (!emailMitra || !idPenyedia || !namaMitra || !tanggalKerjaSama) {
    alert('Harap lengkapi semua field!');
    return;
  }

  const data = { emailMitra, idPenyedia: parseInt(idPenyedia), namaMitra, tanggalKerjaSama };

  if (editIndex === null) {
    mitraData.push(data);
  } else {
    mitraData[editIndex] = data;
  }

  closeModal();
  populatePenyediaFilter();
  filterTable();
}

// =====================
// DELETE
// =====================
function deleteMitra(index) {
  if (confirm(`Hapus mitra "${mitraData[index].namaMitra}"?`)) {
    mitraData.splice(index, 1);
    populatePenyediaFilter();
    filterTable();
  }
}

// =====================
// INIT
// =====================
populatePenyediaFilter();
renderTable();