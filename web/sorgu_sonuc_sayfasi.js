// Basit client-side PDF üretimi — jsPDF kullanır (CDN yüklü olmalı).

function showSnackbar(text) {
  const sb = document.getElementById('snackbar');
  sb.textContent = text;
  sb.classList.add('show');
  clearTimeout(sb._timeout);
  sb._timeout = setTimeout(() => sb.classList.remove('show'), 3500);
}

async function generateDnaReport(sonuclar, saseNo) {
  // jsPDF UMD kullanımı
  const { jsPDF } = window.jspdf;
  const doc = new jsPDF({ unit: 'pt' });

  doc.setFontSize(16);
  doc.text('MÜHÜRLÜ DNA RAPORU', 40, 60);
  doc.setFontSize(11);
  doc.text(`Şasi No: ${saseNo || '- yok -'}`, 40, 90);
  doc.text('Sonuçlar:', 40, 120);

  let y = 140;
  const lineHeight = 14;
  sonuclar.forEach((row, i) => {
    const text = `${i + 1}. ${Object.entries(row).map(([k,v]) => `${k}: ${v}`).join(' — ')}`;
    doc.text(text, 50, y);
    y += lineHeight;
    if (y > 760) { doc.addPage(); y = 40; }
  });

  // Küçük bir mühür simülasyonu (sağ alt)
  doc.setFontSize(9);
  doc.text('— Otodna Mühürlü Rapor —', 40, y + 30);

  return doc;
}

document.getElementById('downloadBtn').addEventListener('click', async () => {
  let saseNo = document.getElementById('saseNo').value.trim();
  let sonuclarText = document.getElementById('sonuclar').value.trim();
  let sonuclar = [];
  try {
    sonuclar = JSON.parse(sonuclarText || '[]');
    if (!Array.isArray(sonuclar)) throw new Error('Array bekleniyor');
  } catch (err) {
    showSnackbar('Sonuçlar geçerli JSON array olmalı.');
    return;
  }

  showSnackbar('PDF oluşturuluyor...');
  try {
    const doc = await generateDnaReport(sonuclar, saseNo);
    const fileName = `muhurlu_rapor_${saseNo || 'unknown'}.pdf`;
    const blob = doc.output('blob');
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = fileName;
    document.body.appendChild(a);
    a.click();
    a.remove();
    URL.revokeObjectURL(url);

    showSnackbar(`Mühürlü PDF Hazır: ${fileName}`);
  } catch (err) {
    console.error(err);
    showSnackbar('PDF oluşturulamadı — konsolu kontrol edin.');
  }
});
