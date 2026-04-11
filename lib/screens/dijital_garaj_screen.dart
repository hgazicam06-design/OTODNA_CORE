import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI VE ROTALAR
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class DijitalGarajScreen extends StatefulWidget {
  final String aracId;
  final String plaka;

  const DijitalGarajScreen({
    super.key,
    required this.aracId,
    required this.plaka,
  });

  @override
  State<DijitalGarajScreen> createState() => _DijitalGarajScreenState();
}

class _DijitalGarajScreenState extends State<DijitalGarajScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isSaving = false;

  final TextEditingController _bakimTutarCtrl = TextEditingController();
  final TextEditingController _bakimNotuCtrl = TextEditingController();

  // --- ⚡ ATOMİK BAKIM MÜHÜRLEME (WriteBatch) ---
  Future<void> _bakimMesaiseEkle() async {
    if (_bakimTutarCtrl.text.isEmpty || _bakimNotuCtrl.text.isEmpty) {
      _siberUyariVer("SİBER İHLAL: Tutar ve Bakım Notu boş bırakılamaz!", isError: true);
      return;
    }

    setState(() => _isSaving = true);

    // 🔥 ATOMİK İŞLEM BAŞLATILIYOR (Zarar Etmek Yok!)
    WriteBatch siberBatch = _db.batch();

    try {
      double tutar = double.tryParse(_bakimTutarCtrl.text) ?? 0.0;

      // 💰 SİBER FİNANSAL PROTOKOL: %12 Karargah Payı
      double karargahPayi = tutar * 0.12;

      // 1. İşlem Kaydı (bakim_gecmisi koleksiyonu)
      DocumentReference bakimRef = _db.collection('bakim_gecmisi').doc();
      siberBatch.set(bakimRef, {
        'arac_id': widget.aracId,
        'plaka': widget.plaka,
        'islem_tipi': 'Periyodik Bakım / Parça Değişimi',
        'islem_notu': _bakimNotuCtrl.text.trim(),
        'tutar': tutar,
        'karargah_payi': karargahPayi, // Karargah payı her zaman takipte
        'bayi_referansi': 'Murat Plaza', // Vitrin kuralı: Murat Plaza mühürlü
        'tarih': FieldValue.serverTimestamp(),
      });

      // 2. DNA Skoru Güncelleme (+5 Puan)
      DocumentReference aracRef = _db.collection('araclar').doc(widget.aracId);
      siberBatch.update(aracRef, {
        'dna_skoru': FieldValue.increment(5),
        'son_bakim_tarihi': FieldValue.serverTimestamp(),
      });

      // 🚀 FÜZELER ATEŞLENDİ: Atomik Onay
      await siberBatch.commit();

      if (!mounted) return;
      setState(() => _isSaving = false);
      _bakimTutarCtrl.clear();
      _bakimNotuCtrl.clear();
      Navigator.pop(context); // Paneli kapat
      _siberUyariVer("BAKIM MÜHÜRLENDİ! DNA Skoru ve Finansal Pay İşlendi. 🦅", isError: false);

    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _siberUyariVer("SİBER AĞ HATASI: Veri mühürlenemedi!", isError: true);
    }
  }

  // 🌑 SİBER CAM EFEKTLİ PANEL
  void _bakimPaneliniAc() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: SiberTema.oledBlack.withOpacity(0.9),
                  border: Border(top: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 1.5)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
                    const SizedBox(height: 24),
                    const Text("YENİ BAKIM & HARCAMA MÜHRÜ", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 24),
                    _buildSiberGirdi("Harcama Tutarı (TL)", Icons.currency_lira, _bakimTutarCtrl, TextInputType.number),
                    const SizedBox(height: 16),
                    _buildSiberGirdi("İşlem Detayı", Icons.settings_suggest, _bakimNotuCtrl, TextInputType.text),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: SiberTema.kuantumButonStili(),
                        onPressed: _isSaving ? null : _bakimMesaiseEkle,
                        child: _isSaving
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 3))
                            : const Text("KARARGAHA İŞLE VE KAYDET", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.w900, fontSize: 12)),
      backgroundColor: isError ? Colors.redAccent : SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: Text(widget.plaka, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 3)),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: SiberTema.kuantumCyan,
          onPressed: _bakimPaneliniAc,
          icon: const Icon(Icons.add_moderator, color: SiberTema.oledBlack),
          label: const Text("BAKIM İŞLE", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ),
        body: Column(
          children: [
            // ÜST STRATEJİK KARTLAR
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  _buildSiberMenuKarti(Icons.auto_stories, "TORPİDO", "Siber Evraklar", () {}),
                  const SizedBox(width: 16),
                  _buildSiberMenuKarti(Icons.qr_code_scanner, "DNA SKORU", "Güvenlik Analizi", () {}),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("SİBER BAKIM GEÇMİŞİ", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
              ),
            ),

            // CANLI FİREBASE AKIŞI
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db.collection('bakim_gecmisi')
                    .where('arac_id', isEqualTo: widget.aracId)
                    .orderBy('tarih', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));

                  final bakimlar = snapshot.data!.docs;

                  if (bakimlar.isEmpty) {
                    return Center(child: Text("SİCİL TEMİZ: HENÜZ KAYIT YOK", style: TextStyle(color: Colors.white.withOpacity(0.2), fontWeight: FontWeight.w900, letterSpacing: 1)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: bakimlar.length,
                    itemBuilder: (context, index) {
                      final veri = bakimlar[index].data() as Map<String, dynamic>;
                      final DateTime tarih = (veri['tarih'] as Timestamp?)?.toDate() ?? DateTime.now();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.verified, color: SiberTema.kuantumCyan.withOpacity(0.5), size: 20),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(veri['islem_notu'] ?? 'BAKIM KAYDI', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text("${tarih.day}.${tarih.month}.${tarih.year} | ${veri['bayi_referansi']}", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                            Text("₺${veri['tutar']}", style: const TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 15)),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiberMenuKarti(IconData ikon, String baslik, String altBaslik, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(ikon, color: SiberTema.kuantumCyan, size: 24),
              const SizedBox(height: 12),
              Text(baslik, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
              Text(altBaslik, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiberGirdi(String label, IconData icon, TextEditingController controller, TextInputType type) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
        prefixIcon: Icon(icon, color: SiberTema.kuantumCyan, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: SiberTema.kuantumCyan)),
      ),
    );
  }
}