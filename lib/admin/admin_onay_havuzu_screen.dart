import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class AdminOnayHavuzuScreen extends StatefulWidget {
  const AdminOnayHavuzuScreen({super.key});

  @override
  State<AdminOnayHavuzuScreen> createState() => _AdminOnayHavuzuScreenState();
}

class _AdminOnayHavuzuScreenState extends State<AdminOnayHavuzuScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 🔴 FİREBASE: ATOMİK ONAY MOTORU (WRITEBATCH) ---
  Future<void> _talebiOnayla(String docId, String bayiId, String firmaAdi, String onerilenIslem) async {
    try {
      final batch = _db.batch();

      // 1. İstek havuzundaki durumu güncelle
      final talepRef = _db.collection('onay_bekleyen_islemler').doc(docId);
      batch.update(talepRef, {'durum': 'onaylandi'});

      // 2. Bayinin vitrinindeki uzmanlık alanını güncelle
      final bayiRef = _db.collection('bayiler').doc(bayiId);
      batch.update(bayiRef, {'uzmanlik_alani': onerilenIslem});

      // 3. Karargah Radarı için Loglara yaz
      final logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'bayi_isim': firmaAdi,
        'islem_detayi': 'ÖZEL İŞLEM ONAYLANDI: $onerilenIslem',
        'islem_turu': 'basarili',
        'tarih': FieldValue.serverTimestamp(),
      });

      // 🚀 Füze Ateşlendi!
      await batch.commit();

      if (mounted) _siberUyariVer("SİBER ONAY: İşlem bayinin vitrinine mühürlendi!", isError: false);
    } catch (e) {
      if (mounted) _siberUyariVer("SİBER HATA: İşlem reddedildi! Kalkanlar kapalı.", isError: true);
    }
  }

  // --- ⚠️ FİREBASE: REDDETME MOTORU ---
  Future<void> _talebiReddet(String docId, String firmaAdi, String onerilenIslem) async {
    try {
      final batch = _db.batch();

      // 1. Durumu reddedildi yap
      final talepRef = _db.collection('onay_bekleyen_islemler').doc(docId);
      batch.update(talepRef, {'durum': 'reddedildi'});

      // 2. Karargah Radarı için Loglara yaz
      final logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'bayi_isim': firmaAdi,
        'islem_detayi': 'REDDEDİLDİ: Yetkisiz işlem talebi ($onerilenIslem).',
        'islem_turu': 'hata',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (mounted) _siberUyariVer("TALEP REDDEDİLDİ: Karantina başarıyla sağlandı.", isError: true);
    } catch (e) {
      if (mounted) _siberUyariVer("SİBER HATA: Bağlantı koptu.", isError: true);
    }
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
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
          leading: IconButton(icon: const Icon(Icons.security, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: Text("SİBER ONAY HAVUZU", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.white.withOpacity(0.05), height: 1),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: _db.collection('onay_bekleyen_islemler').where('durum', isEqualTo: 'bekliyor').orderBy('tarih', descending: false).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3));
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Radar Bağlantısı Koptu!", style: TextStyle(color: SiberTema.kanKirmizi, fontFamily: 'Avenir', fontWeight: FontWeight.bold)));
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [SiberTema.oledBlack, SiberTema.matGrey.withOpacity(0.5)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user_outlined, size: 64, color: SiberTema.kuantumCyan.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text("KARANTİNA HAVUZU TEMİZ", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final docId = docs[index].id;
                  final bayiId = data['bayi_id'] ?? '';
                  final firmaAdi = data['firma_adi'] ?? 'Bilinmeyen Bayi';
                  final onerilenIslem = data['onerilen_islem'] ?? 'Belirtilmemiş';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      // 3D Dışa Çıkık İnceleme Paneli Hissi
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [SiberTema.matGrey.withOpacity(0.8), SiberTema.oledBlack],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: SiberTema.altinSari.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: SiberTema.altinSari.withOpacity(0.3)),
                                ),
                                child: const Icon(Icons.privacy_tip_outlined, color: SiberTema.altinSari, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(firmaAdi, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                                    const SizedBox(height: 4),
                                    Text("Vergi / Bayi ID: $bayiId", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontFamily: 'Avenir')),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // 3D İçeri Çökük Talep Ekranı
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [SiberTema.oledBlack, SiberTema.matGrey.withOpacity(0.5)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                              boxShadow: [
                                BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 10, spreadRadius: -2, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("TALEP EDİLEN ÖZEL İŞLEM:", style: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                                const SizedBox(height: 8),
                                Text(onerilenIslem, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Avenir')),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 3D ONAY/RET BUTONLARI
                          Row(
                            children: [
                              // 3D REDDET BUTONU
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _talebiReddet(docId, firmaAdi, onerilenIslem),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [SiberTema.kanKirmizi.withOpacity(0.15), SiberTema.kanKirmizi.withOpacity(0.05)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.5), width: 1.5),
                                      boxShadow: [
                                        BoxShadow(color: SiberTema.kanKirmizi.withOpacity(0.1), offset: const Offset(0, 4), blurRadius: 8),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.block, color: SiberTema.kanKirmizi, size: 18),
                                        SizedBox(width: 8),
                                        Text("REDDET", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // 3D ONAYLA BUTONU
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _talebiOnayla(docId, bayiId, firmaAdi, onerilenIslem),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [SiberTema.kuantumCyan.withOpacity(0.9), SiberTema.kuantumCyan.withOpacity(0.6)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                                      boxShadow: [
                                        BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.3), offset: const Offset(0, 6), blurRadius: 12),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle_outline, color: SiberTema.oledBlack, size: 18),
                                        SizedBox(width: 8),
                                        Text("ONAYLA", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}