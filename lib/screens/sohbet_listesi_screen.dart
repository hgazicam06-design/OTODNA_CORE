import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 SİBER KÖPRÜLER (Mutlak Rota Mimarisi)
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import 'sohbet_ekrani.dart'; // Bir önceki kurduğumuz Kuantum Sansürlü Tünel

class SohbetListesiScreen extends StatefulWidget {
  const SohbetListesiScreen({super.key});

  @override
  State<SohbetListesiScreen> createState() => _SohbetListesiScreenState();
}

class _SohbetListesiScreenState extends State<SohbetListesiScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _aktifKullaniciId;

  @override
  void initState() {
    super.initState();
    _aktifKullaniciId = _auth.currentUser?.uid ?? "BILINMEYEN_KOMUTAN";
  }

  // 🧠 SİBER İSTİHBARAT: Karşı tarafın adını Kuantum Ağında bul
  Future<String> _karsiTarafIsminiBul(String karsiId) async {
    try {
      DocumentSnapshot doc = await _db.collection('kullanicilar').doc(karsiId).get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        // Bayi ise firma adı, bireysel ise ad_soyad döndür
        return data['ad'] ?? data['ad_soyad'] ?? data['firma_adi'] ?? "Gizli Kullanıcı";
      }
      return "Siber Sürücü";
    } catch (e) {
      return "Bilinmeyen Hedef";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: SiberTema.oledBlack,
          elevation: 1,
          shadowColor: SiberTema.kuantumCyan.withOpacity(0.3),
          leading: IconButton(
            icon: const Icon(Icons.radar, color: SiberTema.kuantumCyan, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "SİBER İLETİŞİM AĞI",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir'),
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("AKTİF KUANTUM TÜNELLERİ", style: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'Avenir')),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  // 🔥 FİREBASE: Sadece içinde bulunduğum sohbet odalarını getir ve son mesaja göre sırala!
                  stream: _db.collection('sohbet_odalari')
                      .where('katilimcilar', arrayContains: _aktifKullaniciId)
                      .orderBy('son_mesaj_zamani', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Siber Ağ Çöktü: ${snapshot.error}", style: const TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.bold)));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildBosDurum();
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var odaVerisi = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                        // Karşı tarafın ID'sini bul
                        List<dynamic> katilimcilar = odaVerisi['katilimcilar'] ?? [];
                        String karsiTarafId = katilimcilar.firstWhere((id) => id != _aktifKullaniciId, orElse: () => "");

                        String sonMesaj = odaVerisi['son_mesaj'] ?? "Bağlantı Kuruldu...";
                        bool sansurluMu = sonMesaj.contains('[SİBER SANSÜR');

                        // ⌛ Zaman damgasını biçimlendir
                        String zamanYazisi = "Şimdi";
                        if (odaVerisi['son_mesaj_zamani'] != null) {
                          DateTime zaman = (odaVerisi['son_mesaj_zamani'] as Timestamp).toDate();
                          zamanYazisi = "${zaman.hour.toString().padLeft(2, '0')}:${zaman.minute.toString().padLeft(2, '0')}";
                        }

                        return FutureBuilder<String>(
                          future: _karsiTarafIsminiBul(karsiTarafId),
                          builder: (context, isimSnapshot) {
                            String karsiTarafIsim = isimSnapshot.data ?? "İstihbarat Yükleniyor...";
                            return _buildSohbetKarti(karsiTarafId, karsiTarafIsim, sonMesaj, zamanYazisi, sansurluMu);
                          },
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
    );
  }

  // --- 🎨 SİBER GÖRSEL ZIRHLAR ---

  Widget _buildSohbetKarti(String karsiId, String isim, String sonMesaj, String zaman, bool sansurluMu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          if (karsiId.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SohbetEkrani(karsiTarafId: karsiId, karsiTarafIsim: isim),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: sansurluMu ? SiberTema.kanKirmizi.withOpacity(0.05) : SiberTema.matGrey.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: sansurluMu ? SiberTema.kanKirmizi.withOpacity(0.4) : SiberTema.kuantumCyan.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(color: sansurluMu ? SiberTema.kanKirmizi.withOpacity(0.1) : Colors.black.withOpacity(0.5), blurRadius: 10, spreadRadius: 1)
                ],
              ),
              child: Row(
                children: [
                  // 🟢 SİBER AVATAR
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: SiberTema.oledBlack,
                      shape: BoxShape.circle,
                      border: Border.all(color: sansurluMu ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, width: 1.5),
                      boxShadow: [BoxShadow(color: sansurluMu ? SiberTema.kanKirmizi.withOpacity(0.3) : SiberTema.kuantumCyan.withOpacity(0.2), blurRadius: 8)],
                    ),
                    child: Center(
                      child: Text(
                        isim.isNotEmpty ? isim[0].toUpperCase() : "X",
                        style: TextStyle(color: sansurluMu ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Avenir'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 📝 MESAJ DETAYLARI
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(isim, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                            ),
                            Text(zaman, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sonMesaj,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: sansurluMu ? SiberTema.kanKirmizi : Colors.white.withOpacity(0.6),
                            fontSize: 13,
                            fontWeight: sansurluMu ? FontWeight.bold : FontWeight.normal,
                            fontFamily: 'Avenir',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBosDurum() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, color: SiberTema.kuantumCyan.withOpacity(0.2), size: 60),
          const SizedBox(height: 16),
          Text("SİBER AĞ TEMİZ", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir')),
          const SizedBox(height: 8),
          Text("Henüz açık bir iletişim tüneliniz bulunmuyor.", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12, fontFamily: 'Avenir')),
        ],
      ),
    );
  }
}