import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // 🌑 TESLA MİMARİSİ: %100 OLED Siyah
  static const _darkSpace = Color(0xFF000000);
  static const _cyan = Color(0xFF00FFC2); // Kuantum Turkuazı
  static const _aiOrange = Color(0xFFFF9100); // AI Analiz Turuncusu

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
          _aiOnerisi = data['ai_garanti_onerisi'] ?? "12 Ay / 20.000 KM"; // Veri yoksa standart öneri
          _garantiController.text = _aiOnerisi;
        });
      } else {
        setState(() {
          _aiOnerisi = "12 Ay / 20.000 KM"; // Veritabanı boşsa standart öneri
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
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: isError ? Colors.redAccent : _cyan.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkSpace,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: _cyan), onPressed: () => Navigator.pop(context)),
        title: const Text("DİJİTAL GARANTİ MÜHÜRLEME", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 15)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _cyan.withOpacity(0.3), height: 1),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/radar_grid.png'), // Arka plan radar ızgarası
            fit: BoxFit.cover,
            opacity: 0.05,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. İŞLEM TAMAMLANDI BİLGİSİ
              Row(
                children: [
                  _buildNeonIkon(Icons.verified_user, _cyan),
                  const SizedBox(width: 16),
                  const Text("SİSTEM ONAYI: İşlem Tamamlandı", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ],
              ),
              const SizedBox(height: 24),

              // 2. AI TELEMETRİ ANALİZ NOTU (Cam Efektli)
              _buildCamEfektliKutu(
                borderColor: _aiOrange.withOpacity(0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.memory, color: _aiOrange, size: 20),
                        SizedBox(width: 8),
                        Text("KUANTUM A.I. TELEMETRİ ANALİZİ", style: TextStyle(color: _aiOrange, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Araç kullanıcısının geçmiş arazi şartları (Asfalt/Zorlu Arazi) ve kullanım alışkanlıkları incelenmiştir. Sistem, riski minimize etmek için aşağıdaki süreyi önermektedir.",
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: _aiOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: _aiOrange.withOpacity(0.3))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Önerilen Güvenli Süre:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text(_aiOnerisi, style: const TextStyle(color: _aiOrange, fontWeight: FontWeight.w900, fontSize: 14)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 3. MÜHÜRLENECEK SÜRE GİRİŞİ
              const Text("GARANTİ SÜRESİNİ ONAYLAYIN (VEYA DÜZENLEYİN)", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 11)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _cyan.withOpacity(0.5)),
                  boxShadow: [BoxShadow(color: _cyan.withOpacity(0.1), blurRadius: 15)],
                ),
                child: TextField(
                  controller: _garantiController,
                  style: const TextStyle(color: _cyan, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
                  decoration: InputDecoration(
                    hintText: "Örn: 12 Ay / 20.000 KM",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                    prefixIcon: const Icon(Icons.shield, color: _cyan),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // 4. MÜHÜRLEME BUTONU
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _cyan,
                    foregroundColor: _darkSpace, // Siyah yazı
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 15,
                    shadowColor: _cyan.withOpacity(0.6),
                  ),
                  onPressed: _isSaving ? null : _garantiyiKuantumAgaMuhurle,
                  icon: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: _darkSpace, strokeWidth: 3))
                      : const Icon(Icons.verified, size: 28),
                  label: Text(
                      _isSaving ? "AĞA YAZILIYOR..." : "GARANTİYİ MÜHÜRLE VE TESLİM ET",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)
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
  Widget _buildCamEfektliKutu({required Widget child, required Color borderColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [BoxShadow(color: borderColor.withOpacity(0.05), blurRadius: 20)],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildNeonIkon(IconData icon, Color renk) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: renk.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: renk.withOpacity(0.4)),
        boxShadow: [BoxShadow(color: renk.withOpacity(0.2), blurRadius: 10)],
      ),
      child: Icon(icon, color: renk, size: 24),
    );
  }
}