import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/siber_tema.dart';

class SiberSepetScreen extends StatefulWidget {
  const SiberSepetScreen({super.key});

  @override
  State<SiberSepetScreen> createState() => _SiberSepetScreenState();
}

class _SiberSepetScreenState extends State<SiberSepetScreen> {
  static const Color primaryCyan = SiberTema.kuantumCyan;
  
  // Örnek sepet verisi (İleride Provider veya Firestore Sepet koleksiyonundan beslenecek)
  final List<Map<String, dynamic>> _sepetUrunleri = [
    {
      "id": "item_1",
      "baslik": "BMW F30 Sağ Far Çıkma Orijinal",
      "resimUrl": "https://via.placeholder.com/150/000000/00FFC2?text=OtoDNA",
      "fiyat": 2500.0,
      "adet": 1,
      "satici": "Murat Plaza & Oto Çıkma"
    },
    {
      "id": "item_2",
      "baslik": "Kuantum Zırhlı 120 NM Redüktör",
      "resimUrl": "https://via.placeholder.com/150/000000/FFD700?text=OtoDNA",
      "fiyat": 1800.0,
      "adet": 2,
      "satici": "Kuantum Motor A.Ş."
    }
  ];

  double get _toplamTutar {
    double toplam = 0;
    for (var urun in _sepetUrunleri) {
      toplam += (urun['fiyat'] as double) * (urun['adet'] as int);
    }
    return toplam * 1.20; // %20 KDV
  }

  void _adetArttir(int index) {
    setState(() {
      _sepetUrunleri[index]['adet']++;
    });
  }

  void _adetAzalt(int index) {
    setState(() {
      if (_sepetUrunleri[index]['adet'] > 1) {
        _sepetUrunleri[index]['adet']--;
      } else {
        _sepetUrunleri.removeAt(index);
      }
    });
  }

  void _havuzaAktar() {
    if (_sepetUrunleri.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: primaryCyan.withOpacity(0.5))),
        title: const Row(children: [Icon(Icons.security, color: primaryCyan), SizedBox(width: 8), Text("SİBER KASA ONAYI", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))]),
        content: Text("₺${_toplamTutar.toStringAsFixed(2)} tutarındaki ödemeniz Kuantum Havuzuna (Siber Kasa) aktarılacaktır. Ürünler elinize ulaşıp onay verene kadar para satıcıya geçmez.\n\nOnaylıyor musunuz?", style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5, fontFamily: 'Avenir')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İPTAL", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() { _sepetUrunleri.clear(); });
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("SİBER ONAY: Tutar havuza aktarıldı, ürünler kargoya hazırlanıyor! 🚀", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan));
            },
            child: const Text("ONAYLA", style: TextStyle(fontWeight: FontWeight.w900)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. KUANTUM ARKA PLAN
          Positioned.fill(child: Container(decoration: SiberTema.siberArkaPlan)),

          // 2. ANA İÇERİK
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildSiberAppBar(),
                _buildKasaGuvenlikKalkani(),
                Expanded(
                  child: _sepetUrunleri.isEmpty
                      ? const Center(child: Text("Sepetiniz Siber Boşlukta 🌌", style: TextStyle(color: Colors.white38, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Avenir')))
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(top: 16, bottom: 180),
                          itemCount: _sepetUrunleri.length,
                          itemBuilder: (context, index) {
                            return _buildSepetKarti(_sepetUrunleri[index], index);
                          },
                        ),
                ),
              ],
            ),
          ),

          // 3. SABİT ALT BAR (CHECKOUT)
          if (_sepetUrunleri.isNotEmpty)
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: _buildOdemeBari(),
            ),
        ],
      ),
    );
  }

  // ─── CAM ZIRHLI APP BAR ───
  Widget _buildSiberAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), border: const Border(bottom: BorderSide(color: Colors.white10))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18)),
              ),
              const Text('S İ B E R   S E P E T', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Avenir')),
              IconButton(onPressed: () {
                setState(() { _sepetUrunleri.clear(); });
              }, icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SİBER KASA GÜVENLİK UYARISI ───
  Widget _buildKasaGuvenlikKalkani() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryCyan.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryCyan.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, color: primaryCyan, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Siber Kasa Aktif: Ödemeniz siz onay verene kadar satıcıya aktarılmaz. Karargah komisyonu (%12) satıcının hakedişinden kesilir.",
              style: TextStyle(color: Colors.white70, fontSize: 10, height: 1.4, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
            ),
          )
        ],
      ),
    );
  }

  // ─── SEPET ÜRÜN KARTI ───
  Widget _buildSepetKarti(Map<String, dynamic> urun, int index) {
    double urunFiyati = urun['fiyat'] * 1.20; // KDV dahil

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100, height: 120,
            decoration: BoxDecoration(color: Colors.black, borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)), image: DecorationImage(image: NetworkImage(urun['resimUrl']), fit: BoxFit.cover)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(urun['satici'], style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  const SizedBox(height: 4),
                  Text(urun['baslik'], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Avenir', height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("₺${urunFiyati.toStringAsFixed(2)}", style: const TextStyle(color: primaryCyan, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                      
                      // Miktar Kontrolcüsü
                      Container(
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                        child: Row(
                          children: [
                            InkWell(onTap: () => _adetAzalt(index), child: const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.remove, color: Colors.white54, size: 16))),
                            Text("${urun['adet']}", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                            InkWell(onTap: () => _adetArttir(index), child: const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.add, color: primaryCyan, size: 16))),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // ─── ÖDEME BARI (CHECKOUT) ───
  Widget _buildOdemeBari() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            border: const Border(top: BorderSide(color: Colors.white10)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Ara Toplam (KDV Dahil)", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  Text("₺${_toplamTutar.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Kargo Tutarı", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  Text("Ücretsiz", style: TextStyle(color: primaryCyan, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white12)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("ÖDENECEK TUTAR", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                  Text("₺${_toplamTutar.toStringAsFixed(2)}", style: const TextStyle(color: primaryCyan, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1, fontFamily: 'Avenir')),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryCyan, foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 10, shadowColor: primaryCyan.withOpacity(0.3),
                  ),
                  onPressed: _havuzaAktar,
                  icon: const Icon(Icons.lock_outline, size: 20),
                  label: const Text("GÜVENLİ ÖDEME (HAVUZA AKTAR)", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, fontFamily: 'Avenir')),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
