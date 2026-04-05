import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA (Zırh v2.0)
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class GarantiBelirlemeEkrani extends StatefulWidget {
  // GERÇEK SİSTEM: Bu ekrana gelirken hangi araca ve hangi işleme mühür basılacağı bilinmelidir!
  final String aracId;
  final String islemId;
  final String bayiId;

  const GarantiBelirlemeEkrani({
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

  static const Color _aiOrange = Color(0xFFFF9100); // AI Analiz Turuncusu

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
      // Araç Kara Kutusundan gelen son veriyi (Sistem kararını) çeker
      DocumentSnapshot aiRaporu = await FirebaseFirestore.instance.collection('arac_raporlari').doc(widget.aracId).get();

      if (aiRaporu.exists && aiRaporu.data() != null) {
        var data = aiRaporu.data() as Map<String, dynamic>;
        // Örn: Araç çok fazla araziye girmişse AI süreyi kısaltır
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
      WriteBatch batch = db.batch(); // Kopmaz Kuantum Bağı (Aynı anda yazılır)

      String onaylananSure = _garantiController.text.trim();

      // 1. İşlem Kaydını Güncelle (Müşteri bunu anında uygulamasında görür)
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

      // 3. Admin (Senin) Kara Kutu Loglarına İşle
      DocumentReference logRef = db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'basarili',
        'islem_detayi': 'GARANTİ MÜHRÜ: ${widget.aracId} plakalı araca $onaylananSure garanti tanımlandı.',
        'bayi_isim': widget.bayiId,
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Füzeyi ateşle!

      if (!mounted) return;
      _siberUyariVer("MÜHÜR BASILDI: Dijital Sertifika Müşteriye İletildi! 🦅", false);
      Navigator.pop(context); // İşlem bitince bayi ana ekranına döner

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
        content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: SiberTema.siberFont)),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Arka plan ResponsiveKalkan'dan gelir
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: const Text("DİJİTAL GARANTİ MÜHÜRLEME", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: SiberTema.siberFont)),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: SiberTema.kuantumCyan.withOpacity(0.3), height: 1),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. İŞLEM TAMAMLANDI BİLGİSİ
              Row(
                children: [
                  _buildNeonIkon(Icons.verified_user, SiberTema.kuantumCyan),
                  const SizedBox(width: 16),
                  const Text("SİSTEM ONAYI: İşlem Tamamlandı", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: SiberTema.siberFont)),
                ],
              ),
              const SizedBox(height: 24),

              // 2. AI TELEMETRİ ANALİZ NOTU (Cam Efektli & 3D)
              SiberTema.siberCamKalkan(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.memory, color: _aiOrange, size: 24, shadows: [Shadow(color: _aiOrange, blurRadius: 10)]),
                        const SizedBox(width: 10),
                        Text("KUANTUM A.I. TELEMETRİ ANALİZİ", style: TextStyle(color: _aiOrange, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 11, fontFamily: SiberTema.siberFont)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Araç kullanıcısının geçmiş arazi şartları (Asfalt/Zorlu Arazi) ve kullanım alışkanlıkları incelenmiştir. Sistem, riski minimize etmek için aşağıdaki süreyi önermektedir.",
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, height: 1.5, fontFamily: SiberTema.siberFont),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                          color: _aiOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _aiOrange.withOpacity(0.3)),
                          boxShadow: [BoxShadow(color: _aiOrange.withOpacity(0.05), blurRadius: 10)] // 3D Turuncu Parlama
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Önerilen Güvenli Süre:", style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: SiberTema.siberFont, fontWeight: FontWeight.bold)),
                          Text(_aiOnerisi, style: const TextStyle(color: _aiOrange, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: SiberTema.siberFont)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 3. MÜHÜRLENECEK SÜRE GİRİŞİ (3D Derinlikli)
              const Text("GARANTİ SÜRESİNİ ONAYLAYIN (VEYA DÜZENLEYİN)", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 10, fontFamily: SiberTema.siberFont)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: SiberTema.matGrey, // Derin yüzey
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 1.5),
                  boxShadow: SiberTema.siberGolgeDerin, // 🔥 3D GÖLGE EKLENDİ
                ),
                child: TextField(
                  controller: _garantiController,
                  style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: SiberTema.siberFont),
                  decoration: InputDecoration(
                    hintText: "Örn: 12 Ay / 20.000 KM",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 16, fontFamily: SiberTema.siberFont),
                    prefixIcon: const Icon(Icons.shield, color: SiberTema.kuantumCyan, size: 28),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // 4. MÜHÜRLEME BUTONU (3D Neon Buton)
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton.icon(
                  style: SiberTema.kuantumButonStili(), // Merkezi 3D buton tasarımı
                  onPressed: _isSaving ? null : _garantiyiKuantumAgaMuhurle,
                  icon: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 3))
                      : const Icon(Icons.verified, size: 28, color: SiberTema.oledBlack),
                  label: Text(
                      _isSaving ? "AĞA YAZILIYOR..." : "GARANTİYİ MÜHÜRLE VE TESLİM ET",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, fontFamily: SiberTema.siberFont, color: SiberTema.oledBlack)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 🎨 SİBER GÖRSEL YARDIMCILAR ---
  Widget _buildNeonIkon(IconData icon, Color renk) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: renk.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: renk.withOpacity(0.4)),
        boxShadow: [BoxShadow(color: renk.withOpacity(0.2), blurRadius: 15, spreadRadius: 2)], // 🔥 Neon Parlama
      ),
      child: Icon(icon, color: renk, size: 24, shadows: [Shadow(color: renk, blurRadius: 10)]), // İkonun kendisi de parlar
    );
  }
}