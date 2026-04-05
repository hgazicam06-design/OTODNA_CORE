import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../services/kuantum_ocr_motoru.dart';

// 🔥 SİBER KÖPRÜLER
import 'qr/siber_goz_radari.dart'; // ✅ ESKİ DOSYA SİLİNDİ, YENİ QR RADARI BAĞLANDI
import 'arac_dna_raporu_screen.dart';
import 'global_siber_pazar_screen.dart';

class KullaniciPaneliScreen extends StatefulWidget {
  const KullaniciPaneliScreen({super.key});

  @override
  State<KullaniciPaneliScreen> createState() => _KullaniciPaneliScreenState();
}

class _KullaniciPaneliScreenState extends State<KullaniciPaneliScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final KuantumOcrMotoru _ocrMotoru = KuantumOcrMotoru();

  bool _isProcessing = false;

  // 🚨 S.O.S MOTORU
  Timer? _sosTimer;
  bool _isSosPressing = false;
  double _sosProgress = 0.0;

  void _sosBasladi(TapDownDetails details) {
    setState(() { _isSosPressing = true; _sosProgress = 0.0; });
    _sosTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() { _sosProgress += 0.01; });
      if (_sosProgress >= 1.0) { timer.cancel(); _sosTetikle(); }
    });
  }

  void _sosBirakildi(TapUpDetails details) => _sosIptal();
  void _sosIptalEdildi() => _sosIptal();
  void _sosIptal() {
    if (_sosProgress < 1.0) {
      _sosTimer?.cancel();
      setState(() { _isSosPressing = false; _sosProgress = 0.0; });
      _siberUyariVer("S.O.S İptal Edildi. Tetiklemek için 5 Saniye basılı tutun!", isError: true);
    }
  }

  Future<void> _sosTetikle() async {
    setState(() { _isSosPressing = false; _sosProgress = 0.0; });
    _siberUyariVer("S.O.S TETİKLENDİ! Konum Alınıyor...", isError: false);
    try {
      Position pozisyon = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      await _db.collection('sos_sinyalleri').add({
        'kullanici_id': _currentUser?.uid ?? 'BİLİNMEYEN_ID',
        'kullanici': _currentUser?.email ?? 'Siber Sürücü',
        'plaka': 'GARAJDAKİ ARAÇ',
        'konum': '${pozisyon.latitude}, ${pozisyon.longitude}',
        'durum': 'Bekliyor',
        'sinyal_zamani': FieldValue.serverTimestamp(),
        'asilsiz_ihbar_mi': false,
      });
      if (mounted) _siberUyariVer("S.O.S AĞA İLETİLDİ! En yakın Karargah birimi yönlendiriliyor.", isError: false);
    } catch (e) {
      if (mounted) _siberUyariVer("SİBER HATA: Konum kalkanı aşılamadı. GPS açık mı?", isError: true);
    }
  }

  Future<void> _yeniAracEkleOcr() async {
    setState(() => _isProcessing = true);
    _siberUyariVer("SİBER GÖZ AÇILIYOR: Ruhsatı veya Plakayı hizalayın...", isError: false);
    final analizSonucu = await _ocrMotoru.ruhsatTaramaMotoru();
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (analizSonucu != null) {
      String plaka = analizSonucu["plaka"] ?? "BULUNAMADI";
      String sase = analizSonucu["sase"] ?? "BULUNAMADI";
      if (plaka != "BULUNAMADI" || sase != "BULUNAMADI") {
        try {
          await _db.collection('araclar').add({'kullanici_id': _currentUser!.uid, 'plaka': plaka, 'sase_no': sase, 'model': 'Tarama İle Eklendi', 'dna_skoru': 100.0, 'eklenme_tarihi': FieldValue.serverTimestamp()});
          _siberUyariVer("ARAÇ GARAJA MÜHÜRLENDİ! Plaka: $plaka", isError: false);
        } catch (e) {
          _siberUyariVer("VERİTABANI HATASI: Araç kaydedilemedi.", isError: true);
        }
      } else { _siberUyariVer("ANALİZ HATASI: Ruhsatta geçerli Plaka veya Şase bulunamadı.", isError: true); }
    } else { _siberUyariVer("TARAMA İPTAL EDİLDİ.", isError: true); }
  }

  Future<void> _siberCikisYap() async { await FirebaseAuth.instance.signOut(); }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, fontFamily: 'Avenir', fontSize: 12)), backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), duration: const Duration(seconds: 4)));
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) return const Center(child: CircularProgressIndicator());

    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: Text("MÜŞTERİ KOKPİTİ", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 2, fontFamily: 'Avenir')), centerTitle: true, actions: [IconButton(icon: const Icon(Icons.power_settings_new, color: SiberTema.kanKirmizi), onPressed: _siberCikisYap, tooltip: "Ağdan Çık")]),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05)),
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _db.collection('araclar').where('kullanici_id', isEqualTo: _currentUser!.uid).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
                        final araclar = snapshot.data?.docs ?? [];
                        if (araclar.isEmpty) return _buildBosGarajDurumu();

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          itemCount: araclar.length + 1,
                          itemBuilder: (context, index) {
                            if (index == araclar.length) {
                              return Padding(padding: const EdgeInsets.only(top: 10), child: ElevatedButton.icon(style: SiberTema.kuantumButonStili(), onPressed: _isProcessing ? null : _yeniAracEkleOcr, icon: const Icon(Icons.document_scanner), label: const Text("RUHSAT TARA VE ARAÇ EKLE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1))));
                            }
                            var arac = araclar[index].data() as Map<String, dynamic>;
                            return _buildAracKarti(arac['plaka'] ?? 'PLAKA YOK', arac['model'] ?? 'Belirtilmemiş', (arac['dna_skoru'] ?? 100).toDouble());
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                        onTap: () => _siberUyariVer("AKILLI TORPİDO AÇILIYOR...", isError: false),
                        child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [SiberTema.matGrey, SiberTema.oledBlack]), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5)),
                            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.folder_special, color: SiberTema.altinSari, size: 24), SizedBox(width: 12), Text("AKILLI TORPİDO (PDF BELGELERİ)", style: TextStyle(color: SiberTema.altinSari, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))])
                        )
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () {
                        _siberUyariVer("GLOBAL PAZAR AĞINA BAĞLANILIYOR...", isError: false);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const GlobalSiberPazarScreen()));
                      },
                      child: Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [SiberTema.matGrey, SiberTema.oledBlack]), borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 1.5), boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.2), blurRadius: 10)]), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.storefront, color: SiberTema.kuantumCyan, size: 24), SizedBox(width: 12), Text("GLOBAL SİBER PAZAR (VİTRİN)", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))])),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: GestureDetector(
                      onTapDown: _isProcessing ? null : _sosBasladi, onTapUp: _sosBirakildi, onTapCancel: _sosIptalEdildi,
                      child: AnimatedContainer(duration: const Duration(milliseconds: 100), width: double.infinity, height: 70, decoration: BoxDecoration(color: _isSosPressing ? SiberTema.kanKirmizi.withOpacity(0.3) : SiberTema.oledBlack, borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.kanKirmizi.withOpacity(_isSosPressing ? 1.0 : 0.5), width: 2), boxShadow: [BoxShadow(color: SiberTema.kanKirmizi.withOpacity(_isSosPressing ? 0.6 : 0.2), offset: const Offset(0, 4), blurRadius: _isSosPressing ? 20 : 10)]), child: Stack(children: [Container(width: MediaQuery.of(context).size.width * _sosProgress, decoration: BoxDecoration(color: SiberTema.kanKirmizi.withOpacity(0.4), borderRadius: BorderRadius.circular(14))), Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.warning_amber_rounded, size: 28, color: _isSosPressing ? Colors.white : SiberTema.kanKirmizi), const SizedBox(width: 12), Text(_isSosPressing ? "S.O.S TETİKLENİYOR..." : "S.O.S (5 SANİYE BASILI TUT)", style: TextStyle(color: _isSosPressing ? Colors.white : SiberTema.kanKirmizi, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5, fontFamily: 'Avenir'))]))])),
                    ),
                  ),
                ],
              ),
            ),
            if (_isProcessing) Container(color: SiberTema.oledBlack.withOpacity(0.8), child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3), SizedBox(height: 24), Text("SİBER İŞLEM SÜRÜYOR...", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, letterSpacing: 3, fontFamily: 'Avenir'))]))),
          ],
        ),
      ),
    );
  }

  Widget _buildBosGarajDurumu() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.garage, size: 64, color: SiberTema.kuantumCyan.withOpacity(0.2)), const SizedBox(height: 16), Text("SİBER GARAJ BOŞ", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16, letterSpacing: 2, fontWeight: FontWeight.bold, fontFamily: 'Avenir')), const SizedBox(height: 24), ElevatedButton.icon(style: SiberTema.kuantumButonStili(), onPressed: _isProcessing ? null : _yeniAracEkleOcr, icon: const Icon(Icons.document_scanner), label: const Text("RUHSAT TARA VE ARAÇ EKLE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)))]));
  }

  Widget _buildAracKarti(String plaka, String model, double dnaSkoru) {
    Color skorRengi = dnaSkoru >= 80 ? SiberTema.kuantumCyan : (dnaSkoru >= 50 ? Colors.orange : SiberTema.kanKirmizi);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [SiberTema.matGrey.withOpacity(0.8), SiberTema.oledBlack]), borderRadius: BorderRadius.circular(20), border: Border.all(color: skorRengi.withOpacity(0.3), width: 1.5), boxShadow: [BoxShadow(color: skorRengi.withOpacity(0.1), blurRadius: 10, spreadRadius: 1)]),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(plaka, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')), const SizedBox(height: 4), Text(model, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontFamily: 'Avenir'))])), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: skorRengi.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: skorRengi.withOpacity(0.5))), child: Column(children: [Text(dnaSkoru.toStringAsFixed(0), style: TextStyle(color: skorRengi, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir')), Text("DNA", style: TextStyle(color: skorRengi.withOpacity(0.7), fontSize: 8, fontWeight: FontWeight.bold))]))]),
            const SizedBox(height: 20),
            Row(children: [Expanded(child: OutlinedButton.icon(style: OutlinedButton.styleFrom(foregroundColor: SiberTema.kuantumCyan, side: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5))), icon: const Icon(Icons.history, size: 16), label: const Text("TÜM İŞLEMLER", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), onPressed: () {})), const SizedBox(width: 12), Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kuantumCyan, foregroundColor: SiberTema.oledBlack), icon: const Icon(Icons.health_and_safety, size: 16), label: const Text("SAĞLIK RAPORU", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)), onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (_) => AracDnaRaporuScreen(plaka: plaka))); }))]),
            const SizedBox(height: 12),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: SiberTema.oledBlack, foregroundColor: SiberTema.kuantumCyan, side: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5))),
                    icon: const Icon(Icons.qr_code_scanner, size: 16),
                    label: const Text("SİBER GÖZ (QR)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      // ✅ CONST HATASI KALDIRILDI VE DOĞRU KÖPRÜYE BAĞLANDI
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SiberGozRadari()));
                    }
                )
            ),
          ],
        ),
      ),
    );
  }
}