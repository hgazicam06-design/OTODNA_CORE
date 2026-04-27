import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🦅 OTODNA SİBER KATALOG VE TEDARİK VİTRİNİ
/// Küresel parçaları çeker ve anında Siber Sepet'e mühürler.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isProcessing = false;

  // 🚀 FİREBASE: SEPETE ATOMİK ÜRÜN MÜHÜRLEME MOTORU
  Future<void> _sepeteEkle(Map<String, dynamic> urunData, String urunId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _siberMesajGoster("İHLAL: Sepete ürün eklemek için ağa giriş yapmalısınız!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      DocumentReference sepetRef = _db.collection('kullanicilar').doc(uid).collection('sepet').doc(urunId);
      DocumentSnapshot snap = await sepetRef.get();

      if (snap.exists) {
        // Eğer ürün sepette varsa adet artır (Atomik increment)
        await sepetRef.update({'adet': FieldValue.increment(1)});
      } else {
        // Ürün sepette yoksa yeni kayıt oluştur
        await sepetRef.set({
          'urunId': urunId,
          'urunAdi': urunData['ad'] ?? 'Bilinmeyen Donanım',
          'fiyat': (urunData['fiyat'] ?? 0).toDouble(),
          'marka': urunData['marka'] ?? 'OEM',
          'adet': 1,
          'eklenme_tarihi': FieldValue.serverTimestamp(),
        });
      }

      _siberMesajGoster("${urunData['ad']} SİBER SEPETE EKLENDİ 🛒");
    } catch (e) {
      _siberMesajGoster("AĞ HATASI: Sepet güncellenemedi!", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _siberMesajGoster(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20),
              onPressed: () => Navigator.pop(context)
          ),
          title: const Text("SİBER KATALOG", style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: StreamBuilder<QuerySnapshot>(
              // Doğrudan Kuantum Ağından verileri çekiyoruz
              stream: _db.collection('yedek_parcalar').orderBy('tarih', descending: true).limit(50).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildBosRadar();
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    return _buildSiberUrunKarti(doc.id, data);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBosRadar() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radar, color: SiberTema.kuantumCyan.withOpacity(0.1), size: 80),
          const SizedBox(height: 24),
          const Text("VİTRİN BOŞ", style: TextStyle(color: SiberTema.textMuted, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 4)),
          const SizedBox(height: 8),
          const Text("Sisteme henüz donanım eklenmemiş.", style: TextStyle(color: SiberTema.textMuted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSiberUrunKarti(String urunId, Map<String, dynamic> data) {
    String ad = data['ad'] ?? 'İSİMSİZ DONANIM';
    String marka = data['marka'] ?? 'OEM';
    double fiyat = (data['fiyat'] ?? 0).toDouble();

    return Container(
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // GÖRSEL ALANI (Kuantum Hologramı)
          Expanded(
            flex: 4,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white26,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(Icons.memory, size: 50, color: SiberTema.kuantumCyan.withOpacity(0.15))),
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: const Text("KARARGAH ONAYLI", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 7, fontWeight: FontWeight.w900)),
                    ),
                  )
                ],
              ),
            ),
          ),

          // BİLGİ VE AKSİYON ALANI
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(marka.toUpperCase(), style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(ad.toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold, height: 1.3)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("₺${fiyat.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : () => _sepeteEkle(data, urunId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SiberTema.kuantumCyan,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("SEPETE AT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}