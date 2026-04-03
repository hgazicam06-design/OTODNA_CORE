import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import '../services/ai_service.dart'; // AI servisi ileride Kuantum modülüne bağlanacak

class PartSearchMapScreen extends StatefulWidget {
  const PartSearchMapScreen({super.key});

  @override
  State<PartSearchMapScreen> createState() => _PartSearchMapScreenState();
}

class _PartSearchMapScreenState extends State<PartSearchMapScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color warningColor = Colors.orangeAccent;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _aramaController = TextEditingController();

  void _uyariGoster(String mesaj, {bool isCart = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1)),
        backgroundColor: isCart ? warningColor : primaryCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("OTODNA TEDARİK AĞI", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: primaryCyan),
            onPressed: () => _uyariGoster("SİBER SEPETE BAĞLANILIYOR..."),
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000), // 🖥️ Double Teyp & Web Zırhı
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. AI SİBER RADAR (Arama Çubuğu)
                  _buildSiberAramaCubugu(),

                  // 2. FİREBASE: VİP / KAMPANYALI PARÇALAR
                  _buildBolumBasligi("🔥 SİBER FIRSAT RADARI", primaryCyan),
                  _buildKampanyaListesi(),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Divider(color: Colors.white12, thickness: 1),
                  ),

                  // 3. FİREBASE: TÜM YEDEK PARÇALAR AĞI
                  _buildBolumBasligi("🌍 KÜRESEL PARÇA ENVANTERİ", Colors.white54),
                  _buildEnvanterGrid(),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 📡 SİBER ARAMA ÇUBUĞU
  Widget _buildSiberAramaCubugu() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryCyan.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 20)],
      ),
      child: TextField(
        controller: _aramaController,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
        decoration: InputDecoration(
          hintText: "OEM KODU, MARKA VEYA PARÇA ARA...",
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
          prefixIcon: const Icon(Icons.radar, color: primaryCyan),
          suffixIcon: IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white38),
            onPressed: () => _uyariGoster("AI OPTİK TARAYICI BAŞLATILIYOR..."),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
        onSubmitted: (val) {
          _uyariGoster("KUANTUM AĞINDA ARANIYOR: ${val.toUpperCase()}");
          // TODO: AIServis().esnaflariHaritadaGoster(val);
        },
      ),
    );
  }

  Widget _buildBolumBasligi(String baslik, Color renk) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(baslik, style: TextStyle(color: renk, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    );
  }

  // 🚀 FİREBASE: YATAY KAMPANYA LİSTESİ
  Widget _buildKampanyaListesi() {
    return SizedBox(
      height: 260,
      child: StreamBuilder<QuerySnapshot>(
        // Firebase'den sadece kampanyalı (veya öne çıkan) ürünleri çeker
        stream: _db.collection('yedek_parcalar').where('kampanya', isEqualTo: true).limit(5).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryCyan));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildBosRadar("AKTİF SİBER KAMPANYA BULUNAMADI");
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _buildKuantumUrunKarti(
                ad: data['ad'] ?? 'BİLİNMEYEN PARÇA',
                marka: data['marka'] ?? 'OEM',
                fiyat: (data['fiyat'] ?? 0).toString(),
                eskiFiyat: (data['eski_fiyat'] ?? '').toString(),
              );
            },
          );
        },
      ),
    );
  }

  // 🚀 FİREBASE: TÜM ÜRÜNLER GRID YAPISI
  Widget _buildEnvanterGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('yedek_parcalar').limit(20).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: primaryCyan)));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildBosRadar("ENVANTER BOŞ. AĞDA PARÇA YOK.");
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220, // Double Teyp ve Web'de yan yana sığması için esnek yapı
            childAspectRatio: 0.65,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return _buildKuantumUrunKarti(
              ad: data['ad'] ?? 'BİLİNMEYEN PARÇA',
              marka: data['marka'] ?? 'OEM',
              fiyat: (data['fiyat'] ?? 0).toString(),
              eskiFiyat: '', // Grid'de sade dursun
            );
          },
        );
      },
    );
  }

  // 💎 YARDIMCI BİLEŞEN: BOŞ RADAR (VERİ YOKSA)
  Widget _buildBosRadar(String mesaj) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radar, color: primaryCyan.withOpacity(0.2), size: 40),
          const SizedBox(height: 12),
          Text(mesaj, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER ÜRÜN KARTI (Iron Man HUD Tarzı)
  Widget _buildKuantumUrunKarti({required String ad, required String marka, required String fiyat, String eskiFiyat = ""}) {
    return Container(
      width: 170, // Horizontal listeler için sabit genişlik
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // GÖRSEL ALANI (Holografik Zemin)
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: const Border(bottom: BorderSide(color: Colors.white12)),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(Icons.memory, size: 48, color: primaryCyan.withOpacity(0.2))),
                  // %12 KESİNTİ MÜHRÜ (Sadece arkaplanda ticari zekayı simgelemek için şık bir detay)
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: primaryCyan.withOpacity(0.5))),
                      child: const Text("OTO DNA", style: TextStyle(color: primaryCyan, fontSize: 7, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  )
                ],
              ),
            ),
          ),

          // BİLGİ ALANI
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(marka.toUpperCase(), style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(ad.toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, height: 1.3)),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (eskiFiyat.isNotEmpty)
                        Text("₺$eskiFiyat", style: const TextStyle(decoration: TextDecoration.lineThrough, color: dangerColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text("₺$fiyat", style: const TextStyle(color: primaryCyan, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
                      const SizedBox(height: 12),

                      // 🛒 SİBER SEPETE EKLE BUTONU
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () => _uyariGoster("$ad AĞ SEPETİNE MÜHÜRLENDİ! 🛒", isCart: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryCyan.withOpacity(0.1),
                            foregroundColor: primaryCyan,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: primaryCyan.withOpacity(0.5))),
                          ),
                          child: const Text("SEPETE AL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}