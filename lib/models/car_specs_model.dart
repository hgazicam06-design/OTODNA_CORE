import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM FABRİKA TEKNİK DÖKÜMANI (KOZMİK ODA)
/// Bu sınıf, araçların fabrikasyon verilerini ve yapay zeka destekli kronik sorun bilgilerini taşır.
class CarSpecs {
  final String? id; // Firebase Document ID
  final String brandModel; // Örn: TOYOTA COROLLA 1.8 HYBRID
  final String modelCode; // Örn: E210
  final int hp;           // Beygir Gücü
  final int torque;       // Tork
  final double engineSize; // Motor Hacmi
  final String fuelType;  // Yakıt Tipi
  final String oilType;   // Tavsiye Edilen Yağ (Usta Terminali İçin Kritik!)
  final int tirePressure; // Tavsiye Edilen Lastik Basıncı (PSI)

  // 🧠 KUANTUM EKSTRASI: Yapay Zekanın Ustayı Uyaracağı Kronik Sorunlar
  final List<String> kronikArizalar;

  CarSpecs({
    this.id,
    required this.brandModel,
    required this.modelCode,
    required this.hp,
    required this.torque,
    required this.engineSize,
    required this.fuelType,
    required this.oilType,
    required this.tirePressure,
    this.kronikArizalar = const [],
  });

  // 🚀 FİREBASE'E ATOMİK YAZMA MOTORU (KATALOG GÜNCELLEME)
  Map<String, dynamic> toMap() {
    return {
      'brand_model': brandModel.toUpperCase(),
      'model_code': modelCode.toUpperCase(),
      'hp': hp,
      'torque': torque,
      'engine_size': engineSize,
      'fuel_type': fuelType,
      'oil_type': oilType,
      'tire_pressure': tirePressure,
      'kronik_arizalar': kronikArizalar,
      'katalog_guncellenme_tarihi': FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN ANALİTİK OKUMA MOTORU (SİBER GÖZ AKTİF)
  factory CarSpecs.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return CarSpecs(
      id: doc.id,
      brandModel: data['brand_model'] ?? 'BİLİNMEYEN ARAÇ',
      modelCode: data['model_code'] ?? 'KOD BELİRTİLMEDİ',
      hp: (data['hp'] ?? 0).toInt(),
      torque: (data['torque'] ?? 0).toInt(),
      engineSize: (data['engine_size'] ?? 0.0).toDouble(),
      fuelType: data['fuel_type'] ?? 'Belirtilmemiş',
      oilType: data['oil_type'] ?? 'Belirtilmemiş',
      tirePressure: (data['tire_pressure'] ?? 32).toInt(),
      kronikArizalar: List<String>.from(data['kronik_arizalar'] ?? []),
    );
  }
}