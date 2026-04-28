import 'package:otodna/core/siber_tema.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class SiberIstihbaratMerkeziScreen extends StatefulWidget {
  SiberIstihbaratMerkeziScreen({super.key});

  @override
  State<SiberIstihbaratMerkeziScreen> createState() => _SiberIstihbaratMerkeziScreenState();
}

class _SiberIstihbaratMerkeziScreenState extends State<SiberIstihbaratMerkeziScreen> {
  String _seciliKategori = "TÜMÜ";
  final List<String> _kategoriler = ["TÜMÜ", "GÜVENLİK", "KARA_KUTU", "İMECE_DİVANI", "BAYİ_RÜTBESİ"];

  Color _getKategoriRengi(String kategori) {
    switch (kategori) {
      case 'GÜVENLİK': return SiberTema.kanKirmizi;
      case 'KARA_KUTU': return Colors.purpleAccent;
      case 'İMECE_DİVANI': return SiberTema.altinSari;
      case 'BAYİ_RÜTBESİ': return SiberTema.kuantumCyan;
      default: return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.8),
          elevation: 0,
          title: Text("SİBER İSTİHBARAT AĞI", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)),
          centerTitle: true,
          iconTheme: IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: Column(
          children: [
            // Filtreleme Paneli
            _buildFiltrePaneli(),
            
            // Terminal Log Akışı
            Expanded(
              child: Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3)),
                  boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.1), blurRadius: 20, spreadRadius: 2)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: _buildMatrixLogAkisi(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltrePaneli() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      physics: BouncingScrollPhysics(),
      child: Row(
        children: _kategoriler.map((kat) {
          final isSelected = _seciliKategori == kat;
          final renk = _getKategoriRengi(kat);
          return GestureDetector(
            onTap: () => setState(() => _seciliKategori = kat),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? renk.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? renk : Colors.white12),
              ),
              child: Text(
                kat,
                style: TextStyle(
                  color: isSelected ? renk : Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMatrixLogAkisi() {
    Query query = FirebaseFirestore.instance.collection('siber_istihbarat_loglari')
      .orderBy('tarih', descending: true)
      .limit(100);

    if (_seciliKategori != "TÜMÜ") {
      query = query.where('kategori', isEqualTo: _seciliKategori);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(child: Text("> RADAR TEMİZ...", style: TextStyle(color: SiberTema.kuantumCyan, fontFamily: 'Courier', fontWeight: FontWeight.bold)));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          physics: BouncingScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final kategori = data['kategori'] ?? data['islem_turu'] ?? 'SİSTEM';
            final seviye = data['seviye'] ?? 'BİLGİ';
            final mesaj = data['mesaj'] ?? data['islem_detayi'] ?? data['islem_basligi'] ?? '';
            final hedefId = data['hedef_id'] ?? data['kullanici_id'] ?? data['bayi_id'] ?? data['usta_id'] ?? data['fail_adi'] ?? 'Anonim';
            final Timestamp? tStamp = data['tarih'] ?? data['zaman_damgasi'];
            final String saat = tStamp != null ? "${tStamp.toDate().hour.toString().padLeft(2, '0')}:${tStamp.toDate().minute.toString().padLeft(2, '0')}:${tStamp.toDate().second.toString().padLeft(2, '0')}" : "--:--";

            final Color renk = _getKategoriRengi(kategori);
            final bool isKritik = seviye == 'KRİTİK';

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isKritik ? SiberTema.kanKirmizi.withOpacity(0.1) : Colors.black45,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isKritik ? SiberTema.kanKirmizi.withOpacity(0.5) : renk.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.terminal, color: isKritik ? SiberTema.kanKirmizi : renk, size: 14),
                          SizedBox(width: 8),
                          Text("[$saat] HEDEF@$hedefId", style: TextStyle(color: SiberTema.textMuted, fontFamily: 'Courier', fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: isKritik ? SiberTema.kanKirmizi.withOpacity(0.2) : renk.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                        child: Text(isKritik ? "KRİTİK ALARM" : kategori, style: TextStyle(color: isKritik ? SiberTema.kanKirmizi : renk, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text("> [$seviye] OTO_DNA_RADAR", style: TextStyle(color: isKritik ? SiberTema.kanKirmizi : renk, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Courier')),
                  SizedBox(height: 4),
                  Text(mesaj, style: TextStyle(color: isKritik ? Colors.white : Colors.white70, fontSize: 11, fontFamily: 'Courier', fontWeight: isKritik ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
