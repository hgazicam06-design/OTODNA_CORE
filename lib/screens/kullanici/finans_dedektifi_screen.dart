// lib/screens/kullanici/finans_dedektifi_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE TEMA
import '../../core/responsive_kalkan.dart';

/// 🛡️ PLAZA FİNANS DEDEKTİFİ
/// Araçların yakıt ve parça/servis giderlerini takip edip "KM Başına Maliyet" radarı sunar.
class FinansDedektifiScreen extends StatefulWidget {
  final String aracId;
  final String plaka;

  const FinansDedektifiScreen({super.key, required this.aracId, required this.plaka});

  @override
  State<FinansDedektifiScreen> createState() => _FinansDedektifiScreenState();
}

class _FinansDedektifiScreenState extends State<FinansDedektifiScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController _tutarCtrl = TextEditingController();
  final TextEditingController _kmCtrl = TextEditingController();
  final TextEditingController _aciklamaCtrl = TextEditingController();

  String _secilenKategori = 'YAKIT'; // YAKIT veya SERVİS
  bool _isProcessing = false;

  // 🏢 PLAZA KALİTESİ PALET
  final Color primaryTeal = Colors.teal.shade700;
  final Color bgColor = const Color(0xFFFAFAFC);
  final Color textColor = const Color(0xFF1E293B);
  final Color dangerColor = Colors.redAccent;
  final Color warningColor = Colors.orange;

  // ── 🚀 GİDER MÜHÜRLEME MOTORU (ATOMİK ZIRHLI) ──
  Future<void> _gideriKarargahaYaz() async {
    double tutar = double.tryParse(_tutarCtrl.text.trim()) ?? 0.0;
    int km = int.tryParse(_kmCtrl.text.trim()) ?? 0;
    String aciklama = _aciklamaCtrl.text.trim();

    if (tutar <= 0 || km <= 0) {
      HapticFeedback.heavyImpact();
      _siberUyari("SİSTEM İHLALİ", "Geçerli bir Tutar ve Kilometre girilmelidir!", dangerColor);
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.lightImpact();

    try {
      WriteBatch batch = _db.batch();

      // 1. Gideri Aracın Gider Havuzuna Ekle
      DocumentReference giderRef = _db.collection('arac_giderleri').doc();
      batch.set(giderRef, {
        'arac_id': widget.aracId,
        'kategori': _secilenKategori,
        'tutar': tutar,
        'km': km,
        'aciklama': aciklama.isNotEmpty ? aciklama : 'Otomatik Kayıt',
        'tarih': FieldValue.serverTimestamp(),
      });

      // 2. Sistem Loglarına Kaydet
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'FİNANS_GİDER_KAYDI',
        'islem_detayi': '${widget.plaka} aracı için ₺$tutar ($_secilenKategori) gideri eklendi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      _tutarCtrl.clear();
      _kmCtrl.clear();
      _aciklamaCtrl.clear();

      if (mounted) {
        _siberUyari("ONAY", "Gider başarıyla sisteme mühürlendi.", primaryTeal);
        Navigator.pop(context); // Paneli kapat
      }
    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: Gider kaydedilemedi!", error: e);
      _siberUyari("BAĞLANTI HATASI", "Sunucu ile iletişim koptu.", dangerColor);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ── 🚨 UYARI SİSTEMİ ──
  void _siberUyari(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: renk, width: 2)),
      behavior: SnackBarBehavior.floating,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
          Text(mesaj, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        ],
      ),
    ));
  }

  // ── 📝 GİDER EKLEME PANELİ (BOTTOM SHEET) ──
  void _giderEklePaneliniAc() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: primaryTeal.withValues(alpha: 0.5), width: 2)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 24),
              Text("YENİ GİDER EKLE", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
              const SizedBox(height: 20),

              // Kategori Seçici
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text("YAKIT", style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                      value: 'YAKIT',
                      groupValue: _secilenKategori,
                      activeColor: primaryTeal,
                      onChanged: (val) => setState(() => _secilenKategori = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text("SERVİS/PARÇA", style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                      value: 'SERVIS',
                      groupValue: _secilenKategori,
                      activeColor: primaryTeal,
                      onChanged: (val) => setState(() => _secilenKategori = val!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              _buildGirdiAlani(controller: _tutarCtrl, hint: "Tutar (₺)", ikon: Icons.attach_money, isNumber: true),
              const SizedBox(height: 10),
              _buildGirdiAlani(controller: _kmCtrl, hint: "Güncel Kilometre (KM)", ikon: Icons.speed, isNumber: true),
              const SizedBox(height: 10),
              _buildGirdiAlani(controller: _aciklamaCtrl, hint: "Açıklama (Örn: Shell 50L veya Balata)", ikon: Icons.description),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: _isProcessing
                    ? Center(child: CircularProgressIndicator(color: primaryTeal))
                    : ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _gideriKarargahaYaz,
                  icon: const Icon(Icons.save_alt),
                  label: const Text("SİSTEME MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGirdiAlani({required TextEditingController controller, required String hint, required IconData ikon, bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
      decoration: InputDecoration(
        filled: true,
        fillColor: bgColor,
        prefixIcon: Icon(ikon, color: primaryTeal, size: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 12, fontFamily: 'Avenir'),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryTeal, width: 1.5)),
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
          title: Text("FİNANS DEDEKTİFİ", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 18), onPressed: () => Navigator.pop(context)),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.white,
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: primaryTeal.withValues(alpha: 0.5))),
          onPressed: _giderEklePaneliniAc,
          icon: Icon(Icons.add, color: primaryTeal),
          label: Text("GİDER EKLE", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
        ),
        body: StreamBuilder<QuerySnapshot>(
          // 📡 ARACA AİT GİDERLERİ CANLI ÇEK
          stream: _db.collection('arac_giderleri')
              .where('arac_id', isEqualTo: widget.aracId)
              .orderBy('tarih', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryTeal));

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("FİNANS VERİSİ YOK\nHenüz gider mühürlenmedi.", textAlign: TextAlign.center, style: TextStyle(color: Colors.black38, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')));
            }

            // 🧠 SİBER ANALİZ: Maliyetleri Hesapla
            double toplamYakit = 0;
            double toplamServis = 0;
            int minKm = 9999999;
            int maxKm = 0;

            for (var doc in snapshot.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;
              double tutar = (data['tutar'] ?? 0).toDouble();
              int km = data['km'] ?? 0;

              if (data['kategori'] == 'YAKIT') toplamYakit += tutar;
              if (data['kategori'] == 'SERVIS') toplamServis += tutar;

              if (km < minKm) minKm = km;
              if (km > maxKm) maxKm = km;
            }

            int yapilanKm = (maxKm - minKm) > 0 ? (maxKm - minKm) : 1; // Sıfıra bölme hatasını engelle
            double kmBasinaMaliyet = (toplamYakit + toplamServis) / yapilanKm;

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // 📊 SİBER RADAR KARTI (KM BAŞINA MALİYET)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryTeal.withValues(alpha: 0.3), width: 1.5),
                      boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      children: [
                        const Text("KM BAŞINA ORTALAMA MALİYET", style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                        const SizedBox(height: 10),
                        Text("₺${kmBasinaMaliyet.toStringAsFixed(2)}", style: TextStyle(color: primaryTeal, fontSize: 40, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMiniRadar("YAKIT", "₺${toplamYakit.toStringAsFixed(0)}", warningColor),
                            _buildMiniRadar("SERVİS", "₺${toplamServis.toStringAsFixed(0)}", dangerColor),
                            _buildMiniRadar("MESAFE", "$yapilanKm KM", textColor),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Align(alignment: Alignment.centerLeft, child: Text("SON MÜHÜRLENEN GİDERLER", style: TextStyle(color: Colors.black54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir'))),
                  const SizedBox(height: 10),

                  // 📜 GİDER LİSTESİ
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var gider = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        bool isYakit = gider['kategori'] == 'YAKIT';
                        Color kRenk = isYakit ? warningColor : dangerColor;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]
                          ),
                          child: Row(
                            children: [
                              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: kRenk.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(isYakit ? Icons.local_gas_station : Icons.build_circle, color: kRenk, size: 24)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(gider['aciklama'], style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                                    const SizedBox(height: 4),
                                    Text("${gider['km']} KM", style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                                  ],
                                ),
                              ),
                              Text("₺${gider['tutar']}", style: TextStyle(color: primaryTeal, fontSize: 15, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMiniRadar(String baslik, String deger, Color renk) {
    return Column(
      children: [
        Text(deger, style: TextStyle(color: renk, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
        const SizedBox(height: 4),
        Text(baslik, style: const TextStyle(color: Colors.black38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
      ],
    );
  }
}