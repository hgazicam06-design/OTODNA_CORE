// lib/screens/usta_denetim.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:developer' as developer;

/// 🛡️ KUANTUM USTA ASİSTANI VE DENETİM MERKEZİ
/// Müşterinin talebini Karargahtan (Firebase) çeker, ustaya sesli okur ve ustanın komutuyla listeyi düzenleyip mühürler.
class SiberUstaDenetimSayfasi extends StatefulWidget {
  final String talepId; // İncelenen arıza talebinin referans kimliği
  final String ustaId; // Ekranı kullanan ustanın Karargah kimliği
  final String ustaAdi; // Sesli asistanın hitap edeceği ustanın ismi

  const SiberUstaDenetimSayfasi({
    super.key,
    required this.talepId,
    required this.ustaId,
    required this.ustaAdi
  });

  @override
  State<SiberUstaDenetimSayfasi> createState() => _SiberUstaDenetimSayfasiState();
}

class _SiberUstaDenetimSayfasiState extends State<SiberUstaDenetimSayfasi> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  FlutterTts _flutterTts = FlutterTts();
  stt.SpeechToText _speech = stt.SpeechToText();

  List<dynamic> _yapilacaklar = []; // Firebase'den çekilecek liste
  String _ekranMesaji = "SİBER AĞ: Müşteri istihbaratı indiriliyor...";
  bool _isListening = false;
  bool _islemSuruyor = false;

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  @override
  void initState() {
    super.initState();
    _siberIstihbaratiCek();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speech.stop();
    super.dispose();
  }

  // ── 📡 FİREBASE VERİ ÇEKİM MOTORU ──
  Future<void> _siberIstihbaratiCek() async {
    try {
      DocumentSnapshot talepDoc = await _db.collection('ariza_talepleri').doc(widget.talepId).get();

      if (talepDoc.exists) {
        setState(() {
          _yapilacaklar = talepDoc['talep_edilen_islemler'] ?? ["Belirsiz İşlem"];
          _ekranMesaji = "İstihbarat alındı. Raporu dinlemeye veya komut vermeye hazırsınız.";
        });
      } else {
        setState(() => _ekranMesaji = "SİBER İHLAL: Arıza talebi bulunamadı.");
      }
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: İstihbarat çekilemedi!", error: e);
      setState(() => _ekranMesaji = "BAĞLANTI HATASI: Kuantum Ağına ulaşılamıyor.");
    }
  }

  // ── 🗣️ SİBER ASİSTAN MOTORU (OKUYUCU) ──
  Future<void> _raporuOku() async {
    if (_yapilacaklar.isEmpty) return;

    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5); // Otoriter ton

    setState(() => _ekranMesaji = "RADAR AKTİF: Sistem Raporu Okunuyor...");

    String islemListesi = _yapilacaklar.join(" ve ");
    String metin = "${widget.ustaAdi} Usta, müşteri aracında $islemListesi kontrolü talep etmiş. Yeni bir parça eklemek isterseniz komut veriniz veya işlemi onaylayınız.";

    await _flutterTts.speak(metin);
  }

  // ── 🎙️ DİNLEME VE YAPAY ZEKA AYIKLAMA MOTORU ──
  Future<void> _ustayiDinle() async {
    if (_islemSuruyor) return;

    HapticFeedback.lightImpact();
    bool available = await _speech.initialize(
      onStatus: (val) => developer.log('🎙️ SES RADARI: $val'),
      onError: (val) => developer.log('🚨 SES HATASI: $val'),
    );

    if (available) {
      setState(() => _isListening = true);
      await _flutterTts.stop(); // Konuşurken sustur

      _speech.listen(
          localeId: "tr_TR",
          onResult: (val) {
            setState(() {
              String komut = val.recognizedWords;
              String kucukHarfKomut = komut.toLowerCase();
              _ekranMesaji = "SİBER KULAK DİNLİYOR:\n\"$komut\"";

              // SİBER ALGORİTMA 1: PARÇA EKLEME ("Polen filtresi ekle" vb.)
              if (kucukHarfKomut.contains("ekle") || kucukHarfKomut.contains("ilave")) {
                _speech.stop();
                _isListening = false;

                // "ekle" kelimesinden önceki kısmı al
                String eklenecekParca = kucukHarfKomut.replaceAll("ekle", "").replaceAll("ilave et", "").trim();
                if (eklenecekParca.isNotEmpty) {
                  _yapilacaklar.add(eklenecekParca.toUpperCase());
                  _flutterTts.speak("Anlaşıldı. $eklenecekParca listeye eklendi.");
                }
              }

              // SİBER ALGORİTMA 2: MÜHÜR VE ONAY
              if (kucukHarfKomut.contains("onay") || kucukHarfKomut.contains("mühürle")) {
                _speech.stop();
                _isListening = false;
                _finalMuhruVur();
              }
            });
          }
      );
    } else {
      _siberUyariGoster("SİBER İHLAL", "Mikrofon erişimi reddedildi.", Colors.redAccent);
    }
  }

  // ── 🚀 FİREBASE MÜHÜRLEME PROTOKOLÜ ──
  Future<void> _finalMuhruVur() async {
    if (_islemSuruyor) return;
    setState(() => _islemSuruyor = true);
    HapticFeedback.heavyImpact();

    developer.log("🚀 SİBER ONAY: Liste ustanın kararıyla güncelleniyor ve mühürleniyor!");

    try {
      // 1. Orijinal talebi güncelle ve Karargaha raporu yaz
      await _db.collection('ariza_talepleri').doc(widget.talepId).update({
        'talep_edilen_islemler': _yapilacaklar, // Ustanın ekledikleriyle birlikte
        'durum': 'USTA_TARAFINDAN_ONAYLANDI',
        'islem_yapan_usta_id': widget.ustaId,
        'onay_zaman_damgasi': FieldValue.serverTimestamp(),
      });

      // 2. İşlemler klasörüne yeni bir kayıt fırlat
      await _db.collection('yapilan_islemler').add({
        'bagli_talep_id': widget.talepId,
        'yapilan_isler': _yapilacaklar,
        'usta_id': widget.ustaId,
        'islem_durumu': 'MUDUHALEYE_BASLANDI',
        'zaman_damgasi': FieldValue.serverTimestamp(),
      });

      await _flutterTts.speak("Rapor son haline getirildi ve bayiniz adına Kuantum Ağına mühürlendi. Elinize sağlık ${widget.ustaAdi} usta.");
      HapticFeedback.vibrate();
      developer.log("✅ İŞLEM MÜHÜRLENDİ: Matrix'e kazındı.");

      if (mounted) {
        _siberUyariGoster("BAYİ ONAYI GERÇEKLEŞTİ", "Sistem Karargaha kaydedildi.", _kuantumCyan);
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) Navigator.pop(context);
        });
      }

    } catch (e) {
      HapticFeedback.heavyImpact();
      developer.log("🚨 AĞ ÇÖKTÜ: Mühürleme başarısız!", error: e);
      _siberUyariGoster("BAĞLANTI HATASI", "Mühür Karargaha iletilemedi.", Colors.redAccent);
      setState(() => _islemSuruyor = false);
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
        title: const Text("USTA DENETİM VE ASİSTAN", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kuantumCyan),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // 📋 MÜŞTERİ TALEBİ PANELİ
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: _matGrey,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kuantumCyan.withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: _kuantumCyan.withOpacity(0.05), blurRadius: 20, spreadRadius: 2)
                    ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.description_outlined, color: _kuantumCyan, size: 20),
                        SizedBox(width: 8),
                        Text("GÜNCEL İŞLEM LİSTESİ", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _yapilacaklar.map((islem) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: _kuantumCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: _kuantumCyan.withOpacity(0.3))),
                        child: Text(islem.toString(), style: const TextStyle(color: _kuantumCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                      )).toList(),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 🎙️ SİBER RADAR VE MESAJ EKRANI
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening ? Colors.redAccent.withOpacity(0.1) : _matGrey,
                    border: Border.all(color: _isListening ? Colors.redAccent : Colors.white12, width: 2),
                    boxShadow: [
                      if (_isListening) BoxShadow(color: Colors.redAccent.withOpacity(0.3), blurRadius: 40, spreadRadius: 10)
                    ]
                ),
                child: Icon(
                    Icons.engineering_outlined,
                    size: 80,
                    color: _isListening ? Colors.redAccent : Colors.white24
                ),
              ),
              const SizedBox(height: 20),
              Text(
                  _ekranMesaji,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: _isListening ? Colors.white : Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.5
                  )
              ),

              const Spacer(),

              // 🚀 KOMUTA DÜĞMELERİ
              if (_islemSuruyor)
                const Column(
                  children: [
                    CircularProgressIndicator(color: _kuantumCyan),
                    SizedBox(height: 16),
                    Text("KARARGAHA MÜHÜRLENİYOR...", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _raporuOku,
                        icon: const Icon(Icons.volume_up_outlined, size: 18, color: Colors.white),
                        label: const Text("DİNLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isListening ? () {
                          _speech.stop();
                          setState(() => _isListening = false);
                        } : _ustayiDinle,
                        icon: Icon(_isListening ? Icons.stop : Icons.settings_voice, color: Colors.black, size: 20),
                        label: Text(_isListening ? "DURDUR" : "KOMUT VER / ONAYLA", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: _isListening ? Colors.redAccent : _kuantumCyan,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 10,
                          shadowColor: (_isListening ? Colors.redAccent : _kuantumCyan).withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}