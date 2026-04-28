import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class UlusalGarantiScreen extends StatefulWidget {
  UlusalGarantiScreen({super.key});

  @override
  State<UlusalGarantiScreen> createState() => _UlusalGarantiScreenState();
}

class _UlusalGarantiScreenState extends State<UlusalGarantiScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  String _benimFirmaAdim = "Bilinmeyen Firma";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _kimlikTespitiYap();
  }

  Future<void> _kimlikTespitiYap() async {
    if (_currentUser == null) return;
    var doc = await _db.collection('kullanicilar').doc(_currentUser!.uid).get();
    if (doc.exists && mounted) {
      setState(() {
        _benimFirmaAdim = doc.data()?['ad'] ?? "Bilinmeyen Firma";
      });
    }
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
  // ⚖️ FİRMA-FİRMA UZLAŞMA VE ADLİ SÜREÇ MOTORU (KARAR VERME)
  // =========================================================================
  void _talepInceleVeKararVer(String talepId, Map<String, dynamic> talep) {
    bool isProcessing = false;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(color: Color(0xFF1E293B), borderRadius: BorderRadius.vertical(top: Radius.circular(24)), border: Border(top: BorderSide(color: Colors.redAccent, width: 2))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Icon(Icons.gavel, color: Colors.redAccent, size: 32), SizedBox(width: 12), Text("Garanti Sorumluluk & Uzlaşma", style: TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.bold))]),
                  SizedBox(height: 16),
                  Text("Sizin onardığınız bir araç başka bir ilde arıza yapmıştır. Müşteri mağdur edilmeyecektir. Karşı bayinin tuttuğu raporu inceleyip faturayı üstlenmeniz gerekmektedir.", style: TextStyle(color: SiberTema.textMuted, fontSize: 13, height: 1.5)),
                  SizedBox(height: 24),

                  Container(
                    padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.textMuted)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [Icon(Icons.business, color: SiberTema.textMuted, size: 16), SizedBox(width: 8), Text("Raporlayan Bayi: ${talep['raporlayan_firma']}", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold))]),
                        SizedBox(height: 12),
                        Text("Sunulan Kanıtlar:", style: TextStyle(color: SiberTema.textMuted, fontSize: 12)),
                        Text(talep['kanit_raporu'] ?? 'Kanıt sisteme yüklendi.', style: TextStyle(color: Colors.orangeAccent, fontSize: 12, fontStyle: FontStyle.italic)),
                        SizedBox(height: 12),
                        Divider(color: SiberTema.textMuted),
                        SizedBox(height: 12),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Karşı Bayiye Ödenecek Tutar:", style: TextStyle(color: Color(0xFF00FFC2), fontSize: 14, fontWeight: FontWeight.bold)), Text("${talep['b2b_fatura_tutari']} TL", style: TextStyle(color: Color(0xFF00FFC2), fontSize: 16, fontWeight: FontWeight.bold))]),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.redAccent)),
                    child: Row(children: [Icon(Icons.warning, color: Colors.redAccent, size: 20), SizedBox(width: 8), Expanded(child: Text("SİSTEM UYARISI: Ödemeyi reddederseniz OtoDNA hakem heyeti devreye girer. Hata sizde bulunursa sözleşme gereği 'Adli Süreç' başlar ve sistemden men edilirsiniz.", style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)))]),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(side: BorderSide(color: SiberTema.kanKirmizi), padding: EdgeInsets.symmetric(vertical: 16)),
                          onPressed: isProcessing ? null : () async {
                            setModalState(() => isProcessing = true);
                            
                            WriteBatch batch = _db.batch();
                            batch.update(_db.collection('garanti_talepleri').doc(talepId), {'durum': 'Hakem Heyeti / Adli Süreç'});
                            batch.set(_db.collection('siber_istihbarat_loglari').doc(), {
                                'islem_turu': 'GARANTI_RED_ADLI_SUREC',
                                'seviye': 'KRİTİK',
                                'islem_detayi': 'SİBER GARANTİ: ${_currentUser!.uid} numaralı bayi, $talepId ID\'li talebi reddetti. Hakem Heyeti devrede.',
                                'vaka_id': talepId,
                                'kullanici_id': _currentUser!.uid,
                                'tarih': FieldValue.serverTimestamp()
                            });
                            await batch.commit();

                            if (mounted) {
                              Navigator.pop(context);
                              _siberUyari('Talep Reddedildi. Adli Süreç ve Hakem Heyeti İçin Admine İletildi! ⚖️🚨', isError: true);
                            }
                          },
                          icon: Icon(Icons.balance, color: SiberTema.kanKirmizi),
                          label: Text("Reddet (Adli Süreç)", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 12, fontWeight: FontWeight.bold))
                      )),
                      SizedBox(width: 12),
                      Expanded(child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kuantumCyan, padding: EdgeInsets.symmetric(vertical: 16)),
                          onPressed: isProcessing ? null : () async {
                            setModalState(() => isProcessing = true);

                            WriteBatch batch = _db.batch();
                            batch.update(_db.collection('garanti_talepleri').doc(talepId), {'durum': 'Uzlaşma Sağlandı - Ödenecek'});
                            batch.set(_db.collection('siber_istihbarat_loglari').doc(), {
                                'islem_turu': 'GARANTI_ONAY_UZLASMA',
                                'seviye': 'BİLGİ',
                                'islem_detayi': 'SİBER GARANTİ: ${_currentUser!.uid} numaralı bayi, $talepId ID\'li talebi kabul etti ve uzlaşma sağladı.',
                                'vaka_id': talepId,
                                'kullanici_id': _currentUser!.uid,
                                'tarih': FieldValue.serverTimestamp()
                            });
                            await batch.commit();

                            if (mounted) {
                              Navigator.pop(context);
                              _siberUyari('Uzlaşma Sağlandı! Tutar Karşı Firmaya Aktarılıyor. 🤝');
                            }
                          },
                          icon: isProcessing ? SizedBox(width:16, height:16, child: CircularProgressIndicator(color: Colors.white)) : Icon(Icons.handshake, color: Color(0xFF0F172A)),
                          label: Text("Kabul Et & Öde", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13))
                      )),
                    ],
                  )
                ],
              ),
            );
          }
      ),
    );
  }

  // =========================================================================
  // 📝 BAŞKA BAYİYE FATURA KESME (YENİ TALEP OLUŞTURMA) MOTORU
  // =========================================================================
  void _yeniFaturaKesModal() {
    final plakaCtrl = TextEditingController();
    final sorunCtrl = TextEditingController();
    final tutarCtrl = TextEditingController();
    String? secilenHataliFirmaId;
    String? secilenHataliFirmaAdi;
    bool isSaving = false;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(color: Color(0xFF1E293B), borderRadius: BorderRadius.vertical(top: Radius.circular(24)), border: Border(top: BorderSide(color: Color(0xFF00FFC2), width: 2))),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Rapor Oluştur & Fatura Kes", style: TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),

                      // FİRMA SEÇİMİ (FİREBASE CANLI)
                      Text("Hatalı İşlem Yapan Firma", style: TextStyle(color: SiberTema.textMuted, fontSize: 11)),
                      SizedBox(height: 4),
                      FutureBuilder<QuerySnapshot>(
                        future: _db.collection('kullanicilar').where('rol', isEqualTo: 'bayi').where('aktif_mi', isEqualTo: true).get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Color(0xFF00FFC2)));
                          var firmalar = snapshot.data!.docs.where((doc) => doc.id != _currentUser?.uid).toList();

                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.textMuted)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                dropdownColor: Color(0xFF0F172A),
                                hint: Text("Firma Seçin...", style: TextStyle(color: SiberTema.textMuted, fontSize: 13)),
                                value: secilenHataliFirmaId,
                                isExpanded: true,
                                style: TextStyle(color: SiberTema.textMain, fontSize: 13),
                                items: firmalar.map((doc) => DropdownMenuItem(value: doc.id, child: Text(doc['ad'] ?? 'İsimsiz Firma'))).toList(),
                                onChanged: (val) {
                                  setModalState(() {
                                    secilenHataliFirmaId = val;
                                    secilenHataliFirmaAdi = firmalar.firstWhere((element) => element.id == val)['ad'];
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 12),

                      TextField(controller: plakaCtrl, style: TextStyle(color: SiberTema.textMain), decoration: InputDecoration(hintText: 'Araç Plakası (Örn: 34 DNA 2026)', hintStyle: TextStyle(color: SiberTema.textMuted, fontSize: 13), filled: true, fillColor: Color(0xFF0F172A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                      SizedBox(height: 12),
                      TextField(controller: sorunCtrl, style: TextStyle(color: SiberTema.textMain), decoration: InputDecoration(hintText: 'Tespit Edilen Sorun (Örn: Triger Kopması)', hintStyle: TextStyle(color: SiberTema.textMuted, fontSize: 13), filled: true, fillColor: Color(0xFF0F172A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                      SizedBox(height: 12),
                      TextField(controller: tutarCtrl, keyboardType: TextInputType.number, style: TextStyle(color: SiberTema.textMain), decoration: InputDecoration(hintText: 'Talep Edilen Tutar (TL)', hintStyle: TextStyle(color: SiberTema.textMuted, fontSize: 13), filled: true, fillColor: Color(0xFF0F172A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),

                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00FFC2), padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: isSaving ? null : () async {
                            if (plakaCtrl.text.isEmpty || secilenHataliFirmaId == null || tutarCtrl.text.isEmpty) {
                              _siberUyari("Tüm alanları doldurmanız zorunludur!", isError: true);
                              return;
                            }
                            setModalState(() => isSaving = true);
                            try {
                              WriteBatch batch = _db.batch();
                              DocumentReference talepRef = _db.collection('garanti_talepleri').doc();
                              batch.set(talepRef, {
                                'arac': plakaPlakaFormatla(plakaCtrl.text),
                                'sorun': sorunCtrl.text.trim(),
                                'sorun_ili': 'Kendi Bölgeniz', // İleride GPS'den çekilir
                                'raporlayan_firma_id': _currentUser!.uid,
                                'raporlayan_firma': _benimFirmaAdim,
                                'hatali_firma_id': secilenHataliFirmaId,
                                'hatali_firma': secilenHataliFirmaAdi,
                                'b2b_fatura_tutari': double.tryParse(tutarCtrl.text.trim()) ?? 0.0,
                                'durum': 'Sizden Uzlaşma/Ödeme Bekleniyor',
                                'kanit_raporu': 'Sistem üzerinden rapor yüklendi.',
                                'tarih': FieldValue.serverTimestamp(),
                              });

                              batch.set(_db.collection('siber_istihbarat_loglari').doc(), {
                                'islem_turu': 'YENI_GARANTI_TALEBI',
                                'seviye': 'UYARI',
                                'islem_detayi': 'SİBER GARANTİ: $_benimFirmaAdim (${_currentUser!.uid}), $secilenHataliFirmaAdi ($secilenHataliFirmaId) firmasına ${tutarCtrl.text} TL B2B fatura talebinde bulundu.',
                                'vaka_id': talepRef.id,
                                'kullanici_id': _currentUser!.uid,
                                'tarih': FieldValue.serverTimestamp(),
                              });

                              await batch.commit();

                              if (mounted) {
                                Navigator.pop(context);
                                _siberUyari('Talep Kuantum Ağına İletildi! Karşı Bayinin Onayı Bekleniyor. ⚖️');
                              }
                            } catch (e) {
                              _siberUyari('Ağ Hatası: $e', isError: true);
                              setModalState(() => isSaving = false);
                            }
                          },
                          icon: isSaving ? SizedBox() : Icon(Icons.send, color: Color(0xFF0F172A)),
                          label: isSaving ? CircularProgressIndicator(color: Colors.white) : Text("Ağa Gönder & Talep Et", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
      ),
    );
  }

  String plakaPlakaFormatla(String plaka) => plaka.toUpperCase().replaceAll(" ", "");

  @override
  Widget build(BuildContext context) {
    const bgColor = SiberTema.oledBlack;
    const primaryCyan = SiberTema.kuantumCyan;
    const cardColor = SiberTema.matGrey;

    if (_currentUser == null) return Scaffold(backgroundColor: bgColor, body: Center(child: Text("Kimlik Hatası!")));

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
        title: Text('Ulusal Garanti & İmece Ağı', style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true, iconTheme: IconThemeData(color: primaryCyan),
        bottom: TabBar(
          controller: _tabController, indicatorColor: primaryCyan, labelColor: primaryCyan, unselectedLabelColor: Colors.white54,
          tabs: [Tab(text: "Garanti Sorumluluklarım"), Tab(text: "Diğer Bayilere Desteğim")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ===================================================================================
          // 📡 1. SEKME: BANA KESİLEN CEZALAR / FATURALAR (hatali_firma_id == BEN)
          // ===================================================================================
          StreamBuilder<QuerySnapshot>(
              stream: _db.collection('garanti_talepleri').where('hatali_firma_id', isEqualTo: _currentUser!.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: Colors.redAccent));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("Harika! Hiçbir garanti sorumluluğunuz / cezanız bulunmuyor. ✅", textAlign: TextAlign.center, style: TextStyle(color: primaryCyan)));

                var talepler = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(16), physics: BouncingScrollPhysics(), itemCount: talepler.length,
                  itemBuilder: (context, index) {
                    var talepDoc = talepler[index];
                    var talep = talepDoc.data() as Map<String, dynamic>;
                    bool isResolved = talep['durum'].toString().contains("Uzlaşma") || talep['durum'].toString().contains("Adli");

                    return Container(
                      margin: EdgeInsets.only(bottom: 16), padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isResolved ? Colors.white12 : Colors.redAccent.withOpacity(0.5), width: 2)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(isResolved ? Icons.history : Icons.gavel, color: isResolved ? Colors.white54 : Colors.redAccent, size: 16), SizedBox(width: 8), Text(talepDoc.id.substring(0, 8).toUpperCase(), style: TextStyle(color: SiberTema.textMuted, fontSize: 11))]), Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: isResolved ? Colors.white12 : Colors.redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Text(talep['durum'], style: TextStyle(color: isResolved ? Colors.white70 : Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)))]),
                          SizedBox(height: 16),
                          Text(talep['arac'], style: TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(talep['sorun'], style: TextStyle(color: Colors.orangeAccent, fontSize: 13)),
                          SizedBox(height: 12),
                          Row(children: [Icon(Icons.location_on, color: SiberTema.textMuted, size: 14), SizedBox(width: 4), Text("Yolda Kalınan Yer: ${talep['sorun_ili']}", style: TextStyle(color: SiberTema.textMuted, fontSize: 12))]),
                          SizedBox(height: 12),
                          Divider(color: SiberTema.textMuted),
                          SizedBox(height: 8),
                          Text("Raporlayan ve Destek Veren Bayi: ${talep['raporlayan_firma']}", style: TextStyle(color: SiberTema.textMuted, fontSize: 11)),
                          SizedBox(height: 12),
                          Container(width: double.infinity, padding: EdgeInsets.all(12), decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(Icons.receipt_long, color: primaryCyan, size: 18), SizedBox(width: 8), Text("Karşı Bayinin Faturası: ${talep['b2b_fatura_tutari']} TL", style: TextStyle(color: primaryCyan, fontWeight: FontWeight.bold, fontSize: 12))])),
                          SizedBox(height: 16),
                          if (!isResolved)
                            SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () => _talepInceleVeKararVer(talepDoc.id, talep), icon: Icon(Icons.balance, color: SiberTema.kuantumCyan, size: 18), label: Text("Talebi İncele ve Karar Ver", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold)))),
                        ],
                      ),
                    );
                  },
                );
              }
          ),

          // ===================================================================================
          // 📡 2. SEKME: BENİM KESTİĞİM FATURALAR (raporlayan_firma_id == BEN)
          // ===================================================================================
          ListView(
            padding: EdgeInsets.all(16), physics: BouncingScrollPhysics(),
            children: [
              Container(
                padding: EdgeInsets.all(24), decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryCyan.withOpacity(0.3), style: BorderStyle.solid)),
                child: Column(
                  children: [
                    Icon(Icons.handshake, color: primaryCyan, size: 48), SizedBox(height: 16),
                    Text("Başka Bayinin Müşterisine Destek Ver", style: TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text("Yolda kalmış ve OtoDNA garantisi devam eden bir aracı dükkanınıza aldıysanız, müşteriden ASLA ücret talep etmeyin. Raporunuzu oluşturun ve faturayı işlemi yapan asıl firmaya B2B ekranından gönderin.", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMuted, fontSize: 12)),
                    SizedBox(height: 16),
                    ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryCyan), onPressed: _yeniFaturaKesModal, child: Text("Rapor Oluştur & Fatura Kes", style: TextStyle(color: bgColor, fontWeight: FontWeight.bold)))
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text("Kestiğim Faturalar (Tahsilat Durumu)", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 12),

              // CANLI FİREBASE SORGUSU
              StreamBuilder<QuerySnapshot>(
                  stream: _db.collection('garanti_talepleri').where('raporlayan_firma_id', isEqualTo: _currentUser!.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryCyan));
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Padding(padding: EdgeInsets.only(top: 20), child: Center(child: Text("Henüz kestiğiniz bir uzlaşma faturası yok.", style: TextStyle(color: SiberTema.textMuted))));

                    var kestigimFaturalar = snapshot.data!.docs;

                    return Column(
                      children: kestigimFaturalar.map((doc) {
                        var destek = doc.data() as Map<String, dynamic>;
                        bool isApproved = destek['durum'].toString().contains("Uzlaşma");
                        bool isRejected = destek['durum'].toString().contains("Adli");

                        Color durumRengi = Colors.orangeAccent;
                        if (isApproved) durumRengi = Colors.greenAccent;
                        if (isRejected) durumRengi = Colors.redAccent;

                        return Container(
                          padding: EdgeInsets.all(16), margin: EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.textMuted)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(destek['arac'], style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold)), Icon(isApproved ? Icons.check_circle : (isRejected ? Icons.gavel : Icons.hourglass_empty), color: durumRengi, size: 16)]),
                              SizedBox(height: 8),
                              Text("Sorun: ${destek['sorun']}", style: TextStyle(color: SiberTema.textMuted, fontSize: 12)),
                              Text("Fatura Kesilen Firma: ${destek['hatali_firma']}", style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
                              SizedBox(height: 8),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${destek['b2b_fatura_tutari']} TL", style: TextStyle(color: primaryCyan, fontWeight: FontWeight.bold)), Text(destek['durum'], style: TextStyle(color: durumRengi, fontSize: 10, fontWeight: FontWeight.bold))])
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}