import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../core/otodna_hizmet_kutuphanesi.dart';
import '../core/siber_lokasyon_motoru.dart';

class UstaAramaScreen extends StatefulWidget {
  const UstaAramaScreen({super.key});

  @override
  State<UstaAramaScreen> createState() => _UstaAramaScreenState();
}

class _UstaAramaScreenState extends State<UstaAramaScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // 🎯 FİLTRELEME DURUMLARI
  String _secilenKategori = "TÜMÜ";
  String _secilenDetayFiltre = "TÜMÜ"; // Tümü, Premium, Ekonomik, En Yakın
  
  // 🌍 LOKASYON DURUMLARI (Otonom Başlangıç)
  String _seciliUlke = "Türkiye";
  String _seciliSehir = "ANKARA";
  String _seciliBolge = "İç Anadolu Bölgesi";

  void _siberUyariGoster(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(fontWeight: FontWeight.w900, color: isError ? Colors.white : SiberTema.oledBlack, letterSpacing: 1, fontFamily: 'Avenir')),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 🌍 LOKASYON DEĞİŞTİRME TERMİNALİ (BottomSheet)
  void _lokasyonTerminaliniAc() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: SiberTema.oledBlack,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2),
          ),
          child: SiberLokasyonMotoru(
            onLokasyonSecildi: (ulke, sehir, bolge) {
              setState(() {
                _seciliUlke = ulke;
                _seciliSehir = sehir;
                _seciliBolge = bolge;
              });
              Navigator.pop(context);
              _siberUyariGoster("RADAR YENİDEN HEDEFLENDİ: $sehir / $bolge", isError: false);
            },
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text("KÜRESEL USTA RADARI", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          actions: [
            IconButton(
              icon: const Icon(Icons.map_outlined, color: SiberTema.kuantumCyan),
              onPressed: () => _siberUyariGoster("SİBER HARİTA MODÜLÜ YAKINDA AKTİF EDİLECEK!"),
            )
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800), // 🖥️ Web / Double Teyp Kalkanı
                child: Column(
                  children: [
                    // =================================================================
                    // 1. SİBER LOKASYON FİLTRESİ
                    // =================================================================
                    Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: SiberTema.matGrey.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
                        boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 20)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.radar, color: SiberTema.kuantumCyan, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("AKTİF TARAMA BÖLGESİ", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                                const SizedBox(height: 4),
                                Text("$_seciliBolge / $_seciliSehir", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _lokasyonTerminaliniAc,
                            child: const Text("GENİŞLET", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                          )
                        ],
                      ),
                    ),

                    // =================================================================
                    // 2. SİBER KATEGORİ FİLTRESİ
                    // =================================================================
                    SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          _buildKategoriCipi("TÜMÜ"),
                          ...SiberHizmetKutuphanesi.anaKategorileriGetir().map((kategori) => _buildKategoriCipi(kategori)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // =================================================================
                    // 3. DETAYLI KUANTUM FİLTRELER (Premium, Ekonomik)
                    // =================================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          _buildDetayFiltreCipi("TÜMÜ", Icons.all_inclusive),
                          _buildDetayFiltreCipi("PREMIUM (5 YILDIZ)", Icons.star),
                          _buildDetayFiltreCipi("EKONOMİK", Icons.savings),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // =================================================================
                    // 4. FİREBASE USTA VE FİRMA LİSTESİ (Canlı Veri Ağı)
                    // =================================================================
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _secilenKategori == "TÜMÜ" 
                            ? _db.collection('firmalar').where('sehir', isEqualTo: _seciliSehir).orderBy('puan', descending: true).snapshots()
                            : _db.collection('firmalar').where('sehir', isEqualTo: _seciliSehir).where('uzmanlik_kategorileri', arrayContains: _secilenKategori).orderBy('puan', descending: true).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
                          }

                          // 🚨 VERİ YOKSA SİBER MOCK GÖSTERİMİ (Karargah Çökmesin Diye)
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return ListView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              children: [
                                _buildSiberUstaKarti("MURAT PLAZA SERVİSİ", "ANKARA", 4.9, "1.2 KM"),
                                _buildSiberUstaKarti("HASSAS MOTOR REKTEFİYE", "ANKARA", 3.8, "3.4 KM"),
                                _buildSiberUstaKarti("STANDART KAPORTA", "ANKARA", 2.1, "5.0 KM"),
                                _buildSiberUstaKarti("KORSAN ELEKTRONİK", "ANKARA", 1.0, "8.2 KM"), // Kara Liste simülasyonu
                              ],
                            );
                          }

                          // 🚨 DETAYLI FİLTRELEME (İSTEMCİ TARAFLI SÜZME)
                          var dokumanlar = snapshot.data!.docs;
                          if (_secilenDetayFiltre == "PREMIUM (5 YILDIZ)") {
                            dokumanlar = dokumanlar.where((d) => (d.data() as Map)['puan'] >= 4.5).toList();
                          } else if (_secilenDetayFiltre == "EKONOMİK") {
                            // Ekonomik ustalar, f/p oranı yüksek veya fiyat politikası uygun ustalar
                            // Şimdilik puanı 3 ile 4.5 arası olan "Standart/Ekonomik" ustalar
                            dokumanlar = dokumanlar.where((d) => (d.data() as Map)['puan'] >= 3.0 && (d.data() as Map)['puan'] < 4.5).toList();
                          }

                          if (dokumanlar.isEmpty) {
                            return const Center(child: Text("BU BÖLGEDE UYGUN USTA BULUNAMADI", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontFamily: 'Avenir')));
                          }

                          // GERÇEK VERİTABANI DÖNGÜSÜ
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: dokumanlar.length,
                            itemBuilder: (context, index) {
                              var data = dokumanlar[index].data() as Map<String, dynamic>;
                              return _buildSiberUstaKarti(
                                data['isim'] ?? 'BİLİNMEYEN FİRMA',
                                data['sehir'] ?? 'BİLİNMEYEN KONUM',
                                (data['puan'] ?? 0.0).toDouble(),
                                "${data['mesafe'] ?? '0.0'} KM", // Mesafe şimdilik GPS otonomisi öncesi gösterim
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: KATEGORİ ÇİPİ
  Widget _buildKategoriCipi(String kategori) {
    bool isSelected = _secilenKategori == kategori;
    return GestureDetector(
      onTap: () {
        setState(() => _secilenKategori = kategori);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? SiberTema.kuantumCyan.withOpacity(0.2) : SiberTema.matGrey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? SiberTema.kuantumCyan : Colors.white12, width: 1.5),
        ),
        child: Center(
          child: Text(
            kategori.toUpperCase(),
            style: TextStyle(
              color: isSelected ? SiberTema.kuantumCyan : Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              fontFamily: 'Avenir'
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: DETAY FİLTRE ÇİPİ (Premium, Ekonomik)
  Widget _buildDetayFiltreCipi(String baslik, IconData ikon) {
    bool isSelected = _secilenDetayFiltre == baslik;
    return GestureDetector(
      onTap: () => setState(() => _secilenDetayFiltre = baslik),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? SiberTema.kuantumCyan.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? SiberTema.kuantumCyan : Colors.white12),
        ),
        child: Row(
          children: [
            Icon(ikon, color: isSelected ? SiberTema.kuantumCyan : Colors.white54, size: 12),
            const SizedBox(width: 4),
            Text(
              baslik,
              style: TextStyle(color: isSelected ? SiberTema.kuantumCyan : Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
            ),
          ],
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER FİRMA KARTI
  Widget _buildSiberUstaKarti(String isim, String konum, double puan, String mesafe) {
    bool isKaraListe = puan < 1.5;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: SiberTema.matGrey.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isKaraListe ? SiberTema.kanKirmizi.withOpacity(0.5) : Colors.white.withOpacity(0.05), width: 1.5),
            boxShadow: isKaraListe ? [BoxShadow(color: SiberTema.kanKirmizi.withOpacity(0.1), blurRadius: 20)] : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isim.toUpperCase(), style: TextStyle(color: isKaraListe ? SiberTema.kanKirmizi : Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.my_location, color: Colors.white38, size: 12),
                            const SizedBox(width: 4),
                            Text("$konum  •  $mesafe", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildSiberRozet(puan),
                ],
              ),
              const SizedBox(height: 20),

              // =====================================================
              // İKİLİ ETKİLEŞİM KALKANI: TEKLİF İSTE & RANDEVU AL
              // =====================================================
              Row(
                children: [
                  // 1. GİZLİ TEKLİF BUTONU (Mali Sorumluluk Kalkanı)
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: isKaraListe ? null : () {
                          _siberUyariGoster("$isim FİRMASINDAN GİZLİ TEKLİF İSTENİYOR...");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isKaraListe ? SiberTema.kanKirmizi.withOpacity(0.1) : SiberTema.siberGold.withOpacity(0.1),
                          foregroundColor: isKaraListe ? SiberTema.kanKirmizi : SiberTema.siberGold,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isKaraListe ? SiberTema.kanKirmizi.withOpacity(0.3) : SiberTema.siberGold.withOpacity(0.5))),
                        ),
                        icon: Icon(isKaraListe ? Icons.block : Icons.request_quote, size: 16),
                        label: Text(
                          isKaraListe ? "MEN EDİLDİ" : "TEKLİF İSTE",
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 2. RANDEVU AL BUTONU
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: isKaraListe ? null : () {
                          _siberUyariGoster("$isim İÇİN RANDEVU PROTOKOLÜ BAŞLATILIYOR...");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isKaraListe ? SiberTema.kanKirmizi.withOpacity(0.1) : SiberTema.kuantumCyan.withOpacity(0.1),
                          foregroundColor: isKaraListe ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isKaraListe ? SiberTema.kanKirmizi.withOpacity(0.3) : SiberTema.kuantumCyan.withOpacity(0.5))),
                        ),
                        icon: Icon(isKaraListe ? Icons.block : Icons.calendar_month, size: 16),
                        label: Text(
                          isKaraListe ? "MEN EDİLDİ" : "RANDEVU AL",
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: DİJİTAL ROZET HİYERARŞİSİ
  Widget _buildSiberRozet(double puan) {
    if (puan >= 4.5) {
      return _rozet(Icons.star, SiberTema.altinSari, "ALTIN"); // 5 Yıldız
    } else if (puan >= 3.5) {
      return _rozet(Icons.star, const Color(0xFFC0C0C0), "GÜMÜŞ"); // 4 Yıldız
    } else if (puan >= 2.5) {
      return _rozet(Icons.star, const Color(0xFFCD7F32), "BRONZ"); // 3 Yıldız
    } else if (puan >= 1.5) {
      return _rozet(Icons.star_border, Colors.white54, "BOŞ ROZET"); // 2 Yıldız
    } else {
      // 1 Yıldız: Kara Liste (Siyah Yıldız + Kara Liste Yazısı)
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: SiberTema.kanKirmizi.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.5))),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.black, size: 14),
            SizedBox(width: 4),
            Text("KARA LİSTE", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
          ],
        ),
      );
    }
  }

  Widget _rozet(IconData ikon, Color renk, String metin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: renk.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: renk.withOpacity(0.5))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, color: renk, size: 14),
          const SizedBox(width: 4),
          Text(metin, style: TextStyle(color: renk, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
        ],
      ),
    );
  }
}