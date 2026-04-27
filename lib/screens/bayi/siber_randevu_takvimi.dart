import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA
import '../../core/siber_tema.dart'; // Yolları kendi klasör yapına göre ayarla
import '../../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM RANDEVU RADARI VE TAKVİM MOTORU
/// Bayinin günlük randevularını canlı (Stream) takip ettiği ve yönettiği siber terminal.
class SiberRandevuTakvimi extends StatefulWidget {
  const SiberRandevuTakvimi({super.key});

  @override
  State<SiberRandevuTakvimi> createState() => _SiberRandevuTakvimiState();
}

class _SiberRandevuTakvimiState extends State<SiberRandevuTakvimi> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _bayiId = FirebaseAuth.instance.currentUser?.uid ?? "BILINMEYEN_BAYI";

  DateTime _seciliTarih = DateTime.now();
  bool _isProcessing = false;

  // Standart Karargah Mesai Saatleri
  final List<String> _mesaiSaatleri = [
    "09:00", "10:00", "11:00", "13:00", "14:00", "15:00", "16:00", "17:00"
  ];

  // ── 📅 TARİH SEÇİCİ MOTORU ──
  void _tarihDegistir(DateTime yeniTarih) {
    HapticFeedback.selectionClick();
    setState(() {
      _seciliTarih = yeniTarih;
    });
  }

  // ── 🚀 ATOMİK RANDEVU KİLİTLEME / AÇMA (WRITEBATCH) ──
  Future<void> _randevuSaatiniYonet(String saat, bool isDolu, String? docId) async {
    HapticFeedback.heavyImpact();
    setState(() => _isProcessing = true);

    try {
      WriteBatch batch = _db.batch();
      String tarihFormatli = DateFormat('yyyy-MM-dd').format(_seciliTarih);

      if (isDolu && docId != null) {
        // Zaten doluysa, bayinin randevuyu iptal etmesi/boşa çıkarması
        DocumentReference randevuRef = _db.collection('randevular').doc(docId);
        batch.delete(randevuRef);

        DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
        batch.set(logRef, {
          'islem_turu': 'RANDEVU_IPTAL',
          'islem_detayi': 'SİBER TAKVİM: $_bayiId, $tarihFormatli $saat seansını boşa çıkardı.',
          'tarih': FieldValue.serverTimestamp(),
        });
      } else {
        // Boş saati bayi olarak manuel kapatma (Örn: Dışarıdan müşteri geldi)
        DocumentReference randevuRef = _db.collection('randevular').doc();
        batch.set(randevuRef, {
          'bayi_id': _bayiId,
          'tarih': tarihFormatli,
          'saat': saat,
          'durum': 'MANUEL_KAPALI',
          'olusturma_zamani': FieldValue.serverTimestamp(),
        });

        DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
        batch.set(logRef, {
          'islem_turu': 'RANDEVU_KILIT',
          'islem_detayi': 'SİBER TAKVİM: $_bayiId, $tarihFormatli $saat seansını manuel olarak mühürledi.',
          'tarih': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      developer.log("✅ ONAY: Takvim matrisi başarıyla güncellendi.");

    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: Takvim güncellenemedi!", error: e);
      if (mounted) {
        _siberUyariGoster("SİSTEM HATASI", "Randevu matrisi güncellenemedi.", SiberTema.kritikRed);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.matGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: SiberTema.textMuted, fontSize: 12, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String tarihFormatli = DateFormat('yyyy-MM-dd').format(_seciliTarih);

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("KUANTUM RANDEVU RADARI", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14, fontFamily: 'Avenir')),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: Column(
          children: [
            // ── 📅 1. YATAY TARİH KAYDIRICISI ──
            _buildTarihSecici(),

            const SizedBox(height: 10),
            Container(width: double.infinity, height: 1, color: Colors.white.withOpacity(0.05)),
            const SizedBox(height: 10),

            // ── 📡 2. CANLI SAAT MATRİSİ (FIREBASE STREAM) ──
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db.collection('randevular')
                    .where('bayi_id', isEqualTo: _bayiId)
                    .where('tarih', isEqualTo: tarihFormatli)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
                  }

                  // Dolu saatleri ve doküman ID'lerini bir haritada topla
                  Map<String, Map<String, dynamic>> doluSaatler = {};
                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      var data = doc.data() as Map<String, dynamic>;
                      doluSaatler[data['saat']] = {
                        'docId': doc.id,
                        'durum': data['durum'] ?? 'BILINMIYOR',
                        'plaka': data['plaka'] ?? 'DIŞARIDAN/MANUEL',
                      };
                    }
                  }

                  return Stack(
                    children: [
                      GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _mesaiSaatleri.length,
                        itemBuilder: (context, index) {
                          String saat = _mesaiSaatleri[index];
                          bool isDolu = doluSaatler.containsKey(saat);
                          String? docId = isDolu ? doluSaatler[saat]!['docId'] : null;
                          String plaka = isDolu ? doluSaatler[saat]!['plaka'] : '';

                          return _buildSaatKapsulu(saat, isDolu, plaka, docId);
                        },
                      ),

                      // İşlem sürerken arayüzü kilitleyen Kuantum Kalkanı
                      if (_isProcessing)
                        Container(
                          color: Colors.white.withOpacity(0.5),
                          child: const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan)),
                        )
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 📅 YATAY TARİH SEÇİCİ BİLEŞENİ ──
  Widget _buildTarihSecici() {
    DateTime bugun = DateTime.now();
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 30, // Gelecek 30 günü göster
        itemBuilder: (context, index) {
          DateTime gun = bugun.add(Duration(days: index));
          bool isSelected = gun.day == _seciliTarih.day && gun.month == _seciliTarih.month;

          return GestureDetector(
            onTap: () => _tarihDegistir(gun),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              width: 70,
              decoration: BoxDecoration(
                color: isSelected ? SiberTema.kuantumCyan.withOpacity(0.15) : SiberTema.matGrey,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? SiberTema.kuantumCyan : Colors.white.withOpacity(0.05),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.2), blurRadius: 10)] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('MMM').format(gun).toUpperCase(), style: TextStyle(color: isSelected ? SiberTema.kuantumCyan : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  const SizedBox(height: 4),
                  Text(gun.day.toString(), style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── ⏳ SAAT KAPSÜLÜ (DOLU/BOŞ HÜCRELER) ──
  Widget _buildSaatKapsulu(String saat, bool isDolu, String plaka, String? docId) {
    Color borderColor = isDolu ? SiberTema.kritikRed.withOpacity(0.5) : SiberTema.kuantumCyan.withOpacity(0.5);
    Color bgColor = isDolu ? SiberTema.kritikRed.withOpacity(0.1) : SiberTema.matGrey;
    Color textColor = isDolu ? SiberTema.kritikRed : Colors.white;

    return GestureDetector(
      onTap: () => _randevuSaatiniYonet(saat, isDolu, docId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: isDolu ? [BoxShadow(color: SiberTema.kritikRed.withOpacity(0.1), blurRadius: 10)] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(saat, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'monospace', letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(
              isDolu ? (plaka.isNotEmpty ? plaka : "KAPALI") : "MÜSAİT",
              style: TextStyle(color: isDolu ? SiberTema.kritikRed : SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir', letterSpacing: 1),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}