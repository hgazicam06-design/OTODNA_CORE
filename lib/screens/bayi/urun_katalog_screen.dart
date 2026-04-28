import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class UrunKatalogScreen extends StatefulWidget {
  UrunKatalogScreen({super.key});

  @override
  State<UrunKatalogScreen> createState() => _UrunKatalogScreenState();
}

class _UrunKatalogScreenState extends State<UrunKatalogScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // Firebase'den Çekilecek VIP Limit Bilgileri
  bool _isVip = false;
  String _rozet = "Standart";
  int _kullanilanIlanSayisi = 0;
  bool _isLoadingLimits = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _kullaniciLimitleriniCek();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _siberUyari(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
    ));
  }

  // =========================================================================
  // 🛡️ SİBER SAAS LİMİT KONTROLÜ (PAYWALL)
  // =========================================================================
  Future<void> _kullaniciLimitleriniCek() async {
    if (_currentUser == null) return;
    try {
      var doc = await _db.collection('kullanicilar').doc(_currentUser!.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _isVip = doc.data()?['is_vip'] ?? false;
          _rozet = doc.data()?['rozet'] ?? "Standart";
          _kullanilanIlanSayisi = doc.data()?['kullanilan_ilan_sayisi'] ?? 0;
          _isLoadingLimits = false;
        });
      }
    } catch (e) {
      _siberUyari("Limitler Okunamadı!", isError: true);
    }
  }

  bool _limitDolduMu() {
    if (_isVip) return false; // VIP için sınır yok!
    return _kullanilanIlanSayisi >= 10; // Standart için 10 limit!
  }

  void _paywallGoster() {
    showDialog(
        context: context, barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.redAccent)),
          title: Row(children: [Icon(Icons.block, color: Colors.redAccent), SizedBox(width: 10), Text("LİMİT DOLDU!", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))]),
          content: Text("Standart paketinizin 10 adet ilan limitini doldurdunuz veya toplu yükleme yetkiniz yok. Sınırsız yükleme için VIP'e geçin.", style: TextStyle(color: SiberTema.textMuted)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("İPTAL", style: TextStyle(color: SiberTema.textMuted))),
            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00FFC2), foregroundColor: Colors.white), onPressed: () => Navigator.pop(context), child: Text("VIP PAKET AL", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        )
    );
  }

  // =========================================================================
  // 📥 PDF / EXCEL İLE TOPLU ÜRÜN ÇEKME (SADECE VIP!)
  // =========================================================================
  void _topluYuklemeBaslat() {
    if (!_isVip) {
      _paywallGoster();
      return;
    }

    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(color: Color(0xFF1E293B), borderRadius: BorderRadius.vertical(top: Radius.circular(24)), border: Border(top: BorderSide(color: Color(0xFF00FFC2), width: 2))),
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 28), SizedBox(width: 8), Text("PDF/Excel Yükle", style: TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.bold))]),
                Container(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Color(0xFF00FFC2).withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Text("$_rozet Paket", style: TextStyle(color: Color(0xFF00FFC2), fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
            SizedBox(height: 16),
            Text("Tedarikçi faturanızı veya parça listenizi (PDF/XLS) yükleyin. OtoDNA Yapay Zekası OEM kodlarını tarayıp görselleri HUB'dan otomatik çekecektir.\n\nMevcut Paket Limitiniz: Sınırsız Yükleme.", style: TextStyle(color: SiberTema.textMuted, fontSize: 13, height: 1.5)),
            SizedBox(height: 24),

            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _siberUyari("Dosya Seçici Açılıyor... (Test Modu)");
              },
              child: Container(
                width: double.infinity, padding: EdgeInsets.all(32),
                decoration: BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.textMuted, style: BorderStyle.solid)),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload, color: Color(0xFF00FFC2), size: 48), SizedBox(height: 12),
                    Text("Dosya Seçmek İçin Dokunun", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4), Text("PDF, XLS, CSV (Max 10MB)", style: TextStyle(color: SiberTema.textMuted, fontSize: 11)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 🛠️ TEKLİ VEYA 2. EL ÇIKMA ÜRÜN EKLEME EKRANI (FİREBASE ENTEGRE)
  // =========================================================================
  void _tekliUrunEkle(bool isIkinciEl) {
    if (_limitDolduMu()) {
      _paywallGoster();
      return;
    }

    final oemCtrl = TextEditingController();
    final adCtrl = TextEditingController();
    final fiyatCtrl = TextEditingController();
    final stokCtrl = TextEditingController();
    final hasarCtrl = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.85, padding: EdgeInsets.all(24),
                decoration: BoxDecoration(color: Color(0xFF1E293B), borderRadius: BorderRadius.vertical(top: Radius.circular(24)), border: Border(top: BorderSide(color: isIkinciEl ? Colors.orangeAccent : Color(0xFF00FFC2), width: 2))),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [Icon(isIkinciEl ? Icons.autorenew : Icons.add_box, color: isIkinciEl ? Colors.orangeAccent : Color(0xFF00FFC2), size: 28), SizedBox(width: 8), Text(isIkinciEl ? "2. El / Çıkma Parça Ekle" : "Sıfır Parça Ekle", style: TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.bold))]),
                      SizedBox(height: 20),

                      // OEM Kodu İle Hızlı Çekim
                      if (!isIkinciEl) ...[
                        Row(
                          children: [
                            Expanded(child: TextField(controller: oemCtrl, style: TextStyle(color: SiberTema.textMain), decoration: InputDecoration(hintText: 'OEM / Barkod No', hintStyle: TextStyle(color: SiberTema.textMuted), filled: true, fillColor: Color(0xFF0F172A), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none)))),
                            SizedBox(width: 8),
                            Container(padding: EdgeInsets.all(14), decoration: BoxDecoration(color: Color(0xFF00FFC2), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.qr_code_scanner, color: Color(0xFF0F172A))),
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(top: 8.0, bottom: 16.0), child: Text("Kodu girerseniz görsel ve açıklamalar Hub'dan otomatik gelir.", style: TextStyle(color: SiberTema.textMuted, fontSize: 11))),
                      ],

                      // 2. El İçin Zorunlu Fotoğraf
                      if (isIkinciEl) ...[
                        Container(width: double.infinity, padding: EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orangeAccent)), child: Column(children: [Icon(Icons.add_a_photo, color: Colors.orangeAccent, size: 36), SizedBox(height: 8), Text("Gerçek Ürün Fotoğrafı Yükle (Zorunlu)", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold))])),
                        SizedBox(height: 16),
                        TextField(controller: hasarCtrl, style: TextStyle(color: SiberTema.textMain), decoration: InputDecoration(labelText: 'Hasar / Kondisyon Durumu (Zorunlu)', labelStyle: TextStyle(color: Colors.orangeAccent), filled: true, fillColor: Color(0xFF0F172A), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))))),
                      ] else ...[
                        Container(width: double.infinity, padding: EdgeInsets.all(24), decoration: BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.textMuted)), child: Column(children: [Icon(Icons.image, color: SiberTema.textMuted, size: 36), SizedBox(height: 8), Text("Kendi Görselini Yükle (Veya Hub'a Bırak)", style: TextStyle(color: SiberTema.textMuted))])),
                      ],

                      SizedBox(height: 16),
                      TextField(controller: adCtrl, style: TextStyle(color: SiberTema.textMain), decoration: InputDecoration(hintText: 'Ürün Adı', filled: true, fillColor: Color(0xFF0F172A), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))))),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: fiyatCtrl, keyboardType: TextInputType.number, style: TextStyle(color: SiberTema.textMain), decoration: InputDecoration(hintText: 'Fiyat (TL)', filled: true, fillColor: Color(0xFF0F172A), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))))),
                          SizedBox(width: 12),
                          Expanded(child: TextField(controller: stokCtrl, keyboardType: TextInputType.number, style: TextStyle(color: SiberTema.textMain), decoration: InputDecoration(hintText: 'Stok Adedi', filled: true, fillColor: Color(0xFF0F172A), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)))))),
                        ],
                      ),
                      SizedBox(height: 24),

                      // 🚀 FİREBASE KAYIT MÜHRÜ
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: isIkinciEl ? Colors.orangeAccent : Color(0xFF00FFC2), padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              onPressed: isSaving ? null : () async {
                                if (adCtrl.text.isEmpty || fiyatCtrl.text.isEmpty) {
                                  _siberUyari("Ad ve Fiyat zorunludur!", isError: true);
                                  return;
                                }
                                setModalState(() => isSaving = true);

                                try {
                                  WriteBatch batch = _db.batch();

                                  // 1. Yedek Parçayı Ekle
                                  DocumentReference parcaRef = _db.collection('yedek_parcalar').doc();
                                  batch.set(parcaRef, {
                                    'satici_id': _currentUser!.uid,
                                    'urun_adi': adCtrl.text.trim(),
                                    'oem_kodu': oemCtrl.text.trim(),
                                    'fiyat': double.tryParse(fiyatCtrl.text.trim()) ?? 0.0,
                                    'stok': int.tryParse(stokCtrl.text.trim()) ?? 1,
                                    'is_ikinci_el': isIkinciEl,
                                    'hasar_durumu': hasarCtrl.text.trim(),
                                    'eklenme_tarihi': FieldValue.serverTimestamp(),
                                  });

                                  // 2. VIP Değilse Limit Sayacını Artır
                                  if (!_isVip) {
                                    DocumentReference userRef = _db.collection('kullanicilar').doc(_currentUser!.uid);
                                    batch.update(userRef, {'kullanilan_ilan_sayisi': FieldValue.increment(1)});
                                  }

                                  // 3. İstihbarat Logu
                                  DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
                                  batch.set(logRef, {
                                    'islem_turu': isIkinciEl ? 'IKINCI_EL_ILAN_EKLEME' : 'SIFIR_ILAN_EKLEME',
                                    'seviye': 'BİLGİ',
                                    'islem_detayi': 'SİBER KATALOG: ${_currentUser!.uid} numaralı bayi, "${adCtrl.text.trim()}" isimli yeni bir ürünü vitrine ekledi.',
                                    'bayi_id': _currentUser!.uid,
                                    'vaka_id': parcaRef.id,
                                    'tarih': FieldValue.serverTimestamp()
                                  });

                                  await batch.commit();

                                  if (mounted) {
                                    Navigator.pop(context);
                                    _siberUyari('Parça OtoDNA Marketine Yüklendi! ✅');
                                    _kullaniciLimitleriniCek(); // Limitleri arayüzde güncelle
                                  }
                                } catch (e) {
                                  setModalState(() => isSaving = false);
                                  _siberUyari('Kayıt Hatası: $e', isError: true);
                                }
                              },
                              child: isSaving
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text("OtoDNA Market'te Yayınla", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16))
                          )
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = SiberTema.oledBlack;
    const primaryCyan = SiberTema.kuantumCyan;
    const cardColor = SiberTema.matGrey;

    if (_currentUser == null) return Scaffold(backgroundColor: bgColor, body: Center(child: Text("Siber Kimlik Hatası!", style: TextStyle(color: SiberTema.kanKirmizi))));

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Katalog & Envanter', style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold)),
        centerTitle: true, iconTheme: IconThemeData(color: primaryCyan),
        bottom: TabBar(
          controller: _tabController, indicatorColor: primaryCyan, labelColor: primaryCyan, unselectedLabelColor: Colors.white54,
          tabs: [Tab(text: "Sıfır & OEM Parçalar"), Tab(text: "2. El & Çıkma Parçalar")],
        ),
      ),
      body: _isLoadingLimits
          ? Center(child: CircularProgressIndicator(color: primaryCyan))
          : Column(
        children: [
          // PAKET DURUMU (GERÇEK VERİ)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), color: cardColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Icon(_isVip ? Icons.verified : Icons.info, color: _isVip ? primaryCyan : Colors.orangeAccent, size: 20), SizedBox(width: 8), Text("Mevcut Plan: $_rozet Paket", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold))]),
                if (!_isVip)
                  GestureDetector(onTap: () {}, child: Text("$_kullanilanIlanSayisi/10 İlan | Yükselt", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)))
              ],
            ),
          ),

          // AKSİYON BUTONLARI
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: cardColor, padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.redAccent))), onPressed: _topluYuklemeBaslat, icon: Icon(Icons.picture_as_pdf, color: Colors.redAccent), label: Text("PDF Yükle (VIP)", style: TextStyle(color: SiberTema.textMain, fontSize: 13)))),
                SizedBox(width: 12),
                Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: primaryCyan.withOpacity(0.2), padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: primaryCyan))), onPressed: () => _tekliUrunEkle(false), icon: Icon(Icons.add, color: primaryCyan), label: Text("Tekli Ekle", style: TextStyle(color: primaryCyan)))),
              ],
            ),
          ),

          // TAB VIEW (Sıfır ve İkinci El CANLI Listesi)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: _db.collection('yedek_parcalar').where('satici_id', isEqualTo: _currentUser!.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryCyan));

                  var tumUrunler = snapshot.data?.docs ?? [];
                  var sifirUrunler = tumUrunler.where((doc) => doc['is_ikinci_el'] == false).toList();
                  var ikinciElUrunler = tumUrunler.where((doc) => doc['is_ikinci_el'] == true).toList();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // 1. SIFIR ÜRÜNLER EKRANI (CANLI)
                      sifirUrunler.isEmpty
                          ? Center(child: Text("Sıfır parça vitrininiz boş.", style: TextStyle(color: SiberTema.textMuted)))
                          : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: sifirUrunler.length,
                          itemBuilder: (context, index) {
                            var urun = sifirUrunler[index].data() as Map<String, dynamic>;
                            return _buildUrunKarti(urun['urun_adi'] ?? '-', "OEM: ${urun['oem_kodu'] ?? 'Belirtilmedi'}", "${urun['fiyat']} TL", true, Icons.settings_input_component);
                          }
                      ),

                      // 2. İKİNCİ EL ÜRÜNLER EKRANI (CANLI)
                      ListView(
                        padding: EdgeInsets.all(16),
                        children: [
                          Container(padding: EdgeInsets.all(12), margin: EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orangeAccent)), child: Row(children: [Icon(Icons.info_outline, color: Colors.orangeAccent), SizedBox(width: 8), Expanded(child: Text("OtoDNA Güvenlik Kuralı: 2. el ürünlerde temsil görsel kullanılamaz, ürünün güncel fotoğrafı zorunludur.", style: TextStyle(color: Colors.orangeAccent, fontSize: 11)))])),
                          SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent.withOpacity(0.2), padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.orangeAccent))), onPressed: () => _tekliUrunEkle(true), icon: Icon(Icons.add_a_photo, color: Colors.orangeAccent), label: Text("2. El Çıkma Parça Ekle", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)))),
                          SizedBox(height: 16),

                          if (ikinciElUrunler.isEmpty)
                            Padding(padding: EdgeInsets.only(top: 20), child: Center(child: Text("2. El vitrininiz boş.", style: TextStyle(color: SiberTema.textMuted))))
                          else
                            ...ikinciElUrunler.map((doc) {
                              var urun = doc.data() as Map<String, dynamic>;
                              return _buildUrunKarti(urun['urun_adi'] ?? '-', "Kondisyon: ${urun['hasar_durumu'] ?? 'Belirtilmedi'}", "${urun['fiyat']} TL", false, Icons.build_circle);
                            }),
                        ],
                      )
                    ],
                  );
                }
            ),
          )
        ],
      ),
    );
  }

  Widget _buildUrunKarti(String baslik, String altBaslik, String fiyat, bool isSifir, IconData ikon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12), padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.textMuted)),
      child: Row(
        children: [
          Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.circular(12)), child: Icon(ikon, color: isSifir ? Color(0xFF00FFC2) : Colors.orangeAccent, size: 32)),
          SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(baslik, style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 14)), SizedBox(height: 4), Text(altBaslik, style: TextStyle(color: SiberTema.textMuted, fontSize: 11)), SizedBox(height: 8), Text(fiyat, style: TextStyle(color: Color(0xFF00FFC2), fontWeight: FontWeight.bold, fontSize: 16))])),
          IconButton(icon: Icon(Icons.more_vert, color: SiberTema.textMuted), onPressed: () {})
        ],
      ),
      ),
    );
  }
}