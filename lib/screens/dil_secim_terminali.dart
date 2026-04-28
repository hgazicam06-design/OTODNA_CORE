import 'package:otodna/core/siber_tema.dart';
// lib/screens/dil_secim_terminali.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class DilSecimTerminali extends StatefulWidget {
  DilSecimTerminali({super.key});

  @override
  State<DilSecimTerminali> createState() => _DilSecimTerminaliState();
}

class _DilSecimTerminaliState extends State<DilSecimTerminali> {
  bool _isProcessing = false;
  String _seciliDilKodu = "tr"; // Varsayılan: Karargah Merkezi

  // 🌍 DÜNYANIN EN GÜÇLÜ 10 DİLİ (Kuantum Matrisi)
  final List<Map<String, String>> _siberDiller = [
    {"kod": "tr", "isim": "TÜRKÇE", "alt_isim": "KARARGAH MERKEZİ", "bayrak": "🇹🇷"},
    {"kod": "en", "isim": "ENGLISH", "alt_isim": "GLOBAL PROTOCOL", "bayrak": "🇬🇧"},
    {"kod": "es", "isim": "ESPAÑOL", "alt_isim": "İSPANYOLCA", "bayrak": "🇪🇸"},
    {"kod": "fr", "isim": "FRANÇAIS", "alt_isim": "FRANSIZCA", "bayrak": "🇫🇷"},
    {"kod": "de", "isim": "DEUTSCH", "alt_isim": "ALMANCA", "bayrak": "🇩🇪"},
    {"kod": "ru", "isim": "РУССКИЙ", "alt_isim": "RUSÇA", "bayrak": "🇷🇺"},
    {"kod": "zh", "isim": "中文", "alt_isim": "ÇİNCE (MANDARİN)", "bayrak": "🇨🇳"},
    {"kod": "ja", "isim": "日本語", "alt_isim": "JAPONCA", "bayrak": "🇯🇵"},
    {"kod": "ar", "isim": "العربية", "alt_isim": "ARAPÇA", "bayrak": "🇸🇦"},
    {"kod": "pt", "isim": "PORTUGUÊS", "alt_isim": "PORTEKİZCE", "bayrak": "🇵🇹"},
  ];

  // --- 🔴 FİREBASE: DİL TERCİHİ MÜHÜRLEME MOTORU ---
  Future<void> _dilTercihiniMuhurle() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _siberUyariVer("SİBER İHLAL: Kimlik doğrulanamadı!", true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final db = FirebaseFirestore.instance;
      WriteBatch batch = db.batch();

      // 1. Kullanıcı Siciline Dili İşle
      DocumentReference userRef = db.collection('kullanicilar').doc(user.uid);
      batch.set(userRef, {
        'dil_tercihi': _seciliDilKodu,
        'son_guncelleme': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Kara Kutu Logu (İstihbarat)
      DocumentReference logRef = db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'dil_degisikligi',
        'islem_detayi': 'Kullanıcı (${user.uid}) sistem dilini [$_seciliDilKodu] olarak mühürledi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Füzeyi ateşle!

      if (!mounted) return;
      _siberUyariVer("SİSTEM DİLİ GÜNCELLENDİ!", false);

      // İşlem bitince ekranı kapat
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });

    } catch (e) {
      if (!mounted) return;
      _siberUyariVer("AĞ HATASI: Dil mühürlenemedi! $e", true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _siberUyariVer(String mesaj, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir', fontSize: 11)),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: Text("KÜRESEL DİL TERMİNALİ", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // 🛡️ BİLGİ BANDI
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1)),
                color: SiberTema.oledBlack,
              ),
              child: Row(
                children: [
                  Icon(Icons.language, color: SiberTema.kuantumCyan, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text("SİBER AĞ, SEÇTİĞİNİZ DİL BÖLGESİNE GÖRE OTONOM OLARAK YAPILANDIRILACAKTIR.", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))),
                ],
              ),
            ),

            // 🌍 LİSTE
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(16),
                itemCount: _siberDiller.length,
                itemBuilder: (context, index) {
                  final dil = _siberDiller[index];
                  final isSelected = _seciliDilKodu == dil['kod'];

                  return GestureDetector(
                    onTap: () => setState(() => _seciliDilKodu = dil['kod']!),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? SiberTema.kuantumCyan.withOpacity(0.1) : SiberTema.matGrey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? SiberTema.kuantumCyan : Colors.white10, width: isSelected ? 2 : 1),
                        boxShadow: isSelected ? [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.2), blurRadius: 15, spreadRadius: 1)] : [],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Row(
                              children: [
                                Text(dil['bayrak']!, style: TextStyle(fontSize: 24)),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(dil['isim']!, style: TextStyle(color: isSelected ? SiberTema.kuantumCyan : Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                                      SizedBox(height: 4),
                                      Text(dil['alt_isim']!, style: TextStyle(color: SiberTema.textMain.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle, color: SiberTema.kuantumCyan, size: 24)
                                else
                                  Icon(Icons.circle_outlined, color: Colors.white.withOpacity(0.2), size: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🚀 MÜHÜRLE BUTONU
            Container(
              padding: EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SiberTema.kuantumCyan,
                    foregroundColor: SiberTema.oledBlack,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 10,
                    shadowColor: SiberTema.kuantumCyan.withOpacity(0.5),
                  ),
                  onPressed: _isProcessing ? null : _dilTercihiniMuhurle,
                  icon: _isProcessing
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 2))
                      : Icon(Icons.fingerprint, size: 20),
                  label: Text(
                      _isProcessing ? "MÜHÜRLENİYOR..." : "DİL TERCİHİNİ MÜHÜRLE",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, fontFamily: 'Avenir')
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}