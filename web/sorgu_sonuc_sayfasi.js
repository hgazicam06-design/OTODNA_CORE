// Basit client-side PDF üretimi — jsPDF kullanır (CDN yüklü olmalı).

function showSnackbar(text) {
  const sb = document.getElementById('snackbar');
  sb.textContent = text;
  sb.classList.add('show');
  clearTimeout(sb._timeout);
  sb._timeout = setTimeout(() => sb.classList.remove('show'), 3500);
}

async function generateDnaReport(sonuclar, saseNo) {
  const { jsPDF } = window.jspdf;
  const doc = new jsPDF({ unit: 'pt' });

  // 🎨 Kurumsal Rapor Tasarımı
  doc.setFillColor(255, 255, 255);
  doc.rect(0, 0, 600, 850, 'F'); // Beyaz Arka Plan

  doc.setTextColor(0, 90, 100); // Kurumsal Zümrüt
  doc.setFontSize(22);
  doc.setFont("helvetica", "bold");
  doc.text('OTODNA KURUMSAL RAPORU', 40, 60);

  doc.setTextColor(30, 41, 59); // text-main
  doc.setFontSize(12);
  doc.text(`Şasi No (DNA): ${saseNo || '- BİLİNMİYOR -'}`, 40, 100);
  doc.text(`Tarih: ${new Date().toLocaleString('tr-TR')}`, 40, 120);

  // Çizgi
  doc.setDrawColor(0, 90, 100);
  doc.setLineWidth(2);
  doc.line(40, 140, 550, 140);

  doc.setFontSize(14);
  doc.setTextColor(0, 90, 100);
  doc.text('SİSTEM SONUÇLARI:', 40, 170);

  let y = 200;
  const lineHeight = 20;
  doc.setFontSize(11);
  sonuclar.forEach((row, i) => {
    doc.setTextColor(30, 41, 59);
    const text = `[00${i + 1}] ${Object.entries(row).map(([k,v]) => `${k}: ${v}`).join(' | ')}`;
    doc.text(text, 40, y);
    y += lineHeight;
    if (y > 760) { 
      doc.addPage(); 
      doc.setFillColor(255, 255, 255);
      doc.rect(0, 0, 600, 850, 'F');
      y = 60; 
    }
  });

  // Kurumsal mühür
  doc.setDrawColor(0, 90, 100);
  doc.line(40, y + 20, 550, y + 20);
  doc.setTextColor(100, 100, 100);
  doc.setFontSize(8);
  doc.text('İŞBU BELGE İLGİLİ FİRMA TARAFINDAN DÜZENLENMİŞTİR. OTODNA YALNIZCA DİJİTAL ALTYAPI', 40, y + 40);
  doc.text('HİZMETİ SUNAR VE İÇERİKLE İLGİLİ HİÇBİR HUKUKİ/TİCARİ MESULİYET KABUL ETMEZ.', 40, y + 52);

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

  showSnackbar('Kurumsal PDF oluşturuluyor...');
  try {
    const doc = await generateDnaReport(sonuclar, saseNo);
    const fileName = `OtoDNA_Kurumsal_Rapor_${saseNo || 'unknown'}.pdf`;
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
