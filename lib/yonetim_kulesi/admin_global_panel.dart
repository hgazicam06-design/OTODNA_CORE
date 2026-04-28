import 'package:otodna/core/siber_tema.dart';
// lib/screens/admin/admin_global_panel.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🔥 SİBER KÖPRÜLER - YENİ YOL HİYERARŞİSİNE GÖRE AYARLANDI
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class AdminGlobalPanel extends StatefulWidget {
  AdminGlobalPanel({super.key});

  @override
  State<AdminGlobalPanel> createState() => _AdminGlobalPanelState();
}

class _AdminGlobalPanelState extends State<AdminGlobalPanel> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isProcessing = false; // Çift tıklama kalkanı

  // Siber Renk Paleti - Merkezi Temadan Çekiliyor
  final Color _primaryCyan = SiberTema.kuantumCyan;
  final Color _cyberBlack = SiberTema.oledBlack;
  final Color _surfaceColor = SiberTema.matGrey.withOpacity(0.2);

  // 🌍 YENİ DİSTRİBÜTÖR AĞI OLUŞTURMA (ATOMİK ZIRHLI)
  Future<void> _yeniUlkeAgaEkle() async {
    setState(() => _isProcessing = true);
    developer.log("🌍 SİBER AĞ: Yeni Ülke İskeleti Oluşturma Protokolü Başlatıldı...");

    try {
      // ⛓️ ATOMİK ZIRH: İşlemleri Birbirine Kilitle
      WriteBatch batch = _db.batch();

      // 1. Yeni Ülke İskeletini Firebase'e Mühürle (Örnek: TR Merkez Üs)
      DocumentReference ulkeRef = _db.collection('global_aglari').doc('TR');
      batch.set(ulkeRef, {
        'kod': 'TR',
        'ulke': 'TÜRKİYE (MERKEZ)',
        'detay': '81 İl / 7 Bölge Kuantum Ağı',
        'durum': 'AKTİF',
        'oncelik': 100, // Sıralama için
        'olusturulma_tarihi': FieldValue.serverTimestamp(),
      });

      // 2. Kara Kutuya (Sistem Logları) Fişi Kes
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'KURESEL_AG_GENISLEMESI',
        'islem_detayi': 'SİBER HAREKAT: TR (TÜRKİYE) Merkez Kuantum Ağı iskeleti veritabanına mühürlendi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      // Füzeleri ateşle!
      await batch.commit();
      developer.log("✅ ONAY: Küresel Ağ genişlemesi Karargaha ATOMİK olarak işlendi.");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: _cyberBlack,
              shape: RoundedRectangleBorder(side: BorderSide(color: _primaryCyan, width: 1.5)),
              content: Text(
                  "✅ AĞ BAĞLANTISI KURULDU: TÜRKİYE (TR)",
                  style: TextStyle(color: _primaryCyan, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')
              ),
            )
        );
      }
    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: Küresel iskelet oluşturulamadı!", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text("SİBER İHLAL: Bağlantı kurulamadı!", style: TextStyle(fontWeight: FontWeight.bold)),
            )
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
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
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context)
          ),
          title: Text(
              'G L O B A L   S İ B E R   A Ğ',
              style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3, fontFamily: 'Avenir')
          ),
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRadarHeader(),
            _buildSectionTitle(),
            SizedBox(height: 16),
            _buildGlobalNetworkList(),
          ],
        ),
        bottomNavigationBar: _buildBottomAction(),
      ),
    );
  }

  Widget _buildRadarHeader() {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _primaryCyan.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: _cyberBlack, shape: BoxShape.circle, border: Border.all(color: _primaryCyan.withOpacity(0.5))),
              child: Icon(Icons.radar, color: _primaryCyan, size: 32),
            ),
            SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("OTODNA KÜRESEL UYDU BAĞLANTISI", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                  SizedBox(height: 8),
                  Text("SİSTEM ÇEVRİMİÇİ | MERKEZ: ANKARA HQ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Text("AKTİF ÜLKE VE BÖLGELER", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
    );
  }

  Widget _buildGlobalNetworkList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('global_aglari').orderBy('oncelik', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: _primaryCyan));

          // 🚀 MAKETLER YIKILDI: Gerçek boş durum kontrolü
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.satellite_alt_outlined, color: Colors.white24, size: 48),
                  SizedBox(height: 16),
                  Text("UYDU SİNYALİ YOK", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  SizedBox(height: 8),
                  Text("Henüz küresel bir ağ oluşturulmadı.", style: TextStyle(color: _primaryCyan.withOpacity(0.5), fontSize: 10)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 24),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var veri = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _buildUlkeKarti(
                  veri['kod'] ?? 'XX',
                  veri['ulke'] ?? 'BİLİNMEYEN ÜLKE',
                  veri['detay'] ?? 'Detay yok',
                  veri['durum'] ?? 'PASİF',
                  veri['durum'] == 'AKTİF' ? _primaryCyan : Colors.blueAccent
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomAction() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(color: _surfaceColor, border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
        child: SizedBox(
          height: 60,
          child: ElevatedButton.icon(
            style: SiberTema.kuantumButonStili(outlined: true),
            onPressed: _isProcessing ? null : _yeniUlkeAgaEkle,
            icon: _isProcessing
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: SiberTema.oledBlack))
                : Icon(Icons.add_location_alt_outlined, size: 20),
            label: Text(_isProcessing ? "MÜHÜRLENİYOR..." : "YENİ ÜLKE / BÖLGE İSKELETİ OLUŞTUR", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
          ),
        ),
      ),
    );
  }

  Widget _buildUlkeKarti(String kod, String ulke, String detay, String durum, Color renk) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: _cyberBlack, borderRadius: BorderRadius.circular(16), border: Border.all(color: renk.withOpacity(0.3))),
            child: Text(kod.toUpperCase(), style: TextStyle(color: renk, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ulke.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                Text(detay, style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: renk.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: renk.withOpacity(0.5))),
            child: Text(durum, style: TextStyle(color: renk, fontSize: 9, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
          ),
        ],
      ),
    );
  }
}