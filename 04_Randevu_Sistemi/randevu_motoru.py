/**
 * OtoDNA Randevu ve Cayma Bedeli Sistemi
 * Amacı: Randevuyu parayla mühürlemek, suistimali önlemek.
 */

class RandevuSistemi {
  final double randevuBedeli = 200.0;

  // Randevu oluşturulduğunda para güvenli havuza alınır
  Map<String, dynamic> randevuOlustur(String musteriId, String ustaId) {
    return {
      "musteri": musteriId,
      "usta": ustaId,
      "tutar": randevuBedeli,
      "durum": "Havuzda Bekliyor",
      "mesaj": "200 TL tahsil edildi. Randevu saati mühürlendi."
    };
  }

  // Müşteri randevuya gelmezse (Cayma Protokolü)
  Map<String, double> caymaBedeliDagit() {
    // 200 TL'yi adilce bölüyoruz:
    double ustaTazminati = 100.0; // Ustanın beklediği süre için
    double otodnaIsletme = 100.0; // Sistemin ayakta kalması için
    
    return {
      "usta_payi": ustaTazminati,
      "otodna_payi": otodnaIsletme,
    };
  }
}