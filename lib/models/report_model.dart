import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için

// ---------------------------------------------------------
// 1. KUANTUM EKSPERTİZ RAPORU VERİ MODELİ (FİREBASE UYUMLU)
// ---------------------------------------------------------
class OtoDNAReport {
  final String? id; // Firebase Document ID
  final String raporNo; // Örn: OTODNA-7823
  final String saseNo;
  final String bayiAdi; // Murat Plaza veya diğer esnaflar

  // ⚙️ TEKNİK VERİLER
  final int motorPerformans; // Yüzdelik (Örn: 85)
  final Map<String, dynamic> kaportaDurumu; // {'Kaput': 'Orijinal', 'Sağ Çamurluk': 'Boyalı'}

  // 🚨 SİBER GÜVENLİK VE FİNANS MOTORU
  final bool kritikHataVarMi; // Usta Kırmızı X attıysa true olur
  final double ekspertizUcreti; // Ekspertiz için alınan para
  final double komisyonOrani; // Murat Plaza %30, diğerleri %12

  final DateTime ekspertizTarihi;

  OtoDNAReport({
    this.id,
    required this.raporNo,
    required this.saseNo,
    required this.bayiAdi,
    required this.motorPerformans,
    required this.kaportaDurumu,
    this.kritikHataVarMi = false,
    required this.ekspertizUcreti,
    this.komisyonOrani = 0.12,
    DateTime? ekspertizTarihi,
  }) : ekspertizTarihi = ekspertizTarihi ?? DateTime.now();

  // 🚀 FİREBASE'E YAZMA MOTORU (Usta Raporu Onayladığı An)
  Map<String, dynamic> toMap() {
    return {
      'rapor_no': raporNo,
      'sase_no': saseNo,
      'bayi_adi': bayiAdi,
      'motor_performans': motorPerformans,
      'kaporta_durumu': kaportaDurumu,
      'kritik_hata_var_mi': kritikHataVarMi,
      'ekspertiz_ucreti': ekspertizUcreti,
      // 💰 FİNANS KALKANI: Ekspertizden gelen paranın komisyonu
      'komisyon_orani': bayiAdi == "Murat Plaza" ? 0.30 : komisyonOrani,
      'gazi_payi': ekspertizUcreti * (bayiAdi == "Murat Plaza" ? 0.30 : komisyonOrani),
      'ekspertiz_tarihi': FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN OKUMA MOTORU (Kullanıcı Rapor Geçmişini Açtığında)
  factory OtoDNAReport.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return OtoDNAReport(
      id: doc.id,
      raporNo: data['rapor_no'] ?? 'OTODNA-XXXX',
      saseNo: data['sase_no'] ?? 'Bilinmiyor',
      bayiAdi: data['bayi_adi'] ?? 'Belirtilmedi',
      motorPerformans: data['motor_performans'] ?? 0,
      kaportaDurumu: data['kaporta_durumu'] ?? {},
      kritikHataVarMi: data['kritik_hata_var_mi'] ?? false,
      ekspertizUcreti: (data['ekspertiz_ucreti'] ?? 0).toDouble(),
      komisyonOrani: (data['komisyon_orani'] ?? 0.12).toDouble(),
      ekspertizTarihi: (data['ekspertiz_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ---------------------------------------------------------
// 2. OTODNA MÜHÜRLÜ RAPOR TASARIMI (CANLI WIDGET)
// ---------------------------------------------------------
class TeknikRaporKart extends StatelessWidget {
  final OtoDNAReport rapor;

  const TeknikRaporKart({super.key, required this.rapor});

  // Siber Renk Paleti
  static const _neonGreen = Color(0xFF00FFCC);
  static const _cyberCard = Color(0xFF1E1E2E);

  @override
  Widget build(BuildContext context) {
    // Kırmızı X Alarmı Kontrolü
    bool alarm = rapor.kritikHataVarMi;
    String tarihStr = DateFormat('dd.MM.yyyy - HH:mm').format(rapor.ekspertizTarihi);

    return Card(
      color: _cyberCard,
      elevation: 8,
      shadowColor: alarm ? Colors.redAccent.withOpacity(0.4) : _neonGreen.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: alarm ? Colors.redAccent : _neonGreen.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🛡️ BAŞLIK VE SİBER MÜHÜR
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: alarm ? Colors.red[900] : Colors.blueGrey[900],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("TEKNİK RAPOR #${rapor.raporNo}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                Row(
                  children: [
                    Text(alarm ? "AĞIR HASAR" : "OTODNA ONAYLI", style: TextStyle(color: alarm ? Colors.white : _neonGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Icon(alarm ? Icons.warning_amber_rounded : Icons.verified, color: alarm ? Colors.white : _neonGreen, size: 20),
                  ],
                ),
              ],
            ),
          ),

          // 🚘 ARAÇ TEMEL BİLGİLERİ
          ListTile(
            title: Text("Şase: ${rapor.saseNo}", style: const TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text("Tarih: $tarihStr", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text("Raporlayan: ${rapor.bayiAdi}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Motor", style: TextStyle(color: Colors.grey, fontSize: 10)),
                Text("%${rapor.motorPerformans}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: alarm ? Colors.redAccent : Colors.blueAccent)),
              ],
            ),
          ),

          const Divider(color: Colors.white12),

          // 🛠️ KAPORTA DİNAMİK ÖZETİ (Firebase'den Akacak)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: rapor.kaportaDurumu.entries.map((entry) {
                // Duruma göre parça rengini belirle
                Color chipColor;
                String durum = entry.value.toString().toLowerCase();
                if (durum.contains("orijinal")) {
                  chipColor = _neonGreen.withOpacity(0.2);
                } else if (durum.contains("boyalı")) {
                  chipColor = Colors.orangeAccent.withOpacity(0.2);
                } else if (durum.contains("değişen")) {
                  chipColor = Colors.redAccent.withOpacity(0.2);
                } else {
                  chipColor = Colors.white10;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: chipColor.withOpacity(0.5)),
                  ),
                  child: Text("${entry.key}: ${entry.value}", style: const TextStyle(color: Colors.white, fontSize: 12)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}