// lib/screens/kullanici/musteri_ekran.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA BAĞLANTISI (2 Kat Yukarı)
import '../../../../core/siber_tema.dart';
import '../../../../core/responsive_kalkan.dart';

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

  // ── 🚀 FİREBASE ÇAĞRI MOTORU (ATOMİK MÜHÜR) ──
  Future<void> _arizaTalebiniFirlat() async {
    if (secilenler.isEmpty) {
      HapticFeedback.heavyImpact();
      _siberUyariGoster("SİBER İHLAL", "En az bir arıza veya kontrol tipi seçmelisiniz.", SiberTema.kanKirmizi);
      return;
    }

    if (_islemSuruyor) return;
    setState(() => _islemSuruyor = true);

    HapticFeedback.lightImpact();
    developer.log("🚀 SİBER ÇAĞRI: Arıza talebi Karargaha iletiliyor...");

    try {
      // 🛡️ ATOMİK ZIRH: İşlemi ve Karargah Logunu aynı anda kilitler!
      WriteBatch batch = _db.batch();

      DocumentReference talepRef = _db.collection('ariza_talepleri').doc();
      batch.set(talepRef, {
        'musteri_id': widget.musteriId,
        'talep_edilen_islemler': secilenler,
        'durum': 'BEKLIYOR', // Usta radarına düşecek
        'zaman_damgasi': FieldValue.serverTimestamp(),
      });

      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'MUSTERI_ARIZA_TALEBI',
        'islem_detayi': 'SİBER ÇAĞRI: ${widget.musteriId} kimlikli kullanıcı arıza/bakım talebi fırlattı.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Füzeleri ateşle!

      HapticFeedback.vibrate();
      developer.log("✅ ÇAĞRI ONAYLANDI: Talep başarıyla ustaların sistemine düştü.");

      if (mounted) {
        _siberUyariGoster("KARARGAH ONAYI", "Talebiniz alınmıştır, en yakın ustamız sizinle iletişime geçecektir.", SiberTema.kuantumCyan);
        Navigator.pop(context); // İşlem bitince ekranı siber bir geçişle kapatır
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      developer.log("🚨 AĞ ÇÖKTÜ: Talep fırlatılamadı!", error: e);
      if (mounted) {
        _siberUyariGoster("BAĞLANTI HATASI", "Sistem şu an meşgul, lütfen tekrar deneyin.", SiberTema.kanKirmizi);
      }
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.matGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Zırhın aydınlatması arkadan gelsin
        appBar: AppBar(
          title: const Text("ARIZA BİLDİRİM RADARI", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BİLGİ PANELİ (Siber Cam)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: SiberTema.matGrey.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 15, spreadRadius: 1)
                    ]
                ),
                child: const Row(
                  children: [
                    Icon(Icons.precision_manufacturing, color: SiberTema.kuantumCyan, size: 28),
                    SizedBox(width: 12),
                    Expanded(child: Text("Aracınızdaki şikayetleri seçin. Siber ağımız en uygun ustayı yönlendirecektir.", style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5, letterSpacing: 0.5, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),

              // LİSTE BAŞLIĞI
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text("ŞİKAYET VE KONTROL LİSTESİ", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900)),
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
                          color: seciliMi ? SiberTema.kuantumCyan.withOpacity(0.1) : SiberTema.matGrey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: seciliMi ? SiberTema.kuantumCyan : Colors.white12, width: seciliMi ? 2 : 1),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              seciliMi ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: seciliMi ? SiberTema.kuantumCyan : Colors.white54,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                ariza,
                                style: TextStyle(
                                    color: seciliMi ? SiberTema.kuantumCyan : Colors.white,
                                    fontWeight: seciliMi ? FontWeight.w900 : FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.5
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
                      ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                      : ElevatedButton.icon(
                    icon: const Icon(Icons.radar, color: SiberTema.oledBlack, size: 24),
                    label: const Text("KARARGAHA VE USTAYA İLET", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, color: SiberTema.oledBlack)),
                    style: SiberTema.kuantumButonStili(),
                    onPressed: _arizaTalebiniFirlat,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}