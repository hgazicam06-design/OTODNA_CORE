class NotificationService {
  // Bildirim türüne göre Kuantum İkonları
  String turIcon(String tur) {
    switch (tur.toLowerCase()) {
      case 'kaza':
        return '💥';
      case 'park':
        return '🅿️';
      case 'acil':
        return '🚨';
      case 'sistem':
        return '⚙️';
      case 'guvenlik':
        return '🛡️';
      default:
        return '📩';
    }
  }

  // Bildirim türüne göre Askeri Başlıklar
  String turLabel(String tur) {
    switch (tur.toLowerCase()) {
      case 'kaza':
        return 'Kaza / Temas İhtimali';
      case 'park':
        return 'Hatalı Park İhlali';
      case 'acil':
        return 'Acil Durum Sinyali';
      case 'sistem':
        return 'OtoDNA Sistem Mesajı';
      case 'guvenlik':
        return 'Kuantum Ağ Güvenliği';
      default:
        return 'Genel Bildirim';
    }
  }
}