import 'package:otodna/core/siber_tema.dart';
// lib/screens/kullanici/hizli_kusur_ekrani.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

import '../../../../core/responsive_kalkan.dart';

/// 🛡️ PLAZA KRİTİK KUSUR BİLDİRİMİ
/// Aracın kritik raporlarını Firebase'den çeker ve VIP onarıma yönlendirir.
class SiberHizliKusurEkrani extends StatelessWidget {
  final String saseNo;

  SiberHizliKusurEkrani({super.key, required this.saseNo});

  // ── 🚀 VİP ONARIM TETİKLEYİCİSİ (Aksiyon Motoru) ──
  void _vipMudahaleTalebiBaslat(BuildContext context) {
    HapticFeedback.heavyImpact();
    developer.log("🚨 KRİZ YÖNETİMİ: $saseNo için VIP Onarım Protokolü tetiklendi!");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.teal.shade700,
        content: Text("ONAY: Merkez ustalara acil onarım talebi iletiliyor...", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color dangerColor = Colors.redAccent;
    final Color textColor = Color(0xFF1E293B);
    final Color primaryTeal = Colors.teal.shade700;

    return Material(
      color: Colors.transparent, // Arka plan karartması çağıran yerden yönetilecek
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: dangerColor.withValues(alpha: 0.3), width: 1.5),
              boxShadow: [
                BoxShadow(color: dangerColor.withValues(alpha: 0.1), blurRadius: 40, spreadRadius: 10),
              ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(color: dangerColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.warning_amber_rounded, color: dangerColor, size: 60)
              ),
              SizedBox(height: 20),
              Text("KRİTİK KUSUR BİLDİRİMİ", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
              ),

              // 📡 CANLI FİREBASE KUSUR TARAMASI
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('acil_raporlar')
                    .where('sase_no', isEqualTo: saseNo)
                    .where('risk_seviyesi', isEqualTo: 'YUKSEK_TRAFIGE_CIKAMAZ')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: primaryTeal),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("SİSTEM TEMİZ: Kritik bir kusur bulunamadı.", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                    );
                  }

                  // 🚨 Kusur bulunduysa listele
                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return _kusurSatiri(data['hatali_parca'] ?? "Bilinmeyen Modül", dangerColor, textColor);
                    }).toList(),
                  );
                },
              ),

              SizedBox(height: 24),
              Text(
                  "Sistem bu aracın trafiğe çıkmasını riskli buldu. Güvenliğiniz için Plaza Ağımız üzerinden hemen onarım talep edin.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.6, letterSpacing: 0.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir')
              ),
              SizedBox(height: 32),

              // 🚀 ATEŞLEME BUTONU
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => _vipMudahaleTalebiBaslat(context),
                  icon: Icon(Icons.build_circle_outlined, size: 24),
                  label: Text("VİP ACİL ONARIM TALEP ET", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, fontFamily: 'Avenir')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dangerColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 🔧 YARDIMCI WIDGET: KUSUR SATIRI ──
  Widget _kusurSatiri(String parca, Color dangerColor, Color textColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: dangerColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dangerColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.cancel_outlined, color: dangerColor, size: 20),
          SizedBox(width: 12),
          Expanded(child: Text(parca, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, fontFamily: 'Avenir'))),
        ],
      ),
    );
  }
}