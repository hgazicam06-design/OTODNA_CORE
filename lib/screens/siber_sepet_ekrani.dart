// lib/screens/siber_sepet_ekrani.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM SEPET VE FİNANS GEÇİDİ
/// Kullanıcının sepetini Firebase'den canlı okur ve siparişi Matrix'e mühürler.
class SiberSepetEkrani extends StatefulWidget {
  const SiberSepetEkrani({super.key});

  @override
  State<SiberSepetEkrani> createState() => _SiberSepetEkraniState();
}

class _SiberSepetEkraniState extends State<SiberSepetEkrani> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _islemSuruyor = false;

  // ── 🚀 SİPARİŞİ MATRİX'E MÜHÜRLEME MOTORU ──
  Future<void> _siparisiAtesle(List<QueryDocumentSnapshot> sepetUrunleri, double toplamTutar) async {
    if (sepetUrunleri.isEmpty) return;

    setState(() => _islemSuruyor = true);
    HapticFeedback.heavyImpact();

    try {
      String uid = _auth.currentUser!.uid;
      String siparisId = "KOD-${DateTime.now().millisecondsSinceEpoch}";

      // ACID Kuantum İşlemi (Siparişi oluştur ve sepeti boşalt)
      WriteBatch batch = _db.batch();

      // 1. Siparişi Karargah Kayıtlarına (Havuz Hesabına) Ekle
      DocumentReference siparisRef = _db.collection('siparisler').doc(siparisId);
      List<Map<String, dynamic>> urunListesi = sepetUrunleri.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          'urun_kodu': doc.id,
          'ad': data['ad'],
          'fiyat': data['fiyat'],
          'adet': data['adet'] ?? 1,
          'satici_id': data['satici_id'] ?? 'BILINMIYOR',
        };
      }).toList();

      batch.set(siparisRef, {
        'musteri_id': uid,
        'siparis_kodu': siparisId,
        'urunler': urunListesi,
        'toplam_tutar': toplamTutar,
        'durum': 'HAVUZDA BEKLİYOR', // Karargah güvenlik kalkanı durumu
        'olusturulma_tarihi': FieldValue.serverTimestamp(),
      });

      // 2. Sepeti Otonom Olarak Temizle
      for (var doc in sepetUrunleri) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      HapticFeedback.vibrate();
      developer.log("✅ FİNANS ONAYI: Sipariş Matrix'e işlendi, Havuz Hesabına aktarıldı!");

      if (mounted) {
        _siberUyariGoster("SİPARİŞ ONAYLANDI", "Tutar Karargah Havuzuna güvenle kilitlendi.", SiberTema.kuantumCyan);
        Navigator.pop(context); // Sepetten çık
      }
    } catch (e) {
      developer.log("🚨 FİNANS AĞI ÇÖKTÜ!", error: e);
      _siberUyariGoster("İŞLEM BAŞARISIZ", "Sipariş Karargaha iletilemedi.", SiberTema.kanKirmizi);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── 🗑️ SEPETTEN ÜRÜN İMHA MOTORU ──
  Future<void> _urunuSepettenSil(String docId) async {
    try {
      String uid = _auth.currentUser!.uid;
      await _db.collection('kullanicilar').doc(uid).collection('sepet').doc(docId).delete();
      HapticFeedback.lightImpact();
    } catch (e) {
      developer.log("🚨 Silme hatası: $e");
    }
  }

  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.matGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      return const ResponsiveKalkan(
        child: Scaffold(
          body: Center(child: Text("SİBER İHLAL: Kimlik tespit edilemedi!", style: TextStyle(color: SiberTema.kanKirmizi))),
        ),
      );
    }

    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("KUANTUM SEPET", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _db.collection('kullanicilar').doc(currentUser.uid).collection('sepet').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.remove_shopping_cart, color: SiberTema.kuantumCyan.withOpacity(0.5), size: 80),
                    const SizedBox(height: 16),
                    const Text("SEPETİNİZ BOŞ", style: TextStyle(color: Colors.white54, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ],
                ),
              );
            }

            var sepetUrunleri = snapshot.data!.docs;
            double toplamTutar = 0;

            for (var doc in sepetUrunleri) {
              var data = doc.data() as Map<String, dynamic>;
              toplamTutar += (data['fiyat'] ?? 0.0) * (data['adet'] ?? 1);
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: sepetUrunleri.length,
                    itemBuilder: (context, index) {
                      var doc = sepetUrunleri[index];
                      var urun = doc.data() as Map<String, dynamic>;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: SiberTema.matGrey,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 60,
                            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.inventory_2, color: SiberTema.kuantumCyan),
                          ),
                          title: Text(urun['ad'] ?? "Bilinmeyen Ürün", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text("₺${urun['fiyat']} x ${urun['adet'] ?? 1}", style: const TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 16)),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: SiberTema.kanKirmizi),
                            onPressed: () => _urunuSepettenSil(doc.id),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ── 💰 ALT ÖDEME PANELİ (Siber Cam Efektli) ──
                SiberTema.siberCamKalkan(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("TOPLAM GÜÇ:", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          Text("₺${toplamTutar.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: _islemSuruyor
                            ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                            : ElevatedButton.icon(
                          style: SiberTema.kuantumButonStili(),
                          onPressed: () => _siparisiAtesle(sepetUrunleri, toplamTutar),
                          icon: const Icon(Icons.security, color: SiberTema.oledBlack),
                          label: const Text("HAVUZ HESABINA AKTAR VE ONAYLA"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}