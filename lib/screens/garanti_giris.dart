import 'package:otodna/core/siber_tema.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA (7D Zırh v2.0)
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class GarantiBelirlemeEkrani extends StatefulWidget {
  // GERÇEK SİSTEM: Bu ekrana gelirken hangi araca ve hangi işleme mühür basılacağı bilinmelidir!
  final String aracId;
  final String islemId;
  final String bayiId;

  GarantiBelirlemeEkrani({
    super.key,
    required this.aracId,
    required this.islemId,
    required this.bayiId,
  });

  @override
  State<GarantiBelirlemeEkrani> createState() => _GarantiBelirlemeEkraniState();
}

class _GarantiBelirlemeEkraniState extends State<GarantiBelirlemeEkrani> {
  final TextEditingController _garantiController = TextEditingController();
  bool _isSaving = false;
  String _aiOnerisi = "Analiz ediliyor...";

  static Color _aiOrange = Color(0xFFFF9100); // AI Analiz Turuncusu (Kehribar/Güvenlik Rengi)

  @override
  void initState() {
    super.initState();
    _telemetriVeAiAnaliziCek();
  }

  @override
  void dispose() {
    _garantiController.dispose();
    super.dispose();
  }

  // --- 📡 FİREBASE: SİBER TELEMETRİ VE AI ANALİZİ ---
  Future<void> _telemetriVeAiAnaliziCek() async {
    try {
      DocumentSnapshot aiRaporu = await FirebaseFirestore.instance.collection('arac_raporlari').doc(widget.aracId).get();

      if (aiRaporu.exists && aiRaporu.data() != null) {
        var data = aiRaporu.data() as Map<String, dynamic>;
        setState(() {
          _aiOnerisi = data['ai_garanti_onerisi'] ?? "12 Ay / 20.000 KM";
          _garantiController.text = _aiOnerisi;
        });
      } else {
        setState(() {
          _aiOnerisi = "12 Ay / 20.000 KM";
          _garantiController.text = _aiOnerisi;
        });
      }
    } catch (e) {
      setState(() {
        _aiOnerisi = "Bağlantı Hatası: Standart 12 Ay / 20.000 KM";
        _garantiController.text = "12 Ay / 20.000 KM";
      });
    }
  }

  // --- 🔴 FİREBASE: GARANTİ MÜHÜRLEME MOTORU (ATOMİK İŞLEM) ---
  Future<void> _garantiyiKuantumAgaMuhurle() async {
    if (_garantiController.text.trim().isEmpty) {
      _siberUyariVer("SİBER İHLAL: Garanti süresi boş bırakılamaz!", true);
      return;
    }

    setState(() => _isSaving = true);
    FocusScope.of(context).unfocus();

    try {
      final db = FirebaseFirestore.instance;
      WriteBatch batch = db.batch();

      String onaylananSure = _garantiController.text.trim();

      // 1. İşlem Kaydını Güncelle
      DocumentReference islemRef = db.collection('yapilan_islemler').doc(widget.islemId);
      batch.update(islemRef, {
        'garanti_suresi': onaylananSure,
        'garanti_baslangic': FieldValue.serverTimestamp(),
        'durum': 'TAMAMLANDI VE MÜHÜRLENDİ',
      });

      // 2. Aracın Genel Garanti Sertifikasını Güncelle
      DocumentReference aracRef = db.collection('arac_sertifikalari').doc(widget.aracId);
      batch.set(aracRef, {
        'aktif_garanti': onaylananSure,
        'son_islem_tarihi': FieldValue.serverTimestamp(),
        'son_islem_bayi': widget.bayiId,
      }, SetOptions(merge: true));

      // 3. Admin Kara Kutu Loglarına İşle
      DocumentReference logRef = db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'basarili',
        'islem_detayi': 'GARANTİ MÜHRÜ: ${widget.aracId} plakalı araca $onaylananSure garanti tanımlandı.',
        'bayi_isim': widget.bayiId,
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (!mounted) return;
      _siberUyariVer("MÜHÜR BASILDI: Dijital Sertifika Müşteriye İletildi! 🦅", false);
      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      _siberUyariVer("SİBER AĞ HATASI: Veritabanına yazılamadı! $e", true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _siberUyariVer(String mesaj, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
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
          title: Text("DİJİTAL GARANTİ MÜHÜRLEME", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Container(color: SiberTema.kuantumCyan.withOpacity(0.3), height: 1),
          ),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. İŞLEM TAMAMLANDI BİLGİSİ (7D Glow Efekti)
              Row(
                children: [
                  _build7DNeonIkon(Icons.verified_user, SiberTema.kuantumCyan),
                  SizedBox(width: 16),
                  Text("SİSTEM ONAYI: İşlem Tamamlandı", style: TextStyle(color: SiberTema.textMain, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                ],
              ),
              SizedBox(height: 24),

              // 2. AI TELEMETRİ ANALİZ NOTU (7D Donanımsal Ekran)
              _build7DAiTelemetriPaneli(),

              SizedBox(height: 40),

              // 3. MÜHÜRLENECEK SÜRE GİRİŞİ (7D İç Gölgeli Ekran)
              Text("GARANTİ SÜRESİNİ ONAYLAYIN (VEYA DÜZENLEYİN)", style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 10, fontFamily: 'Avenir')),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                    color: SiberTema.oledBlack, // Derin Siyah Ekran Hissi
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 1.5),
                    // SİBER DÜZELTME: inset: true kaldırıldı, hata yok edildi!
                    boxShadow: [
                      BoxShadow(color: Colors.white.withOpacity(0.9), blurRadius: 10),
                      BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.1), blurRadius: 15, spreadRadius: 2), // Dış Neon Kalkanı
                    ]
                ),
                child: TextField(
                  controller: _garantiController,
                  style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'),
                  decoration: InputDecoration(
                    hintText: "Örn: 12 Ay / 20.000 KM",
                    hintStyle: TextStyle(color: SiberTema.textMain.withOpacity(0.2), fontSize: 16, fontFamily: 'Avenir'),
                    prefixIcon: Icon(Icons.shield, color: SiberTema.kuantumCyan, size: 28),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  ),
                ),
              ),

