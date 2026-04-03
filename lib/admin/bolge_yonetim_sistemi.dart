import 'package:cloud_firestore/cloud_firestore.dart';

/// OTODNA KUANTUM İSTİHBARAT VE BÖLGE YÖNETİM SERVİSİ
class BolgeYonetimSistemi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 📡 SİBER RÖNTGEN: İL BAZLI CANLI FİREBASE ANALİZİ ---
  Future<Map<String, dynamic>> ilAnaliziYap(String sehir) async {
    try {
      // 1. O şehre ait aktif tüm bayileri Kuantum Ağında tara
      final querySnapshot = await _db
          .collection('bayiler')
          .where('il', isEqualTo: sehir)
          .where('aktif_mi', isEqualTo: true)
          .get();

      double sehirToplamCiro = 0.0;
      int kritikBayiSayisi = 0;
      List<Map<String, dynamic>> riskliBayiler = [];

      // 2. Verileri İlmek İlmek İşle
      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        // Ciro hesaplaması (Gerçekte her bayinin aylık cirosunu temsil eden alandan çekilir)
        double bayiCiro = (data['aylik_ciro'] ?? 0).toDouble();
        sehirToplamCiro += bayiCiro;

        // Şikayet ve Risk Analizi
        int sikayet = data['sikayet_sayisi'] ?? 0;
        if (sikayet >= 5) {
          kritikBayiSayisi++;
          riskliBayiler.add({
            'id': doc.id,
            'firma_adi': data['firma_adi'] ?? 'Bilinmeyen Bayi',
            'sikayet': sikayet,
          });

          // Füzeyi Ateşle: Şikayeti 5'i geçen bayiye otomatik siber ihtar gönder
          await _otomatikBayiUyariGonder(doc.id, data['firma_adi'], sikayet);
        }
      }

      // 3. Gazi Komutan Payı (Anlaşma Gereği Net %12)
      double komutanPayi = sehirToplamCiro * 0.12;

      // 4. Analiz Raporunu UI (Arayüz) için Döndür
      return {
        'basarili': true,
        'sehir': sehir,
        'aktif_bayi_sayisi': querySnapshot.docs.length,
        'toplam_ciro': sehirToplamCiro,
        'komutan_payi': komutanPayi,
        'kritik_bayi_sayisi': kritikBayiSayisi,
        'riskli_bayiler': riskliBayiler,
      };

    } catch (e) {
      // Kalkan Çökmesi Durumunda Hata Raporla
      return {
        'basarili': false,
        'hata': "Siber Ağ Bağlantısı Koptu: $e",
      };
    }
  }

  // --- ⚠️ OTOMATİK SİBER İHTAR VE CEZA SİSTEMİ ---
  Future<void> _otomatikBayiUyariGonder(String bayiId, String? firmaAdi, int sikayet) async {
    try {
      // 1. Bayinin statüsünü veritabanında 'KARA LİSTE ADAYI' yap
      await _db.collection('bayiler').doc(bayiId).update({
        'durum': 'ŞİKAYET VAR - RİSKLİ',
        'puan': 2.0, // Ceza puanı otomatik düşürülür
        'son_uyari_tarihi': FieldValue.serverTimestamp(),
      });

      // 2. Admin Kontrol Merkezi'nde (Kara Kutu) anında kırmızı yanması için SİSTEM LOGLARINA yaz!
      await _db.collection('sistem_loglari').add({
        'bayi_isim': firmaAdi ?? 'Bilinmeyen Bayi',
        'islem_detayi': '$sikayet şikayet tespit edildi! Sistem tarafından otomatik ihtar gönderildi ve puan düşürüldü.',
        'islem_turu': 'hata', // 'hata' türü UI tarafında Kırmızı Neon yakar
        'tarih': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      // Loglama hatası olursa terminali kilitlememesi için sessizce yakala
    }
  }
}