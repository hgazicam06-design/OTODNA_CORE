import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🦅 SİBER SEPET TERMİNALİ (V2.0 - ZIRHLI)
/// OtoDNA ekosistemindeki tüm donanım ve hizmet alımlarının finansal çıkış kapısı.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // 🌑 SİBER RENK PALETİ (TESLA/CYBERPUNK)
  final Color bgColor = SiberTema.oledBlack;
  final Color surfaceColor = const Color(0xFF111111);
  final Color primaryCyan = SiberTema.kuantumCyan;
  final Color dangerColor = Colors.redAccent;

  bool _isProcessing = false;

  // ── 🚀 1. ATOMİK ADET GÜNCELLEME MOTORU ────────────────────────────────────
  Future<void> _adetGuncelle(DocumentReference docRef, int mevcutAdet, int artis) async {
    // Çift tıklama ve aşırı yüklenme kalkanı
    if (_isProcessing) return;

    try {
      int yeniAdet = mevcutAdet + artis;

      if (yeniAdet <= 0) {
        // 🔥 ATOMİK İMHA: Ürün sepetten tamamen siliniyor
        await docRef.delete();
        _siberBildirim('DONANIM SEPETTEN İMHA EDİLDİ', isError: true);
      } else {
        // ⚡ KUANTUM GÜNCELLEME: Sadece gerekli alan
        await docRef.update({'adet': yeniAdet});
      }
    } catch (e) {
      _siberBildirim('AĞ HATASI: Veri mühürlenemedi!', isError: true);
    }
  }

  // ── 💳 2. GÜVENLİ ÖDEME VE FİNANSAL KÖPRÜ ─────────────────────────────────
  void _odemeAdiminaGec() async {
    setState(() => _isProcessing = true);

    try {
      // TODO: Burada Iyzico veya Stripe Payload hazırlanacak
      // %12 Karargah Payı bu aşamada ödeme sistemine net veri olarak aktarılır.
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      _siberBildirim('KUANTUM ÖDEME AĞINA BAĞLANILIYOR... 💳');

    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Kalkanın arka planını kullan
        appBar: _buildAppBar(),
        body: uid == null ? _buildHataEkrani('YETKİSİZ ERİŞİM: GİRİŞ YAPIN') : _buildSepetAkisi(uid),
      ),
    );
  }

  // ── 🛡️ UI BİLEŞENLERİ: KOMUTA MERKEZİ ───────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'S İ B E R   S E P E T',
        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 4),
      ),
    );
  }

  Widget _buildSepetAkisi(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('kullanicilar')
          .doc(uid)
          .collection('sepet')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: primaryCyan, strokeWidth: 1));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return _buildBosSepet();

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildSepetElemani(doc.reference, data);
                },
              ),
            ),
            _buildOdemeOzeti(docs),
          ],
        );
      },
    );
  }

  Widget _buildSepetElemani(DocumentReference docRef, Map<String, dynamic> data) {
    final ad = data['urunAdi'] ?? 'SİBER DONANIM';
    final fiyat = (data['fiyat'] ?? 0).toDouble();
    final adet = (data['adet'] ?? 1).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // 💿 ÜRÜN İKONU (GLASSMORPHISM)
          Container(
            height: 50, width: 50,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryCyan.withOpacity(0.1)),
            ),
            child: Icon(Icons.settings_input_component_rounded, color: primaryCyan, size: 20),
          ),
          const SizedBox(width: 16),
          // 📝 ÜRÜN BİLGİSİ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ad.toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                const SizedBox(height: 6),
                Text('₺${fiyat.toStringAsFixed(2)}', style: TextStyle(color: primaryCyan, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
              ],
            ),
          ),
          // 🕹️ ADET KONTROLÜ
          _buildAdetKontrolcu(docRef, adet),
        ],
      ),
    );
  }

  Widget _buildAdetKontrolcu(DocumentReference docRef, int adet) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          _buildActionButton(Icons.remove, () => _adetGuncelle(docRef, adet, -1)),
          Text('$adet', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          _buildActionButton(Icons.add, () => _adetGuncelle(docRef, adet, 1), isCyan: true),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap, {bool isCyan = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Icon(icon, color: isCyan ? primaryCyan : Colors.white38, size: 14),
      ),
    );
  }

  Widget _buildOdemeOzeti(List<QueryDocumentSnapshot> docs) {
    double toplamTutar = 0;
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      toplamTutar += ((data['fiyat'] ?? 0).toDouble() * (data['adet'] ?? 1).toInt());
    }

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.8),
            border: Border(top: BorderSide(color: primaryCyan.withOpacity(0.2))),
          ),
          child: Column(
            children: [
              _buildFinansSatir('ARA TOPLAM', '₺${toplamTutar.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildFinansSatir('KARARGAH PAYI (%12 DAHİL)', '₺${(toplamTutar * 0.12).toStringAsFixed(2)}', isSmall: true),
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white10)),
              _buildFinansSatir('GENEL TOPLAM', '₺${toplamTutar.toStringAsFixed(2)}', isBold: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _odemeAdiminaGec,
                  style: SiberTema.kuantumButonStili(),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                      : const Text('GÜVENLİ ÖDEMEYİ BAŞLAT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinansSatir(String baslik, String deger, {bool isSmall = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(baslik, style: TextStyle(color: Colors.white.withOpacity(isSmall ? 0.3 : 0.6), fontSize: isSmall ? 9 : 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
        Text(deger, style: TextStyle(color: isBold ? primaryCyan : Colors.white, fontSize: isBold ? 18 : 12, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
      ],
    );
  }

  void _siberBildirim(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? dangerColor : primaryCyan,
        content: Text(mesaj, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
      ),
    );
  }

  Widget _buildBosSepet() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, color: Colors.white10, size: 60),
          const SizedBox(height: 16),
          const Text('SİBER KASANIZ BOŞ', style: TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildHataEkrani(String mesaj) {
    return Center(child: Text(mesaj, style: TextStyle(color: dangerColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)));
  }
}