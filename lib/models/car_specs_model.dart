import 'package:cloud_firestore/cloud_firestore.dart';

// car_specs_model.dart - Kuantum Fabrika Teknik Dökümanı (Kozmik Oda)

class CarSpecs {
  final String? id; // Firebase Document ID
  final String brandModel; // Örn: Toyota-Corolla-1.8-Hybrid
  final String modelCode; // Örn: E210, BMW-G20
  final int hp;           // Beygir Gücü
  final int torque;       // Tork
  final double engineSize; // Motor Hacmi
  final String fuelType;  // Yakıt Tipi
  final String oilType;   // Tavsiye Edilen Yağ (Ustalar için kritik bilgi!)
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

  // 🚀 FİREBASE'E YAZMA MOTORU (Admin Panelinden yeni bir araç kataloğa eklendiğinde)
  Map<String, dynamic> toMap() {
    return {
      'brand_model': brandModel,
      'model_code': modelCode,
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

  // 📥 FİREBASE'DEN OKUMA MOTORU (Siber Göz aracı taradığında ustaya dökülecek veriler)
  factory CarSpecs.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return CarSpecs(
      id: doc.id,
      brandModel: data['brand_model'] ?? 'Bilinmeyen Araç',
      modelCode: data['model_code'] ?? 'Bilinmeyen Kod',
      hp: data['hp'] ?? 0,
      torque: data['torque'] ?? 0,
      engineSize: (data['engine_size'] ?? 0).toDouble(),
      fuelType: data['fuel_type'] ?? 'Belirtilmemiş',
      oilType: data['oil_type'] ?? 'Belirtilmemiş',
      tirePressure: data['tire_pressure'] ?? 32, // Varsayılan güvenlik basıncı
      kronikArizalar: List<String>.from(data['kronik_arizalar'] ?? []),
    );
  }
}