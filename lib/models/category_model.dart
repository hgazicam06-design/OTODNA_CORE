import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM BRANŞ TANIMLARI
/// Bu model, servislerin kategorize edilmesini ve arayüzde dinamik renk/ikon ile sunulmasını sağlar.
class ServiceCategory {
  final String? id; // Firebase Document ID
  final String title; // Örn: "Ağır Vasıta Şanzıman", "Elektrik & Elektronik"
  final String iconName; // Veritabanında "build", "electric_bolt" vb. tutulur
  final String hexColor; // Veritabanında "#00FFCC" vb. tutulur
  
  // 🎯 UZMANLIK VE FİLTRASYON (SİBER EKLENTİLER)
  final List<String> uyumluAracTipleri; // Örn: ['Otomobil', 'SUV', 'Kamyon']
  final String hizmetTuru; // Örn: 'Mekanik', 'Kaporta', 'Yazılım', 'Oto Kuaför'

  final bool aktifMi;    // Admin panelinden pasifize edilebilirlik
  final int siralama;    // Ekranda gösterim önceliği

  const ServiceCategory({
    this.id,
    required this.title,
    required this.iconName,
    required this.hexColor,
    this.uyumluAracTipleri = const [],
    this.hizmetTuru = 'Genel',
    this.aktifMi = true,
    this.siralama = 0,
  });

  // 🔄 DURUM YÖNETİMİ İÇİN KOPYALAMA MOTORU (State Management)
  ServiceCategory copyWith({
    String? id,
    String? title,
    String? iconName,
    String? hexColor,
    List<String>? uyumluAracTipleri,
    String? hizmetTuru,
    bool? aktifMi,
    int? siralama,
  }) {
    return ServiceCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      iconName: iconName ?? this.iconName,
      hexColor: hexColor ?? this.hexColor,
      uyumluAracTipleri: uyumluAracTipleri ?? this.uyumluAracTipleri,
      hizmetTuru: hizmetTuru ?? this.hizmetTuru,
      aktifMi: aktifMi ?? this.aktifMi,
      siralama: siralama ?? this.siralama,
    );
  }

  // 🚀 FİREBASE'E ATOMİK YAZMA MOTORU (BRANŞ KAYIT)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'icon_name': iconName,
      'hex_color': hexColor,
      'uyumlu_arac_tipleri': uyumluAracTipleri,
      'hizmet_turu': hizmetTuru,
      'aktif_mi': aktifMi,
      'siralama': siralama,
      'guncellenme_tarihi': FieldValue.serverTimestamp(), // Kayıt yenileme takibi için
    };
  }

  // 📥 FİREBASE'DEN ANALİTİK OKUMA MOTORU
  factory ServiceCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ServiceCategory(
      id: doc.id,
      title: data['title'] as String? ?? 'BİLİNMEYEN BRANŞ',
      iconName: data['icon_name'] as String? ?? 'category',
      hexColor: data['hex_color'] as String? ?? '#00FFC2',
      uyumluAracTipleri: List<String>.from(data['uyumlu_arac_tipleri'] ?? []),
      hizmetTuru: data['hizmet_turu'] as String? ?? 'Genel',
      aktifMi: data['aktif_mi'] as bool? ?? true,
      siralama: (data['siralama'] as num? ?? 99).toInt(),
    );
  }

  // 🎨 SİBER RENK ÇÖZÜMLEME (HEX -> Color)
  Color get color {
    try {
      final hexCode = hexColor.replaceAll('#', '');
      if (hexCode.length == 6) {
        return Color(int.parse('FF$hexCode', radix: 16));
      } else if (hexCode.length == 8) {
        return Color(int.parse(hexCode, radix: 16));
      }
    } catch (e) {
      debugPrint("SİBER HATA: Renk kodu çözülemedi [\$hexColor] -> \$e");
    }
    return Colors.cyanAccent; // Hata durumunda Kuantum Turkuaz acil durum rengi
  }

  // 🛠️ SİBER İKON MOTORU (String -> IconData)
  IconData get icon {
    switch (iconName) {
      case 'build': return Icons.build_rounded;
      case 'tire_repair': return Icons.tire_repair_rounded;
      case 'settings_input_component': return Icons.settings_input_component_rounded;
      case 'battery_charging_full': return Icons.battery_charging_full_rounded;
      case 'format_paint': return Icons.format_paint_rounded;
      case 'electric_bolt': return Icons.electric_bolt_rounded;
      case 'qr_code_scanner': return Icons.qr_code_scanner_rounded;
      case 'security': return Icons.security_rounded;
      case 'car_repair': return Icons.car_repair_rounded;
      case 'oil_barrel': return Icons.oil_barrel_rounded;
      case 'health_and_safety': return Icons.health_and_safety_rounded; // DNA Skoru
      case 'memory': return Icons.memory_rounded; // Çip/Yazılım
      case 'radar': return Icons.radar_rounded; // Sensör/Kalibrasyon
      case 'precision_manufacturing': return Icons.precision_manufacturing_rounded; // Ağır Sanayi
      case 'speed': return Icons.speed_rounded; // Performans
      default: return Icons.token_rounded; // Bulunamazsa Kuantum Jeton İkonu
    }
  }

  // 🖨️ TERMİNAL LOGLAMA İÇİN (Debugging)
  @override
  String toString() {
    return 'ServiceCategory(id: $id, title: $title, hizmetTuru: $hizmetTuru, aktifMi: $aktifMi)';
  }

  // ⚖️ EŞİTLİK DENETİMİ (Gereksiz Renderları Önler)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceCategory &&
        other.id == id &&
        other.title == title &&
        other.iconName == iconName &&
        other.hexColor == hexColor &&
        other.hizmetTuru == hizmetTuru &&
        other.aktifMi == aktifMi &&
        other.siralama == siralama;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        iconName.hashCode ^
        hexColor.hashCode ^
        hizmetTuru.hashCode ^
        aktifMi.hashCode ^
        siralama.hashCode;
  }
}