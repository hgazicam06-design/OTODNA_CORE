import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 SİBER KÖPRÜLER (Göreceli Rota Mimarisi - Kırmızı çizgiyi engeller!)
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class SohbetEkrani extends StatefulWidget {
  final String karsiTarafId;
  final String karsiTarafIsim;

  const SohbetEkrani({
    super.key,
    required this.karsiTarafId,
    required this.karsiTarafIsim,
  });

  @override
  State<SohbetEkrani> createState() => _SohbetEkraniState();
}

class _SohbetEkraniState extends State<SohbetEkrani> {
  final TextEditingController _mesajController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String _aktifKullaniciId;
  late String _sohbetOdasiId;

  @override
  void initState() {
    super.initState();
    _aktifKullaniciId = _auth.currentUser?.uid ?? "BILINMEYEN_KOMUTAN";
    _sohbetOdasiId = _sohbetOdasiIdOlustur(_aktifKullaniciId, widget.karsiTarafId);
  }

  @override
  void dispose() {
    _mesajController.dispose();
    super.dispose();
  }

  // 🧠 SİBER ZÜKA: İki ID'den benzersiz bir sohbet odası (Kuantum Tüneli) oluşturur
  String _sohbetOdasiIdOlustur(String id1, String id2) {
    if (id1.hashCode <= id2.hashCode) {
      return "${id1}_$id2";
    } else {
      return "${id2}_$id1";
    }
  }

  // ====================================================================
  // 🚀 FİREBASE: MESAJI KUANTUM AĞINA FIRLAT (SANSÜRSÜZ - ÖZGÜR)
  // ====================================================================
  Future<void> _mesajGonder() async {
    String hamMesaj = _mesajController.text.trim();
    if (hamMesaj.isEmpty) return;

    _mesajController.clear(); // Arayüzü hemen temizle, kullanıcı beklemesin

    try {
      WriteBatch batch = _db.batch(); // 🔥 Kuantum Mührü

      // 1. Mesajı Sohbet Odasına Ekle
      DocumentReference mesajRef = _db
          .collection('sohbet_odalari')
          .doc(_sohbetOdasiId)
          .collection('mesajlar')
          .doc();

      batch.set(mesajRef, {
        'gonderen_id': _aktifKullaniciId,
        'alici_id': widget.karsiTarafId,
        'mesaj': hamMesaj,
        'zaman': FieldValue.serverTimestamp(),
      });

      // 2. Sohbet Odasının Son Durumunu Güncelle
      DocumentReference odaRef = _db.collection('sohbet_odalari').doc(_sohbetOdasiId);
      batch.set(odaRef, {
        'son_mesaj': hamMesaj,
        'son_mesaj_zamani': FieldValue.serverTimestamp(),
        'katilimcilar': [_aktifKullaniciId, widget.karsiTarafId]
      }, SetOptions(merge: true));

      // Füzeyi Ateşle!
      await batch.commit();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ağ Hatası: Mesaj İletilemedi ($e)", style: const TextStyle(color: SiberTema.textMain)), backgroundColor: SiberTema.kanKirmizi),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: SiberTema.oledBlack,
          elevation: 1,
          shadowColor: SiberTema.kuantumCyan.withOpacity(0.3),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: SiberTema.kuantumCyan, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5))),
                child: const Icon(Icons.person, color: SiberTema.kuantumCyan, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.karsiTarafIsim, style: TextStyle(color: SiberTema.textMain.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                    const Text("Kuantum Ağı Bağlantısı Aktif 🟢", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontFamily: 'Avenir', letterSpacing: 1)),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05),
          ),
          child: Column(
            children: [
              // ⚖️ YASAL KALKAN (Sorumluluk Reddi)
              _buildYasalUyariKalkani(),

              // 💬 MESAJLAR BÖLÜMÜ (FİREBASE CANLI YAYIN)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _db.collection('sohbet_odalari').doc(_sohbetOdasiId).collection('mesajlar').orderBy('zaman', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 2));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text("Siber Tünel Temiz. İlk mesajı siz gönderin.", style: TextStyle(color: SiberTema.textMain.withOpacity(0.3), fontWeight: FontWeight.bold, fontFamily: 'Avenir')));
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      reverse: true, // Mesajlar alttan yukarı doğru dizilsin
                      padding: const EdgeInsets.all(16),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var mesajVerisi = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        bool benMiGonderdim = mesajVerisi['gonderen_id'] == _aktifKullaniciId;
                        String mesajMetni = mesajVerisi['mesaj'] ?? '';

                        return _buildMesajBalonu(mesajMetni, benMiGonderdim);
                      },
                    );
                  },
                ),
              ),

              // ⌨️ SİBER KLAVYE VE GÖNDERİM BÖLÜMÜ
              _buildMesajGonderimAlani(),
            ],
          ),
        ),
      ),
    );
  }

  // --- 🎨 SİBER GÖRSEL ZIRHLAR ---

  // ⚖️ KARARGAH HUKUKİ ZIRHI (SORUMLULUK REDDİ)
  Widget _buildYasalUyariKalkani() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SiberTema.altinSari.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SiberTema.altinSari.withOpacity(0.5), width: 1.5),
        boxShadow: [BoxShadow(color: SiberTema.altinSari.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.gavel, color: SiberTema.altinSari, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SİBER UYARI & YASAL BİLDİRİM", style: TextStyle(color: SiberTema.altinSari, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1, fontFamily: 'Avenir')),
                const SizedBox(height: 4),
                Text(
                  "OtoDNA sistemi üzerinden yapılmayan hiçbir ticaret Karargah güvencesinde değildir. Uygulama dışı ödeme ve işlemlerde tüm sorumluluk size aittir. Bu tüneldeki yazışmalar uyuşmazlık halinde resmi delil kabul edilir.",
                  style: TextStyle(color: SiberTema.textMain.withOpacity(0.8), fontSize: 10, height: 1.4, fontFamily: 'Avenir'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMesajBalonu(String mesaj, bool benMiGonderdim) {
    return Align(
      alignment: benMiGonderdim ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: benMiGonderdim ? SiberTema.kuantumCyan.withOpacity(0.15) : SiberTema.matGrey,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(benMiGonderdim ? 16 : 0),
            bottomRight: Radius.circular(benMiGonderdim ? 0 : 16),
          ),
          border: Border.all(
            color: benMiGonderdim ? SiberTema.kuantumCyan.withOpacity(0.3) : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Text(
          mesaj,
          style: TextStyle(
            color: SiberTema.textMain.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Avenir',
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildMesajGonderimAlani() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: SiberTema.oledBlack.withOpacity(0.8),
            border: Border(top: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.2))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: SiberTema.matGrey,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextField(
                    controller: _mesajController,
                    style: const TextStyle(color: SiberTema.textMain, fontSize: 14, fontFamily: 'Avenir'),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null, // Çoklu satır desteği
                    decoration: InputDecoration(
                      hintText: "Siber Ağa Mesaj Yaz...",
                      hintStyle: TextStyle(color: SiberTema.textMain.withOpacity(0.3), fontSize: 13, fontFamily: 'Avenir'),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _mesajGonder,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: SiberTema.kuantumCyan,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.4), blurRadius: 15, spreadRadius: 2)],
                  ),
                  child: const Icon(Icons.send_rounded, color: SiberTema.oledBlack, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}