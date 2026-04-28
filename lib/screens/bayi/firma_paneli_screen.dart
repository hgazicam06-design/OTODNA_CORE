import 'package:otodna/core/siber_tema.dart';
// lib/bayi/firma_paneli_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI VE TERMİNALLERE BAĞLANTI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../core/siber_yetki_kalkani.dart';
import '../screens/urun_ekleme_formu.dart';

// Kendi dosyalarına göre burayı yönetebilirsin
import 'bayi_veri_giris_screen.dart';
import 'b2b_imece_agi_screen.dart';

class FirmaPaneliScreen extends StatefulWidget {
  FirmaPaneliScreen({super.key});

  @override
  State<FirmaPaneliScreen> createState() => _FirmaPaneliScreenState();
}

class _FirmaPaneliScreenState extends State<FirmaPaneliScreen> with SingleTickerProviderStateMixin {
  late AnimationController _sosTitresimController;
  int _seciliSekme = 0;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Kırmızı Alarm Titreşim Motoru (S.O.S için)
    _sosTitresimController = AnimationController(vsync: this, duration: Duration(milliseconds: 800))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sosTitresimController.dispose();
    super.dispose();
  }

  void _siberUyari(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // =======================================================================
  // 🚀 MEGA MARKET: İLAN TÜRÜ SEÇİMİ POP-UP (Kabloları Bağlandı)
  // =======================================================================
  void _ilanEklemeMenusu(String bayiId, String firmaAdi) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.vertical(top: Radius.circular(32)), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: SiberTema.textMuted, borderRadius: BorderRadius.circular(10)))),
            SizedBox(height: 32),
            Text("Yeni İlan & Ürün", style: TextStyle(color: SiberTema.textMain, fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
            SizedBox(height: 12),
            Text("OtoDNA Mega Market'e ne eklemek istiyorsunuz?", style: TextStyle(color: SiberTema.textMuted, fontSize: 13)),
            SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: _buildIlanSecimButonu(Icons.directions_car_outlined, "Otomobil İlanı", "2. El veya Sıfır", Colors.white, () {
                  Navigator.pop(context);
                  _siberUyari('Otomobil İlan Terminali Yakında Aktif Olacak...');
                })),
                SizedBox(width: 16),
                // 🚀 OTONOM ÜRÜN FIRLATMA MERKEZİNE BAĞLANDI
                Expanded(child: _buildIlanSecimButonu(Icons.settings_outlined, "Yedek Parça", "OEM / Aksesuar", SiberTema.kuantumCyan, () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SiberUrunEklemeFormu(bayiId: bayiId, bayiAdi: firmaAdi)));
                })),
              ],
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildIlanSecimButonu(IconData ikon, String baslik, String altBaslik, Color renk, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(color: SiberTema.oledBlack, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Column(
          children: [
            Icon(ikon, color: renk, size: 36),
            SizedBox(height: 16),
            Text(baslik, textAlign: TextAlign.center, style: TextStyle(color: renk, fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(altBaslik, style: TextStyle(color: SiberTema.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(backgroundColor: SiberTema.oledBlack, body: Center(child: Text("Siber Kimlik Bulunamadı!", style: TextStyle(color: SiberTema.textMuted))));
    }

    // 🛡️ TAAHÜT ETTİĞİMİZ SİBER ZIRH EKLENDİ
    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Kalkan siyaha boyar
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 18), onPressed: () => Navigator.pop(context)),
          title: Text("Firma Terminali", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 4)),
          centerTitle: true,
          actions: [IconButton(icon: Icon(Icons.settings_outlined, color: SiberTema.textMuted, size: 20), onPressed: () {})],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          // 📡 1. KUANTUM RADARI: Ustanın kendi profilini canlı dinle!
            stream: _db.collection('kullanicilar').doc(_currentUser!.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 2));
              if (!snapshot.hasData || !snapshot.data!.exists) return Center(child: Text("Firma Verisi Bekleniyor...", style: TextStyle(color: SiberTema.textMuted)));

              var bayiData = snapshot.data!.data() as Map<String, dynamic>;
              String firmaAdi = bayiData['firma_adi'] ?? "OtoDNA Yetkili Bayi";
              String rozet = bayiData['vip_mi'] == true ? "VIP Rozetli Bayi" : "Yetkili Bayi";
              double aylikCiro = (bayiData['aylik_ciro'] ?? 0).toDouble();

              // 💰 FİNANS VE KOMİSYON MOTORU
              double komisyonOrani = firmaAdi.toUpperCase().contains("MURAT PLAZA") ? 0.30 : 0.12;
              double otodnaKesintisi = aylikCiro * komisyonOrani;
              double netHakedis = aylikCiro - otodnaKesintisi;

              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =================================================================
                    // 1. FİRMA PROFİLİ VE ROZET SİSTEMİ
                    // =================================================================
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.altinSari.withOpacity(0.3))),
                      child: Row(
                        children: [
                          Icon(Icons.storefront_outlined, color: SiberTema.altinSari, size: 36),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(firmaAdi.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: SiberTema.textMain, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.stars_outlined, color: SiberTema.altinSari, size: 14),
                                    SizedBox(width: 4),
                                    Text(rozet, style: TextStyle(color: SiberTema.altinSari, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 32),

                    // =================================================================
                    // 2. ACİL S.O.S RADARI (CANLI FİREBASE SORGUSU)
                    // =================================================================
                    StreamBuilder<QuerySnapshot>(
                      stream: _db.collection('sos_sinyalleri').where('hedef_bayi_1', isEqualTo: _currentUser!.uid).where('durum', isEqualTo: 'YENI_SINYAL').limit(1).snapshots(),
                      builder: (context, sosSnapshot) {
                        if (!sosSnapshot.hasData || sosSnapshot.data!.docs.isEmpty) return SizedBox.shrink();

                        return AnimatedBuilder(
                          animation: _sosTitresimController,
                          builder: (context, child) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 32),
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: SiberTema.kanKirmizi.withOpacity(0.05 + (_sosTitresimController.value * 0.05)),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.5))
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.warning_amber_rounded, color: SiberTema.kanKirmizi, size: 24),
                                      SizedBox(width: 12),
                                      Text("BÖLGENİZDE ACİL S.O.S ÇAĞRISI!", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Text("Yakınınızda bir araç yol yardımı talep ediyor. 30 dakika içinde müdahale edilmezse puanınız düşürülecektir.", style: TextStyle(color: SiberTema.textMuted, fontSize: 12, height: 1.5)),
                                  SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity, height: 48,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kanKirmizi, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                      onPressed: () {
                                        String sosId = sosSnapshot.data!.docs.first.id;
                                        WriteBatch batch = _db.batch();
                                        
                                        // 1. Sinyali Güncelle
                                        batch.update(_db.collection('sos_sinyalleri').doc(sosId), {
                                          'durum': 'MÜDAHALE BAŞLADI',
                                          'mudahale_eden_id': _currentUser!.uid,
                                        });

                                        // 2. Siber İstihbarat Logu
                                        batch.set(_db.collection('siber_istihbarat_loglari').doc(), {
                                          'kategori': 'GÜVENLİK',
                                          'seviye': 'BİLGİ',
                                          'mesaj': 'S.O.S KABUL EDİLDİ: Firma ($firmaAdi) acil durum çağrısına müdahale başlattı!',
                                          'hedef_id': sosId,
                                          'tarih': FieldValue.serverTimestamp(),
                                        });
                                        
                                        batch.commit();
                                        _siberUyari("S.O.S Çağrısı Kabul Edildi. Navigasyon Başlatılıyor...");
                                      },
                                      child: Text("MÜDAHALE ET", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5)),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // =================================================================
                    // 3. İSTATİSTİKLER VE FİNANSAL ÖZET
                    // =================================================================
                    Row(
                      children: [
                        Expanded(child: _buildStatBox("Ciro (Aylık)", "₺${(aylikCiro/1000).toStringAsFixed(1)}K", Icons.account_balance_wallet_outlined, SiberTema.matGrey)),
                        SizedBox(width: 12),
                        Expanded(child: _buildStatBox("Aktif İlan", "Canlı", Icons.list_alt_outlined, SiberTema.matGrey)),
                        SizedBox(width: 12),
                        Expanded(child: _buildStatBox("Puan", "${bayiData['puan'] ?? 5.0}", Icons.star_border, SiberTema.matGrey)),
                      ],
                    ),
                    SizedBox(height: 32),

                    Text("Siber Finans Merkezi", style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
                      child: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Toplam İşlem Hacmi", style: TextStyle(color: SiberTema.textMuted, fontSize: 13)), Text("₺${aylikCiro.toStringAsFixed(2)}", style: TextStyle(color: SiberTema.textMain, fontSize: 15, fontWeight: FontWeight.bold))]),
                          Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: SiberTema.textMuted, height: 1)),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("OtoDNA Payı (%${(komisyonOrani * 100).toInt()})", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 13)), Text("-₺${otodnaKesintisi.toStringAsFixed(2)}", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 15, fontWeight: FontWeight.bold))]),
                          Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: SiberTema.textMuted, height: 1)),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Net Hakediş", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.bold)), Text("₺${netHakedis.toStringAsFixed(2)}", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 20, fontWeight: FontWeight.bold))]),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),

                    // =================================================================
                    // 4. B2B, EKSPERTİZ VE MEGA MARKET BUTONLARI
                    // =================================================================
                    Text("Operasyon Merkezi", style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    SizedBox(height: 16),

                    // Flaş Kampanya Butonu
                    _buildGeniIslemButonu("Flaş Kampanya Oluştur", "Seçili araç veya parçalarda 24 saatlik indirim tanımlayın.", Icons.bolt_outlined, SiberTema.kuantumCyan, SiberTema.kuantumCyan.withOpacity(0.05), () {
                      _siberUyari("Kampanya Motoru Başlatılıyor...");
                    }),
                    SizedBox(height: 16),

                    // Yeni İlan Ekleme Butonu (Menüyü Açar) - KALKANLA KORUNUYOR
                    SiberYetkiKalkani(
                      islemTuru: SiberYetki.ilanVer,
                      isButtonMode: true,
                      child: _buildGeniIslemButonu("Yeni İlan / Ürün Ekle", "Araç, OEM Parça veya Aksesuar ekleyin.", Icons.add_circle_outline, Colors.white, SiberTema.matGrey, () => _ilanEklemeMenusu(_currentUser!.uid, firmaAdi)),
                    ),
                    SizedBox(height: 16),

                    // B2B ve Ekspertiz (Grid)
                    Row(
                      children: [
                        Expanded(child: _buildKutuIslemKarti("Ekspertiz\nTerminali", Icons.precision_manufacturing_outlined, SiberTema.matGrey, () => Navigator.push(context, MaterialPageRoute(builder: (context) => BayiVeriGirisScreen())))),
                        SizedBox(width: 16),
                        Expanded(child: _buildKutuIslemKarti("B2B İmece\nAğı", Icons.handshake_outlined, SiberTema.matGrey, () => Navigator.push(context, MaterialPageRoute(builder: (context) => B2bImeceAgiScreen())))),
                      ],
                    ),
                    SizedBox(height: 40),

                    // =================================================================
                    // 🚀 GERÇEK ZAMANLI MEGA MARKET ENVANTERİ (FİREBASE)
                    // =================================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Envanter & İlanlar", style: TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
                        Text("Canlı Veri", style: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 16),

                    StreamBuilder<QuerySnapshot>(
                        stream: _db.collection('market_urunleri').where('asil_satici_id', isEqualTo: _currentUser!.uid).snapshots(),
                        builder: (context, urunSnapshot) {
                          if (urunSnapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
                          if (!urunSnapshot.hasData || urunSnapshot.data!.docs.isEmpty) {
                            return Container(
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.textMuted)),
                              child: Center(child: Text("Siber Vitrininde henüz ürün yok. Hemen ilan ekle!", style: TextStyle(color: SiberTema.textMuted))),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true, physics: NeverScrollableScrollPhysics(),
                            itemCount: urunSnapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var urun = urunSnapshot.data!.docs[index].data() as Map<String, dynamic>;
                              return Container(
                                margin: EdgeInsets.only(bottom: 12), padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
                                child: Row(
                                  children: [
                                    Icon(Icons.settings_outlined, color: SiberTema.kuantumCyan, size: 28),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(urun['ad'] ?? "Bilinmeyen Ürün", style: TextStyle(color: SiberTema.textMain, fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                          SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Text("₺${urun['fiyat']}", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 13, fontWeight: FontWeight.bold)),
                                              SizedBox(width: 12),
                                              Text("• Matriks Onaylı", style: TextStyle(color: SiberTema.textMuted, fontSize: 11)),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.edit_outlined, color: SiberTema.textMuted, size: 20),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              );
            }
        ),

        // ALT MENÜ (Sade ve İnce)
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: SiberTema.oledBlack, type: BottomNavigationBarType.fixed, elevation: 0,
          selectedItemColor: SiberTema.kuantumCyan, unselectedItemColor: Colors.white24,
          selectedFontSize: 11, unselectedFontSize: 11,
          currentIndex: _seciliSekme,
          onTap: (index) => setState(() => _seciliSekme = index),
          items: [
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.dashboard_outlined)), label: "Panel"),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.inventory_2_outlined)), label: "Envanter"),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.campaign_outlined)), label: "Kampanyalar"),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.chat_bubble_outline)), label: "Müşteriler"),
          ],
        ),
      ),
    );
  }

  // YARDIMCI WIDGETLAR
  Widget _buildStatBox(String baslik, String deger, IconData ikon, Color cardColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(ikon, color: SiberTema.textMuted, size: 24),
          SizedBox(height: 12),
          Text(deger, style: TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(baslik, style: TextStyle(color: SiberTema.textMuted, fontSize: 10, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildGeniIslemButonu(String baslik, String altBaslik, IconData ikon, Color renk, Color arkaPlan, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, padding: EdgeInsets.all(24),
        decoration: BoxDecoration(color: arkaPlan, borderRadius: BorderRadius.circular(16), border: Border.all(color: renk.withOpacity(0.2))),
        child: Row(
          children: [
            Icon(ikon, color: renk, size: 28),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(baslik, style: TextStyle(color: renk, fontSize: 15, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(altBaslik, style: TextStyle(color: renk.withOpacity(0.7), fontSize: 11, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKutuIslemKarti(String baslik, IconData ikon, Color cardColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Column(
          children: [
            Icon(ikon, color: SiberTema.textMuted, size: 28),
            SizedBox(height: 12),
            Text(baslik, textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
// ── DOSYA SONU MÜHRÜ ──