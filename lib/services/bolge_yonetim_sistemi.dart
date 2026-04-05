import 'package:cloud_firestore/cloud_firestore.dart';

class BolgeYonetimSistemi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔴 İL BAZLI SİBER TARAMA VE FİNANS MOTORU
  Future<Map<String, dynamic>> ilAnaliziYap(String il) async {
    try {
      // SİBER TARAMA SİMÜLASYONU (Ağı test etmek için 1.5 saniye tarama efekti)
      await Future.delayed(const Duration(milliseconds: 1500));

      // TODO: Burası ileride doğrudan canlı Firebase 'islemler' koleksiyonuna bağlanacak.
      // Şimdilik Karargah ekranının hatasız çalıştığını ve UI zırhlarını görmek için test verisi yolluyoruz.

      double toplamCiro = 0.0;
      double komutanPayi = 0.0;
      int aktifBayi = 0;
      int kritikBayi = 0;
      List<Map<String, dynamic>> riskliBayiler = [];

      // Eğer Ankara (Merkez) veya İstanbul seçilirse sistemi dolu gösterelim
      if (il == 'Ankara' || il == 'İstanbul') {
        toplamCiro = 450000.0;
        komutanPayi = toplamCiro * 0.12; // 💸 SİBER KURAL: Değişmez %12 Komutan Payı
        aktifBayi = 85;
        kritikBayi = 2;
        riskliBayiler = [
          {'firma_adi': 'Kaçak Egzozcu Veli', 'sikayet': 6},
          {'firma_adi': 'Merdivenaltı Rotbalans', 'sikayet': 9}
        ];
      } else {
        // Diğer standart iller için
        toplamCiro = 125000.0;
        komutanPayi = toplamCiro * 0.12; // 💸 SİBER KURAL: Değişmez %12 Komutan Payı
        aktifBayi = 24;
        kritikBayi = 0;
      }

      return {
        'basarili': true,
        'toplam_ciro': toplamCiro,
        'komutan_payi': komutanPayi,
        'aktif_bayi_sayisi': aktifBayi,
        'kritik_bayi_sayisi': kritikBayi,
        'riskli_bayiler': riskliBayiler,
      };

    } catch (e) {
      // Kuantum Kalkanı hatayı yakaladı
      return {
        'basarili': false,
        'hata': 'SİBER AĞ HATASI: Radar bağlantısı kurulamadı. Detay: $e'
      };
    }
  }
}