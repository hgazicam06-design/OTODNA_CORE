import 'package:otodna/core/siber_tema.dart';
// lib/screens/bayi/onay_merkezi.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA BAĞLANTISI (2 Kat Yukarı)
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM DİJİTAL ONAY VE FİNANS MOTORU
/// Ustanın zaman damgalı/sesli onayını mühürler ve Karargahın şaşmaz %12 kesintisini otonom hesaplar.
class SiberOnayVeHesapEkrani extends StatefulWidget {
  final String islemId; // Onaylanacak işlemin referans kodu
  final String bayiId; // İşlemi yapan bayi
  final double girilenFiyat; // Satış fiyatı

  SiberOnayVeHesapEkrani({
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

  // ── ⚖️ SİBER FİNANS HESAPLAMA MOTORU (SERBEST PAZAR DOKTRİNİ) ──
  Map<String, double> _hesaplamayiYap() {
    double satisFiyati = widget.girilenFiyat;

    // 🔥 YENİ KARARGAH KURALI: Ayrıcalık yok! Herkesten standart %12 Karargah payı kesilir.
    double karargahPayi = satisFiyati * 0.12;
    double bayiHakedis = satisFiyati - karargahPayi;

    return {
      "Satis_Fiyati": satisFiyati,
      "Karargah_Payi": karargahPayi,
      "Bayi_Hakedis": bayiHakedis,
    };
  }

  // ── 🚀 FİREBASE MÜHÜRLEME PROTOKOLÜ (ATOMİK ACID ZIRHI) ──
  Future<void> _dijitalMuhuVur(Map<String, double> finans) async {
    if (_onaylaniyor) return;
    setState(() => _onaylaniyor = true);

    HapticFeedback.heavyImpact();
    developer.log("📡 SİBER ONAY: İşlem mühürleniyor. Finans aktarımı başlatıldı...");

    try {
      // ACID Transaction ile kırılmaz mühürleme (İnternet kopsa bile para kaybolmaz)
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

        // 3. Siber İstihbarat Kara Kutusuna Finansal Raporu Mühürle
        DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
        transaction.set(logRef, {
          'islem_turu': 'FINANSAL_ONAY',
          'islem_detayi': 'SİBER FİNANS: İşlem (${widget.islemId}) mühürlendi. Toplam: ₺${finans['Satis_Fiyati']} | Karargah Payı: ₺${finans['Karargah_Payi']} | Bayi Net: ₺${finans['Bayi_Hakedis']}',
          'islem_id': widget.islemId,
          'bayi_id': widget.bayiId,
          'tarih': FieldValue.serverTimestamp(),
        });
      });

      HapticFeedback.vibrate();
      developer.log("✅ İŞLEM MÜHÜRLENDİ: Finans aktarıldı ve dijital imza atıldı.");

      if (mounted) {
        Navigator.pop(context); // Mühür vurulunca önceki ekrana siber geçişle döner
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

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Kalkan aydınlatması arkadan vursun
        appBar: AppBar(
          title: Text("FİNANSAL ONAY VE MÜHÜR", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // 🎙️ DİJİTAL İMZA KARTI (Siber Cam)
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: SiberTema.matGrey.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2),
                      boxShadow: [
                        BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 20, spreadRadius: 2)
                      ]
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.fingerprint, color: SiberTema.kuantumCyan, size: 40),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("SESLİ VE DİJİTAL ONAY BEKLENİYOR", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1)),
                            SizedBox(height: 4),
                            Text("Zaman damgalı video ile mühürlenecektir.", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                // 📊 HESAPLAMA TABLOSU
                Container(
                  decoration: BoxDecoration(
                    color: SiberTema.matGrey.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SiberTema.textMuted),
                  ),
                  child: Column(
                    children: [
                      _buildSiberSatir("Girilen Satış Tutarı", "₺${widget.girilenFiyat.toStringAsFixed(2)}"),
                      Divider(color: SiberTema.textMuted, height: 1),
                      _buildSiberSatir("Karargah Payı (%12)", "-₺${finans['Karargah_Payi']!.toStringAsFixed(2)}", renk: SiberTema.kanKirmizi),
                      Divider(color: SiberTema.textMuted, height: 1, thickness: 1),
                      _buildSiberSatir("BAYİ NET HAKEDİŞİ", "₺${finans['Bayi_Hakedis']!.toStringAsFixed(2)}", renk: SiberTema.kuantumCyan, isBold: true),
                    ],
                  ),
                ),
                SizedBox(height: 40),

                // 🚀 MÜHÜRLEME BUTONU
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: _onaylaniyor
                      ? Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                      : ElevatedButton.icon(
                    icon: Icon(Icons.verified_user_outlined, color: SiberTema.oledBlack, size: 28),
                    label: Text("DİJİTAL MÜHRÜ VUR VE ONAYLA", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, color: SiberTema.oledBlack)),
                    style: SiberTema.kuantumButonStili(),
                    onPressed: () => _dijitalMuhuVur(finans),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Özel Tablo Satırı Widget'ı
  Widget _buildSiberSatir(String etiket, String deger, {Color renk = Colors.white54, bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiket, style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, letterSpacing: 0.5)),
          Text(deger, style: TextStyle(color: renk, fontSize: isBold ? 18 : 14, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, letterSpacing: 1, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}