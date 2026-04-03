// lib/screens/arac_profil_ekrani.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM ARAÇ DNA PROFİLİ
/// Siber Göz'ün (QR Radar) bulduğu şase numarasını Matrix'te sorgular ve sicilini döker.
class AracProfilEkrani extends StatefulWidget {
  final String saseNo; // Radardan gelen kripto şase numarası

  const AracProfilEkrani({super.key, required this.saseNo});

  @override
  State<AracProfilEkrani> createState() => _AracProfilEkraniState();
}

class _AracProfilEkraniState extends State<AracProfilEkrani> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Zırh arka planı hallediyor
        appBar: AppBar(
          title: const Text("SİBER SİCİL RAPORU", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: SiberTema.kuantumCyan),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          // Matrix'ten doğrudan aracın kimlik belgesini çekiyoruz
          stream: _db.collection('arac_kimlikleri').doc(widget.saseNo).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return _buildKritikIhlalEkrani();
            }

            var aracData = snapshot.data!.data() as Map<String, dynamic>;
            int dnaSkoru = (aracData['dna_skoru'] ?? 0).toInt();
            String muayeneDurumu = aracData['muayene_durumu'] ?? "BİLİNMİYOR";
            String plaka = aracData['plaka'] ?? "PLAKA GİZLİ";
            String markaModel = aracData['marka_model'] ?? "Bilinmeyen Kasa";

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. OTONOM DNA SKOR RADARI
                  _buildKuantumSkorRadari(dnaSkoru, muayeneDurumu),
                  const SizedBox(height: 30),

                  // 2. KİMLİK BİLGİLERİ (Siber Cam Kalkanı İçinde)
                  SiberTema.siberCamKalkan(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildSiberSatir("KAYITLI PLAKA", plaka, isBuyuk: true),
                        const Divider(color: Colors.white24, height: 30),
                        _buildSiberSatir("MARKA / MODEL", markaModel),
                        const Divider(color: Colors.white12, height: 20),
                        _buildSiberSatir("KRİPTO ŞASE NO", widget.saseNo),
                        const Divider(color: Colors.white12, height: 20),
                        _buildSiberSatir(
                            "SON İSTİHBARAT GÜNCELLEMESİ",
                            aracData['son_muayene_zaman_damgasi'] != null
                                ? (aracData['son_muayene_zaman_damgasi'] as Timestamp).toDate().toString().split('.')[0]
                                : "Kayıt Yok"
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 3. GEÇMİŞ İHLALLER VE BAKIMLAR (Canlı Alt Liste)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("SİBER BAKIM GEÇMİŞİ", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ),
                  const SizedBox(height: 12),
                  _buildGecmisIslemlerListesi(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI VE MOTORLAR ──

  Widget _buildKritikIhlalEkrani() {
    return Center(
      child: SiberTema.siberCamKalkan(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: SiberTema.kanKirmizi, size: 80),
            const SizedBox(height: 16),
            const Text("SİCİL BULUNAMADI!", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text("Şase No: ${widget.saseNo}\nBu araç OtoDNA Karargahına kayıtlı değil veya Kuantum Ağına henüz bağlanmamış.", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildKuantumSkorRadari(int skor, String durum) {
    // Skora göre otonom renk ve ikon tespiti
    Color skorRengi = skor >= 80 ? SiberTema.kuantumCyan : (skor >= 50 ? SiberTema.altinSari : SiberTema.kanKirmizi);
    IconData skorIkoni = skor >= 80 ? Icons.verified : (skor >= 50 ? Icons.warning_amber : Icons.gavel);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: SiberTema.matGrey,
        border: Border.all(color: skorRengi.withOpacity(0.5), width: 4),
        boxShadow: [BoxShadow(color: skorRengi.withOpacity(0.2), blurRadius: 40, spreadRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(skorIkoni, color: skorRengi, size: 40),
          const SizedBox(height: 8),
          Text("$skor", style: TextStyle(color: skorRengi, fontSize: 60, fontWeight: FontWeight.w900, height: 1)),
          const Text("DNA SKORU", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: skorRengi.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: skorRengi)),
            child: Text(durum.toUpperCase(), style: TextStyle(color: skorRengi, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildSiberSatir(String etiket, String deger, {bool isBuyuk = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(etiket, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        Flexible(
          child: Text(deger, textAlign: TextAlign.right, style: TextStyle(color: isBuyuk ? SiberTema.kuantumCyan : Colors.white, fontSize: isBuyuk ? 18 : 14, fontWeight: isBuyuk ? FontWeight.w900 : FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildGecmisIslemlerListesi() {
    return StreamBuilder<QuerySnapshot>(
      // Bu aracın şasesine ait tamamlanmış işlemleri/bakımları tarih sırasına göre çeker
      stream: _db.collection('arac_bakimlari').where('sase_no', isEqualTo: widget.saseNo).orderBy('olusturulma_zaman_damgasi', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
            child: const Text("Karargah kayıtlarında bu araca ait geçmiş bir işlem bulunamadı.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white30, fontStyle: FontStyle.italic)),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var islem = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            bool tamamlandi = islem['durum'] == "TAMAMLANDI";

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SiberTema.matGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tamamlandi ? SiberTema.kuantumCyan.withOpacity(0.3) : SiberTema.kanKirmizi.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(tamamlandi ? Icons.check_circle : Icons.pending_actions, color: tamamlandi ? SiberTema.kuantumCyan : SiberTema.altinSari, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(islem['islem_adi'] ?? "Genel Kontrol / Muayene", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text("KM: ${islem['baslangic_km']}  |  Durum: ${islem['durum']}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}