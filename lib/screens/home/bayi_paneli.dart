import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// 🚀 KARARGAH ZIRHLARI VE TEMASI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

// 🔥 ROTALAR (Bayi işleme başladığında buraya uçacak)
import 'mega_revizyon_screen.dart';
import '../../widgets/siber_rehber_dialog.dart';

class BayiPaneliScreen extends StatefulWidget {
  final String bayiId; // Firebase Auth'dan gelecek olan Bayi UID'si

  BayiPaneliScreen({super.key, required this.bayiId});

  @override
  State<BayiPaneliScreen> createState() => _BayiPaneliScreenState();
}

class _BayiPaneliScreenState extends State<BayiPaneliScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rehberiGoster(otomatik: true);
    });
  }

  void _rehberiGoster({bool otomatik = false}) {
    String baslik = "BAYİ KOKPİTİ (MEGA REVİZYON)";
    String icerik = "OtoDNA Bayi Kokpitine hoş geldiniz.\n\n"
        "Burası işletmenizin ana kumanda merkezidir. Puanınızı, itibarınızı ve sistemden gelen canlı bölgesel 'S.O.S (Yolda Kalma)' sinyallerini buradan takip edersiniz.\n\n"
        "Yolda kalmış bir araç için 'Müdahale Et' derseniz konumuna navigasyonla gidebilir, asılsızsa 'Asılsız İhbar' diyerek ağı temizleyebilirsiniz. "
        "Ayrıca dükkanınıza gelen araçlar için 'YENİ ARAÇ İŞLEMİ BAŞLAT' butonuna tıklayarak Mega Revizyon modülüne geçiş yapabilirsiniz.";

    if (otomatik) {
      SiberRehber.otomatikGoster(context: context, screenKey: 'bayi_kokpiti_rehber', baslik: baslik, icerik: icerik);
    } else {
      SiberRehber.goster(context: context, screenKey: 'bayi_kokpiti_rehber', baslik: baslik, icerik: icerik);
    }
  }

  // --- SOS SİNYAL GÜNCELLEME MOTORU ---
  Future<void> _sinyalDurumGuncelle(String docId, String yeniDurum, bool asilsizMi) async {
    try {
      await FirebaseFirestore.instance.collection('sos_sinyalleri').doc(docId).update({
        'durum': yeniDurum,
        'asilsiz_ihbar_mi': asilsizMi,
        'guncelleme_tarihi': FieldValue.serverTimestamp(),
      });
      if (mounted) _siberUyariVer('Kuantum Ağı: Sinyal Durumu "$yeniDurum" olarak mühürlendi!', false);
    } catch (e) {
      if (mounted) _siberUyariVer('🚨 GÜNCELLEME HATASI: $e', true);
    }
  }

  // --- GERÇEK HARİTADA AÇMA MOTORU ---
  Future<void> _haritayiAc(String konumStr) async {
    if (konumStr == 'Konum Alınamadı' || !konumStr.contains(',')) {
      _siberUyariVer('Geçerli bir koordinat bulunamadı!', true);
      return;
    }

    try {
      final kordinatlar = konumStr.split(',');
      final lat = kordinatlar[0].trim();
      final lng = kordinatlar[1].trim();
      final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) throw Exception('Harita açılamadı');
    } catch (e) {
      if (mounted) _siberUyariVer('Siber Hata: Harita tetiklenemedi!', true);
    }
  }

  void _siberUyariVer(String mesaj, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
    ));
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
          leading: IconButton(icon: Icon(Icons.radar, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: Text("BAYİ KOKPİTİ", style: TextStyle(color: SiberTema.textMain.withOpacity(0.9), fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
          bottom: PreferredSize(preferredSize: Size.fromHeight(1), child: Container(color: Colors.white.withOpacity(0.05), height: 1)),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline_rounded, color: SiberTema.kuantumCyan),
              tooltip: "Siber Rehber",
              onPressed: () => _rehberiGoster(otomatik: false),
            )
          ],
        ),
        body: Container(
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05)),
          child: Column(
            children: [
              // ── 1. ÜST PANEL: BAYİ İTİBAR VE İŞLEM BAŞLATMA ──
              _buildBayiProfiliVeIslemMotoru(),

              // ── 2. ALT PANEL: CANLI SOS RADARI ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.cell_tower, color: SiberTema.kanKirmizi, size: 18),
                    SizedBox(width: 8),
                    Text("BÖLGESEL S.O.S RADARI", style: TextStyle(color: SiberTema.textMain.withOpacity(0.7), fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 12, fontFamily: 'Avenir')),
                  ],
                ),
              ),
              Expanded(child: _buildCanliSosMotoru()),
            ],
          ),
        ),
      ),
    );
  }

  // --- 🟡 1. FİREBASE: BAYİ İTİBAR PROFİLİ VE MEGA REVİZYON BUTONU ---
  Widget _buildBayiProfiliVeIslemMotoru() {
    return StreamBuilder<DocumentSnapshot>(
      // DİKKAT: Bayinin kendi ID'sine göre veri çekiyoruz
      stream: FirebaseFirestore.instance.collection('bayiler').doc(widget.bayiId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan)));
        }

        // Eğer bayi sistemde yoksa veya onay bekliyorsa
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildUyariKutusu("SİCİL BULUNAMADI VEYA ONAY BEKLİYOR.", SiberTema.kanKirmizi);
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        bool isKaraListe = data['kara_liste'] ?? false;
        double puan = (data['puan'] ?? 5.0).toDouble();
        String isim = data['firma_adi'] ?? 'Bilinmeyen Firma';

        if (isKaraListe) return _buildUyariKutusu("KARA LİSTE: AĞA ERİŞİMİNİZ KESİLDİ.", SiberTema.oledBlack, isBlacklist: true);

        return Padding(
          padding: EdgeInsets.all(20),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [SiberTema.matGrey.withOpacity(0.8), SiberTema.oledBlack]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
              boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.1), blurRadius: 15, spreadRadius: 1)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(isim, style: TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir'))),
                    _buildRozetGosterici(puan),
                  ],
                ),
                SizedBox(height: 24),
                // 🚀 TRUVA ATI: MEGA REVİZYON TETİKLEYİCİSİ
                GestureDetector(
                  onTap: () {
                    // Bayi işleme başladığında Mega Revizyon Ekranına fırlatıyoruz!
                    Navigator.push(context, MaterialPageRoute(builder: (_) => MegaRevizyonScreen()));
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [SiberTema.kuantumCyan.withOpacity(0.9), SiberTema.kuantumCyan.withOpacity(0.6)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.4), offset: Offset(0, 4), blurRadius: 10)],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.build_circle, color: SiberTema.oledBlack, size: 20),
                        SizedBox(width: 8),
                        Text("YENİ ARAÇ İŞLEMİ BAŞLAT", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- 🔴 2. FİREBASE: CANLI SOS MOTORU (Senin kodun 3D zırhlı hali) ---
  Widget _buildCanliSosMotoru() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('sos_sinyalleri').orderBy('sinyal_zamani', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: SiberTema.kanKirmizi));
        if (snapshot.hasError) return Center(child: Text('Radar Hatası!', style: TextStyle(color: SiberTema.kanKirmizi)));

        final data = snapshot.requireData;
        if (data.size == 0) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security, color: SiberTema.kuantumCyan.withOpacity(0.3), size: 64),
                SizedBox(height: 16),
                Text('BÖLGE GÜVENDE. S.O.S YOK.', style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir')),
              ],
            ),
          );
        }

        return ListView.builder(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20),
          itemCount: data.size,
          itemBuilder: (context, index) {
            var sinyalData = data.docs[index].data() as Map<String, dynamic>;
            var docId = data.docs[index].id;
            bool isBekliyor = sinyalData['durum'] == 'Bekliyor';
            Color durumRengi = isBekliyor ? SiberTema.kanKirmizi : SiberTema.kuantumCyan;

            return Container(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [SiberTema.oledBlack, SiberTema.matGrey.withOpacity(0.5)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: durumRengi.withOpacity(isBekliyor ? 0.5 : 0.2), width: isBekliyor ? 2 : 1),
                boxShadow: isBekliyor ? [BoxShadow(color: SiberTema.kanKirmizi.withOpacity(0.15), blurRadius: 15, spreadRadius: 1)] : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(isBekliyor ? Icons.warning_amber_rounded : Icons.shield, color: durumRengi, size: 20),
                          SizedBox(width: 8),
                          Text(sinyalData['plaka'] ?? 'BİLİNMİYOR', style: TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'Avenir')),
                        ],
                      ),
                      Text(sinyalData['durum'] ?? 'Bekliyor', style: TextStyle(color: durumRengi, fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'Avenir')),
                    ],
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: SiberTema.textMuted)),

                  // Harita Tetikleyici
                  GestureDetector(
                    onTap: () => _haritayiAc(sinyalData['konum'] ?? ''),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.textMuted)),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: SiberTema.altinSari, size: 18),
                          SizedBox(width: 8),
                          Expanded(child: Text("Navigasyon İçin Tıklayın", style: TextStyle(color: SiberTema.altinSari, fontSize: 12, fontWeight: FontWeight.bold))),
                          Icon(Icons.navigation, color: SiberTema.altinSari, size: 14),
                        ],
                      ),
                    ),
                  ),

                  if (isBekliyor) ...[
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(foregroundColor: SiberTema.kanKirmizi, side: BorderSide(color: SiberTema.kanKirmizi), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            onPressed: () => _sinyalDurumGuncelle(docId, 'Asılsız İhbar', true),
                            child: Text('ASILSIZ İHBAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kanKirmizi, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            onPressed: () => _sinyalDurumGuncelle(docId, 'Müdahale Edildi', false),
                            child: Text('MÜDAHALE ET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                          ),
                        ),
                      ],
                    )
                  ]
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- YARDIMCI GÖRSELLER ---
  Widget _buildRozetGosterici(double puan) {
    Color renk = puan >= 4.5 ? SiberTema.altinSari : (puan >= 3.0 ? Colors.grey[300]! : SiberTema.kanKirmizi);
    String metin = puan >= 4.5 ? "ALTIN ROZET" : (puan >= 3.0 ? "STANDART" : "RİSKLİ");

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: renk.withOpacity(0.1), border: Border.all(color: renk.withOpacity(0.5)), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(Icons.star, color: renk, size: 14),
          SizedBox(width: 4),
          Text("$metin ($puan)", style: TextStyle(color: renk, fontSize: 10, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
        ],
      ),
    );
  }

  Widget _buildUyariKutusu(String mesaj, Color renk, {bool isBlacklist = false}) {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(color: isBlacklist ? renk : renk.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: isBlacklist ? SiberTema.kanKirmizi : renk.withOpacity(0.5), width: 2)),
      child: Center(child: Text(mesaj, style: TextStyle(color: isBlacklist ? SiberTema.kanKirmizi : renk, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir', letterSpacing: 1), textAlign: TextAlign.center)),
    );
  }
}