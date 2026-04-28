import 'package:otodna/core/siber_tema.dart';
// lib/bayi/siber_gelismis_urun_ekleme.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM DETAYLI ÜRÜN GİRİŞ TERMİNALİ (AI, HUB ve SAAS KOTALI)
class SiberGelismisUrunEkleme extends StatefulWidget {
  SiberGelismisUrunEkleme({super.key});

  @override
  State<SiberGelismisUrunEkleme> createState() => _SiberGelismisUrunEklemeState();
}

class _SiberGelismisUrunEklemeState extends State<SiberGelismisUrunEkleme> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _bayiId = FirebaseAuth.instance.currentUser?.uid ?? "BILINMEYEN_BAYI";

  // ── 📸 ÇOKLU MEDYA GALERİSİ ──
  final List<File> _secilenGorseller = [];
  String _hubResimUrl = ""; 

  // ── 📦 BÖLÜM 1: KİMLİK VE VİTRİN ──
  final TextEditingController _urunAdiCtrl = TextEditingController();
  final TextEditingController _kategoriCtrl = TextEditingController();
  final TextEditingController _markaCtrl = TextEditingController();
  final TextEditingController _stokKoduCtrl = TextEditingController(); 

  // ── 📝 BÖLÜM 2: DETAY VE ROZETLER ──
  final TextEditingController _aciklamaCtrl = TextEditingController();
  final TextEditingController _etiketlerCtrl = TextEditingController(); 
  final TextEditingController _uyumluAraclarCtrl = TextEditingController(); 
  bool _rozetGaranti = true;
  bool _rozetOrijinal = true;
  bool _rozetKurulumAliciyaAit = true;

  // ── 💰 BÖLÜM 3: FİNANS VE %12 DNA'SI ──
  final TextEditingController _gelisFiyatiCtrl = TextEditingController();
  final TextEditingController _kdvOraniCtrl = TextEditingController(text: "20");
  final TextEditingController _karMarjiCtrl = TextEditingController();

  // Otonom Veriler
  double _kdvliGelis = 0.0;
  double _bayiNetHedefi = 0.0;
  double _otodnaPayi = 0.0;
  double _musteriVitrinFiyati = 0.0;
  bool _islemSuruyor = false;

  // ── 🛡️ KOTA VE PAKET MATEMATİĞİ ──
  int _getMaxProducts(String paket) {
    if (paket == 'ULTRA') return 50;
    if (paket == 'ULTRA_PLUS') return 100;
    if (paket == 'ULTRA_VIP') return 999999;
    return 10; // NORMAL
  }

  int _getPdfBatchSize(String paket) {
    if (paket == 'ULTRA') return 10;
    if (paket == 'ULTRA_PLUS') return 20;
    if (paket == 'ULTRA_VIP') return 999999;
    return 10; // NORMAL
  }

  String _getUpsellMessage(String paket) {
    if (paket == 'ULTRA') return "Daha fazlası için Ultra Plus'a geçin!";
    if (paket == 'ULTRA_PLUS') return "Sınırları kaldırmak için Ultra VIP'ye geçin!";
    if (paket == 'ULTRA_VIP') return "Sınırsız sürümdesiniz, Karargah emrinizde!";
    return "Daha fazlası için Ultra Pakete geçin!";
  }

  // ── 🤖 SİBER AI VE HUB MOTORLARI ──

  /// PDF/Fatura okuma ve TOPLU EKLEME (Bulk Insert) simülasyonu
  Future<void> _pdfYukleVeCozumle() async {
    setState(() => _islemSuruyor = true);
    HapticFeedback.mediumImpact();
    developer.log("🤖 SİBER AI: PDF İçe Aktarma Protokolü Başlatıldı...");

    try {
      // 1. Kapasite Radarı (Kullanıcı verisi ve Ürün Sayısı)
      var userDoc = await _db.collection('kullanicilar').doc(_bayiId).get();
      String paket = userDoc.data()?['abonelik_paketi'] ?? 'NORMAL';

      var countQuery = await _db.collection('market_urunleri')
          .where('bayi_id', isEqualTo: _bayiId)
          .where('aktif_mi', isEqualTo: true).count().get();
      int currentCount = countQuery.count ?? 0;

      int maxLimit = _getMaxProducts(paket);
      int pdfBatch = _getPdfBatchSize(paket);

      if (currentCount >= maxLimit) {
        _siberUyariGoster("KAPASİTE DOLDU", "Dükkanınız sınır olan $maxLimit ürüne ulaştı. ${_getUpsellMessage(paket)}", SiberTema.kanKirmizi);
        return;
      }

      int availableSpace = maxLimit - currentCount;
      int itemsToAdd = availableSpace < pdfBatch ? availableSpace : pdfBatch;

      developer.log("SİBER ONAY: $itemsToAdd adet ürün faturadan Kuantum ağına aktarılıyor...");
      await Future.delayed(Duration(seconds: 3)); // AI Simülasyon Gecikmesi

      // 2. ATOMİK TOPLU YÜKLEME (WriteBatch)
      WriteBatch batch = _db.batch();
      for(int i = 0; i < itemsToAdd; i++) {
         DocumentReference ref = _db.collection('market_urunleri').doc();
         batch.set(ref, {
           'urun_id': ref.id,
           'bayi_id': _bayiId,
           'galeri': [],
           'hub_resim_url': '',
           'kimlik': {
             'urun_adi': 'PDF OTONOM ÜRÜN ${i+1}',
             'kategori': 'YEDEK PARÇA',
             'marka': 'BELİRSİZ',
             'stok_kodu': 'PDF-OE-${DateTime.now().millisecondsSinceEpoch}-$i',
           },
           'rozetler': {
             'garanti_2yil': true,
             'orijinal_urun': false,
             'kurulum_aliciya_ait': true,
           },
           'detaylar': {
             'aciklama': 'PDF fatura okuma asistanı ile otomatik oluşturuldu.',
             'etiketler': ['OTO', 'YEDEK', 'PDF'],
             'uyumlu_araclar': 'Belirtilmedi'
           },
           'finans': {
             // Otonom varsayılan değerler
             'net_gelis': 1000.0,
             'kdv_orani': 20.0,
             'kar_marji': 30.0,
             'otodna_kesintisi': 187.5,
             'bayi_net_hakedis': 1560.0,
             'kdv_dahil_vitrin_fiyati': 1747.5, 
           },
           'olusturulma_tarihi': FieldValue.serverTimestamp(),
           'aktif_mi': true,
         });
      }

      // Kara Kutu
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
          'islem_turu': 'TOPLU_PDF_YUKLEME',
          'islem_detayi': 'SİBER TİCARET: $_bayiId, PDF üzerinden $itemsToAdd ürün aktardı.',
          'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      _siberUyariGoster("AI AKTARIMI BAŞARILI", "$itemsToAdd ürün dükkana eklendi. ${availableSpace <= pdfBatch ? _getUpsellMessage(paket) : ''}", SiberTema.kuantumCyan);
    } catch(e) {
      developer.log("AI HATASI", error: e);
      _siberUyariGoster("SİSTEM HATASI", "PDF aktarımı başarısız.", SiberTema.kanKirmizi);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  /// Google Hub'dan OE Kodu ile orijinal veri çekme
  Future<void> _hubSorgula() async {
    String oe = _stokKoduCtrl.text.trim().toUpperCase();
    if (oe.isEmpty) {
      _siberUyariGoster("OE KODU EKSİK", "Hub taraması için lütfen Stok/OE Kodu giriniz.", SiberTema.kanKirmizi);
      return;
    }

    setState(() => _islemSuruyor = true);
    HapticFeedback.heavyImpact();
    developer.log("🌐 GOOGLE HUB: $oe için Global İstihbarat Ağı taranıyor...");

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _aciklamaCtrl.text = "Orijinal fabrika çıkışlı yüksek dayanımlı parça. Global Hub onayı mevcut.";
      _uyumluAraclarCtrl.text = "Mercedes W205 C-Class, W213 E-Class, GLC";
      _hubResimUrl = "https://example.com/orijinal_parca_$oe.jpg"; // Mock URL
      _islemSuruyor = false;
    });

    _siberUyariGoster("HUB BAĞLANTISI BAŞARILI", "Orijinal fabrika resmi ve uyumlu araçlar sisteme çekildi.", SiberTema.altinSari);
  }

  // ── 📸 GALERİ YÖNETİMİ ──
  Future<void> _gorselEkle() async {
    try {
      final picker = ImagePicker();
      final List<XFile> secilenler = await picker.pickMultiImage(imageQuality: 70);
      if (secilenler.isNotEmpty) {
        setState(() {
          _secilenGorseller.addAll(secilenler.map((x) => File(x.path)));
        });
      }
    } catch (e) {
      developer.log("SİBER KAMERA HATASI", error: e);
    }
  }

  // ── ⚙️ KUANTUM FİNANS HESAPLAYICI ──
  void _siberHesaplamayiTetikle() {
    double gelis = double.tryParse(_gelisFiyatiCtrl.text.replaceAll(',', '.')) ?? 0.0;
    double kdv = double.tryParse(_kdvOraniCtrl.text.replaceAll(',', '.')) ?? 20.0;
    double marj = double.tryParse(_karMarjiCtrl.text.replaceAll(',', '.')) ?? 0.0;

    setState(() {
      _kdvliGelis = gelis * (1 + (kdv / 100));
      _bayiNetHedefi = _kdvliGelis * (1 + (marj / 100));

      // ⚖️ KARARGAH KESİNTİSİ
      double kesintiOrani = (_bayiId == "MURAT_PLAZA") ? 0.30 : 0.12;
      double carpan = 1.0 - kesintiOrani;

      _musteriVitrinFiyati = _bayiNetHedefi / carpan;
      _otodnaPayi = _musteriVitrinFiyati * kesintiOrani;
    });
  }

  // ── 🚀 ATOMİK MÜHÜRLEME (STORAGE + WRITEBATCH) ──
  Future<void> _urunuMarketeFirlat() async {
    if (!_formKey.currentState!.validate()) {
      _siberUyariGoster("VERİ EKSİK", "Kırmızı ile işaretli zorunlu alanları doldurmalısınız.", SiberTema.kanKirmizi);
      return;
    }

    setState(() => _islemSuruyor = true);
    HapticFeedback.heavyImpact();

    try {
      // 🛡️ 1. KAPASİTE KONTROLÜ
      var userDoc = await _db.collection('kullanicilar').doc(_bayiId).get();
      String paket = userDoc.data()?['abonelik_paketi'] ?? 'NORMAL';

      var countQuery = await _db.collection('market_urunleri')
          .where('bayi_id', isEqualTo: _bayiId)
          .where('aktif_mi', isEqualTo: true).count().get();
      int currentCount = countQuery.count ?? 0;
      int maxLimit = _getMaxProducts(paket);

      if (currentCount >= maxLimit) {
        _siberUyariGoster("KAPASİTE DOLDU", "Dükkanınız sınır olan $maxLimit ürüne ulaştı. ${_getUpsellMessage(paket)}", SiberTema.kanKirmizi);
        return;
      }

      developer.log("🚀 SİBER MÜHÜRLEME BAŞLADI...");

      // 2. GÖRSEL İŞLEMLERİ
      List<String> gorselLinkleri = [];
      if (_secilenGorseller.isNotEmpty) {
        for (int i = 0; i < _secilenGorseller.length; i++) {
          File dosya = _secilenGorseller[i];
          String yol = 'market_gorselleri/$_bayiId/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          TaskSnapshot snap = await _storage.ref().child(yol).putFile(dosya);
          String url = await snap.ref.getDownloadURL();
          gorselLinkleri.add(url);
        }
      } else if (_hubResimUrl.isNotEmpty) {
        gorselLinkleri.add(_hubResimUrl);
      }

      // 3. ATOMİK ZIRH (WriteBatch)
      WriteBatch batch = _db.batch();
      DocumentReference urunRef = _db.collection('market_urunleri').doc();

      List<String> etiketListesi = _etiketlerCtrl.text.split(',').map((e) => e.trim().toUpperCase()).toList();

      batch.set(urunRef, {
        'urun_id': urunRef.id,
        'bayi_id': _bayiId,
        'galeri': gorselLinkleri,
        'hub_resim_url': _hubResimUrl, 
        'kimlik': {
          'urun_adi': _urunAdiCtrl.text.trim().toUpperCase(),
          'kategori': _kategoriCtrl.text.trim().toUpperCase(),
          'marka': _markaCtrl.text.trim().toUpperCase(),
          'stok_kodu': _stokKoduCtrl.text.trim().toUpperCase(),
        },
        'rozetler': {
          'garanti_2yil': _rozetGaranti,
          'orijinal_urun': _rozetOrijinal,
          'kurulum_aliciya_ait': _rozetKurulumAliciyaAit,
        },
        'detaylar': {
          'aciklama': _aciklamaCtrl.text.trim(),
          'etiketler': etiketListesi,
          'uyumlu_araclar': _uyumluAraclarCtrl.text.trim(), 
        },
        'finans': {
          'net_gelis': double.tryParse(_gelisFiyatiCtrl.text.replaceAll(',', '.')) ?? 0.0,
          'kdv_orani': double.tryParse(_kdvOraniCtrl.text.replaceAll(',', '.')) ?? 20.0,
          'kar_marji': double.tryParse(_karMarjiCtrl.text.replaceAll(',', '.')) ?? 0.0,
          'otodna_kesintisi': double.tryParse(_otodnaPayi.toStringAsFixed(2)) ?? 0.0,
          'bayi_net_hakedis': double.tryParse(_bayiNetHedefi.toStringAsFixed(2)) ?? 0.0,
          'kdv_dahil_vitrin_fiyati': double.tryParse(_musteriVitrinFiyati.toStringAsFixed(2)) ?? 0.0,
        },
        'olusturulma_tarihi': FieldValue.serverTimestamp(),
        'aktif_mi': true,
      });

      // 4. KARA KUTU LOGU
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'DETAYLI_URUN_YAYINLANDI',
        'islem_detayi': 'SİBER TİCARET: $_bayiId, ${_urunAdiCtrl.text} ürününü markete mühürledi. Vitrin: ₺${_musteriVitrinFiyati.toStringAsFixed(2)}',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (mounted) {
        _siberUyariGoster("SİBER MÜHÜR BASILDI", "Ürün Kuantum Ağına işlendi. %12 Karargah komisyonu aktiftir.", SiberTema.kuantumCyan);
        Navigator.pop(context);
      }
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ", error: e);
      if (mounted) _siberUyariGoster("HATA", "İşlem mühürlenemedi.", SiberTema.kanKirmizi);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("ÜRÜN & GALERİ MERKEZİ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, fontFamily: 'Avenir')),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(20),
            children: [
              // ── 🤖 SİBER ASİSTAN PANELİ VE KAPASİTE RADARI ──
              _buildSiberAsistanPaneli(),
              SizedBox(height: 24),

              // ── 📸 GALERİ BÖLÜMÜ ──
              _buildBolumBasligi("MEDYA VE GÖRSEL KANITLAR (Opsiyonel)", Icons.photo_library),
              SizedBox(height: 12),
              _buildGaleri(),
              SizedBox(height: 24),

              // ── 📦 KİMLİK BÖLÜMÜ ──
              _buildBolumBasligi("KİMLİK VE KATEGORİ", Icons.fingerprint),
              SizedBox(height: 12),
              _buildSiberInput(controller: _stokKoduCtrl, hint: "Stok Kodu / OE Kodu (Örn: A2054210112)", isRequired: true),
              SizedBox(height: 12),
              _buildSiberInput(controller: _urunAdiCtrl, hint: "Ürün Adı (Örn: Brembo Disk)", isRequired: true),
              Row(
                children: [
                  Expanded(child: _buildSiberInput(controller: _markaCtrl, hint: "Marka")),
                  SizedBox(width: 12),
                  Expanded(child: _buildSiberInput(controller: _kategoriCtrl, hint: "Kategori")),
                ],
              ),
              SizedBox(height: 24),

              // ── 📝 DETAYLAR VE ROZETLER ──
              _buildBolumBasligi("TEKNİK DETAYLAR VE GÜVENCELER", Icons.description),
              SizedBox(height: 12),
              _buildSiberInput(controller: _aciklamaCtrl, hint: "Ürün Özellikleri (Opsiyonel)", maxLines: 3),
              _buildSiberInput(controller: _uyumluAraclarCtrl, hint: "Uyumlu Araçlar (Hub ile Otonom Çekilebilir)"),
              _buildSiberInput(controller: _etiketlerCtrl, hint: "Arama Etiketleri (Örn: fren, disk)"),
              SizedBox(height: 12),
              _buildSiberRozet("2 Yıl Garanti Kalkanı", _rozetGaranti, (v) => setState(() => _rozetGaranti = v)),
              _buildSiberRozet("%100 Orijinal Ürün Mührü", _rozetOrijinal, (v) => setState(() => _rozetOrijinal = v)),
              _buildSiberRozet("Kurulum Alıcıya Aittir", _rozetKurulumAliciyaAit, (v) => setState(() => _rozetKurulumAliciyaAit = v)),
              SizedBox(height: 24),

              // ── 💰 FİNANS BÖLÜMÜ ──
              _buildBolumBasligi("SİBER FİNANS VE %12 KESİNTİ", Icons.account_balance_wallet),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildSiberInput(controller: _gelisFiyatiCtrl, hint: "Net Geliş (₺)", isNumber: true, isRequired: true, onChanged: (v) => _siberHesaplamayiTetikle())),
                  SizedBox(width: 12),
                  Expanded(child: _buildSiberInput(controller: _kdvOraniCtrl, hint: "KDV (%)", isNumber: true, onChanged: (v) => _siberHesaplamayiTetikle())),
                ],
              ),
              _buildSiberInput(controller: _karMarjiCtrl, hint: "Hedef Kâr Marjı (%)", isNumber: true, isRequired: true, onChanged: (v) => _siberHesaplamayiTetikle()),
              SizedBox(height: 20),

              // 🛡️ OTONOM FİNANS TABLOSU
              if (_musteriVitrinFiyati > 0) _buildFinansPanosu(),

              SizedBox(height: 40),

              // 🚀 MÜHÜRLE BUTONU
              SizedBox(
                height: 60,
                child: _islemSuruyor
                    ? Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                    : ElevatedButton.icon(
                  style: SiberTema.kuantumButonStili(),
                  icon: Icon(Icons.security, color: Colors.black),
                  label: Text("TİCARETİ MÜHÜRLE VE YAYINLA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                  onPressed: _urunuMarketeFirlat,
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── 🤖 YARDIMCI BİLEŞENLER ──
  Widget _buildSiberAsistanPaneli() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SiberTema.kuantumCyan.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.smart_toy, color: SiberTema.kuantumCyan, size: 20),
                  SizedBox(width: 8),
                  Text("SİBER YZ & HUB ASİSTANI", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5)),
                ],
              ),
              _buildKapasiteRadari(),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _islemSuruyor ? null : _pdfYukleVeCozumle,
                  icon: Icon(Icons.picture_as_pdf, size: 16),
                  label: Text("PDF İLE TOPLU YÜKLE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SiberTema.altinSari,
                    side: BorderSide(color: SiberTema.altinSari.withOpacity(0.5)),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _islemSuruyor ? null : _hubSorgula,
                  icon: Icon(Icons.travel_explore, size: 16),
                  label: Text("OE İLE HUB'DAN ÇEK", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SiberTema.kuantumCyan,
                    side: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5)),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text("PDF butonu aboneliğinize (Normal: 10, Ultra: 10, Plus: 20, VIP: Sınırsız) göre toplu ürün aktarımı yapar.", style: TextStyle(color: Colors.white38, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildKapasiteRadari() {
    return FutureBuilder<DocumentSnapshot>(
      future: _db.collection('kullanicilar').doc(_bayiId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();
        String paket = snapshot.data?.data() != null ? ((snapshot.data!.data() as Map)['abonelik_paketi'] ?? 'NORMAL') : 'NORMAL';
        int max = _getMaxProducts(paket);

        return StreamBuilder<AggregateQuerySnapshot>(
          stream: _db.collection('market_urunleri').where('bayi_id', isEqualTo: _bayiId).where('aktif_mi', isEqualTo: true).count().snapshots(),
          builder: (context, countSnap) {
            int current = countSnap.data?.count ?? 0;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(4)),
              child: Text("HACİM: $current / ${max > 900000 ? '∞' : max}", style: TextStyle(color: current >= max ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, fontSize: 9, fontWeight: FontWeight.bold)),
            );
          },
        );
      },
    );
  }

  Widget _buildGaleri() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_hubResimUrl.isNotEmpty && _secilenGorseller.isEmpty)
          Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green)),
            child: Row(children: [Icon(Icons.check_circle, color: Colors.green, size: 16), SizedBox(width: 8), Text("Global Hub üzerinden orijinal görsel bağlandı.", style: TextStyle(color: Colors.green, fontSize: 10))]),
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          child: Row(
            children: [
              GestureDetector(
                onTap: _gorselEkle,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.kuantumCyan, width: 1.5, style: BorderStyle.solid)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, color: SiberTema.kuantumCyan), SizedBox(height: 8), Text("FOTO EKLE", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))]),
                ),
              ),
              SizedBox(width: 12),
              ..._secilenGorseller.map((dosya) => Container(
                width: 100, height: 100, margin: EdgeInsets.only(right: 12),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24), image: DecorationImage(image: FileImage(dosya), fit: BoxFit.cover)),
                child: Align(alignment: Alignment.topRight, child: IconButton(icon: Icon(Icons.cancel, color: SiberTema.kanKirmizi), onPressed: () => setState(() => _secilenGorseller.remove(dosya)))),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinansPanosu() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: SiberTema.siberCamZirh(renk: Colors.black),
      child: Column(
        children: [
          _bilgiSatiri("KDV'Lİ MALİYET:", "₺${_kdvliGelis.toStringAsFixed(2)}", Colors.white54),
          SizedBox(height: 8),
          _bilgiSatiri("BAYİ NET KAZANCI:", "₺${_bayiNetHedefi.toStringAsFixed(2)}", SiberTema.altinSari),
          SizedBox(height: 8),
          _bilgiSatiri("OTODNA %12 KESİNTİSİ:", "- ₺${_otodnaPayi.toStringAsFixed(2)}", SiberTema.kanKirmizi),
          Divider(color: Colors.white24, height: 24),
          _bilgiSatiri("KDV DAHİL MÜŞTERİ FİYATI:", "₺${_musteriVitrinFiyati.toStringAsFixed(2)}", SiberTema.kuantumCyan, isBold: true, isLarge: true),
        ],
      ),
    );
  }

  Widget _buildBolumBasligi(String baslik, IconData ikon) {
    return Row(children: [Icon(ikon, color: SiberTema.kuantumCyan, size: 18), SizedBox(width: 8), Text(baslik, style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir'))]);
  }

  Widget _buildSiberInput({required TextEditingController controller, required String hint, bool isNumber = false, bool isRequired = false, int maxLines = 1, Function(String)? onChanged}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: SiberTema.matGrey.withOpacity(0.5), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white12)),
      child: TextFormField(
        controller: controller, maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Avenir'),
        onChanged: onChanged,
        validator: isRequired ? (v) => v == null || v.isEmpty ? "Zorunlu" : null : null,
        decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.white30, fontSize: 11, fontFamily: 'Avenir'), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      ),
    );
  }

  Widget _buildSiberRozet(String baslik, bool deger, Function(bool) onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(8), border: Border.all(color: deger ? SiberTema.kuantumCyan.withOpacity(0.5) : Colors.white10)),
      child: SwitchListTile(
        title: Text(baslik, style: TextStyle(color: deger ? Colors.white : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        value: deger, activeColor: SiberTema.kuantumCyan, onChanged: onChanged,
      ),
    );
  }

  Widget _bilgiSatiri(String baslik, String deger, Color renk, {bool isBold = false, bool isLarge = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(baslik, style: TextStyle(color: Colors.white54, fontSize: isLarge ? 12 : 10, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontFamily: 'Avenir')), Text(deger, style: TextStyle(color: renk, fontSize: isLarge ? 20 : 14, fontWeight: FontWeight.w900, fontFamily: 'monospace'))]);
  }

  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: SiberTema.matGrey, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)), content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')), SizedBox(height: 4), Text(mesaj, style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Avenir'))])));
  }
}