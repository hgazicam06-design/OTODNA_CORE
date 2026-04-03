import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ROTALAR (İlgili dosyaların importları)
// import 'torpido_ekleme_screen.dart';
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

  // --- MATRİKSE BAKIM / HARCAMA EKLEME (Gerçek Firebase Yazma) ---
  Future<void> _bakimMesaiseEkle() async {
    if (_bakimTutarCtrl.text.isEmpty || _bakimNotuCtrl.text.isEmpty) {
      _siberUyariVer("SİBER İHLAL: Tutar ve Bakım Notu boş bırakılamaz!", isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      double tutar = double.tryParse(_bakimTutarCtrl.text) ?? 0.0;

      // %12 Karargah Payı Hesaplama Simülasyonu (Arka planda finansal analiz için)
      double karargahPayi = tutar * 0.12;

      await _db.collection('bakim_gecmisi').add({
        'arac_id': widget.aracId,
        'plaka': widget.plaka,
        'islem_tipi': 'Periyodik Bakım / Parça Değişimi',
        'islem_notu': _bakimNotuCtrl.text,
        'tutar': tutar,
        'karargah_payi_kesintisi': karargahPayi, // Finansal veri tabanı için gizli veri
        'bayi_referansi': 'Murat Plaza', // Oto market ismi vitrinde gizlenir, Murat Plaza mühürlenir
        'tarih': FieldValue.serverTimestamp(),
      });

      // Araca bakım yapıldığı için DNA Skorunu Kuantum Ağı'nda iyileştir (+5 Puan)
      await _db.collection('araclar').doc(widget.aracId).update({
        'dna_skoru': FieldValue.increment(5),
      });

      if (!mounted) return;
      setState(() => _isSaving = false);
      _bakimTutarCtrl.clear();
      _bakimNotuCtrl.clear();
      Navigator.pop(context); // Paneli kapat
      _siberUyariVer("BAKIM MÜHÜRLENDİ! DNA Skoru Yükseltildi.", isError: false);

    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _siberUyariVer("SİBER AĞ HATASI: İşlem başarısız.", isError: true);
    }
  }

  // SİBER CAM EFEKTLİ BAKIM EKLEME PANELİ
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
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: SiberTema.oledBlack.withOpacity(0.9),
                  border: Border(top: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 50, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(height: 24),
                    const Text("YENİ BAKIM & HARCAMA MÜHRÜ", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 2)),
                    const SizedBox(height: 8),
                    const Text("Murat Plaza Garantili Yedek Parça ve Servis Ağı", style: TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'Avenir')),
                    const SizedBox(height: 24),

                    _buildSiberGirdi("Harcama Tutarı (TL)", Icons.account_balance_wallet, _bakimTutarCtrl, TextInputType.number),
                    const SizedBox(height: 16),
                    _buildSiberGirdi("İşlem Detayı (Örn: Yağ Filtresi, Balata)", Icons.build, _bakimNotuCtrl, TextInputType.text),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: SiberTema.kuantumButonStili(),
                        onPressed: _isSaving ? null : _bakimMesaiseEkle,
                        child: _isSaving
                            ? const CircularProgressIndicator(color: SiberTema.oledBlack)
                            : const Text("KARARGAHA İŞLE VE KAYDET", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1)),
                      ),
                    ),
                    const SizedBox(height: 16),
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
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
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
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: Text("DİJİTAL GARAJ: ${widget.plaka}", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: SiberTema.kuantumCyan,
          foregroundColor: SiberTema.oledBlack,
          onPressed: _bakimPaneliniAc,
          icon: const Icon(Icons.add_task),
          label: const Text("BAKIM İŞLE", style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1)),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ÜST YÖNETİM KARTLARI
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    _buildSiberMenuKarti(Icons.folder_special, "TORPİDO", "Belgeler", () {
                      // Torpido Ekleme Ekranına Geçiş
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => TorpidoEklemeScreen(aracId: widget.aracId, aracIsim: widget.plaka, kullaniciId: FirebaseAuth.instance.currentUser!.uid)));
                      _siberUyariVer("Akıllı Torpido Bağlantısı Tetiklendi!", isError: false);
                    }),
                    const SizedBox(width: 16),
                    _buildSiberMenuKarti(Icons.verified_user, "DNA RAPORU", "Araç Sağlığı", () {
                      _siberUyariVer("Detaylı Kuantum DNA Raporu Yükleniyor...", isError: false);
                    }),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Text("FİNANS VE BAKIM GEÇMİŞİ", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
              ),

              // CANLI BAKIM VERİLERİ (FIREBASE STREAM)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _db.collection('bakim_gecmisi').where('arac_id', isEqualTo: widget.aracId).orderBy('tarih', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
                    if (snapshot.hasError) return const Center(child: Text("Siber Ağa Ulaşılamıyor.", style: TextStyle(color: SiberTema.kanKirmizi)));

                    final bakimlar = snapshot.data?.docs ?? [];

                    if (bakimlar.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off, size: 64, color: SiberTema.kuantumCyan.withOpacity(0.2)),
                            const SizedBox(height: 16),
                            Text("HENÜZ BAKIM MÜHRÜ YOK", style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: bakimlar.length,
                      itemBuilder: (context, index) {
                        final veri = bakimlar[index].data() as Map<String, dynamic>;
                        final tarih = (veri['tarih'] as Timestamp?)?.toDate() ?? DateTime.now();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.build_circle, color: SiberTema.kuantumCyan),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(veri['islem_notu'] ?? 'Bilinmeyen İşlem', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Avenir', fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text("Ref: ${veri['bayi_referansi']} | ${tarih.day}.${tarih.month}.${tarih.year}", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontFamily: 'Avenir')),
                                  ],
                                ),
                              ),
                              Text("₺${veri['tutar']}", style: const TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontFamily: 'Avenir', fontSize: 16)),
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
      ),
    );
  }

  Widget _buildSiberMenuKarti(IconData ikon, String baslik, String altBaslik, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SiberTema.kuantumCyan.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(ikon, color: SiberTema.kuantumCyan, size: 28),
                  const SizedBox(height: 12),
                  Text(baslik, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1)),
                  Text(altBaslik, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, fontFamily: 'Avenir')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSiberGirdi(String baslik, IconData ikon, TextEditingController kontrolcu, TextInputType klavye) {
    return TextField(
      controller: kontrolcu,
      keyboardType: klavye,
      style: const TextStyle(color: Colors.white, fontFamily: 'Avenir', fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: baslik,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontFamily: 'Avenir'),
        prefixIcon: Icon(ikon, color: SiberTema.kuantumCyan, size: 20),
        filled: true,
        fillColor: Colors.black.withOpacity(0.5),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.kuantumCyan, width: 2)),
      ),
    );
  }
}