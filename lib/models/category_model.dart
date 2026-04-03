import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// category_model.dart - Kuantum Branş Tanımları

class ServiceCategory {
  final String? id; // Firebase Document ID
  final String title;
  final String iconName; // Veritabanında "build", "tire_repair" gibi tutulur
  final String hexColor; // Veritabanında "#00FFCC" gibi tutulur
  final bool aktifMi; // Admin panelinden kapatılıp açılabilmesi için
  final int siralama; // Kategorilerin ekranda hangi sırayla çıkacağı

  ServiceCategory({
    this.id,
    required this.title,
    required this.iconName,
    required this.hexColor,
    this.aktifMi = true,
    this.siralama = 0,
  });

  // 🚀 FİREBASE'E YAZMA MOTORU (Admin panelinden yeni kategori eklemek için)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'icon_name': iconName,
      'hex_color': hexColor,
      'aktif_mi': aktifMi,
      'siralama': siralama,
      'olusturulma_tarihi': FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN OKUMA MOTORU (Anasayfada kategorileri listelemek için)
  factory ServiceCategory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ServiceCategory(
      id: doc.id,
      title: data['title'] ?? 'Bilinmeyen Kategori',
      iconName: data['icon_name'] ?? 'category', // Hata durumunda varsayılan ikon
      hexColor: data['hex_color'] ?? '#FFFFFF', // Hata durumunda beyaz renk
      aktifMi: data['aktif_mi'] ?? true,
      siralama: data['siralama'] ?? 99, // Sırası olmayanlar en sona atılır
    );
  }

  // 🎨 YARDIMCI METOT: HEX kodunu Flutter Color nesnesine çevirir
  Color get color {
    final hexCode = hexColor.replaceAll('#', '');
    if (hexCode.length == 6) {
      return Color(int.parse('FF$hexCode', radix: 16));
    }
    return Colors.grey; // Hatalı format koruması
  }

  // 🛠️ YARDIMCI METOT: String ikon ismini Flutter IconData'ya çevirir (Geliştirilebilir)
  IconData get icon {
    switch (iconName) {
      case 'build': return Icons.build;
      case 'tire_repair': return Icons.tire_repair;
      case 'settings_input_component': return Icons.settings_input_component;
      case 'battery_charging_full': return Icons.battery_charging_full;
      case 'format_paint': return Icons.format_paint;
      case 'electric_bolt': return Icons.electric_bolt;
      case 'qr_code_scanner': return Icons.qr_code_scanner; // Siber Göz için
      case 'security': return Icons.security; // Kuantum Kasa için
      default: return Icons.category; // Bulunamazsa varsayılan ikon
    }
  }
}