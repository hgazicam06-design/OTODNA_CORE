import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../widgets/siber_rehber_dialog.dart';
import 'finans/siber_odeme_gecidi_screen.dart'; 

/// 🦅 SİBER GARAJ VE ABONELİK KOKPİTİ (B2C SAAS MOTORU)
class MusteriCuzdanScreen extends StatefulWidget {
  MusteriCuzdanScreen({super.key});

  @override
  State<MusteriCuzdanScreen> createState() => _MusteriCuzdanScreenState();
}

class _MusteriCuzdanScreenState extends State<MusteriCuzdanScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;
  bool _islemSuruyor = false;

  // SİBER GARAJ: Simüle edilmiş araç listesi
  List<Map<String, dynamic>> _araclar = [
    {"plaka": "34 DNA 01", "sase": "WBA00012345", "marka": "BMW 520i", "bildirim_sayisi": 2},
    {"plaka": "06 VTN 06", "sase": "WDC00098765", "marka": "Mercedes C200", "bildirim_sayisi": 0},
  ];

  @override
  void initState() {
    super.initState();
    // Ekran yüklendiğinde (eğer kullanıcı daha önce 'Gösterme' demediyse) rehberi otomatik aç.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SiberRehber.otomatikGoster(
        context: context,
        screenKey: 'musteri_cuzdan_rehber',
        baslik: "SİBER GARAJ & CÜZDAN",
        icerik: "Bu ekran sizin 'Kuantum Garajınızdır'. Burada sahip olduğunuz tüm araçları görebilir ve onlara özel oluşturulan QR mühürlerini indirebilirsiniz.\n\n"
                "Aynı zamanda araçlarınıza gelen bildirimleri (örn: 'Aracınızın camı açık kaldı') doğrudan buradan takip edebilirsiniz.\n\n"
                "Standart hesapla garajınızda en fazla 2 araç barındırabilirsiniz. Daha büyük bir filonuz varsa 'Yeni Araç Ekle' butonuna basarak aboneliğinizi yükseltebilirsiniz.",
      );
    });
  }

  // ABONELİK TİPİ VE LİMİT MOTORU
  String _abonelikTipi = "Standart"; 
  int get _aracLimiti {
    switch (_abonelikTipi) {
      case "Ultra": return 10;
      case "Ultra Pro": return 20;
      case "Ultra Premium": return 999; 
      default: return 2;
    }
  }

  void _siberUyari(String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(side: BorderSide(color: renk), borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── SİBER REHBER (AI ASİSTAN) ──
  void _siberRehberiAc() {
    SiberRehber.goster(
      context: context,
      screenKey: 'musteri_cuzdan_rehber',
      baslik: "SİBER GARAJ & CÜZDAN",
      icerik: "Bu ekran sizin 'Kuantum Garajınızdır'. Burada sahip olduğunuz tüm araçları görebilir ve onlara özel oluşturulan QR mühürlerini indirebilirsiniz.\n\n"
              "Aynı zamanda araçlarınıza gelen bildirimleri (örn: 'Aracınızın camı açık kaldı') doğrudan buradan takip edebilirsiniz.\n\n"
              "Standart hesapla garajınızda en fazla 2 araç barındırabilirsiniz. Daha büyük bir filonuz varsa 'Yeni Araç Ekle' butonuna basarak aboneliğinizi yükseltebilirsiniz.",
    );
  }

  // ── PAKET YÜKSELTME (SİBER ÖDEME GEÇİDİ) ──
  Future<void> _paketYukselt(String yeniPaket, double tutar) async {
    final sonuc = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SiberOdemeGecidiScreen(
          toplamTutar: tutar,
          komisyonTutar: 0.0, 
          esnafNet: 0.0,
        ),
      ),
    );

    if (sonuc == true) {
      setState(() {
        _abonelikTipi = yeniPaket;
      });
      _siberUyari("✅ ABONELİĞİNİZ '$yeniPaket' SEVİYESİNE YÜKSELTİLDİ!", SiberTema.kuantumCyan);
    }
  }

  // ── YENİ ARAÇ EKLEME KONTROLÜ ──
  void _yeniAracEkle() {
    if (_araclar.length >= _aracLimiti) {
      HapticFeedback.heavyImpact();
      _abonelikYukseltmePaneliAc();
    } else {
      HapticFeedback.lightImpact();
      setState(() {
        _araclar.add({"plaka": "YENİ ARAÇ", "sase": "YENI_SASE_${_araclar.length}", "marka": "Belirlenmedi", "bildirim_sayisi": 0});
      });
      _siberUyari("Garaja yeni araç mühürlendi.", SiberTema.kuantumCyan);
    }
  }

  // ── ABONELİK (SAAS) YÜKSELTME BOTTOM SHEET ──
  void _abonelikYukseltmePaneliAc() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: SiberTema.sariAltin, width: 2),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, color: SiberTema.sariAltin, size: 64),
              SizedBox(height: 16),
              Text("GARAJ KOTASI DOLDU", style: TextStyle(color: SiberTema.sariAltin, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
              SizedBox(height: 8),
              Text("Kuruluş Kampanyası: %66'ya varan İNDİRİM FIRSATIYLA filonuzu genişletin!", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMuted, fontSize: 13, fontWeight: FontWeight.bold)),
              SizedBox(height: 32),
              
              // İndirimli Paketler (Eski fiyat * 3 = Çizili fiyat)
              _buildPaketKarti("Ultra", "Maksimum 10 Araç", 597.00, 199.00),
              SizedBox(height: 12),
              _buildPaketKarti("Ultra Pro", "Maksimum 20 Araç", 1497.00, 499.00),
              SizedBox(height: 12),
              _buildPaketKarti("Ultra Premium", "Sınırsız Araç ve Belge", 2997.00, 999.00, isPremium: true),
              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaketKarti(String paketAdi, String ozellik, double eskiFiyat, double indirimliFiyat, {bool isPremium = false}) {
    Color anaRenk = isPremium ? SiberTema.kuantumCyan : SiberTema.sariAltin;
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); 
        _paketYukselt(paketAdi, indirimliFiyat);
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SiberTema.matGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: anaRenk.withOpacity(0.5)),
          boxShadow: isPremium ? [BoxShadow(color: anaRenk.withOpacity(0.2), blurRadius: 10)] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(paketAdi, style: TextStyle(color: anaRenk, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: SiberTema.kanKirmizi, borderRadius: BorderRadius.circular(4)),
                      child: Text("KAMPANYA", style: TextStyle(color: SiberTema.textMain, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    )
                  ],
                ),
                SizedBox(height: 4),
                Text(ozellik, style: TextStyle(color: SiberTema.textMuted, fontSize: 12)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${eskiFiyat.toInt()} ₺", style: TextStyle(color: SiberTema.textMuted, decoration: TextDecoration.lineThrough, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: anaRenk.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text("${indirimliFiyat.toInt()} ₺", style: TextStyle(color: anaRenk, fontWeight: FontWeight.w900, fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
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
          backgroundColor: Colors.black.withOpacity(0.8),
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: Text("SİBER GARAJ & CÜZDAN", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline_rounded, color: SiberTema.kuantumCyan),
              tooltip: "Siber Rehber (Nasıl Çalışır?)",
              onPressed: _siberRehberiAc,
            )
          ],
        ),
        body: Column(
          children: [
            _buildGarajBilgiPaneli(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Divider(color: SiberTema.textMuted, thickness: 1),
            ),
            Expanded(
              child: _buildAracListesi(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _yeniAracEkle,
          backgroundColor: SiberTema.kuantumCyan,
          foregroundColor: Colors.white,
          icon: Icon(Icons.add_circle_outline),
          label: Text("YENİ ARAÇ EKLE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        ),
      ),
    );
  }

  // ── GARAJ LİMİT VE ABONELİK BİLGİSİ ──
  Widget _buildGarajBilgiPaneli() {
    double dolulukOrani = _araclar.length / _aracLimiti;
    if (dolulukOrani > 1) dolulukOrani = 1.0;

    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 30)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("GÜNCEL PAKET", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  SizedBox(height: 4),
                  Text("OtoDNA Aboneliği", style: TextStyle(color: SiberTema.textMuted, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: SiberTema.sariAltin.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.sariAltin.withOpacity(0.5))),
                child: Text(_abonelikTipi.toUpperCase(), style: TextStyle(color: SiberTema.sariAltin, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
              )
            ],
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Garaj Kapasitesi", style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 12)),
              Text("${_araclar.length} / ${_abonelikTipi == 'Ultra Premium' ? '∞' : _aracLimiti}", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _abonelikTipi == 'Ultra Premium' ? 0.1 : dolulukOrani,
              backgroundColor: Colors.white12,
              color: dolulukOrani >= 1.0 ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ── ARAÇ (QR) LİSTESİ ──
  Widget _buildAracListesi() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: BouncingScrollPhysics(),
      itemCount: _araclar.length,
      itemBuilder: (context, index) {
        final arac = _araclar[index];
        final bool bildirimVar = arac['bildirim_sayisi'] > 0;

        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: SiberTema.matGrey,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: bildirimVar ? SiberTema.sariAltin : Colors.white12, width: bildirimVar ? 1.5 : 1),
            boxShadow: bildirimVar ? [BoxShadow(color: SiberTema.sariAltin.withOpacity(0.1), blurRadius: 10)] : [],
          ),
          child: ExpansionTile(
            collapsedIconColor: Colors.white54,
            iconColor: SiberTema.kuantumCyan,
            tilePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.directions_car_rounded, color: SiberTema.kuantumCyan, size: 24),
                ),
                if (bildirimVar)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(color: SiberTema.kanKirmizi, shape: BoxShape.circle),
                      child: Text("${arac['bildirim_sayisi']}", style: TextStyle(color: SiberTema.textMain, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  )
              ],
            ),
            title: Text(arac['plaka'], style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
            subtitle: Text("${arac['marka']} • Şasi: ${arac['sase']}", style: TextStyle(color: SiberTema.textMuted, fontSize: 11)),
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: SiberTema.textMuted)),
                  color: Colors.white24,
                ),
                child: Row(
                  children: [
                    // SİBER QR KOD SİMÜLASYONU
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: SiberTema.kuantumCyan, width: 2),
                      ),
                      child: Center(
                        child: Icon(Icons.qr_code_2, size: 80, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("KUANTUM QR MÜHRÜ", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          SizedBox(height: 8),
                          Text("Aracınızın camına yapıştıracağınız evrensel bildirim kodu. Okutulduğunda sadece bu araca uyarı gelir.", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, height: 1.4)),
                          SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => _siberUyari("Siber Cüzdandan QR Indiriliyor...", SiberTema.kuantumCyan),
                            icon: Icon(Icons.download_rounded, size: 16),
                            label: Text("QR'I İNDİR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: SiberTema.kuantumCyan,
                              side: BorderSide(color: SiberTema.kuantumCyan),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}