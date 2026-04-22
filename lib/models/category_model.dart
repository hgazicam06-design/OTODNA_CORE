import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM BRANŞ TANIMLARI
/// Bu model, servislerin kategorize edilmesini ve arayüzde dinamik renk/ikon ile sunulmasını sağlar.
class ServiceCategory {
  final String? id; // Firebase Document ID
  final String title; // Örn: "Ağır Vasıta Şanzıman", "Elektrik & Elektronik"
  final String iconName; // Veritabanında "build", "electric_bolt" vb. tutulur
  final String hexColor; // Veritabanında "#00FFCC" vb. tutulur
  
  // 🎯 UZMANLIK VE FİLTRASYON (YENİ SİBER EKLENTİLER)
  final List<String> uyumluAracTipleri; // Örn: ['Otomobil', 'SUV'], ['Kamyon', 'Tır']
  final String hizmetTuru; // Örn: 'Mekanik', 'Kaporta', 'Yazılım', 'Oto Kuaför'

  final bool aktifMi;    // Admin panelinden pasifize edilebilirlik
  final int siralama;    // Ekranda gösterim önceliği

  ServiceCategory({
    this.id,
    required this.title,
    required this.iconName,
    required this.hexColor,
    this.uyumluAracTipleri = const [],
    this.hizmetTuru = 'Genel',
    this.aktifMi = true,
    this.siralama = 0,
  });

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
      'olusturulma_tarihi': FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN ANALİTİK OKUMA MOTORU
  factory ServiceCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ServiceCategory(
      id: doc.id,
      title: data['title'] ?? 'BİLİNMEYEN BRANŞ',
      iconName: data['icon_name'] ?? 'category',
      hexColor: data['hex_color'] ?? '#00FFC2',
      uyumluAracTipleri: List<String>.from(data['uyumlu_arac_tipleri'] ?? []),
      hizmetTuru: data['hizmet_turu'] ?? 'Genel',
      aktifMi: data['aktif_mi'] ?? true,
      siralama: (data['siralama'] ?? 99).toInt(),
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
      debugPrint("SİBER HATA: Renk kodu çözülemedi -> $e");
    }
    return Colors.cyanAccent; // Hata durumunda siber acil durum rengi
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
      case 'health_and_safety': return Icons.health_and_safety_rounded; // DNA Skoru için
      default: return Icons.token_rounded; // Bulunamazsa Kuantum Jeton İkonu
    }
  }
}