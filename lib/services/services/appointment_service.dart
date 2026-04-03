class AppointmentService {
  // Ankara Merkez Havuzuna düşen randevular
  static List<Map<String, dynamic>> randevuHavuzu = [
    {'il': 'Ankara', 'tutar': 1000, 'durum': 'Bekliyor'},
    {'il': 'İstanbul', 'tutar': 1500, 'durum': 'Onaylandı'},
  ];

  static void randevuAl(String il, double kapora) {
    // Kapora üzerinden %12 (10+2) kesinti hemen hesaplanır
    double bizimPay = kapora * 0.12; 
    print("Randevu alındı: $il. OtoDNA Payı ($bizimPay TL) ayrıldı.");
  }
}