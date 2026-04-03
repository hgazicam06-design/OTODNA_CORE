// lib/widgets/akilli_asistan.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM YAPAY ZEKA VE OTONOM HATIRLATMA MOTORU (OtoDNAAsistan)
/// Aracın DNA'sını inceler, mekanik riskleri hesaplar ve Karargah gelirlerini tetikleyen VIP teklifler sunar.
class OtoDNAAsistan extends StatefulWidget {
  final String saseNo;

  const OtoDNAAsistan({super.key, required this.saseNo});

  @override
  State<OtoDNAAsistan> createState() => _OtoDNAAsistanState();
}

class _OtoDNAAsistanState extends State<OtoDNAAsistan> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  // ── 🧠 YAPAY ZEKA ANALİZ MOTORU ──
  bool _trigerRiskiVarMi(int sonKM, int sonTrigerDegisimKM) {
    // Triger kayışı ortalama 60.000 KM'de bir değişmelidir.
    return (sonKM - sonTrigerDegisimKM) >= 60000;
  }

  // ── 💰 VIP SATIN ALMA VE %12 FİNANS MOTORU TETİKLEYİCİSİ ──
  Future<void> _vipHizmetSatinAl(String hizmetTuru) async {
    developer.log("💎 VIP İŞLEM: $hizmetTuru için siber ödeme köprüsü açılıyor...");

    // SİBER NOT: Gerçek sistemde burada Ödeme Ekranı (Iyzico vs.) açılır.
    // Başarılı olduğunda FinanceService %10 + %2 Vergi (%12) Karargah payını kesip havuza atar.

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _kuantumCyan,
        content: Text("SİBER ONAY: $hizmetTuru Talebiniz Karargaha İletildi!",
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  // ── 🔧 KM GÜNCELLEME DİYALOĞU ──
  void _kmGuncelleDialog(int mevcutKM) {
    final kmController = TextEditingController(text: mevcutKM.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _matGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: _kuantumCyan.withOpacity(0.5))),
        title: const Text("GÜNCEL KM VERİSİ", style: TextStyle(color: Colors.white, letterSpacing: 1.5)),
        content: TextField(
          controller: kmController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: _kuantumCyan, fontSize: 20, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            hintText: "Örn: 125000",
            hintStyle: TextStyle(color: Colors.white30),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _kuantumCyan)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İPTAL", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _kuantumCyan, foregroundColor: Colors.black),
            onPressed: () async {
              int yeniKm = int.tryParse(kmController.text) ?? mevcutKM;
              if (yeniKm > mevcutKM) {
                await _db.collection('araclar').doc(widget.saseNo).update({'guncel_km': yeniKm});
                developer.log("✅ SİBER BİLGİ: Araç DNA'sındaki KM $yeniKm olarak güncellendi.");
              }
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text("MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _oledBlack,
      appBar: AppBar(
        title: const Text('OTODNA AKILLI ASİSTAN',
            style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kuantumCyan),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _db.collection('araclar').doc(widget.saseNo).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _kuantumCyan));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("SİBER İHLAL: Araç verisi bulunamadı.", style: TextStyle(color: Colors.redAccent)));
          }

          var aracVerisi = snapshot.data!.data() as Map<String, dynamic>;
          int sonKM = aracVerisi['guncel_km'] ?? 0;
          int sonTrigerDegisimKM = aracVerisi['son_triger_km'] ?? 0;

          bool trigerRiski = _trigerRiskiVarMi(sonKM, sonTrigerDegisimKM);

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              // ── 🧠 AI BİLGİLENDİRME PANELİ ──
              _buildSiberBilgiKarti("ROBOT AL:", "Gazi Bey, sistem araç verilerinizi analiz etti. Güncel profilinize uygun Karargah teklifleri aşağıdadır."),
              const SizedBox(height: 24),

              // ── 💎 VIP TEKLİF KARTLARI ──
              _teklifKarti("VIP KASKO & SİGORTA", "Anlaşmalı 15 Siber firmadan en iyi fiyat.", Icons.shield_outlined, Colors.blueAccent, () => _vipHizmetSatinAl("KASKO")),
              const SizedBox(height: 12),
              _teklifKarti("VIP MUAYENE RANDEVUSU", "Sıra beklemeden, adınıza biz alalım.", Icons.history_edu_outlined, Colors.amberAccent, () => _vipHizmetSatinAl("MUAYENE")),

              const SizedBox(height: 24),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 16),

              // ── 🏎️ KM VE MEKANİK KONTROL MERKEZİ ──
              Container(
                decoration: BoxDecoration(color: _matGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                child: ListTile(
                  leading: const Icon(Icons.speed_outlined, color: _kuantumCyan, size: 30),
                  title: const Text("KİLOMETRE GÜNCELLEME", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
                  subtitle: Text("Siber Kayıt: $sonKM KM", style: const TextStyle(color: Colors.white54, fontSize: 14)),
                  trailing: const Icon(Icons.edit_outlined, color: _kuantumCyan),
                  onTap: () => _kmGuncelleDialog(sonKM),
                ),
              ),

              const SizedBox(height: 16),

              // ── 🚨 AI KRİZ ALARMI (TRİGER / BALATA) ──
              if (trigerRiski)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                          SizedBox(width: 10),
                          Text("⚠️ YAPAY ZEKA ALARMI", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Araç DNA'sı analiz edildi. Triger setinin ömrü (60.000 KM) dolmuş veya aşılmış olabilir! Motorun çökmemesi için acilen Karargah Ustalarına yönlendirin.",
                        style: TextStyle(color: Colors.white70, height: 1.5, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: () => _vipHizmetSatinAl("ACİL BAKIM RANDEVUSU"),
                          child: const Text("EN YAKIN USTADAN RANDEVU AL", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                      )
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ── 🔧 ARAYÜZ YARDIMCILARI ───────────────────────────────────────────────

  Widget _buildSiberBilgiKarti(String baslik, String mesaj) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _kuantumCyan.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: _kuantumCyan.withOpacity(0.3))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.smart_toy_outlined, color: _kuantumCyan, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik, style: const TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _teklifKarti(String baslik, String icerik, IconData ikon, Color renk, VoidCallback onTapped) {
    return Container(
      decoration: BoxDecoration(color: _matGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: renk.withOpacity(0.3))),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(ikon, color: renk, size: 30),
        title: Text(baslik, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(icerik, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: renk.withOpacity(0.2),
            foregroundColor: renk,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk.withOpacity(0.5))),
          ),
          onPressed: onTapped,
          child: const Text("HEMEN AL", style: TextStyle(fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}