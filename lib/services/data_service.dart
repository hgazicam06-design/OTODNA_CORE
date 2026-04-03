import 'dart:developer' as developer;

/// 🛡️ KUANTUM VERİ VE ARAÇ KATALOG MOTORU (DataService)
/// Araç markaları, modelleri ve sistemsel sabit verileri barındırır.
/// SİBER NOT: Şehir ve bölge verileri artık sadece 'CityService' üzerinden çekilmelidir!
class DataService {

  // 🚗 SİBER ARAÇ MARKALARI KATALOĞU (Genişletilmiş Karargah Verisi)
  static const List<String> _markalar = [
    'AUDI', 'BMW', 'CHEVROLET', 'CITROEN', 'DACIA', 'FIAT', 'FORD',
    'HONDA', 'HYUNDAI', 'KIA', 'MERCEDES-BENZ', 'NISSAN', 'OPEL',
    'PEUGEOT', 'RENAULT', 'SEAT', 'SKODA', 'TESLA', 'TOYOTA', 'VOLKSWAGEN', 'VOLVO', 'TOGG'
  ];

  // ── 📡 ARAÇ MARKALARINI SORGULA ────────────────────────────────────────────
  /// İleride Firebase'den çekileceği için Future (Asenkron) yapıda kurulmuştur.
  static Future<List<String>> markalariGetir() async {
    try {
      developer.log("SİBER BİLGİ: Araç marka kataloğu radara yükleniyor...");

      // Kuantum Veritabanı Gecikme Simülasyonu
      await Future.delayed(const Duration(milliseconds: 300));

      List<String> siraliMarkalar = List.from(_markalar)..sort();
      return siraliMarkalar;
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Marka kataloğu çekilemedi!", error: e);
      return [];
    }
  }

  // ── 📡 MARKAYA GÖRE MODEL SORGULAMA MOTORU ───────────────────────────────
  /// Seçilen markaya ait modelleri Kuantum ağından çeker.
  static Future<List<String>> modelleriGetir(String marka) async {
    try {
      developer.log("SİBER BİLGİ: $marka markası için model istihbaratı çekiliyor...");
      await Future.delayed(const Duration(milliseconds: 400));

      // TODO: İleride bu veri Firebase 'arac_modelleri' tablosundan canlı çekilecek.
      // Şimdilik Karargahın içine gömülü (Hardcoded) Kuantum Simülasyonu:
      switch (marka.toUpperCase()) {
        case 'RENAULT': return ['CLIO', 'MEGANE', 'SYMBOL', 'TALISMAN', 'KADJAR', 'AUSTRAL'];
        case 'FIAT': return ['EGEA', 'LINEA', 'FIORINO', 'DOBLO', 'PUNTO', '500X'];
        case 'VOLKSWAGEN': return ['GOLF', 'PASSAT', 'POLO', 'TIGUAN', 'CADDY', 'T-ROC'];
        case 'TOYOTA': return ['COROLLA', 'YARIS', 'AURIS', 'C-HR', 'HILUX', 'RAV4'];
        case 'FORD': return ['FOCUS', 'FIESTA', 'MONDEO', 'TRANSIT', 'KUGA', 'PUMA'];
        case 'TOGG': return ['T10X', 'T10F'];
        case 'BMW': return ['1 SERİSİ', '3 SERİSİ', '5 SERİSİ', 'X1', 'X3', 'X5'];
        case 'MERCEDES-BENZ': return ['A-SERİSİ', 'C-SERİSİ', 'E-SERİSİ', 'GLA', 'GLC'];
        default: return ['STANDART MODEL 1', 'STANDART MODEL 2', 'DİĞER'];
      }
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Model verileri alınamadı!", error: e);
      return [];
    }
  }
}