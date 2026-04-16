// lib/screens/kullanici/hizli_kusur_ekrani.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA BAĞLANTISI (2 Kat Yukarı)
import '../../../../core/siber_tema.dart';
import '../../../../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM KRİZ VE KUSUR RADARI (SiberHizliKusurEkrani)
/// Aracın Kırmızı X yediği kritik raporları Firebase'den çeker ve VIP onarıma zorlar.
class SiberHizliKusurEkrani extends StatelessWidget {
  final String saseNo; // İncelenen aracın Karargah kimliği

  const SiberHizliKusurEkrani({super.key, required this.saseNo});

  // ── 🚀 VİP ONARIM TETİKLEYİCİSİ (Aksiyon Motoru) ──
  void _vipMudahaleTalebiBaslat(BuildContext context) {
    HapticFeedback.heavyImpact();
    developer.log("🚨 KRİZ YÖNETİMİ: $saseNo için VIP Onarım Protokolü tetiklendi!");

    // SİBER NOT: Gerçekte burada bir WriteBatch ile talep oluşturulur ve Asistan/VIP sayfasına gidilir
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.kuantumCyan,
        content: const Text("SİBER ONAY: Karargah ustalarına acil onarım talebi iletiliyor...", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🛡️ Bu modül genellikle bir Dialog veya Popup olarak çağrıldığı için Scaffold yerine Material ile sarmalanır.
    return Material(
      color: Colors.transparent, // Arka plan karartması çağıran yerden yönetilecek
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: SiberTema.matGrey.withOpacity(0.95), // Yüksek kontrastlı siber gri
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.8), width: 2),
              boxShadow: [
                BoxShadow(color: SiberTema.kanKirmizi.withOpacity(0.3), blurRadius: 40, spreadRadius: 10),
              ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: SiberTema.kanKirmizi, size: 70),
              const SizedBox(height: 16),
              const Text("KRİTİK KUSUR RADARI", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
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
                      child: CircularProgressIndicator(color: SiberTema.kanKirmizi),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("SİBER RADAR TEMİZ: Kritik bir kusur bulunamadı.", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    );
                  }

                  // 🚨 Kusur bulunduysa listele
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
                  style: TextStyle(color: Colors.white70, fontSize: 10, height: 1.6, letterSpacing: 0.5, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 24),

              // 🚀 ATEŞLEME BUTONU
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => _vipMudahaleTalebiBaslat(context),
                  icon: const Icon(Icons.build_circle_outlined, color: Colors.white, size: 24),
                  label: const Text("VIP ACİL ONARIM TALEP ET", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SiberTema.kanKirmizi,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 10,
                    shadowColor: SiberTema.kanKirmizi.withOpacity(0.5),
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
  Widget _kusurSatiri(String parca) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: SiberTema.kanKirmizi.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel_outlined, color: SiberTema.kanKirmizi, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(parca, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1))),
        ],
      ),
    );
  }
}