import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OtoMarketScreen extends StatefulWidget {
  const OtoMarketScreen({super.key});

  @override
  State<OtoMarketScreen> createState() => _OtoMarketScreenState();
}

class _OtoMarketScreenState extends State<OtoMarketScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = const Color(0xFF000000);
  final Color surfaceColor = const Color(0xFF111111);
  final Color primaryCyan = const Color(0xFF00FFC2);

  String _aramaMetni = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // =======================================================================
  // 💎 MİNİMALİST ROZET ALGORİTMASI (Firebase'den gelen puana göre)
  // =======================================================================
  Widget _buildSaticiRozeti(int puan, String saticiAdi) {
    Color rozetRengi;
    IconData ikon = Icons.star_rounded;
    String rozetMetni;

    if (puan >= 5) { rozetRengi = Colors.amber; rozetMetni = "Premium Onaylı"; }
    else if (puan == 4) { rozetRengi = Colors.grey[300]!; rozetMetni = "Güvenilir"; }
    else if (puan == 3) { rozetRengi = Colors.brown[300]!; rozetMetni = "Standart"; }
    else if (puan == 2) {
      return Row(children: [const Icon(Icons.star_border_rounded, color: Colors.white38, size: 14), const SizedBox(width: 6), Text(saticiAdi.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))]);
    }
    else {
      return Row(
        children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), border: Border.all(color: Colors.redAccent.withOpacity(0.5)), borderRadius: BorderRadius.circular(6)), child: const Row(children: [Icon(Icons.gpp_bad_outlined, color: Colors.redAccent, size: 12), SizedBox(width: 4), Text("KARA LİSTE", style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1))])),
          const SizedBox(width: 8),
          Expanded(child: Text(saticiAdi, style: TextStyle(color: Colors.redAccent.withOpacity(0.5), fontSize: 11, decoration: TextDecoration.lineThrough), overflow: TextOverflow.ellipsis)),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: rozetRengi.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: rozetRengi.withOpacity(0.3))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, color: rozetRengi, size: 14),
          const SizedBox(width: 6),
          Expanded(child: Text("$saticiAdi ($rozetMetni)".toUpperCase(), style: TextStyle(color: rozetRengi, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  // =======================================================================
  // 💎 TESLA MİMARİSİ: ŞIK ÖDEME (HAVUZ) PANELİ VE %12 KESİNTİ MOTORU
  // =======================================================================
  void _havuzOdemesiBaslat(double safFiyat, int saticiPuani) {
    if (saticiPuani <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AĞ UYARISI: Bu satıcı Kara Liste\'dedir. İşlem bloke edildi!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.redAccent));
      return;
    }

    // ACIMASIZ TİCARİ ZEKAMIZ DEVREDE
    double otodnaPayi = safFiyat * 0.10;
    double vergiPayi = safFiyat * 0.02;
    double toplamHizmetBedeli = otodnaPayi + vergiPayi;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: primaryCyan.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 32),
            Row(children: [const Icon(Icons.security_outlined, color: primaryCyan, size: 28), const SizedBox(width: 12), const Text("KUANTUM HAVUZ SİSTEMİ", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1))]),
            const SizedBox(height: 16),
            const Text("Ödemeniz hemen satıcıya aktarılmaz. Ürün size ulaşıp siz onay verene kadar OtoDNA Siber Kasasında mühürlü kalır.", style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5)),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: Column(
                children: [
                  _fiyatSatiri("Ürün Bedeli:", "${safFiyat.toStringAsFixed(2)} ₺", Colors.white),
                  const SizedBox(height: 16),
                  _fiyatSatiri("Ağ Güvenlik Payı (%10):", "+${otodnaPayi.toStringAsFixed(2)} ₺", Colors.white38),
                  const SizedBox(height: 12),
                  _fiyatSatiri("Yasal Vergi (%2):", "+${vergiPayi.toStringAsFixed(2)} ₺", Colors.white38),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.white12)),
                  _fiyatSatiri("KASADAN ÇEKİLECEK TUTAR", "${(safFiyat + toplamHizmetBedeli).toStringAsFixed(2)} ₺", primaryCyan, isBold: true, isLarge: true),
                ],
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bakiye bloke edildi. Satıcıya güvenli ağ mesajı fırlatıldı! 🚀', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan));
                },
                icon: const Icon(Icons.lock_outline, size: 20),
                label: const Text("BAKİYEYİ HAVUZA AKTAR", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _fiyatSatiri(String baslik, String deger, Color renk, {bool isBold = false, bool isLarge = false}) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: TextStyle(color: isLarge ? Colors.white54 : renk, fontSize: isLarge ? 11 : 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, letterSpacing: isLarge ? 1 : 0)),
          Text(deger, style: TextStyle(color: renk, fontSize: isLarge ? 20 : 13, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold))
        ]
    );
  }

  // =======================================================================
  // 💎 ANA İSKELET
  // =======================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('S İ B E R   P A Z A R', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // MİNİMALİST SEKMELER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white38,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5),
                tabs: const [Tab(text: "Parça Pazarı"), Tab(text: "Oto Galeri")],
              ),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildOtoMarketSekmesi(),
                _buildOtoGaleriSekmesi(),
              ],
            ),
          ),
        ],
      ),
      // İLAN VER BUTONU
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.1))),
        onPressed: _siberIlanVerDialog,
        icon: const Icon(Icons.add_a_photo_outlined, color: Colors.white, size: 20),
        label: const Text("İLAN VER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
      ),
    );
  }

  // ─── 1. SEKME: CANLI OTO MARKET (SERBEST PİYASA) ───
  Widget _buildOtoMarketSekmesi() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              _buildAiAramaKutusu(),
              const SizedBox(height: 16),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: primaryCyan.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryCyan.withOpacity(0.2))), child: Row(children: [Icon(Icons.shield_outlined, color: primaryCyan, size: 20), const SizedBox(width: 12), const Expanded(child: Text("Bireysel ve Kurumsal tüm satıcılar OtoDNA güvencesindedir.", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, height: 1.4)))]))
            ],
          ),
        ),
        Expanded(
          // 🚀 FİREBASE CANLI VERİ AKIŞI
          child: StreamBuilder<QuerySnapshot>(
            stream: _db.collection('yedek_parcalar').where('durum', isEqualTo: 'Onaylı/Satışta').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryCyan));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Siber ağda parça bulunmuyor.", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)));

              var urunler = snapshot.data!.docs.where((doc) {
                var veri = doc.data() as Map<String, dynamic>;
                String ad = (veri['urun_ad'] ?? "").toString().toLowerCase();
                return ad.contains(_aramaMetni.toLowerCase());
              }).toList();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: urunler.length,
                itemBuilder: (context, index) {
                  var veri = urunler[index].data() as Map<String, dynamic>;
                  String gercekSaticiAdi = veri['satici_adi'] ?? veri['firma_adi'] ?? "Bireysel Satıcı";
                  double fiyatDouble = (veri['toplam_fiyat'] ?? 0).toDouble();
                  int saticiPuani = (veri['satici_puani'] ?? 3).toInt(); // Firebase'den çekilen puan

                  return _buildParcaKarti(
                    baslik: veri['urun_ad'] ?? "Bilinmeyen Parça",
                    oemKodu: veri['oem_kodu'] ?? "OEM Belirtilmemiş",
                    satici: gercekSaticiAdi,
                    saticiPuani: saticiPuani,
                    fiyatDouble: fiyatDouble,
                    resimUrl: veri['resim_url'] ?? "https://via.placeholder.com/150/111111/00FFC2?text=OtoDNA",
                    isIkinciEl: veri['ikinci_el_mi'] ?? true,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── 2. SEKME: CANLI OTO GALERİ ───
  Widget _buildOtoGaleriSekmesi() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.amber.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.amber.withOpacity(0.2))), child: const Row(children: [Icon(Icons.diamond_outlined, color: Colors.amber, size: 20), SizedBox(width: 12), Expanded(child: Text("OtoDNA Onaylı (VIP) Araçlar Kuantum algoritmasıyla üstte gösterilir.", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, height: 1.4)))])),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db.collection('araclar').where('ilan_durumu', isEqualTo: 'Yayında').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryCyan));
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Siber galeride araç bulunmuyor.", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)));

              var araclar = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: araclar.length,
                itemBuilder: (context, index) {
                  var veri = araclar[index].data() as Map<String, dynamic>;
                  bool isOtoDna = (veri['dna_skoru'] ?? 0) >= 80 && !(veri['kritik_hata_var_mi'] ?? false);

                  return _buildAracIlanKarti(
                    aracAdi: "${veri['marka'] ?? ''} ${veri['model'] ?? ''}",
                    detay: "${veri['yil'] ?? '-'} Model • ${veri['km'] ?? '0'} KM",
                    fiyat: "₺${veri['fiyat'] ?? 0}",
                    dnaSkoru: (veri['dna_skoru'] ?? 0).toDouble(),
                    resimUrl: veri['resim_url'] ?? "https://via.placeholder.com/300x150/111111/00FFC2?text=OtoDNA",
                    isOtoDnaOnayli: isOtoDna,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── YARDIMCI WIDGETLAR ───
  Widget _buildAiAramaKutusu() {
    return Container(
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: TextField(
        onChanged: (deger) => setState(() => _aramaMetni = deger),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: "OEM Kodu, Şase veya Parça Ara...",
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
          suffixIcon: IconButton(icon: Icon(Icons.document_scanner_outlined, color: primaryCyan, size: 20), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("AI Lens Taraması Başlatılıyor... 📸", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan))),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildParcaKarti({required String baslik, required String oemKodu, required String satici, required int saticiPuani, required double fiyatDouble, required String resimUrl, required bool isIkinciEl}) {
    bool isKaraListe = saticiPuani <= 1;

    return Opacity(
      opacity: isKaraListe ? 0.4 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isKaraListe ? Colors.redAccent.withOpacity(0.3) : Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İlan Görseli
            Container(
              height: 180, width: double.infinity,
              decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), image: DecorationImage(image: NetworkImage(resimUrl), fit: BoxFit.cover)),
              child: isIkinciEl ? Align(alignment: Alignment.topLeft, child: Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.orangeAccent, borderRadius: BorderRadius.circular(8)), child: const Text("ÇIKMA / 2. EL", style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)))) : null,
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(baslik, style: TextStyle(color: isKaraListe ? Colors.redAccent : Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.5, decoration: isKaraListe ? TextDecoration.lineThrough : TextDecoration.none)),
                  const SizedBox(height: 8),
                  Text("OEM: $oemKodu", style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 16),
                  Text("₺${fiyatDouble.toStringAsFixed(2)}", style: TextStyle(color: isKaraListe ? Colors.redAccent.withOpacity(0.5) : primaryCyan, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1)),
                  const SizedBox(height: 20),

                  // ROZET SİSTEMİ ÇAĞRISI
                  _buildSaticiRozeti(saticiPuani, satici),

                  const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: Colors.white12)),

                  // HAVUZ VE MESAJLAŞMA BUTONLARI
                  Row(
                    children: [
                      if (!isKaraListe)
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, foregroundColor: Colors.black, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: () => _havuzOdemesiBaslat(fiyatDouble, saticiPuani),
                            icon: const Icon(Icons.shield_outlined, size: 18),
                            label: const Text("GÜVENLİ AL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          ),
                        )
                      else
                        Expanded(
                          flex: 2,
                          child: Container(padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.redAccent.withOpacity(0.3))), child: const Center(child: Text("HAVUZ GÜVENCESİ YOK", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)))),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: bgColor, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.white.withOpacity(0.1)))),
                          onPressed: () {
                            if (isKaraListe) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uçtan Uca Şifreli Mesaj Kanalı Açılıyor...')));
                          },
                          child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAracIlanKarti({required String aracAdi, required String detay, required String fiyat, required double dnaSkoru, required String resimUrl, required bool isOtoDnaOnayli}) {
    Color dnaRengi = dnaSkoru >= 80 ? primaryCyan : (dnaSkoru >= 50 ? Colors.orangeAccent : Colors.redAccent);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(32), border: Border.all(color: isOtoDnaOnayli ? primaryCyan.withOpacity(0.5) : Colors.white.withOpacity(0.05)), boxShadow: isOtoDnaOnayli ? [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 30)] : []),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(height: 200, decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), image: DecorationImage(image: NetworkImage(resimUrl), fit: BoxFit.cover))),
              if (isOtoDnaOnayli)
                Positioned(top: 16, left: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: bgColor.withOpacity(0.9), borderRadius: BorderRadius.circular(12), border: Border.all(color: primaryCyan.withOpacity(0.5))), child: Row(children: [Icon(Icons.qr_code_scanner_outlined, color: primaryCyan, size: 16), const SizedBox(width: 8), Text("OtoDNA ONAYLI", style: TextStyle(color: primaryCyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1))]))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(aracAdi, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5), overflow: TextOverflow.ellipsis, maxLines: 2)),
                    const SizedBox(width: 16),
                    Text(fiyat, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -1)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(detay, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: Colors.white12)),
                Row(
                  children: [
                    Text("SİBER GENETİK SKORU", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    const Spacer(),
                    Text("%${dnaSkoru.toInt()}", style: TextStyle(color: dnaRengi, fontSize: 20, fontWeight: FontWeight.w900, shadows: [BoxShadow(color: dnaRengi.withOpacity(0.5), blurRadius: 10)])),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: dnaSkoru / 100, minHeight: 6, backgroundColor: Colors.white.withOpacity(0.05), color: dnaRengi)),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _siberIlanVerDialog() {
    showModalBottomSheet(
      context: context, backgroundColor: surfaceColor, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("SİBER İLAN TERMİNALİ", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)), IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(ctx))]),
              const SizedBox(height: 24),
              _buildIlanSecenekKarti("Yedek Parça & Aksesuar", "Bireysel ve kurumsal serbest piyasa ilanı oluşturun.", Icons.settings_outlined, primaryCyan, ctx),
              const SizedBox(height: 16),
              _buildIlanSecenekKarti("Otomobil & Taşıt (Galeri)", "OtoDNA kalkanlı araçlarınızı siber ağa mühürleyin.", Icons.directions_car_outlined, Colors.amber, ctx),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIlanSecenekKarti(String baslik, String altBaslik, IconData ikon, Color renk, BuildContext ctx) {
    return GestureDetector(
      onTap: () => Navigator.pop(ctx),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: renk.withOpacity(0.3))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: renk.withOpacity(0.1), shape: BoxShape.circle), child: Icon(ikon, color: renk, size: 24)),
            const SizedBox(width: 20),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(baslik, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(altBaslik, style: const TextStyle(color: Colors.white54, fontSize: 11, height: 1.4))])),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16)
          ],
        ),
      ),
    );
  }
}