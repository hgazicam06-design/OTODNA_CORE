// lib/screens/onay_merkezi.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM DİJİTAL ONAY VE FİNANS MOTORU
/// Ustanın zaman damgalı/sesli onayını mühürler ve Karargah kesintilerini otonom hesaplar.
class SiberOnayVeHesapEkrani extends StatefulWidget {
  final String islemId; // Onaylanacak işlemin referans kodu
  final String bayiId; // İşlemi yapan bayi (MURAT_PLAZA istisnası için kritik!)
  final double girilenFiyat; // Maliyet veya Satış fiyatı

  const SiberOnayVeHesapEkrani({
    super.key,
    required this.islemId,
    required this.bayiId,
    required this.girilenFiyat,
  });

  @override
  State<SiberOnayVeHesapEkrani> createState() => _SiberOnayVeHesapEkraniState();
}

class _SiberOnayVeHesapEkraniState extends State<SiberOnayVeHesapEkrani> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _onaylaniyor = false;

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  // ── ⚖️ SİBER FİNANS HESAPLAMA MOTORU ──
  Map<String, double> _hesaplamayiYap() {
    double satisFiyati = widget.girilenFiyat;
    double karargahPayi = 0;
    double bayiHakedis = 0;

    // 🔥 KRİTİK KALKAN: Murat Plaza Kontrolü
    if (widget.bayiId == "MURAT_PLAZA") {
      // Murat Plaza'ya %30 Özel Kâr Marjı uygulanır ve Karargah %30 payını alır.
      satisFiyati = widget.girilenFiyat * 1.30;
      karargahPayi = satisFiyati * 0.30;
    } else {
      // Diğer tüm bayilerde satış fiyatına karışılmaz, sistem standart %12 payını keser.
      karargahPayi = satisFiyati * 0.12;
    }

    bayiHakedis = satisFiyati - karargahPayi;

    return {
      "Satis_Fiyati": satisFiyati,
      "Karargah_Payi": karargahPayi,
      "Bayi_Hakedis": bayiHakedis,
    };
  }

  // ── 🚀 FİREBASE MÜHÜRLEME PROTOKOLÜ ──
  Future<void> _dijitalMuhuVur(Map<String, double> finans) async {
    if (_onaylaniyor) return;
    setState(() => _onaylaniyor = true);

    HapticFeedback.heavyImpact();
    developer.log("📡 SİBER ONAY: İşlem mühürleniyor. Finans aktarımı başlatıldı...");

    try {
      // ACID Transaction ile kırılmaz mühürleme
      await _db.runTransaction((transaction) async {
        DocumentReference islemRef = _db.collection('yapilan_islemler').doc(widget.islemId);
        DocumentReference finansHavuzRef = _db.collection('finans_havuzu').doc(widget.bayiId);

        // 1. İşlemi "ONAYLANDI" olarak mühürle
        transaction.update(islemRef, {
          'durum': 'SESLI_ONAY_ALINDI',
          'satis_fiyati': finans['Satis_Fiyati'],
          'kesilen_pay': finans['Karargah_Payi'],
          'bayi_hakedisi': finans['Bayi_Hakedis'],
          'muhur_zaman_damgasi': FieldValue.serverTimestamp(),
        });

        // 2. Bayinin bekleyen hakedişini otonom olarak güncelle
        transaction.set(finansHavuzRef, {
          'bekleyen_hakedis': FieldValue.increment(finans['Bayi_Hakedis']!),
          'son_islem_tarihi': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      HapticFeedback.vibrate();
      developer.log("✅ İŞLEM MÜHÜRLENDİ: Finans aktarıldı ve dijital imza atıldı.");

      if (mounted) {
        Navigator.pop(context); // Mühür vurulunca önceki ekrana döner
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      developer.log("🚨 AĞ ÇÖKTÜ: Mühürleme başarısız!", error: e);
    } finally {
      if (mounted) setState(() => _onaylaniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> finans = _hesaplamayiYap();
    bool isMuratPlaza = widget.bayiId == "MURAT_PLAZA";

    return Scaffold(
      backgroundColor: _oledBlack,
      appBar: AppBar(
        title: const Text("FİNANSAL ONAY VE MÜHÜR", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kuantumCyan),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 🎙️ DİJİTAL İMZA KARTI
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _kuantumCyan.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _kuantumCyan.withOpacity(0.5), width: 2),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.fingerprint, color: _kuantumCyan, size: 40),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("SESLİ VE DİJİTAL ONAY BEKLENİYOR", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          SizedBox(height: 4),
                          Text("Zaman damgalı video ile mühürlenecektir.", style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 📊 HESAPLAMA TABLOSU
              Container(
                decoration: BoxDecoration(
                  color: _matGrey,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    _buildSiberSatir("Girilen ${isMuratPlaza ? 'Maliyet' : 'Satış'} Tutarı", "₺${widget.girilenFiyat.toStringAsFixed(2)}"),
                    const Divider(color: Colors.white12, height: 1),
                    if (isMuratPlaza) ...[
                      _buildSiberSatir("Siber Satış Fiyatı (+%30)", "₺${finans['Satis_Fiyati']!.toStringAsFixed(2)}", renk: Colors.white),
                      const Divider(color: Colors.white12, height: 1),
                    ],
                    _buildSiberSatir("Karargah Payı (${isMuratPlaza ? '%30' : '%12'})", "-₺${finans['Karargah_Payi']!.toStringAsFixed(2)}", renk: Colors.redAccent),
                    const Divider(color: Colors.white24, height: 1, thickness: 1),
                    _buildSiberSatir("BAYİ NET HAKEDİŞİ", "₺${finans['Bayi_Hakedis']!.toStringAsFixed(2)}", renk: _kuantumCyan, isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 🚀 MÜHÜRLEME BUTONU
              SizedBox(
                height: 60,
                width: double.infinity,
                child: _onaylaniyor
                    ? const Center(child: CircularProgressIndicator(color: _kuantumCyan))
                    : ElevatedButton.icon(
                  icon: const Icon(Icons.verified_user_outlined, color: Colors.black, size: 28),
                  label: const Text("DİJİTAL MÜHRÜ VUR VE ONAYLA", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kuantumCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 10,
                    shadowColor: _kuantumCyan.withOpacity(0.5),
                  ),
                  onPressed: () => _dijitalMuhuVur(finans),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Özel Tablo Satırı Widget'ı
  Widget _buildSiberSatir(String etiket, String deger, {Color renk = Colors.white54, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiket, style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, letterSpacing: 0.5)),
          Text(deger, style: TextStyle(color: renk, fontSize: isBold ? 18 : 14, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }
}