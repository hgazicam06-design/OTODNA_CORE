import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = const Color(0xFF000000);
  final Color surfaceColor = const Color(0xFF111111);
  final Color primaryCyan = const Color(0xFF00FFC2);
  final Color dangerColor = Colors.redAccent;

  bool _isProcessing = false;

  // 🚀 FİREBASE ADET GÜNCELLEME MOTORU
  Future<void> _adetGuncelle(DocumentReference docRef, int mevcutAdet, int artis) async {
    int yeniAdet = mevcutAdet + artis;
    if (yeniAdet <= 0) {
      await docRef.delete(); // Adet 0 olursa sepetten Kuantum Ağıyla sil
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ÜRÜN SEPETTEN İMHA EDİLDİ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: Colors.redAccent));
      }
    } else {
      await docRef.update({'adet': yeniAdet});
    }
  }

  // 🚀 GÜVENLİ ÖDEME KÖPRÜSÜ
  void _odemeAdiminaGec() async {
    setState(() => _isProcessing = true);
    // TODO: Siber Ödeme Ekranına (siber_odeme_screen.dart) Iyzico Payload fırlatılacak
    await Future.delayed(const Duration(seconds: 2)); // Bağlantı simülasyonu
    if (!mounted) return;
    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('KUANTUM ÖDEME AĞINA BAĞLANILIYOR... 💳', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: primaryCyan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text(
          'S İ B E R   S E P E T   [ M A R K E T ]',
          style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 3),
        ),
      ),
      // Firebase'den anlık Sepet Dinleyicisi
      body: uid == null
          ? _buildHataEkrani('AĞA BAĞLANMAK İÇİN GİRİŞ YAPIN')
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('kullanicilar')
            .doc(uid)
            .collection('sepet')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryCyan, strokeWidth: 2));
          }

          if (snapshot.hasError) {
            return _buildHataEkrani('RADAR BAĞLANTI HATASI');
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return _buildBosSepet();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
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
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: HATA EKRANI
  Widget _buildHataEkrani(String mesaj) {
    return Center(
      child: Text(mesaj, style: TextStyle(color: dangerColor, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: BOŞ SEPET RADARI
  Widget _buildBosSepet() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.05)), color: surfaceColor),
            child: const Icon(Icons.shopping_cart_outlined, color: Colors.white24, size: 64),
          ),
          const SizedBox(height: 24),
          const Text('SİBER KASANIZ BOŞ', style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 12),
          const Text('OtoDNA Market üzerinden donanım\nmühürlemeye başlayın.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER ÜRÜN KARTI
  Widget _buildSepetElemani(DocumentReference docRef, Map<String, dynamic> data) {
    final ad = data['urunAdi'] ?? 'BİLİNMEYEN DONANIM';
    final fiyat = (data['fiyat'] ?? 0).toDouble();
    final adet = (data['adet'] ?? 1).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Holografik Ürün İkonu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryCyan.withOpacity(0.2))),
            child: const Icon(Icons.memory, color: Color(0xFF00FFC2), size: 28),
          ),
          const SizedBox(width: 16),

          // Ürün Detayları
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ad.toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text('₺${fiyat.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF00FFC2), fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'monospace')),
              ],
            ),
          ),

          // Siber Adet Kontrolörü
          Container(
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAdetButonu(Icons.remove, () => _adetGuncelle(docRef, adet, -1)),
                SizedBox(
                  width: 32,
                  child: Text('$adet', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
                ),
                _buildAdetButonu(Icons.add, () => _adetGuncelle(docRef, adet, 1), isCyan: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdetButonu(IconData icon, VoidCallback onTap, {bool isCyan = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: isCyan ? primaryCyan : Colors.white54, size: 16),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: DİNAMİK ÖDEME PANELİ
  Widget _buildOdemeOzeti(List<QueryDocumentSnapshot> docs) {
    double toplamTutar = 0;
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final fiyat = (data['fiyat'] ?? 0).toDouble();
      final adet = (data['adet'] ?? 1).toInt();
      toplamTutar += (fiyat * adet);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: primaryCyan.withOpacity(0.3), width: 2)),
        boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, -10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOPLAM SİBER TUTAR', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
              Text('₺${toplamTutar.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF00FFC2), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('OtoDNA Kasa Kesintisi (Dahil)', style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Text('%12', style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 64,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _odemeAdiminaGec,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryCyan,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: _isProcessing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Icon(Icons.lock_outline, size: 20),
              label: Text(
                _isProcessing ? 'AĞA BAĞLANILIYOR...' : 'GÜVENLİ ÖDEMEYE GEÇİŞ YAP',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}