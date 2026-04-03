// lib/screens/musteri_ekran.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM ARIZA BİLDİRİM VE SİBER ÇAĞRI EKRANI
/// Müşterinin arıza talebini doğrudan Karargaha mühürler ve ustaların radarına düşürür.
class SiberMusteriArizaSecim extends StatefulWidget {
  final String musteriId; // Talebi açan müşterinin Karargah kimliği

  const SiberMusteriArizaSecim({super.key, required this.musteriId});

  @override
  State<SiberMusteriArizaSecim> createState() => _SiberMusteriArizaSecimState();
}

class _SiberMusteriArizaSecimState extends State<SiberMusteriArizaSecim> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _islemSuruyor = false;

  // ── SİBER İSTİHBARAT: GENİŞLETİLMİŞ ARIZA LİSTESİ ──
  final List<String> arizaListesi = [
    "Fren/Balata Sorunu",
    "Motor Sesi / Titreme",
    "Yağ Sızıntısı / Değişimi",
    "Elektrik / Akü Arızası",
    "Alt Takım / Süspansiyon",
    "LPG Sızıntısı / Bakımı",
    "Egzoz / Emisyon Uyarısı",
    "Genel Kuantum Kontrolü (Check-Up)"
  ];

  List<String> secilenler = [];

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  // ── 🚀 FİREBASE ÇAĞRI MOTORU ──
  Future<void> _arizaTalebiniFirlat() async {
    if (secilenler.isEmpty) {
      HapticFeedback.heavyImpact();
      _siberUyariGoster("SİBER İHLAL", "En az bir arıza veya kontrol tipi seçmelisiniz.", Colors.redAccent);
      return;
    }

    if (_islemSuruyor) return;
    setState(() => _islemSuruyor = true);

    HapticFeedback.lightImpact();
    developer.log("🚀 SİBER ÇAĞRI: Arıza talebi Karargaha iletiliyor...");

    try {
      await _db.collection('ariza_talepleri').add({
        'musteri_id': widget.musteriId,
        'talep_edilen_islemler': secilenler,
        'durum': 'BEKLIYOR', // Usta radarına düşecek
        'zaman_damgasi': FieldValue.serverTimestamp(),
      });

      HapticFeedback.vibrate();
      developer.log("✅ ÇAĞRI ONAYLANDI: Talep başarıyla ustaların sistemine düştü.");

      if (mounted) {
        _siberUyariGoster("KARARGAH ONAYI", "Talebiniz alınmıştır, en yakın ustamız sizinle iletişime geçecektir.", _kuantumCyan);
        Navigator.pop(context); // İşlem bitince ekranı kapatır
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      developer.log("🚨 AĞ ÇÖKTÜ: Talep fırlatılamadı!", error: e);
      if (mounted) {
        _siberUyariGoster("BAĞLANTI HATASI", "Sistem şu an meşgul, lütfen tekrar deneyin.", Colors.redAccent);
      }
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _matGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _oledBlack,
      appBar: AppBar(
        title: const Text("ARIZA BİLDİRİM RADARI", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kuantumCyan),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BİLGİ PANELİ
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: _kuantumCyan.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kuantumCyan.withOpacity(0.3), width: 1.5)
              ),
              child: const Row(
                children: [
                  Icon(Icons.precision_manufacturing, color: _kuantumCyan, size: 28),
                  SizedBox(width: 12),
                  Expanded(child: Text("Aracınızdaki şikayetleri seçin. Siber ağımız en uygun ustayı yönlendirecektir.", style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5, letterSpacing: 0.5))),
                ],
              ),
            ),

            // LİSTE BAŞLIĞI
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text("ŞİKAYET VE KONTROL LİSTESİ", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
            ),

            // SİBER SEÇİM BUTONLARI
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: arizaListesi.length,
                itemBuilder: (context, index) {
                  String ariza = arizaListesi[index];
                  bool seciliMi = secilenler.contains(ariza);

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        seciliMi ? secilenler.remove(ariza) : secilenler.add(ariza);
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: seciliMi ? _kuantumCyan.withOpacity(0.1) : _matGrey,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: seciliMi ? _kuantumCyan : Colors.white12, width: seciliMi ? 2 : 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            seciliMi ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: seciliMi ? _kuantumCyan : Colors.white54,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              ariza,
                              style: TextStyle(
                                color: seciliMi ? _kuantumCyan : Colors.white,
                                fontWeight: seciliMi ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ATEŞLEME BUTONU
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 60,
                width: double.infinity,
                child: _islemSuruyor
                    ? const Center(child: CircularProgressIndicator(color: _kuantumCyan))
                    : ElevatedButton.icon(
                  icon: const Icon(Icons.radar, color: Colors.black, size: 24),
                  label: const Text("KARARGAHA VE USTAYA İLET", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kuantumCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 10,
                    shadowColor: _kuantumCyan.withOpacity(0.5),
                  ),
                  onPressed: _arizaTalebiniFirlat,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}