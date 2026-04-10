// lib/admin/imece_transfer.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI (Mutlak Rota ile Bağlandı)
import 'package:otodna/core/siber_tema.dart';
import 'package:otodna/core/responsive_kalkan.dart';

class ImeceAdaletPaneli extends StatefulWidget {
  const ImeceAdaletPaneli({super.key});

  @override
  State<ImeceAdaletPaneli> createState() => _ImeceAdaletPaneliState();
}

class _ImeceAdaletPaneliState extends State<ImeceAdaletPaneli> {
  bool _isProcessing = false;

  // --- 🔴 FİREBASE: KUANTUM ADALET MOTORU (PARA TRANSFERİ) ---
  Future<void> _kuantumHukmuVer(String belgeId, Map<String, dynamic> vakaData, bool onaylandiMi) async {
    setState(() => _isProcessing = true);

    try {
      final db = FirebaseFirestore.instance;
      WriteBatch batch = db.batch();

      DocumentReference vakaRef = db.collection('imece_talepleri').doc(belgeId);

      if (onaylandiMi) {
        double tutar = (vakaData['tazminat_tutari'] ?? 0).toDouble();
        String hataliBayiId = vakaData['hatali_bayi_id'];
        String onaranBayiId = vakaData['onaran_bayi_id'];

        // 🔥 SİBER KURAL: Adalet Divanında bile Karargah hakkını alır! (%12 Evrensel Kesinti)
        double gaziPayi = tutar * 0.12;
        double onaranBayiHakedis = tutar - gaziPayi;

        // 1. Hatalı Bayinin Hakedişinden TAM TUTARI Kes (Ceza)
        DocumentReference hataliBayiRef = db.collection('kullanicilar').doc(hataliBayiId);
        batch.update(hataliBayiRef, {'toplam_hakedis': FieldValue.increment(-tutar)});

        // 2. Onaran Bayinin Hakedişine NET TUTARI Ekle (Ödül)
        DocumentReference onaranBayiRef = db.collection('kullanicilar').doc(onaranBayiId);
        batch.update(onaranBayiRef, {'toplam_hakedis': FieldValue.increment(onaranBayiHakedis)});

        // 3. Karargah Kasasına %12 Payı Ekle!
        DocumentReference sistemFinansRef = db.collection('sistem_verileri').doc('finans');
        batch.set(sistemFinansRef, {
          'toplam_gazi_payi': FieldValue.increment(gaziPayi),
          'toplam_ciro': FieldValue.increment(tutar), // İmece hacmini de ciroya yansıt
        }, SetOptions(merge: true));

        // 4. Vaka Durumunu Onaylandı Yap
        batch.update(vakaRef, {
          'durum': 'ONAYLANDI - TRANSFER EDİLDİ',
          'karar_tarihi': FieldValue.serverTimestamp(),
        });

        // 5. Sistem Loglarına (Kara Kutu) İşle
        DocumentReference logRef = db.collection('sistem_loglari').doc();
        batch.set(logRef, {
          'islem_turu': 'basarili',
          'islem_detayi': 'İMECE ADALETİ: ₺$tutar ceza kesildi. ₺$onaranBayiHakedis onaran bayiye, ₺$gaziPayi Karargah kasasına aktarıldı.',
          'bayi_isim': 'ADALET DİVANI',
          'tarih': FieldValue.serverTimestamp(),
        });

      } else {
        // Reddedilirse sadece durumu güncelle
        batch.update(vakaRef, {
          'durum': 'REDDEDİLDİ - İNCELEME',
          'karar_tarihi': FieldValue.serverTimestamp(),
        });
      }

      // Tetiği Çek (Atomik İşlem)
      await batch.commit();

      if (!mounted) return;
      _siberUyari(onaylandiMi ? "MÜHÜR BASILDI: Para Transferi Gerçekleşti! ⚖️" : "VAKA REDDEDİLDİ: İncelemeye Alındı.", onaylandiMi ? SiberTema.kuantumCyan : SiberTema.kanKirmizi);

    } catch (e) {
      if (!mounted) return;
      _siberUyari("SİBER AĞ HATASI: İşlem Gerçekleştirilemedi! $e", SiberTema.kanKirmizi);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _siberUyari(String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(color: renk == SiberTema.kuantumCyan ? SiberTema.oledBlack : Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: renk,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: Colors.transparent, // OLED Siyah
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.gavel, color: SiberTema.altinSari), onPressed: () => Navigator.pop(context)),
          title: const Text("İMECE TRANSFER & ADALET DİVANI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: Container(decoration: BoxDecoration(boxShadow: [BoxShadow(color: SiberTema.altinSari.withOpacity(0.5), blurRadius: 10)], gradient: const LinearGradient(colors: [Colors.transparent, SiberTema.altinSari, Colors.transparent])), height: 2),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/radar_grid.png'),
              fit: BoxFit.cover,
              opacity: 0.05,
            ),
          ),
          child: _isProcessing
              ? _buildKuantumLoader("ADALET MÜHRÜ BASILIYOR...")
              : _buildVakaListesi(),
        ),
      ),
    );
  }

  // --- 🟡 FİREBASE: BEKLEYEN VAKALARI ÇEKME ---
  Widget _buildVakaListesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('imece_talepleri').where('durum', isEqualTo: 'BEKLEMEDE').orderBy('talep_tarihi', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildKuantumLoader("VAKALAR TARANIYOR...");
        if (snapshot.hasError) return Center(child: Text("Siber Ağ Hatası: ${snapshot.error}", style: const TextStyle(color: SiberTema.kanKirmizi)));

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.balance, color: Colors.white.withOpacity(0.2), size: 60),
                const SizedBox(height: 16),
                Text("DİVAN TEMİZ. Bekleyen İmece Talebi Yok.", style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var vakaData = docs[index].data() as Map<String, dynamic>;
            return _buildVakaKarti(docs[index].id, vakaData);
          },
        );
      },
    );
  }

  // --- 🎨 SİBER GÖRSEL ZIRHLAR ---
  Widget _buildVakaKarti(String belgeId, Map<String, dynamic> vakaData) {
    String hataliBayi = vakaData['hatali_bayi_adi'] ?? 'Bilinmiyor';
    String onaranBayi = vakaData['onaran_bayi_adi'] ?? 'Bilinmiyor';
    double tutar = (vakaData['tazminat_tutari'] ?? 0).toDouble();
    String ustaNotu = vakaData['usta_notu'] ?? 'Savunma girilmemiş.';

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: _buildCamEfektliKutu(
        borderColor: SiberTema.altinSari.withOpacity(0.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. VAKA ÖZETİ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: SiberTema.kanKirmizi.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.3))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("TAZMİNAT TUTARI", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Text("₺${tutar.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kanKirmizi, fontSize: 22, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white12)),
                  _vakaDetaySatiri(Icons.error_outline, "Hatalı İşlem Yapan:", hataliBayi, SiberTema.kanKirmizi),
                  const SizedBox(height: 12),
                  _vakaDetaySatiri(Icons.build_circle, "Yolda Onaran Bayi:", onaranBayi, SiberTema.kuantumCyan),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. SAVUNMA VE KANITLAR
            const Text("USTA SAVUNMASI & KANITLAR", style: TextStyle(color: SiberTema.altinSari, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
              child: Text(ustaNotu, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.5)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildNeonIkon(Icons.image_search, Colors.white54),
                const SizedBox(width: 12),
                const Text("Kanıt Görselleri (Sisteme Yüklendi)", style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),

            const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.white12)),

            // 3. ADMİN KARAR MERKEZİ
            const Center(child: Text("SİBER KOMUTAN MÜHRÜ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2))),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Colors.white38), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () => _kuantumHukmuVer(belgeId, vakaData, false),
                    child: const Text("REDDET", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: SiberTema.altinSari, foregroundColor: SiberTema.oledBlack, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 10, shadowColor: SiberTema.altinSari.withOpacity(0.5)),
                    onPressed: () => _kuantumHukmuVer(belgeId, vakaData, true),
                    icon: const Icon(Icons.gavel, size: 20),
                    label: const Text("ONAYLA & TRANSFER ET", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _vakaDetaySatiri(IconData ikon, String baslik, String deger, Color renk) {
    return Row(
      children: [
        Icon(ikon, color: renk, size: 20),
        const SizedBox(width: 12),
        Text(baslik, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const Spacer(),
        Text(deger, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCamEfektliKutu({required Widget child, required Color borderColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor), boxShadow: [BoxShadow(color: SiberTema.altinSari.withOpacity(0.05), blurRadius: 20)]),
          child: child,
        ),
      ),
    );
  }

  Widget _buildNeonIkon(IconData icon, Color renk) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: renk.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: renk.withOpacity(0.3))),
      child: Icon(icon, color: renk, size: 18),
    );
  }

  Widget _buildKuantumLoader(String yazi) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: SiberTema.altinSari, strokeWidth: 3),
          const SizedBox(height: 20),
          Text(yazi, style: const TextStyle(color: SiberTema.altinSari, fontWeight: FontWeight.w900, letterSpacing: 2)),
        ],
      ),
    );
  }
}