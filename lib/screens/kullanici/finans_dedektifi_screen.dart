// lib/screens/kullanici/finans_dedektifi_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE TEMA
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM FİNANS DEDEKTİFİ
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

  // ── 🚀 GİDER MÜHÜRLEME MOTORU (ATOMİK ZIRHLI) ──
  Future<void> _gideriKarargahaYaz() async {
    double tutar = double.tryParse(_tutarCtrl.text.trim()) ?? 0.0;
    int km = int.tryParse(_kmCtrl.text.trim()) ?? 0;
    String aciklama = _aciklamaCtrl.text.trim();

    if (tutar <= 0 || km <= 0) {
      HapticFeedback.heavyImpact();
      _siberUyari("SİBER İHLAL", "Geçerli bir Tutar ve Kilometre girilmelidir!", SiberTema.kanKirmizi);
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
        'aciklama': aciklama.isNotEmpty ? aciklama : 'Otonom Kayıt',
        'tarih': FieldValue.serverTimestamp(),
      });

      // 2. Sistem Loglarına Kaydet (Kara Kutu)
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'FİNANS_GİDER_KAYDI',
        'islem_detayi': '${widget.plaka} aracı için ₺$tutar ($_secilenKategori) gideri mühürlendi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      // Füzeleri ateşle!
      await batch.commit();

      _tutarCtrl.clear();
      _kmCtrl.clear();
      _aciklamaCtrl.clear();

      if (mounted) {
        _siberUyari("SİBER ONAY", "Gider başarıyla Karargaha mühürlendi.", SiberTema.kuantumCyan);
        Navigator.pop(context); // Paneli kapat
      }
    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: Gider kaydedilemedi!", error: e);
      _siberUyari("BAĞLANTI HATASI", "Karargah ile iletişim koptu.", SiberTema.kanKirmizi);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ── 🚨 UYARI SİSTEMİ ──
  void _siberUyari(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: SiberTema.matGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), border: BorderSide(color: renk, width: 2)),
      behavior: SnackBarBehavior.floating,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
          Text(mesaj, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
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
            color: SiberTema.oledBlack,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("YENİ GİDER MÜHÜRLE", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
              const SizedBox(height: 20),

              // Kategori Seçici
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("YAKIT", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      value: 'YAKIT',
                      groupValue: _secilenKategori,
                      activeColor: SiberTema.kuantumCyan,
                      onChanged: (val) => setState(() => _secilenKategori = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("SERVİS/PARÇA", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      value: 'SERVIS',
                      groupValue: _secilenKategori,
                      activeColor: SiberTema.kuantumCyan,
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
                    ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                    : ElevatedButton.icon(
                  style: SiberTema.kuantumButonStili(),
                  onPressed: _gideriKarargahaYaz,
                  icon: const Icon(Icons.save_alt, color: SiberTema.oledBlack),
                  label: const Text("KARARGAHA MÜHÜRLE", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
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
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
      decoration: InputDecoration(
        filled: true,
        fillColor: SiberTema.matGrey.withOpacity(0.5),
        prefixIcon: Icon(ikon, color: SiberTema.kuantumCyan, size: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.kuantumCyan, width: 1.5)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("FİNANS DEDEKTİFİ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: SiberTema.kuantumCyan,
          onPressed: _giderEklePaneliniAc,
          icon: const Icon(Icons.add, color: SiberTema.oledBlack),
          label: const Text("GİDER EKLE", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
        ),
        body: StreamBuilder<QuerySnapshot>(
          // 📡 ARACA AİT GİDERLERİ CANLI ÇEK
          stream: _db.collection('arac_giderleri')
              .where('arac_id', isEqualTo: widget.aracId)
              .orderBy('tarih', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("SİBER RADAR TEMİZ\nHenüz gider mühürlenmedi.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, letterSpacing: 2)));
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
                      color: SiberTema.matGrey.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2),
                      boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.1), blurRadius: 30)],
                    ),
                    child: Column(
                      children: [
                        const Text("KM BAŞINA ORTALAMA MALİYET", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        const SizedBox(height: 10),
                        Text("₺${kmBasinaMaliyet.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 40, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMiniRadar("YAKIT", "₺${toplamYakit.toStringAsFixed(0)}", Colors.orangeAccent),
                            _buildMiniRadar("SERVİS", "₺${toplamServis.toStringAsFixed(0)}", SiberTema.kanKirmizi),
                            _buildMiniRadar("MESAFE", "$yapilanKm KM", Colors.white),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Align(alignment: Alignment.centerLeft, child: Text("SON MÜHÜRLENEN GİDERLER", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2))),
                  const SizedBox(height: 10),

                  // 📜 GİDER LİSTESİ
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var gider = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        bool isYakit = gider['kategori'] == 'YAKIT';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Row(
                            children: [
                              Icon(isYakit ? Icons.local_gas_station : Icons.build_circle, color: isYakit ? Colors.orangeAccent : SiberTema.kanKirmizi, size: 28),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(gider['aciklama'], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text("${gider['km']} KM", style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'Avenir')),
                                  ],
                                ),
                              ),
                              Text("₺${gider['tutar']}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 15, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
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
        Text(baslik, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }
}