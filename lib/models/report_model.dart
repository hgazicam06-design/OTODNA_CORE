import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// 🦅 OTODNA KUANTUM EKSPERTİZ RAPORU VE SİBER SİCİL MODELİ
/// Bu model, aracın DNA skorunu belirleyen teknik verileri ve finansal komisyonları yönetir.

class OtoDNAReport {
  final String? id; // Firebase Document ID
  final String raporNo; // Örn: OTODNA-7823
  final String saseNo;
  final String bayiAdi; // Murat Plaza veya diğer esnaflar

  // 🕸️ KUANTUM İSTİHBARAT AĞI (4 KATMANLI ADLİ KONUM)
  // Bu ekspertiz nerede yapıldı? Sigorta kaza istihbaratını beslemek için kritik.
  final String countryId;
  final String regionId;
  final String cityId;
  final String districtId;

  // ⚙️ TEKNİK VERİLER
  final int motorPerformans; // Yüzdelik (Örn: 85)
  final Map<String, dynamic> kaportaDurumu; // {'Kaput': 'Orijinal', 'Sağ Çamurluk': 'Boyalı'}

  // 🚨 SİBER GÜVENLİK VE FİNANS MOTORU
  final bool kritikHataVarMi; // Usta Kırmızı X attıysa true olur
  final double ekspertizUcreti; // Ekspertiz bedeli
  final double komisyonOrani; // Murat Plaza %30, diğerleri %12

  final DateTime ekspertizTarihi;

  OtoDNAReport({
    this.id,
    required this.raporNo,
    required this.saseNo,
    required this.bayiAdi,
    required this.countryId,
    required this.regionId,
    required this.cityId,
    required this.districtId,
    required this.motorPerformans,
    required this.kaportaDurumu,
    this.kritikHataVarMi = false,
    required this.ekspertizUcreti,
    this.komisyonOrani = 0.12,
    DateTime? ekspertizTarihi,
  }) : ekspertizTarihi = ekspertizTarihi ?? DateTime.now();

  // 🚀 FİREBASE'E ATOMİK YAZMA MOTORU
  Map<String, dynamic> toMap() {
    // Kuantum Finans Kuralı Uygulanıyor
    final double uygulananOran = bayiAdi.trim().toLowerCase() == "murat plaza" ? 0.30 : 0.12;

    return {
      'rapor_no': raporNo,
      'sase_no': saseNo.toUpperCase(),
      'bayi_adi': bayiAdi,
      'country_id': countryId,
      'region_id': regionId,
      'city_id': cityId,
      'district_id': districtId,
      'motor_performans': motorPerformans,
      'kaporta_durumu': kaportaDurumu,
      'kritik_hata_var_mi': kritikHataVarMi,
      'ekspertiz_ucreti': ekspertizUcreti,
      // 💰 GAZİ KASASI: Rapor onaylandığı an payın hesaplanıp mühürlenir.
      'komisyon_orani': uygulananOran,
      'gazi_payi': ekspertizUcreti * uygulananOran,
      'ekspertiz_tarihi': FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN ANALİTİK OKUMA MOTORU
  factory OtoDNAReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return OtoDNAReport(
      id: doc.id,
      raporNo: data['rapor_no'] ?? 'OTODNA-XXXX',
      saseNo: data['sase_no'] ?? 'Bilinmiyor',
      bayiAdi: data['bayi_adi'] ?? 'Belirtilmedi',
      countryId: data['country_id'] ?? '',
      regionId: data['region_id'] ?? '',
      cityId: data['city_id'] ?? '',
      districtId: data['district_id'] ?? '',
      motorPerformans: (data['motor_performans'] ?? 0).toInt(),
      kaportaDurumu: Map<String, dynamic>.from(data['kaporta_durumu'] ?? {}),
      kritikHataVarMi: data['kritik_hata_var_mi'] ?? false,
      ekspertizUcreti: (data['ekspertiz_ucreti'] ?? 0).toDouble(),
      komisyonOrani: (data['komisyon_orani'] ?? 0.12).toDouble(),
      ekspertizTarihi: (data['ekspertiz_tarihi'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ---------------------------------------------------------
// 2. OTODNA MÜHÜRLÜ RAPOR TASARIMI (SİBER CAM EFEKTİ)
// ---------------------------------------------------------
class TeknikRaporKart extends StatelessWidget {
  final OtoDNAReport rapor;

  const TeknikRaporKart({super.key, required this.rapor});

  // Kuantum Renk Paleti
  static const _neonTurkuaz = Color(0xFF00FFCC);
  static const _derinKarargahSiyahi = Color(0xFF0A0E14);
  static const _siberKartRengi = Color(0xFF161B22);

  @override
  Widget build(BuildContext context) {
    bool alarm = rapor.kritikHataVarMi;
    String tarihStr = DateFormat('dd.MM.yyyy').format(rapor.ekspertizTarihi);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: _siberKartRengi,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: alarm ? Colors.redAccent.withOpacity(0.5) : _neonTurkuaz.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: alarm ? Colors.redAccent.withOpacity(0.1) : _neonTurkuaz.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // 🛡️ ÜST PANEL: DURUM MÜHÜRÜ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: alarm ? Colors.redAccent.withOpacity(0.2) : _neonTurkuaz.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "RAPOR #${rapor.raporNo}",
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Row(
                    children: [
                      Icon(
                        alarm ? Icons.dangerous : Icons.verified_user,
                        color: alarm ? Colors.redAccent : _neonTurkuaz,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        alarm ? "KRİTİK RİSK" : "DNA ONAYLI",
                        style: TextStyle(
                          color: alarm ? Colors.redAccent : _neonTurkuaz,
                          fontWeight: FontWeight.black,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 🚘 ANA VERİ ALANI
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rapor.saseNo,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Bayi: ${rapor.bayiAdi}",
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                        Text(
                          "Tarih: $tarihStr",
                          style: TextStyle(color: Colors.grey[600], fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  _buildMotorSkoru(rapor.motorPerformans, alarm),
                ],
              ),
            ),

            const Divider(color: Colors.white10, height: 1),

            // 🛠️ KAPORTA ANALİZ RADARI (Dinamik Wrap)
            Padding(
              padding: const EdgeInsets.all(15),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: rapor.kaportaDurumu.entries.map((e) => _buildParcaChip(e.key, e.value)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotorSkoru(int skor, bool isAlarm) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: isAlarm ? Colors.redAccent : _neonTurkuaz, width: 2),
      ),
      child: Column(
        children: [
          const Text("MOTOR", style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold)),
          Text("%$skor", style: TextStyle(color: isAlarm ? Colors.redAccent : _neonTurkuaz, fontSize: 20, fontWeight: FontWeight.black)),
        ],
      ),
    );
  }

  Widget _buildParcaChip(String parca, String durum) {
    Color durumRenk;
    String d = durum.toLowerCase();
    if (d.contains("orijinal")) durumRenk = _neonTurkuaz;
    else if (d.contains("boya")) durumRenk = Colors.orangeAccent;
    else if (d.contains("değiş")) durumRenk = Colors.redAccent;
    else durumRenk = Colors.white54;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: durumRenk.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: durumRenk.withOpacity(0.3)),
      ),
      child: Text(
        "$parca: $durum",
        style: TextStyle(color: durumRenk, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}