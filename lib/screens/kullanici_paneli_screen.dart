import 'package:otodna/core/siber_tema.dart';
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
import 'qr/siber_goz_radari.dart';
import 'arac_dna_raporu_screen.dart';
import 'global_siber_pazar_screen.dart';

class KullaniciPaneliScreen extends StatefulWidget {
  KullaniciPaneliScreen({super.key});

  @override
  State<KullaniciPaneliScreen> createState() => _KullaniciPaneliScreenState();
}

class _KullaniciPaneliScreenState extends State<KullaniciPaneliScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final KuantumOcrMotoru _ocrMotoru = KuantumOcrMotoru();

  bool _isProcessing = false;

  // 🚨 S.O.S MOTORU - Gazi Protokolü (5 Saniye Kuralı)
  Timer? _sosTimer;
  bool _isSosPressing = false;
  double _sosProgress = 0.0;

  void _sosBasladi(TapDownDetails details) {
    setState(() { _isSosPressing = true; _sosProgress = 0.0; });
    _sosTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() { _sosProgress += 0.01; });
      if (_sosProgress >= 1.0) {
        timer.cancel();
        _sosTetikle();
      }
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

  // 🛰️ GERÇEK S.O.S TETİKLEME VE FİREBASE KAYIT
  Future<void> _sosTetikle() async {
    setState(() { _isSosPressing = false; _sosProgress = 0.0; });
    _siberUyariVer("S.O.S TETİKLENDİ! Konum Alınıyor...", isError: false);

    try {
      Position pozisyon = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // 🛡️ ATOMİK VERİ YAZMA: Sinyal doğrudan admin ve en yakın bayiye ulaşır
      await _db.collection('sos_sinyalleri').add({
        'kullanici_id': _currentUser?.uid ?? 'BİLİNMEYEN_ID',
        'kullanici_eposta': _currentUser?.email ?? 'Siber Sürücü',
        'konum': GeoPoint(pozisyon.latitude, pozisyon.longitude),
        'durum': 'BEKLEMEDE',
        'sinyal_zamani': FieldValue.serverTimestamp(),
        'asilsiz_ihbar_mi': false,
        'renk_kodu': 'KIRMIZI'
      });

      if (mounted) _siberUyariVer("S.O.S AĞA İLETİLDİ! En yakın Karargah birimi yönlendiriliyor.", isError: false);
    } catch (e) {
      if (mounted) _siberUyariVer("SİBER HATA: Konum kalkanı aşılamadı. GPS açık mı?", isError: true);
    }
  }

  // 👁️ KUANTUM OCR: RUHSAT TARAMA VE ARAÇ MÜHÜRLERİ
  Future<void> _yeniAracEkleOcr() async {
    setState(() => _isProcessing = true);
    _siberUyariVer("SİBER GÖZ AÇILIYOR: Ruhsatı veya Plakayı hizalayın...", isError: false);

    final analizSonucu = await _ocrMotoru.ruhsatTaramaMotoru();
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (analizSonucu != null) {
      String plaka = analizSonucu["plaka"] ?? "BULUNAMADI";
      String sase = analizSonucu["sase"] ?? "BULUNAMADI";

      if (plaka != "BULUNAMADI") {
        try {
          // 🛡️ DOĞRUDAN CANLI VERİTABANI KAYDI
          await _db.collection('araclar').add({
            'kullanici_id': _currentUser!.uid,
            'plaka': plaka,
            'sase_no': sase,
            'model': 'SİBER TARAMA',
            'dna_skoru': 100.0,
            'eklenme_tarihi': FieldValue.serverTimestamp(),
            'aktif_mi': true
          });
          _siberUyariVer("ARAÇ GARAJA MÜHÜRLENDİ! Plaka: $plaka", isError: false);
        } catch (e) {
          _siberUyariVer("VERİTABANI HATASI: Kayıt başarısız.", isError: true);
        }
      } else {
        _siberUyariVer("ANALİZ HATASI: Geçerli veri bulunamadı.", isError: true);
      }
    }
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mesaj, style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontFamily: 'Avenir', fontSize: 12)),
          backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )
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
            title: Text("MÜŞTERİ KOKPİTİ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
            centerTitle: true,
            actions: [
              IconButton(
                  icon: Icon(Icons.power_settings_new, color: SiberTema.kanKirmizi),
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  tooltip: "Ağdan Çık"
              )
            ]
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _db.collection('araclar').where('kullanici_id', isEqualTo: _currentUser?.uid).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
                      final araclar = snapshot.data?.docs ?? [];
                      if (araclar.isEmpty) return _buildBosGarajDurumu();

                      return ListView.builder(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.all(20),
                        itemCount: araclar.length + 1,
                        itemBuilder: (context, index) {
                          if (index == araclar.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: ElevatedButton.icon(
                                  style: SiberTema.kuantumButonStili(),
                                  onPressed: _isProcessing ? null : _yeniAracEkleOcr,
                                  icon: Icon(Icons.document_scanner),
                                  label: Text("YENİ ARAÇ MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.bold))
                              ),
                            );
                          }
                          var arac = araclar[index].data() as Map<String, dynamic>;
                          return _buildAracKarti(arac['plaka'] ?? '???', arac['model'] ?? 'SİBER ARAÇ', (arac['dna_skoru'] ?? 100).toDouble());
                        },
                      );
                    },
                  ),
                ),

                // 🛒 GLOBAL PAZAR KÖPRÜSÜ
                _buildSiberMenuButonu(
                    ikon: Icons.storefront,
                    etiket: "GLOBAL SİBER PAZAR (VİTRİN)",
                    renk: SiberTema.kuantumCyan,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GlobalSiberPazarScreen()))
                ),

                SizedBox(height: 12),

                // 🚨 ACİL DURUM S.O.S BUTONU (Gazi Protokolü)
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: GestureDetector(
                    onTapDown: _isProcessing ? null : _sosBasladi,
                    onTapUp: _sosBirakildi,
                    onTapCancel: _sosIptalEdildi,
                    child: AnimatedContainer(
                        duration: Duration(milliseconds: 100),
                        width: double.infinity,
                        height: 70,
                        decoration: BoxDecoration(
                            color: _isSosPressing ? SiberTema.kanKirmizi.withOpacity(0.3) : SiberTema.oledBlack,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: SiberTema.kanKirmizi.withOpacity(_isSosPressing ? 1.0 : 0.5), width: 2),
                            boxShadow: [BoxShadow(color: SiberTema.kanKirmizi.withOpacity(_isSosPressing ? 0.6 : 0.2), blurRadius: 20)]
                        ),
                        child: Stack(
                            children: [
                              Container(
                                  width: MediaQuery.of(context).size.width * _sosProgress,
                                  decoration: BoxDecoration(color: SiberTema.kanKirmizi.withOpacity(0.4), borderRadius: BorderRadius.circular(14))
                              ),
                              Center(
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.warning_amber_rounded, color: _isSosPressing ? Colors.white : SiberTema.kanKirmizi),
                                        SizedBox(width: 12),
                                        Text(
                                            _isSosPressing ? "S.O.S TETİKLENİYOR..." : "S.O.S (5 SN BASILI TUT)",
                                            style: TextStyle(color: _isSosPressing ? Colors.white : SiberTema.kanKirmizi, fontWeight: FontWeight.w900, letterSpacing: 1.5)
                                        )
                                      ]
                                  )
                              )
                            ]
                        )
                    ),
                  ),
                ),
              ],
            ),
            if (_isProcessing)
              Container(
                  color: SiberTema.oledBlack.withOpacity(0.8),
                  child: Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAracKarti(String plaka, String model, double dnaSkoru) {
    Color skorRengi = dnaSkoru >= 80 ? SiberTema.kuantumCyan : (dnaSkoru >= 50 ? Colors.orange : SiberTema.kanKirmizi);
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: SiberTema.siberCamDekorasyonu(renk: skorRengi),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plaka, style: TextStyle(color: SiberTema.textMain, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  Text(model, style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 12)),
                ],
              ),
              _buildDnaHalkasi(dnaSkoru, skorRengi),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: SiberTema.kuantumCyan, side: BorderSide(color: SiberTema.kuantumCyan)),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AracDnaRaporuScreen(plaka: plaka))),
                    child: Text("SAĞLIK RAPORU", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kuantumCyan, foregroundColor: SiberTema.oledBlack),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SiberGozRadari())),
                    child: Text("SİBER GÖZ (QR)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDnaHalkasi(double skor, Color renk) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: renk.withOpacity(0.5), width: 2)),
      child: Column(
        children: [
          Text(skor.toStringAsFixed(0), style: TextStyle(color: renk, fontSize: 16, fontWeight: FontWeight.w900)),
          Text("DNA", style: TextStyle(color: SiberTema.textMuted, fontSize: 8)),
        ],
      ),
    );
  }

  Widget _buildSiberMenuButonu({required IconData ikon, required String etiket, required Color renk, required VoidCallback onTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SiberTema.oledBlack,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: renk.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(ikon, color: renk, size: 24),
              SizedBox(width: 12),
              Text(etiket, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBosGarajDurumu() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.garage_outlined, size: 80, color: Colors.white.withOpacity(0.1)),
          SizedBox(height: 16),
          Text("SİBER GARAJ BOŞ", style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.bold, letterSpacing: 2)),
          SizedBox(height: 24),
          ElevatedButton(
              style: SiberTema.kuantumButonStili(),
              onPressed: _yeniAracEkleOcr,
              child: Text("İLK ARACINI MÜHÜRLE")
          )
        ],
      ),
    );
  }
}