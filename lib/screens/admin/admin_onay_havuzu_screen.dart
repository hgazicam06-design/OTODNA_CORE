import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI
import '../../core/responsive_kalkan.dart';
// SiberTema içindeki yasaklı renkleri eziyoruz.
// Sadece True Black, Kuantum Turkuazı, Neon Mor ve Kan Kırmızı kullanacağız.

const Color bgDark = Color(0xFF000000); // True Black (Dipsiz Siyah)
const Color glassBg = Color(0x0AFFFFFF); // Şeffaf Cam
const Color renkIstihbarat = Color(0xFF00FFC2); // Kuantum Turkuazı (Onay)
const Color renkKritik = Colors.redAccent; // Kan Kırmızı (Red)
const Color renkOperasyon = Color(0xFFD500F9); // Neon Mor

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
      if (mounted) _siberUyariVer("SİBER HATA: İşlem onaylanamadı! Kalkanlar kapalı.", isError: true);
    }
  }

  // --- ⚠️ FİREBASE: REDDETME MOTORU (WRITEBATCH) ---
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
        content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: isError ? renkKritik : renkIstihbarat,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: bgDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.security, color: renkIstihbarat), onPressed: () => Navigator.pop(context)),
          title: const Text("SİBER ONAY HAVUZU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.white.withOpacity(0.05), height: 1),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _db.collection('onay_bekleyen_islemler').where('durum', isEqualTo: 'bekliyor').orderBy('tarih', descending: false).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: renkIstihbarat, strokeWidth: 2.5));
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Radar Bağlantısı Koptu!", style: TextStyle(color: renkKritik, fontWeight: FontWeight.bold)));
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: glassBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_user_outlined, size: 56, color: renkIstihbarat.withOpacity(0.3)),
                          const SizedBox(height: 20),
                          Text("KARANTİNA HAVUZU TEMİZ", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final docId = docs[index].id;
                final bayiId = data['bayi_id'] ?? '';
                final firmaAdi = data['firma_adi'] ?? 'Bilinmeyen Bayi';
                final onerilenIslem = data['onerilen_islem'] ?? 'Belirtilmemiş';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: glassBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bayi Bilgileri
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: glassBg,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: renkOperasyon.withOpacity(0.3), width: 1.5),
                                    ),
                                    child: const Icon(Icons.storefront_outlined, color: renkOperasyon, size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(firmaAdi, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                                        const SizedBox(height: 6),
                                        Text("Bayi ID: $bayiId", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Talep Ekranı (İç Cam Panel)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: bgDark.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("TALEP EDİLEN İŞLEM", style: TextStyle(color: renkIstihbarat.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                                    const SizedBox(height: 12),
                                    Text(onerilenIslem, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),

                              // ONAY/RET BUTONLARI (Ferah)
                              Row(
                                children: [
                                  // REDDET BUTONU
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: renkKritik,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        side: BorderSide(color: renkKritik.withOpacity(0.5), width: 1.5),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () => _talebiReddet(docId, firmaAdi, onerilenIslem),
                                      icon: const Icon(Icons.block, size: 18),
                                      label: const Text("REDDET", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // ONAYLA BUTONU
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: renkIstihbarat.withOpacity(0.1),
                                        foregroundColor: renkIstihbarat,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        side: const BorderSide(color: renkIstihbarat, width: 1.5),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () => _talebiOnayla(docId, bayiId, firmaAdi, onerilenIslem),
                                      icon: const Icon(Icons.check_circle_outline, size: 18),
                                      label: const Text("ONAYLA", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}