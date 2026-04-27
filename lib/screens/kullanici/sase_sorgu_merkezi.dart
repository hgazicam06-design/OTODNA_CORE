// lib/screens/kullanici/sase_sorgu_merkezi.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

import '../../core/responsive_kalkan.dart';
import '../../services/dis_ekspertiz_entegrasyon.dart';

/// 🛡️ PLAZA ŞASE SORGU VE SİCİL MERKEZİ
/// Şase numarası girilen aracın OtoDNA ve Global (Google Hub) verilerini birleştirip mühürlü rapor sunar.
class SiberSaseSorguMerkezi extends StatefulWidget {
  const SiberSaseSorguMerkezi({super.key});

  @override
  State<SiberSaseSorguMerkezi> createState() => _SiberSaseSorguMerkeziState();
}

class _SiberSaseSorguMerkeziState extends State<SiberSaseSorguMerkezi> {
  final TextEditingController _saseCtrl = TextEditingController();
  final DisEkspertizServisi _disServis = DisEkspertizServisi();

  bool _tarihceAraniyor = false;
  Map<String, dynamic>? _bulunanVeri;

  final Color primaryTeal = Colors.teal.shade700;
  final Color dangerColor = Colors.redAccent;
  final Color textColor = const Color(0xFF1E293B);
  final Color bgColor = const Color(0xFFFAFAFC);

  // ── 📡 DERİN TARAMA PROTOKOLÜ (OTODNA + GOOGLE HUB) ──
  Future<void> _derinTaramaBaslat() async {
    String sase = _saseCtrl.text.trim().toUpperCase();
    if (sase.length < 11) { // Standart VIN 17 ama 11 sonrası analiz başlar
      _plazaUyari("BİLGİ EKSİK: Geçersiz şase numarası formatı!", isError: true);
      return;
    }

    setState(() => _tarihceAraniyor = true);
    developer.log("📡 RADAR AKTİF: $sase için global derin tarama başlatıldı...");

    try {
      // 1. ÖNCE OTODNA YEREL RADARINA BAK
      var yerelDoc = await FirebaseFirestore.instance.collection('araclar').doc(sase).get();

      // 2. DIŞ VERİ (GOOGLE HUB / EXTERNAL) ENTEGRASYONUNU TETİKLE
      // Uygulamada veri yoksa bile bu servis dışarıdan veriyi çekip Firestore'a yazar.
      await _disServis.disVeriyiKarargahaAktar(
          saseNo: sase,
          kaynakSube: "Global Veri Ağı (Google Hub)",
          disVeriLink: "https://hub.google/api/v1/vin/$sase" // Temsili Hub Bağlantısı
      );

      // 3. BİRLEŞTİRİLMİŞ VERİYİ TEKRAR ÇEK
      var guncelYerelDoc = await FirebaseFirestore.instance.collection('araclar').doc(sase).get();

      setState(() {
        _bulunanVeri = guncelYerelDoc.data();
        _tarihceAraniyor = false;
      });

      developer.log("✅ TARAMA TAMAM: Araç DNA'sı global şebekeden mühürlendi.");

    } catch (e) {
      developer.log("🚨 RADAR ÇÖKTÜ: Global ağa ulaşılamıyor!", error: e);
      setState(() => _tarihceAraniyor = false);
      _plazaUyari("BAĞLANTI HATASI: Global şebekeye ulaşılamadı.", isError: true);
    }
  }

  void _plazaUyari(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.white,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isError ? dangerColor : primaryTeal, width: 2)),
      content: Text(mesaj, style: TextStyle(fontWeight: FontWeight.w900, color: textColor, fontFamily: 'Avenir')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text("ŞASE SORGU VE GLOBAL SİCİL", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          iconTheme: IconThemeData(color: primaryTeal),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 🔍 SORGU PANELİ
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ŞASE NUMARASI (VIN)", style: TextStyle(color: Colors.white45, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05))
                      ),
                      child: TextField(
                        controller: _saseCtrl,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2, fontFamily: 'monospace'),
                        decoration: InputDecoration(
                          hintText: "WBA123XXXXXXXXXXX",
                          hintStyle: const TextStyle(color: Colors.white26, fontSize: 14),
                          border: InputBorder.none,
                          suffixIcon: Icon(Icons.fingerprint, color: primaryTeal),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: _tarihceAraniyor
                          ? Center(child: CircularProgressIndicator(color: primaryTeal))
                          : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _derinTaramaBaslat,
                        icon: const Icon(Icons.radar, color: Colors.white),
                        label: const Text("GLOBAL DNA TARAMASI BAŞLAT", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 12, fontFamily: 'Avenir')),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 📊 SONUÇ RADARI
              if (_bulunanVeri != null)
                _buildSonucPaneli()
              else if (!_tarihceAraniyor)
                _buildBosSinyalPaneli(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSonucPaneli() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryTeal.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))]
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: primaryTeal, size: 24),
              const SizedBox(width: 12),
              Text("ARAÇ DNA'SI TESPİT EDİLDİ", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, fontSize: 13, fontFamily: 'Avenir', letterSpacing: 1)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
          ),
          _buildVeriSatiri("Marka/Model", _bulunanVeri!['marka_model'] ?? "Global Veri"),
          _buildVeriSatiri("Son Kilometre", "${_bulunanVeri!['kilometre'] ?? '---'} KM"),
          _buildVeriSatiri("OtoDNA Geçmişi", _bulunanVeri!['servis_sayisi']?.toString() ?? "Dış Kaynaklı Veri"),
          const SizedBox(height: 16),

          // 🚀 AKSİYON: DETAYLI MÜHÜRLÜ RAPORA GİT
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                developer.log("➡️ RAPOR DETAYINA YÖNLENDİRİLİYOR...");
              },
              icon: Icon(Icons.description, color: primaryTeal),
              label: Text("TAM SİCİL VE ÇIKTI AL", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryTeal.withValues(alpha: 0.5)), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: primaryTeal.withValues(alpha: 0.05)
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVeriSatiri(String etiket, String deger) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiket, style: const TextStyle(color: Colors.white45, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          Text(deger, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Avenir')),
        ],
      ),
    );
  }

  Widget _buildBosSinyalPaneli() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), shape: BoxShape.circle),
          child: const Icon(Icons.satellite_alt, color: Colors.white12, size: 60)
        ),
        const SizedBox(height: 24),
        const Text("SİSTEM HAZIR BEKLİYOR", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text("Şase numarası girerek aracın tüm geçmişini global ağlardan çekebilirsiniz.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir', height: 1.5)),
        ),
      ],
    );
  }
}