              SizedBox(height: 50),

              // 4. MÜHÜRLEME BUTONU (7D Merkezi Neon Buton)
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton.icon(
                  style: SiberTema.kuantumButonStili(),
                  onPressed: _isSaving ? null : _garantiyiKuantumAgaMuhurle,
                  icon: _isSaving
                      ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 3))
                      : Icon(Icons.fingerprint, size: 28, color: SiberTema.oledBlack),
                  label: Text(
                      _isSaving ? "AĞA YAZILIYOR..." : "GARANTİYİ MÜHÜRLE VE TESLİM ET",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, fontFamily: 'Avenir', color: SiberTema.oledBlack)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 🎨 7D SİBER GÖRSEL YARDIMCILAR ---

  // 🎇 7D LED İkon Parlaması
  Widget _build7DNeonIkon(IconData icon, Color renk) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        shape: BoxShape.circle,
        border: Border.all(color: renk.withOpacity(0.4), width: 1.5),
        boxShadow: [BoxShadow(color: renk.withOpacity(0.25), blurRadius: 15, spreadRadius: 2)], // Dış Glow
      ),
      child: Icon(icon, color: renk, size: 24, shadows: [Shadow(color: renk, blurRadius: 12)]), // İç Işık
    );
  }

  // 📺 7D AI TELEMETRİ EKRANI (Donanımsal Titanyum Kasa)
  Widget _build7DAiTelemetriPaneli() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Fırçalanmış Metal / Karbon Kasa Hissi
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A2D34), Color(0xFF141518), Color(0xFF0A0A0C)],
            stops: [0.0, 0.4, 1.0],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 15, offset: Offset(0, 8)), // Kasa Derinliği
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _build7DNeonIkon(Icons.memory, _aiOrange), // AI Çekirdeği
              SizedBox(width: 12),
              Text("KUANTUM A.I. TELEMETRİ ANALİZİ", style: TextStyle(color: _aiOrange, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 11, fontFamily: 'Avenir')),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "Araç kullanıcısının geçmiş arazi şartları (Asfalt/Zorlu Arazi) ve kullanım alışkanlıkları incelenmiştir. Sistem, riski minimize etmek için aşağıdaki süreyi önermektedir.",
            style: TextStyle(color: SiberTema.textMain.withOpacity(0.8), fontSize: 12, height: 1.5, fontFamily: 'Avenir'),
          ),
          SizedBox(height: 20),

          // 📟 AI Sonuç Ekranı
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
                color: Color(0xFF1A0A00), // Koyu Turuncu-Siyah CRT Ekran
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _aiOrange.withOpacity(0.4), width: 1.5),
                // SİBER DÜZELTME: inset: true kaldırıldı!
                boxShadow: [
                  BoxShadow(color: Colors.white.withOpacity(0.9), blurRadius: 8),
                  BoxShadow(color: _aiOrange.withOpacity(0.1), blurRadius: 10, spreadRadius: 1) // Hafif Parlama
                ]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Önerilen Güvenli Süre:", style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontFamily: 'Avenir', fontWeight: FontWeight.bold)),
                Text(_aiOnerisi, style: TextStyle(color: _aiOrange, fontWeight: FontWeight.w900, fontSize: 15, fontFamily: 'Avenir', shadows: [Shadow(color: _aiOrange, blurRadius: 8)])),
              ],
            ),
          )
        ],
      ),
    );
  }
}