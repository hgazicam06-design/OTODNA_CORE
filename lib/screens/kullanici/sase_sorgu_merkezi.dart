// lib/screens/kullanici/sase_sorgu_merkezi.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE SERVİSLER
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../../services/dis_ekspertiz_entegrasyon.dart'; // 📡 Dış Veri Köprüsü

/// 🛡️ KUANTUM ŞASE SORGU VE SİCİL MERKEZİ
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

  // ── 📡 DERİN TARAMA PROTOKOLÜ (OTODNA + GOOGLE HUB) ──
  Future<void> _derinTaramaBaslat() async {
    String sase = _saseCtrl.text.trim().toUpperCase();
    if (sase.length < 11) { // Standart VIN 17 ama 11 sonrası analiz başlar
      _siberUyari("SİBER İHLAL: Geçersiz şase numarası formatı!", isError: true);
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
      _siberUyari("BAĞLANTI HATASI: Siber şebekeye ulaşılamadı.", isError: true);
    }
  }

  void _siberUyari(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
      content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("ŞASE SORGU VE GLOBAL SİCİL", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 🔍 SORGU PANELİ (Siber Cam)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: SiberTema.matGrey.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ŞASE NUMARASI (VIN)", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _saseCtrl,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        hintText: "WBA123XXXXXXXXXXX",
                        hintStyle: TextStyle(color: Colors.white12, fontSize: 14),
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.fingerprint, color: SiberTema.kuantumCyan),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: _tarihceAraniyor
                          ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                          : ElevatedButton.icon(
                        style: SiberTema.kuantumButonStili(),
                        onPressed: _derinTaramaBaslat,
                        icon: const Icon(Icons.radar, color: SiberTema.oledBlack),
                        label: const Text("GLOBAL DNA TARAMASI BAŞLAT", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, fontSize: 12)),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: SiberTema.kuantumCyan, size: 20),
              SizedBox(width: 8),
              Text("ARAC DNA'SI TESPİT EDİLDİ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
          _buildVeriSatiri("Marka/Model", _bulunanVeri!['marka_model'] ?? "Global Veri"),
          _buildVeriSatiri("Son Kilometre", "${_bulunanVeri!['kilometre'] ?? '---'} KM"),
          _buildVeriSatiri("OtoDNA Geçmişi", _bulunanVeri!['servis_sayisi']?.toString() ?? "Dış Kaynaklı Veri"),
          const Divider(color: Colors.white12, height: 30),

          // 🚀 AKSİYON: DETAYLI MÜHÜRLÜ RAPORA GİT (Paid PDF Alanı)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // SİBER NOT: Burada az önce yazdığımız EkspertizDetayScreen'e yönlendiriyoruz
                developer.log("➡️ RAPOR DETAYINA YÖNLENDİRİLİYOR...");
              },
              icon: const Icon(Icons.description, color: Colors.white),
              label: const Text("TAM SİCİL VE PDF ÇIKTISI AL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), padding: const EdgeInsets.all(16)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVeriSatiri(String etiket, String deger) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiket, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          Text(deger, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBosSinyalPaneli() {
    return Column(
      children: [
        const SizedBox(height: 50),
        Icon(Icons.satellite_alt, color: Colors.white10, size: 80),
        const SizedBox(height: 20),
        const Text("RADAR TARAMA BEKLİYOR", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 8),
        const Text("Şase numarası girerek aracın tüm siber geçmişini global ağlardan çekebilirsiniz.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white12, fontSize: 11)),
      ],
    );
  }
}