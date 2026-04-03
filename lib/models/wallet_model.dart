import 'package:cloud_firestore/cloud_firestore.dart';

// wallet_model.dart - Kuantum Cüzdan, Bilanço ve Hakediş Motoru

// ---------------------------------------------------------
// 1. İŞLEM KALEMİ (CÜZDAN GEÇMİŞİ)
// ---------------------------------------------------------
class OtoDNA_Islem {
  final String islemId;
  final DateTime tarih;
  final double tutar;
  final String aciklama; // Örn: "Fiat Egea Balata Satışı" veya "Randevu Kaporası"
  final bool gelirMi; // Esnafın kasasına para girdiyse true, biz komisyon kestiysek false

  OtoDNA_Islem({
    required this.islemId,
    required this.tarih,
    required this.tutar,
    required this.aciklama,
    this.gelirMi = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'islem_id': islemId,
      'tarih': Timestamp.fromDate(tarih),
      'tutar': tutar,
      'aciklama': aciklama,
      'gelir_mi': gelirMi,
    };
  }

  factory OtoDNA_Islem.fromMap(Map<String, dynamic> map) {
    return OtoDNA_Islem(
      islemId: map['islem_id'] ?? '',
      tarih: (map['tarih'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tutar: (map['tutar'] ?? 0).toDouble(),
      aciklama: map['aciklama'] ?? 'Belirtilmedi',
      gelirMi: map['gelir_mi'] ?? true,
    );
  }
}

// ---------------------------------------------------------
// 2. ANA CÜZDAN (ESNAF BİLANÇOSU)
// ---------------------------------------------------------
class OtoDNA_Wallet {
  final String? id; // Firebase Document ID (Genelde dükkan ID ile aynı olur)
  final String dukkanId;

  // 💰 BİLANÇO VE MUHASEBE
  final double toplamBakiye;    // Sisteme giren brüt para
  final double netKarPayi;      // Bizim %10'luk net kısmımız
  final double vergiPayi;       // Devlet için ayrılan %2'lik kısım
  final double esnafHakedis;    // Esnafa kalan %88'lik net hakediş

  final List<OtoDNA_Islem> gecmisIslemler;

  OtoDNA_Wallet({
    this.id,
    required this.dukkanId,
    this.toplamBakiye = 0.0,
    this.netKarPayi = 0.0,
    this.vergiPayi = 0.0,
    this.esnafHakedis = 0.0,
    this.gecmisIslemler = const [],
  });

  // Toplam %12'lik OtoDNA kesintisini hesaplayan canlı fonksiyon
  double get toplamKesinti => netKarPayi + vergiPayi;

  // 🚀 FİREBASE'E YAZMA MOTORU (Esnaf her satış yaptığında cüzdan güncellenir)
  Map<String, dynamic> toMap() {
    return {
      'dukkan_id': dukkanId,
      'toplam_bakiye': toplamBakiye,
      'net_kar_payi': netKarPayi,
      'vergi_payi': vergiPayi,
      'esnaf_hakedis': esnafHakedis,
      // İşlemleri Firebase'in anlayacağı liste haritasına (List<Map>) çeviriyoruz
      'gecmis_islemler': gecmisIslemler.map((islem) => islem.toMap()).toList(),
      'son_guncellenme': FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN OKUMA MOTORU (Esnaf "Cüzdanım" ekranını açtığında)
  factory OtoDNA_Wallet.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // İşlem listesini güvenli bir şekilde çekiyoruz
    var islemListesi = (data['gecmis_islemler'] as List<dynamic>?) ?? [];

    return OtoDNA_Wallet(
      id: doc.id,
      dukkanId: data['dukkan_id'] ?? '',
      toplamBakiye: (data['toplam_bakiye'] ?? 0).toDouble(),
      netKarPayi: (data['net_kar_payi'] ?? 0).toDouble(),
      vergiPayi: (data['vergi_payi'] ?? 0).toDouble(),
      esnafHakedis: (data['esnaf_hakedis'] ?? 0).toDouble(),
      gecmisIslemler: islemListesi.map((item) => OtoDNA_Islem.fromMap(item as Map<String, dynamic>)).toList(),
    );
  }
}