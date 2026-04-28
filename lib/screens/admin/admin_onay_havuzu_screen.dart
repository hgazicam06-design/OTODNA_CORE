import 'package:otodna/core/siber_tema.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../../services/corporate_audit_logger.dart'; // 👁️ HER ŞEYİ GÖREN GÖZ (İSTİHBARAT)

class AdminOnayHavuzuScreen extends StatefulWidget {
  AdminOnayHavuzuScreen({super.key});

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

      // 🚀 Füze Ateşlendi!
      await batch.commit();

      // 3. Karargah İstihbarat Ağına (Matrix'e) Sinyal Gönder
      CorporateAuditLogger.logSystem(
        'BAYİ İŞLEMİ ONAYLANDI', 
        'Yetki onaylandı: $onerilenIslem', 
      );

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

      await batch.commit();

      // 2. Karargah İstihbarat Ağına (Matrix'e) Kırmızı Sinyal Gönder
      CorporateAuditLogger.logSecurity(
        'YETKİSİZ BAYİ TALEBİ REDDEDİLDİ', 
        'Karantinaya alındı: $onerilenIslem', 
        actorId: docId, 
        actorName: firmaAdi
      );

      if (mounted) _siberUyariVer("TALEP REDDEDİLDİ: Karantina başarıyla sağlandı.", isError: true);
    } catch (e) {
      if (mounted) _siberUyariVer("SİBER HATA: Bağlantı koptu.", isError: true);
    }
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: SiberTema.oledBlack,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.security, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: Text("SİBER ONAY HAVUZU", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Container(color: Colors.white.withOpacity(0.05), height: 1),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _db.collection('onay_bekleyen_islemler').where('durum', isEqualTo: 'bekliyor').orderBy('tarih', descending: false).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 2.5));
            }
            if (snapshot.hasError) {
              return Center(child: Text("Radar Bağlantısı Koptu!", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.bold)));
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      padding: EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: SiberTema.matGrey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.verified_user_outlined, size: 56, color: SiberTema.kuantumCyan.withOpacity(0.3)),
                          SizedBox(height: 20),
                          Text("KARANTİNA HAVUZU TEMİZ", style: TextStyle(color: SiberTema.textMain.withOpacity(0.4), fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(24),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final docId = docs[index].id;
                final bayiId = data['bayi_id'] ?? '';
                final firmaAdi = data['firma_adi'] ?? 'Bilinmeyen Bayi';
                final onerilenIslem = data['onerilen_islem'] ?? 'Belirtilmemiş';

                return Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: SiberTema.matGrey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bayi Bilgileri
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: SiberTema.matGrey.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
                                    ),
                                    child: Icon(Icons.storefront_outlined, color: SiberTema.kuantumCyan, size: 24),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(firmaAdi, style: TextStyle(color: SiberTema.textMain, fontSize: 15, fontWeight: FontWeight.w800)),
                                        SizedBox(height: 6),
                                        Text("Bayi ID: $bayiId", style: TextStyle(color: SiberTema.textMain.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24),

                              // Talep Ekranı (İç Cam Panel)
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: SiberTema.oledBlack.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("TALEP EDİLEN İŞLEM", style: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                                    SizedBox(height: 12),
                                    Text(onerilenIslem, style: TextStyle(color: SiberTema.textMain, fontSize: 14, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              SizedBox(height: 32),

                              // ONAY/RET BUTONLARI (Ferah)
                              Row(
                                children: [
                                  // REDDET BUTONU
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: SiberTema.kanKirmizi,
                                        elevation: 0,
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        side: BorderSide(color: SiberTema.kanKirmizi.withOpacity(0.5), width: 1.5),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () => _talebiReddet(docId, firmaAdi, onerilenIslem),
                                      icon: Icon(Icons.block, size: 18),
                                      label: Text("REDDET", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  // ONAYLA BUTONU
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: SiberTema.kuantumCyan.withOpacity(0.1),
                                        foregroundColor: SiberTema.kuantumCyan,
                                        elevation: 0,
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        side: BorderSide(color: SiberTema.kuantumCyan, width: 1.5),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () => _talebiOnayla(docId, bayiId, firmaAdi, onerilenIslem),
                                      icon: Icon(Icons.check_circle_outline, size: 18),
                                      label: Text("ONAYLA", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)),
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