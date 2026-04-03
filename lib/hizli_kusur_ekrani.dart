// lib/screens/hizli_kusur_ekrani.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM KRİZ VE KUSUR RADARI (SiberHizliKusurEkrani)
/// Aracın Kırmızı X yediği kritik raporları Firebase'den çeker ve VIP onarıma zorlar.
class SiberHizliKusurEkrani extends StatelessWidget {
  final String saseNo; // İncelenen aracın Karargah kimliği

  const SiberHizliKusurEkrani({super.key, required this.saseNo});

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  // ── 🚀 VİP ONARIM TETİKLEYİCİSİ ──
  void _vipMudahaleTalebiBaslat(BuildContext context) {
    HapticFeedback.heavyImpact();
    developer.log("🚨 KRİZ YÖNETİMİ: $saseNo için VIP Onarım Protokolü tetiklendi!");

    // SİBER NOT: Burada Asistan veya VIP Randevu ekranına yönlendirme yapılır
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _kuantumCyan,
        content: const Text("SİBER ONAY: Karargah ustalarına acil onarım talebi iletiliyor...", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _oledBlack.withOpacity(0.95), // Arka planı tamamen karartır
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: _matGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(color: Colors.redAccent.withOpacity(0.2), blurRadius: 30, spreadRadius: 5),
              ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 70),
              const SizedBox(height: 16),
              const Text("KRİTİK KUSUR RADARI", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: Colors.white24, height: 1),
              ),

              // 📡 CANLI FİREBASE KUSUR TARAMASI
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('acil_raporlar')
                    .where('sase_no', isEqualTo: saseNo)
                    .where('risk_seviyesi', isEqualTo: 'YUKSEK_TRAFIGE_CIKAMAZ')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: Colors.redAccent),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("SİBER ONAY: Kritik bir kusur bulunamadı.", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.bold)),
                    );
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return _kusurSatiri(data['hatali_parca'] ?? "Bilinmeyen Modül");
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),
              const Text(
                  "Yapay Zeka bu aracın trafiğe çıkmasını riskli buldu. Güvenliğiniz için VIP ağımız üzerinden hemen onarım talep edin.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5, letterSpacing: 0.5)
              ),
              const SizedBox(height: 24),

              // 🚀 ATEŞLEME BUTONU
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => _vipMudahaleTalebiBaslat(context),
                  icon: const Icon(Icons.build_circle_outlined, color: Colors.white),
                  label: const Text("VIP ACİL ONARIM TALEP ET", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 10,
                    shadowColor: Colors.redAccent.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kusurSatiri(String parca) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(parca, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1))),
        ],
      ),
    );
  }
}