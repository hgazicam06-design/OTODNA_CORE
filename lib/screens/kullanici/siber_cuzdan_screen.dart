// lib/screens/siber_cuzdan_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class SiberCuzdanScreen extends StatefulWidget {
  const SiberCuzdanScreen({super.key});

  @override
  State<SiberCuzdanScreen> createState() => _SiberCuzdanScreenState();
}

class _SiberCuzdanScreenState extends State<SiberCuzdanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // İleride Firebase'den çekilecek tanımlı IBAN
  final String _aktifIban = "TR12 0006 4000 0001 2345 6789 00";

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

  void _ibanKopyala() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("IBAN Kuantum Panoya Kopyalandı! 📋", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.bold)), backgroundColor: SiberTema.kuantumCyan, duration: Duration(seconds: 1)));
  }

  // 💎 GERÇEK FİREBASE BAKİYE YÜKLEME (WriteBatch/Increment)
  Future<void> _paraYukleTest() async {
    if (_currentUser == null) return;
    try {
      await _db.collection('kullanicilar').doc(_currentUser!.uid).update({
        'cuzdan_bakiye': FieldValue.increment(5000.0) // 5000 TL Yükle
      });

      // İşlem geçmişine yaz
      await _db.collection('cuzdan_islemleri').add({
        'kullanici_id': _currentUser!.uid,
        'baslik': 'Dış Ağdan Kredi Kartı Yüklemesi',
        'tur': 'gelir',
        'brut': 5000.0, // Brüt Tutar
        'tarih': FieldValue.serverTimestamp(),
        'ikon_tipi': 'cuzdan'
      });

      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("5000 ₺ Kuantum Ağına Mühürlendi! 💸", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.bold)), backgroundColor: Colors.greenAccent));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e", style: const TextStyle(color: Colors.white)), backgroundColor: SiberTema.kanKirmizi));
    }
  }

  void _paraTransferiAc() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("EFT/FAST Transfer Ağı Başlatılıyor... 💸", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.blueAccent));
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) return const Scaffold(backgroundColor: SiberTema.oledBlack, body: Center(child: Text("Siber Kimlik Hatası", style: TextStyle(color: Colors.white))));

    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: Colors.transparent, // OLED Siyah
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text("D İ J İ T A L   C Ü Z D A N", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 3)),
          centerTitle: true,
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: _db.collection('kullanicilar').doc(_currentUser!.uid).snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));

              double anlikBakiye = 0.0;
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                anlikBakiye = (userSnapshot.data!.get('cuzdan_bakiye') ?? 0.0).toDouble();
              }

              return Column(
                children: [
                  // MİNİMALİST SEKMELER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white12)),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.15), borderRadius: BorderRadius.circular(24), border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5))),
                        labelColor: SiberTema.kuantumCyan,
                        unselectedLabelColor: Colors.white38,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                        tabs: const [Tab(text: "Bakiye & Özet"), Tab(text: "Ağ Muhasebesi")],
                      ),
                    ),
                  ),

                  // 💎 İŞLEMLERİ CANLI DİNLEYEN STREAM
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: _db.collection('cuzdan_islemleri').where('kullanici_id', isEqualTo: _currentUser!.uid).orderBy('tarih', descending: true).snapshots(),
                        builder: (context, islemSnapshot) {
                          if (islemSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));

                          List<DocumentSnapshot> islemler = islemSnapshot.hasData ? islemSnapshot.data!.docs : [];

                          return TabBarView(
                            controller: _tabController,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildCuzdanOzetiSekmesi(anlikBakiye, islemler),
                              _buildMuhasebeSekmesi(islemler),
                            ],
                          );
                        }
                    ),
                  ),
                ],
              );
            }
        ),
      ),
    );
  }

  // =======================================================================
  // 1. SEKME: CÜZDAN ÖZETİ (CANLI VERİ)
  // =======================================================================
  Widget _buildCuzdanOzetiSekmesi(double bakiye, List<DocumentSnapshot> islemler) {
    final formatCurrency = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PREMİUM BAKİYE KARTI
          Container(
            width: double.infinity, padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
                color: SiberTema.oledBlack,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 1.5),
                boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.1), blurRadius: 40, spreadRadius: 5, offset: const Offset(0, 10))]
            ),
            child: Column(
              children: [
                const Text("KULLANILABİLİR SİBER BAKİYE", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 12),
                Text(formatCurrency.format(bakiye), style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1)),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text("Tanımlı Cüzdan IBAN", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text("TR12 **** **** **** **** 7890", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1))
                      ]),
                      GestureDetector(onTap: _ibanKopyala, child: const Icon(Icons.content_copy_outlined, color: SiberTema.kuantumCyan, size: 20)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),

          // HIZLI AKSİYONLAR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildHizliAksiyon(Icons.account_balance_wallet_outlined, "Para Yükle", Colors.greenAccent, _paraYukleTest)),
              const SizedBox(width: 12),
              Expanded(child: _buildHizliAksiyon(Icons.send_outlined, "Ağ Transferi", Colors.blueAccent, _paraTransferiAc)),
              const SizedBox(width: 12),
              Expanded(child: _buildHizliAksiyon(Icons.qr_code_scanner_outlined, "QR Ödeme", SiberTema.kuantumCyan, () {})),
            ],
          ),
          const SizedBox(height: 48),

          // SİBER HAREKETLER LİSTESİ
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Finansal Hareketler", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
                Text("Tümü", style: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold))
              ]
          ),
          const SizedBox(height: 20),

          if (islemler.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: Text("Siber ağda henüz bir işlem kaydınız yok.", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)))),

          ...islemler.map((doc) {
            var islem = doc.data() as Map<String, dynamic>;
            bool gelirMi = islem['tur'] == 'gelir';
            double brutTutar = (gelirMi ? islem['brut'] : islem['tutar'])?.toDouble() ?? 0.0;

            // 💰 Otonom %12 Ağ Kesintisi Görselleştirmesi
            double netTutar = gelirMi ? brutTutar * 0.88 : brutTutar;
            Color islemRengi = gelirMi ? Colors.greenAccent : SiberTema.kanKirmizi;

            String tarihMetni = "Tarih Bekleniyor";
            if (islem['tarih'] != null && islem['tarih'] is Timestamp) {
              tarihMetni = DateFormat('dd MMM yyyy • HH:mm', 'tr_TR').format((islem['tarih'] as Timestamp).toDate());
            }

            IconData ikon;
            switch(islem['ikon_tipi']) {
              case 'arac': ikon = Icons.directions_car_outlined; break;
              case 'parca': ikon = Icons.shopping_bag_outlined; break;
              case 'servis': ikon = Icons.build_circle_outlined; break;
              case 'cuzdan': ikon = Icons.account_balance_wallet_outlined; break;
              default: ikon = Icons.swap_horiz_outlined;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
              child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: islemRengi.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: islemRengi.withOpacity(0.3))),
                      child: Icon(ikon, color: islemRengi, size: 20)
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(islem['baslik'] ?? 'İşlem', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                            const SizedBox(height: 6),
                            Text(tarihMetni, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w500))
                          ]
                      )
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("${gelirMi ? '+' : '-'} ${formatCurrency.format(netTutar)}", style: TextStyle(color: islemRengi, fontSize: 14, fontWeight: FontWeight.w900)),
                        if (gelirMi) const SizedBox(height: 6),
                        if (gelirMi) Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: islemRengi.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text("NET KAZANÇ", style: TextStyle(color: islemRengi, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)))
                      ]
                  )
                ],
              ),
            );
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // =======================================================================
  // 2. SEKME: DETAYLI MUHASEBE VE %12 KESİNTİ HESAPLAMALARI
  // =======================================================================
  Widget _buildMuhasebeSekmesi(List<DocumentSnapshot> islemler) {
    final formatCurrency = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    // Gelir ve giderleri otonom olarak ayıklıyoruz
    double toplamGelir = 0.0;
    double toplamGider = 0.0;

    for (var doc in islemler) {
      var islem = doc.data() as Map<String, dynamic>;
      if (islem['tur'] == 'gelir') {
        toplamGelir += (islem['brut'] ?? 0).toDouble();
      } else if (islem['tur'] == 'gider') {
        toplamGider += (islem['tutar'] ?? 0).toDouble();
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Dinamik Gelir Tablosu", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMuhasebeKarti("BRÜT GELİR", formatCurrency.format(toplamGelir), Icons.trending_up_rounded, Colors.greenAccent)),
              const SizedBox(width: 16),
              Expanded(child: _buildMuhasebeKarti("TOPLAM GİDER", formatCurrency.format(toplamGider), Icons.trending_down_rounded, SiberTema.kanKirmizi)),
            ],
          ),
          const SizedBox(height: 40),

          // 💎 OTO-DNA ACIMASIZ TİCARET MOTORU EKRANI
          const Text("Sistem Kesintileri & Vergilendirme", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(24), border: Border.all(color: SiberTema.altinSari.withOpacity(0.3))),
            child: Column(
              children: [
                _fiyatSatiri("Platform Hizmet Bedeli (%10)", "- ${formatCurrency.format(toplamGelir * 0.10)}", SiberTema.altinSari),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white12)),
                _fiyatSatiri("Yasal Vergi Kesintisi (%2)", "- ${formatCurrency.format(toplamGelir * 0.02)}", SiberTema.altinSari),
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white24, thickness: 1)),
                _fiyatSatiri("Toplam Ağ Kesintisi (%12)", "- ${formatCurrency.format(toplamGelir * 0.12)}", SiberTema.kanKirmizi, isBold: true),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // NET KAZANÇ ALANI
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 1.5)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.account_balance_outlined, color: SiberTema.kuantumCyan, size: 28),
                      SizedBox(height: 12),
                      Text("Kuantum Net Kazanç", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))
                    ]
                ),
                Text(formatCurrency.format((toplamGelir * 0.88) - toplamGider), style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1)),
              ],
            ),
          ),
          const SizedBox(height: 48),

          const Text("Tanımlı IBAN Hesapları", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 16),
          _buildIbanKarti("Garanti BBVA - Ticari", _aktifIban, true),
          const SizedBox(height: 12),
          _buildIbanKarti("Ziraat Bankası - Şahıs", "TR99 0001 0000 0001 1111 2222 33", false),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity, height: 56,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(side: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Biyometrik Onay İsteniyor...", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.bold)), backgroundColor: SiberTema.kuantumCyan)),
              icon: const Icon(Icons.add, color: SiberTema.kuantumCyan, size: 20),
              label: const Text("YENİ IBAN EKLE", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 💎 YARDIMCI BİLEŞENLER
  // -------------------------------------------------------------------------
  Widget _buildHizliAksiyon(IconData ikon, String baslik, Color renk, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
        child: Column(
            children: [
              Icon(ikon, color: renk, size: 24),
              const SizedBox(height: 12),
              Text(baslik, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold))
            ]
        ),
      ),
    );
  }

  Widget _buildMuhasebeKarti(String baslik, String deger, IconData ikon, Color renk) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(ikon, color: renk, size: 24),
            const SizedBox(height: 16),
            Text(baslik, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 8),
            Text(deger, style: TextStyle(color: renk, fontSize: 16, fontWeight: FontWeight.w900))
          ]
      ),
    );
  }

  Widget _buildIbanKarti(String banka, String iban, bool aktif) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: aktif ? SiberTema.kuantumCyan.withOpacity(0.05) : SiberTema.matGrey, borderRadius: BorderRadius.circular(20), border: Border.all(color: aktif ? SiberTema.kuantumCyan.withOpacity(0.5) : Colors.white12)),
      child: Row(
        children: [
          Icon(Icons.account_balance_outlined, color: aktif ? SiberTema.kuantumCyan : Colors.white38, size: 24),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(banka, style: TextStyle(color: aktif ? SiberTema.kuantumCyan : Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(iban, style: TextStyle(color: aktif ? Colors.white70 : Colors.white38, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold))
                  ]
              )
          ),
          if (aktif) const Icon(Icons.check_circle, color: SiberTema.kuantumCyan, size: 20),
        ],
      ),
    );
  }

  Widget _fiyatSatiri(String baslik, String deger, Color renk, {bool isBold = false}) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: TextStyle(color: Colors.white70, fontSize: isBold ? 12 : 11, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(deger, style: TextStyle(color: renk, fontSize: isBold ? 16 : 13, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold))
        ]
    );
  }
}