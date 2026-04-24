import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

/// 🏢 SİBER DİSTRİBÜTÖR ANA KARARGAHI (TITANYUM & SİBER ALTIN)
/// Yalnızca yetkili "Distributor" rolüne sahip Kuantum devlerinin erişebildiği Toptan B2B Merkezi.
class DistributorMerkezUssu extends StatefulWidget {
  const DistributorMerkezUssu({super.key});

  @override
  State<DistributorMerkezUssu> createState() => _DistributorMerkezUssuState();
}

class _DistributorMerkezUssuState extends State<DistributorMerkezUssu> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  
  int _seciliSekme = 0;

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: Text("Siber Kimlik Bulunamadı!", style: TextStyle(color: Colors.red))));
    }

    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Zırh üzerinden aydınlatılacak
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.altinSari, size: 18), onPressed: () => Navigator.pop(context)),
          title: const Text("KÜRESEL DİSTRİBÜTÖR AĞI", style: TextStyle(color: SiberTema.altinSari, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Avenir')),
          centerTitle: true,
          actions: [IconButton(icon: const Icon(Icons.radar, color: SiberTema.kuantumCyan, size: 20), onPressed: () {})],
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: _db.collection('kullanicilar').doc(_currentUser!.uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.altinSari));
              if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: Text("B2B Verisi Yükleniyor...", style: TextStyle(color: Colors.white54)));

              var data = snapshot.data!.data() as Map<String, dynamic>;
              String firmaAdi = data['firma_adi'] ?? "KÜRESEL DİSTRİBÜTÖR";
              double aylikCiro = (data['aylik_ciro'] ?? 0).toDouble();
              
              // 💰 DİSTRİBÜTÖRE ÖZEL VIP FİNANS KURALI: %10 Karargah Payı
              double komisyonOrani = 0.10; 
              double otodnaKesintisi = aylikCiro * komisyonOrani;
              double netHakedis = aylikCiro - otodnaKesintisi;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. VIP TİTANYUM KİMLİK KARTI
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1D), // Koyu Titanyum
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: SiberTema.altinSari.withOpacity(0.5), width: 1.5),
                        boxShadow: [BoxShadow(color: SiberTema.altinSari.withOpacity(0.1), blurRadius: 20, spreadRadius: -5)]
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.precision_manufacturing_outlined, color: SiberTema.altinSari, size: 40),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(firmaAdi.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                                const SizedBox(height: 6),
                                const Row(
                                  children: [
                                    Icon(Icons.shield, color: SiberTema.altinSari, size: 14),
                                    SizedBox(width: 4),
                                    Text("VIP B2B TOPTANCI (SİVİLLERE KAPALI)", style: TextStyle(color: SiberTema.altinSari, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 2. SEKTÖREL OTONOM YÜKLEME (KİTLE İMHA) BUTONLARI
                    const Text("B2B Kitle Yükleme Merkezleri", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildSektorKarti("Otomobil\nFilosu", Icons.directions_car_filled_outlined, SiberTema.kuantumCyan),
                        _buildSektorKarti("Alternatif\nYakıt", Icons.electric_bolt_outlined, Colors.greenAccent),
                        _buildSektorKarti("İş Makinası\n& Tarım", Icons.fire_truck_outlined, Colors.orangeAccent),
                        _buildSektorKarti("Motosiklet\n& ATV", Icons.two_wheeler_outlined, Colors.redAccent),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // 3. VIP FİNANSAL BORSA EKRANI
                    const Text("Küresel Borsa & Ciro Akışı", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: const Color(0xFF1A1A1D), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
                      child: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Toplam Toptan Hacim", style: TextStyle(color: Colors.white54, fontSize: 13)), Text("₺${(aylikCiro/1000000).toStringAsFixed(2)} Milyon", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))]),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white12, height: 1)),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Karargah Payı (VIP %10)", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 13)), Text("-₺${otodnaKesintisi.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kanKirmizi, fontSize: 16, fontWeight: FontWeight.bold))]),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white12, height: 1)),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Net Aktarım", style: TextStyle(color: SiberTema.altinSari, fontSize: 14, fontWeight: FontWeight.bold)), Text("₺${netHakedis.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.altinSari, fontSize: 22, fontWeight: FontWeight.w900))]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 4. BAYİ AĞI RADARI
                    _buildSiberGeniIslemButonu(
                      "Bayi Ağı Radarı (Canlı)",
                      "Türkiye genelinde hangi bayinin ne kadar stok çektiğini haritada izleyin.",
                      Icons.map_outlined,
                      SiberTema.altinSari,
                      () {
                        _siberUyari("Kuantum Harita Sistemi B2B Radarına Bağlanıyor...");
                      }
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            }
        ),
        
        // ALT MENÜ (Distribütörlere Özel Kalın Tasarım)
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black, type: BottomNavigationBarType.fixed, elevation: 0,
          selectedItemColor: SiberTema.altinSari, unselectedItemColor: Colors.white24,
          selectedFontSize: 11, unselectedFontSize: 11,
          currentIndex: _seciliSekme,
          onTap: (index) => setState(() => _seciliSekme = index),
          items: const [
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.account_balance_outlined)), label: "Karargah"),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.layers_outlined)), label: "Kitle Yükleme"),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.flash_on_outlined)), label: "Flaş Kampanya"),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 6), child: Icon(Icons.public)), label: "Bayi Ağı"),
          ],
        ),
      ),
    );
  }

  Widget _buildSektorKarti(String baslik, IconData ikon, Color renk) {
    return GestureDetector(
      onTap: () => _siberUyari("$baslik Terminali Aktif Ediliyor..."),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: renk.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: renk.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, color: renk, size: 36),
            const SizedBox(height: 16),
            Text(baslik, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir', height: 1.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildSiberGeniIslemButonu(String baslik, String altBaslik, IconData ikon, Color renk, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: const Color(0xFF1A1A1D), borderRadius: BorderRadius.circular(20), border: Border.all(color: renk.withOpacity(0.3))),
        child: Row(
          children: [
            Icon(ikon, color: renk, size: 32),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(baslik, style: TextStyle(color: renk, fontSize: 15, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                  const SizedBox(height: 4),
                  Text(altBaslik, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _siberUyari(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontFamily: 'Avenir')), backgroundColor: SiberTema.altinSari));
  }
}
