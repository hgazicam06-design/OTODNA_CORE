import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM ARAÇ SEÇİM MOTORU (Canlı Firebase Radarı)
/// Marka -> Model -> Kasa -> Motor hiyerarşisini Karargah veritabanından çeken Siber Şelale Modülü.
class AracSecimMotoru {
  // 🚀 STATİK ÇAĞIRICI (Herhangi bir ekrandan tek satırla ateşlenir)
  static Future<Map<String, String>?> secimiBaslat(BuildContext context) async {
    return await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Kuantum Cam Efekti İçin
      builder: (BuildContext context) {
        return const _KuantumSecimEkrani();
      },
    );
  }
}

// 🧠 BOTTOM SHEET İÇİNDEKİ CANLI SİBER MOTOR
class _KuantumSecimEkrani extends StatefulWidget {
  const _KuantumSecimEkrani();

  @override
  State<_KuantumSecimEkrani> createState() => _KuantumSecimEkraniState();
}

class _KuantumSecimEkraniState extends State<_KuantumSecimEkrani> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  int _secimAdimi = 0; // 0: Marka, 1: Model, 2: Kasa/Yıl, 3: Motor

  String _secilenMarka = "";
  String _secilenModel = "";
  String _secilenKasa = "";

  List<String> _tumListe = [];
  List<String> _guncelListe = []; // Arama filtresi için kalkan
  String _baslik = "MARKA SEÇİNİZ";
  bool _sorgulaniyor = true;

  @override
  void initState() {
    super.initState();
    _kuantumKatalogdanCek(); // İlk açılışta Markaları çek
  }

  // 📡 MAKET YIKILDI: CANLI FİREBASE (KARARGAH) BAĞLANTISI
  Future<void> _kuantumKatalogdanCek() async {
    setState(() => _sorgulaniyor = true);

    try {
      // 🚨 SİBER NOT: Veritabanında 'arac_katalogu' koleksiyonu olmalıdır.
      // Döküman ID'si Marka adı (Örn: "Audi"). İçinde hiyerarşik harita bulunur.
      QuerySnapshot snapshot = await _db.collection('arac_katalogu').get();

      if (snapshot.docs.isEmpty) {
        developer.log("SİBER UYARI: Araç kataloğu boş veya ağ bağlantısı yok!");
        _hataListesiDoldur("KATALOG BOŞ - SİSTEM YÖNETİCİSİNE BİLDİRİN");
        return;
      }

      List<String> markalar = snapshot.docs.map((doc) => doc.id).toList();
      markalar.sort(); // Alfabetik Karargah Düzeni

      if (mounted) {
        setState(() {
          _tumListe = markalar;
          _guncelListe = markalar;
          _sorgulaniyor = false;
        });
      }
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Katalog çekilemedi!", error: e);
      _hataListesiDoldur("AĞ BAĞLANTISI KOPTU");
    }
  }

  // 🚀 İLERİ GİT (SEÇİM) VE VERİ ÇEK
  Future<void> _adimIleri(String secim) async {
    setState(() => _sorgulaniyor = true);

    try {
      if (_secimAdimi == 0) {
        _secilenMarka = secim;
        _baslik = "$_secilenMarka - MODEL SEÇİNİZ";
        await _altKademeyiCek('modeller'); // Firestore'dan modelleri okur
        _secimAdimi++;
      } else if (_secimAdimi == 1) {
        _secilenModel = secim;
        _baslik = "$_secilenModel - KASA / YIL SEÇİNİZ";
        await _altKademeyiCek('kasalar');
        _secimAdimi++;
      } else if (_secimAdimi == 2) {
        _secilenKasa = secim;
        _baslik = "MOTOR VE DONANIM SEÇİNİZ";
        await _altKademeyiCek('motorlar');
        _secimAdimi++;
      } else if (_secimAdimi == 3) {
        String secilenMotor = secim;
        // 🎯 İŞLEM TAMAM! Kuantum Paketini Mühürle ve Gönder
        developer.log("SİBER ONAY: Araç DNA'sı seçildi -> $_secilenMarka $_secilenModel");
        Navigator.pop(context, {
          "marka": _secilenMarka,
          "model": _secilenModel,
          "kasa_yil": _secilenKasa,
          "motor": secilenMotor,
          "tam_isim": "$_secilenMarka $_secilenModel $_secilenKasa - $secilenMotor"
        });
        return; // Pop olduğu için alt kodları çalıştırma
      }
    } catch (e) {
      _hataListesiDoldur("VERİ ÇEKİLEMEDİ");
    } finally {
      if (mounted) setState(() => _sorgulaniyor = false);
    }
  }

  // 📡 ALT KADEME (Hiyerarşi) OKUMA MOTORU
  Future<void> _altKademeyiCek(String hedef) async {
    DocumentSnapshot doc = await _db.collection('arac_katalogu').doc(_secilenMarka).get();

    if (doc.exists && doc.data() != null) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<String> geciciListe = [];

      if (hedef == 'modeller') {
        geciciListe = data.keys.toList(); // Ana koddaki Modeller (A4, Golf vb.)
      } else if (hedef == 'kasalar' && data.containsKey(_secilenModel)) {
        geciciListe = (data[_secilenModel] as Map<String, dynamic>).keys.toList();
      } else if (hedef == 'motorlar' && data.containsKey(_secilenModel)) {
        geciciListe = List<String>.from((data[_secilenModel] as Map<String, dynamic>)[_secilenKasa] ?? []);
      }

      geciciListe.sort();
      setState(() {
        _tumListe = geciciListe;
        _guncelListe = geciciListe;
      });
    } else {
      _hataListesiDoldur("ALT VERİ BULUNAMADI");
    }
  }

  // 🔙 GERİ DÖNÜŞ MOTORU
  void _adimGeri() {
    setState(() {
      if (_secimAdimi == 3) {
        _secimAdimi = 2;
        _baslik = "$_secilenModel - KASA / YIL SEÇİNİZ";
        _altKademeyiCek('kasalar');
      } else if (_secimAdimi == 2) {
        _secimAdimi = 1;
        _baslik = "$_secilenMarka - MODEL SEÇİNİZ";
        _altKademeyiCek('modeller');
      } else if (_secimAdimi == 1) {
        _secimAdimi = 0;
        _baslik = "MARKA SEÇİNİZ";
        _kuantumKatalogdanCek();
      }
    });
  }

  // 🛡️ SİBER FİLTRE (TODO İMHA EDİLDİ!)
  void _siberFiltre(String kelime) {
    setState(() {
      if (kelime.isEmpty) {
        _guncelListe = _tumListe;
      } else {
        _guncelListe = _tumListe
            .where((item) => item.toLowerCase().contains(kelime.toLowerCase()))
            .toList();
      }
    });
  }

  void _hataListesiDoldur(String hata) {
    setState(() {
      _tumListe = [hata];
      _guncelListe = [hata];
    });
  }

  // ── 🎨 SİBER TASARIM DOKTRİNİ (UI) ──────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // Siber Cam Zırhı
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Color(0xFF000000).withOpacity(0.9), // OLED Siyah
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFF00FFC2), width: 2)), // Neon Çizgi
            boxShadow: [
              BoxShadow(color: Color(0xFF00FFC2).withOpacity(0.1), blurRadius: 20, spreadRadius: 5)
            ]
        ),
        child: Column(
          children: [
            // Üst Başlık ve Kontroller
            Row(
              children: [
                if (_secimAdimi > 0)
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Color(0xFF00FFC2)),
                    onPressed: _adimGeri,
                  ),
                Expanded(
                    child: Text(
                        _baslik,
                        textAlign: _secimAdimi == 0 ? TextAlign.center : TextAlign.left,
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)
                    )
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            Divider(color: Colors.white24, height: 24),

            // 🔍 GERÇEK ZAMANLI SİBER ARAMA MOTORU
            TextField(
              style: TextStyle(color: Colors.white, letterSpacing: 1),
              decoration: InputDecoration(
                hintText: "LİSTEDE ARA...",
                hintStyle: TextStyle(color: Colors.white38, letterSpacing: 1.5, fontSize: 12),
                prefixIcon: Icon(Icons.search, color: Color(0xFF00FFC2)),
                filled: true, fillColor: Color(0xFF111111),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white10)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFF00FFC2))),
              ),
              onChanged: _siberFiltre, // Canlı Filtre Aktif
            ),
            SizedBox(height: 16),

            // Seçim Listesi (Şelale Akışı)
            Expanded(
              child: _sorgulaniyor
                  ? Center(child: CircularProgressIndicator(color: Color(0xFF00FFC2)))
                  : ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: _guncelListe.length,
                itemBuilder: (context, index) {
                  String eleman = _guncelListe[index];
                  return InkWell(
                    onTap: () => _adimIleri(eleman),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                          color: Color(0xFF111111),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFF00FFC2).withOpacity(0.2)),
                          boxShadow: [BoxShadow(color: Color(0xFF00FFC2).withOpacity(0.02), blurRadius: 5)]
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(eleman, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1))),
                          Icon(
                            _secimAdimi == 3 ? Icons.check_circle : Icons.chevron_right,
                            color: _secimAdimi == 3 ? Color(0xFF00FFC2) : Colors.white38,
                            size: 20,
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}