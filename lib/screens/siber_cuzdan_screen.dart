import 'package:otodna/core/siber_tema.dart';
// lib/screens/siber_cuzdan_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../core/responsive_kalkan.dart';

class SiberCuzdanScreen extends StatefulWidget {
  SiberCuzdanScreen({super.key});

  @override
  State<SiberCuzdanScreen> createState() => _SiberCuzdanScreenState();
}

class _SiberCuzdanScreenState extends State<SiberCuzdanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // İleride Firebase'den çekilecek tanımlı IBAN
  final String _aktifIban = "TR12 0006 4000 0001 2345 6789 00";

  final Color primaryTeal = Colors.teal.shade700;
  final Color textColor = Color(0xFF1E293B);
  final Color bgColor = Color(0xFFFAFAFC);
  final Color surfaceColor = Colors.white;
  final Color dangerColor = Colors.redAccent;
  final Color successColor = Colors.green;
  final Color warningColor = Colors.orange;

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
    _plazaUyariGoster("KOPYALANDI", "IBAN panoya kopyalandı.", primaryTeal);
  }

  Future<void> _paraYukleTest() async {
    if (_currentUser == null) return;
    try {
      await _db.collection('kullanicilar').doc(_currentUser!.uid).update({
        'cuzdan_bakiye': FieldValue.increment(5000.0)
      });

      await _db.collection('cuzdan_islemleri').add({
        'kullanici_id': _currentUser!.uid,
        'baslik': 'Kredi Kartı Yüklemesi',
        'tur': 'gelir',
        'brut': 5000.0,
        'tarih': FieldValue.serverTimestamp(),
        'ikon_tipi': 'cuzdan'
      });

      if(!mounted) return;
      _plazaUyariGoster("YÜKLEME BAŞARILI", "5000 ₺ cüzdanınıza eklendi.", successColor);
    } catch (e) {
      _plazaUyariGoster("YÜKLEME HATASI", e.toString().replaceAll("Exception: ", ""), dangerColor);
    }
  }

  void _paraTransferiAc() {
    _plazaUyariGoster("TRANSFER", "EFT/FAST modülü başlatılıyor...", Colors.blueAccent);
  }

  void _plazaUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            SizedBox(height: 4),
            Text(mesaj, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) return Scaffold(backgroundColor: bgColor, body: Center(child: Text("Kullanıcı Hatası", style: TextStyle(color: textColor, fontFamily: 'Avenir'))));

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => Navigator.pop(context)),
          title: Text("D İ J İ T A L   C Ü Z D A N", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: _db.collection('kullanicilar').doc(_currentUser!.uid).snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryTeal));

              double anlikBakiye = 0.0;
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                anlikBakiye = (userSnapshot.data!.get('cuzdan_bakiye') ?? 0.0).toDouble();
              }

              return Column(
                children: [
                  // MİNİMALİST SEKMELER
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Container(
                      height: 52,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.03), borderRadius: BorderRadius.circular(26)),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.05), blurRadius: 5, offset: Offset(0, 2))]),
                        labelColor: primaryTeal,
                        unselectedLabelColor: Colors.black45,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5, fontFamily: 'Avenir'),
                        tabs: [Tab(text: "Bakiye & Özet"), Tab(text: "Finansal Analiz")],
                      ),
                    ),
                  ),

                  // 💎 İŞLEMLERİ CANLI DİNLEYEN STREAM
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: _db.collection('cuzdan_islemleri').where('kullanici_id', isEqualTo: _currentUser!.uid).orderBy('tarih', descending: true).snapshots(),
                        builder: (context, islemSnapshot) {
                          if (islemSnapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryTeal));

                          List<DocumentSnapshot> islemler = islemSnapshot.hasData ? islemSnapshot.data!.docs : [];

                          return TabBarView(
                            controller: _tabController,
                            physics: BouncingScrollPhysics(),
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
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PREMİUM BAKİYE KARTI
          Container(
            width: double.infinity, padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
                color: primaryTeal,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.2), blurRadius: 20, offset: Offset(0, 10))],
                gradient: LinearGradient(colors: [primaryTeal, Colors.teal.shade500], begin: Alignment.topLeft, end: Alignment.bottomRight)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("KULLANILABİLİR BAKİYE", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                SizedBox(height: 12),
                Text(formatCurrency.format(bakiye), style: TextStyle(color: SiberTema.textMain, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1, fontFamily: 'Avenir')),
                SizedBox(height: 32),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("Tanımlı Cüzdan IBAN", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                        SizedBox(height: 6),
                        Text("TR12 **** **** **** **** 7890", style: TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'monospace'))
                      ]),
                      GestureDetector(onTap: _ibanKopyala, child: Icon(Icons.content_copy_outlined, color: SiberTema.kuantumCyan, size: 20)),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 32),

          // HIZLI AKSİYONLAR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildHizliAksiyon(Icons.account_balance_wallet_outlined, "Para Yükle", successColor, _paraYukleTest)),
              SizedBox(width: 12),
              Expanded(child: _buildHizliAksiyon(Icons.send_outlined, "Ağ Transferi", Colors.blueAccent, _paraTransferiAc)),
              SizedBox(width: 12),
              Expanded(child: _buildHizliAksiyon(Icons.qr_code_scanner_outlined, "QR Ödeme", primaryTeal, () {})),
            ],
          ),
          SizedBox(height: 48),

          // HAREKETLER LİSTESİ
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Finansal Hareketler", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                Text("Tümü", style: TextStyle(color: primaryTeal, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))
              ]
          ),
          SizedBox(height: 20),

          if (islemler.isEmpty)
            Center(child: Padding(padding: EdgeInsets.all(32), child: Text("Henüz bir işlem kaydınız yok.", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontFamily: 'Avenir')))),

          ...islemler.map((doc) {
            var islem = doc.data() as Map<String, dynamic>;
            bool gelirMi = islem['tur'] == 'gelir';
            double brutTutar = (gelirMi ? islem['brut'] : islem['tutar'])?.toDouble() ?? 0.0;

            // 💰 Otonom %12 Ağ Kesintisi Görselleştirmesi
            double netTutar = gelirMi ? brutTutar * 0.88 : brutTutar;
            Color islemRengi = gelirMi ? successColor : dangerColor;

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
              margin: EdgeInsets.only(bottom: 12), padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10, offset: Offset(0, 4))]),
              child: Row(
                children: [
                  Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(color: islemRengi.withValues(alpha: 0.1), shape: BoxShape.circle, border: Border.all(color: islemRengi.withValues(alpha: 0.3))),
                      child: Icon(ikon, color: islemRengi, size: 20)
                  ),
                  SizedBox(width: 16),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(islem['baslik'] ?? 'İşlem', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                            SizedBox(height: 6),
                            Text(tarihMetni, style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Avenir'))
                          ]
                      )
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("${gelirMi ? '+' : '-'} ${formatCurrency.format(netTutar)}", style: TextStyle(color: islemRengi, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                        if (gelirMi) SizedBox(height: 6),
                        if (gelirMi) Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: BoxDecoration(color: islemRengi.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: Text("NET KAZANÇ", style: TextStyle(color: islemRengi, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')))
                      ]
                  )
                ],
              ),
            );
          }),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  // =======================================================================
  // 2. SEKME: DETAYLI MUHASEBE VE %12 KESİNTİ HESAPLAMALARI
  // =======================================================================
  Widget _buildMuhasebeSekmesi(List<DocumentSnapshot> islemler) {
    final formatCurrency = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

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
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Dinamik Gelir Tablosu", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMuhasebeKarti("BRÜT GELİR", formatCurrency.format(toplamGelir), Icons.trending_up_rounded, successColor)),
              SizedBox(width: 16),
              Expanded(child: _buildMuhasebeKarti("TOPLAM GİDER", formatCurrency.format(toplamGider), Icons.trending_down_rounded, dangerColor)),
            ],
          ),
          SizedBox(height: 40),

          // TİCARET MOTORU EKRANI
          Text("Sistem Kesintileri & Vergilendirme", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: warningColor.withValues(alpha: 0.3)), boxShadow: [BoxShadow(color: warningColor.withValues(alpha: 0.05), blurRadius: 15, offset: Offset(0, 5))]),
            child: Column(
              children: [
                _fiyatSatiri("Hizmet Bedeli (%10)", "- ${formatCurrency.format(toplamGelir * 0.10)}", warningColor),
                Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white.withValues(alpha: 0.05))),
                _fiyatSatiri("Yasal Vergi (%2)", "- ${formatCurrency.format(toplamGelir * 0.02)}", warningColor),
                Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white12, thickness: 1)),
                _fiyatSatiri("Toplam Kesinti (%12)", "- ${formatCurrency.format(toplamGelir * 0.12)}", dangerColor, isBold: true),
              ],
            ),
          ),
          SizedBox(height: 32),

          // NET KAZANÇ ALANI
          Container(
            width: double.infinity, padding: EdgeInsets.all(24),
            decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: primaryTeal.withValues(alpha: 0.3), width: 1.5)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.account_balance_outlined, color: primaryTeal, size: 28),
                      SizedBox(height: 12),
                      Text("Net Kazanç", style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'Avenir'))
                    ]
                ),
                Text(formatCurrency.format((toplamGelir * 0.88) - toplamGider), style: TextStyle(color: primaryTeal, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1, fontFamily: 'Avenir')),
              ],
            ),
          ),
          SizedBox(height: 48),

          Text("Tanımlı IBAN Hesapları", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
          SizedBox(height: 16),
          _buildIbanKarti("Garanti BBVA - Ticari", _aktifIban, true),
          SizedBox(height: 12),
          _buildIbanKarti("Ziraat Bankası - Şahıs", "TR99 0001 0000 0001 1111 2222 33", false),
          SizedBox(height: 32),

          SizedBox(
            width: double.infinity, height: 56,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(backgroundColor: Colors.white, side: BorderSide(color: primaryTeal.withValues(alpha: 0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: () => _plazaUyariGoster("GÜVENLİK ONAYI", "Biyometrik Onay İsteniyor...", primaryTeal),
              icon: Icon(Icons.add, color: primaryTeal, size: 20),
              label: Text("YENİ IBAN EKLE", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, fontFamily: 'Avenir')),
            ),
          ),
          SizedBox(height: 40),
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
        padding: EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10, offset: Offset(0, 5))]),
        child: Column(
            children: [
              Icon(ikon, color: renk, size: 28),
              SizedBox(height: 12),
              Text(baslik, style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, fontFamily: 'Avenir'))
            ]
        ),
      ),
    );
  }

  Widget _buildMuhasebeKarti(String baslik, String deger, IconData ikon, Color renk) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10, offset: Offset(0, 4))]),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: renk.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(ikon, color: renk, size: 20)),
            SizedBox(height: 16),
            Text(baslik, style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
            SizedBox(height: 8),
            Text(deger, style: TextStyle(color: renk, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir'))
          ]
      ),
    );
  }

  Widget _buildIbanKarti(String banka, String iban, bool aktif) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: aktif ? primaryTeal.withValues(alpha: 0.05) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: aktif ? primaryTeal.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05)), boxShadow: aktif ? [] : [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10)]),
      child: Row(
        children: [
          Icon(Icons.account_balance_outlined, color: aktif ? primaryTeal : Colors.black38, size: 24),
          SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(banka, style: TextStyle(color: aktif ? primaryTeal : textColor, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                    SizedBox(height: 6),
                    Text(iban, style: TextStyle(color: aktif ? Colors.black87 : Colors.black45, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w900, fontFamily: 'monospace'))
                  ]
              )
          ),
          if (aktif) Icon(Icons.check_circle, color: primaryTeal, size: 20),
        ],
      ),
    );
  }

  Widget _fiyatSatiri(String baslik, String deger, Color renk, {bool isBold = false}) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: TextStyle(color: textColor, fontSize: isBold ? 12 : 11, fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, fontFamily: 'Avenir')),
          Text(deger, style: TextStyle(color: renk, fontSize: isBold ? 16 : 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir'))
        ]
    );
  }
}
