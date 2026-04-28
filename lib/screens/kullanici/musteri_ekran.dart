import 'package:otodna/core/siber_tema.dart';
// lib/screens/kullanici/musteri_ekran.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

import '../../../../core/responsive_kalkan.dart';

/// 🛡️ PLAZA ARIZA BİLDİRİM VE SERVİS ÇAĞRI EKRANI
/// Müşterinin arıza talebini doğrudan Merkeze mühürler ve ustaların radarına düşürür.
class SiberMusteriArizaSecim extends StatefulWidget {
  final String musteriId; // Talebi açan müşterinin kimliği

  SiberMusteriArizaSecim({super.key, required this.musteriId});

  @override
  State<SiberMusteriArizaSecim> createState() => _SiberMusteriArizaSecimState();
}

class _SiberMusteriArizaSecimState extends State<SiberMusteriArizaSecim> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _islemSuruyor = false;

  final Color primaryTeal = Colors.teal.shade700;
  final Color dangerColor = Colors.redAccent;
  final Color textColor = Color(0xFF1E293B);
  final Color bgColor = Color(0xFFFAFAFC);

  // ── PLAZA İSTİHBARAT: GENİŞLETİLMİŞ ARIZA LİSTESİ ──
  final List<String> arizaListesi = [
    "Fren/Balata Sorunu",
    "Motor Sesi / Titreme",
    "Yağ Sızıntısı / Değişimi",
    "Elektrik / Akü Arızası",
    "Alt Takım / Süspansiyon",
    "LPG Sızıntısı / Bakımı",
    "Egzoz / Emisyon Uyarısı",
    "Genel Araç Kontrolü (Check-Up)"
  ];

  List<String> secilenler = [];

  // ── 🚀 FİREBASE ÇAĞRI MOTORU (ATOMİK MÜHÜR) ──
  Future<void> _arizaTalebiniFirlat() async {
    if (secilenler.isEmpty) {
      HapticFeedback.heavyImpact();
      _plazaUyariGoster("BİLGİ EKSİK", "En az bir arıza veya kontrol tipi seçmelisiniz.", dangerColor);
      return;
    }

    if (_islemSuruyor) return;
    setState(() => _islemSuruyor = true);

    HapticFeedback.lightImpact();
    developer.log("🚀 PLAZA ÇAĞRISI: Arıza talebi Merkeze iletiliyor...");

    try {
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
        'islem_detayi': 'PLAZA ÇAĞRI: ${widget.musteriId} kimlikli kullanıcı arıza/bakım talebi oluşturdu.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      HapticFeedback.vibrate();
      developer.log("✅ ÇAĞRI ONAYLANDI: Talep başarıyla ustaların sistemine düştü.");

      if (mounted) {
        _plazaUyariGoster("TALEP ONAYLANDI", "Talebiniz alınmıştır, en yakın ustamız sizinle iletişime geçecektir.", primaryTeal);
        Navigator.pop(context); // İşlem bitince ekranı kapatır
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      developer.log("🚨 AĞ ÇÖKTÜ: Talep gönderilemedi!", error: e);
      if (mounted) {
        _plazaUyariGoster("BAĞLANTI HATASI", "Sistem şu an meşgul, lütfen tekrar deneyin.", dangerColor);
      }
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _plazaUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            SizedBox(height: 4),
            Text(mesaj, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text("ARIZA BİLDİRİM FORMU", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          iconTheme: IconThemeData(color: primaryTeal),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BİLGİ PANELİ
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    boxShadow: [
                      BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 15, offset: Offset(0, 5))
                    ]
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(Icons.precision_manufacturing, color: primaryTeal, size: 28),
                    ),
                    SizedBox(width: 16),
                    Expanded(child: Text("Aracınızdaki şikayetleri seçin. Plaza ağımız sizi en uygun ustaya yönlendirecektir.", style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5, letterSpacing: 0.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))),
                  ],
                ),
              ),

              // LİSTE BAŞLIĞI
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text("ŞİKAYET VE KONTROL LİSTESİ", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
              ),

              // SEÇİM BUTONLARI
              Expanded(
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16),
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
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: seciliMi ? primaryTeal.withValues(alpha: 0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: seciliMi ? primaryTeal.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05), width: seciliMi ? 2 : 1),
                          boxShadow: seciliMi ? null : [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 5)]
                        ),
                        child: Row(
                          children: [
                            Icon(
                              seciliMi ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: seciliMi ? primaryTeal : Colors.black26,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                ariza,
                                style: TextStyle(
                                    color: seciliMi ? primaryTeal : textColor,
                                    fontWeight: seciliMi ? FontWeight.w900 : FontWeight.bold,
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                    fontFamily: 'Avenir'
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
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                  boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10, offset: Offset(0, -5))]
                ),
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: _islemSuruyor
                      ? Center(child: CircularProgressIndicator(color: primaryTeal))
                      : ElevatedButton.icon(
                    icon: Icon(Icons.radar, color: SiberTema.kuantumCyan, size: 24),
                    label: Text("MERKEZE VE USTAYA İLET", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, color: SiberTema.textMain, fontFamily: 'Avenir')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
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