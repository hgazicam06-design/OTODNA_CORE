// lib/admin/imece_transfer.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI (Mutlak Rota ile Bağlandı)
import 'package:otodna/core/siber_tema.dart';
import 'package:otodna/core/responsive_kalkan.dart';

enum KararTipi { INCELEME, MUSTERI_HATASI, PARCA_GARANTI, ARABULUCU }

class ImeceAdaletPaneli extends StatefulWidget {
  const ImeceAdaletPaneli({super.key});

  @override
  State<ImeceAdaletPaneli> createState() => _ImeceAdaletPaneliState();
}

class _ImeceAdaletPaneliState extends State<ImeceAdaletPaneli> {
  bool _isProcessing = false;

  // --- 🔴 FİREBASE: SİBER MAHKEME VE HAKEM MOTORU ---
  Future<void> _kuantumHukmuVer(String belgeId, Map<String, dynamic> vakaData, KararTipi karar, {double onaylananTutar = 0}) async {
    setState(() => _isProcessing = true);

    try {
      final db = FirebaseFirestore.instance;
      WriteBatch batch = db.batch();

      DocumentReference vakaRef = db.collection('imece_talepleri').doc(belgeId);
      String hataliBayiId = vakaData['hatali_bayi_id'] ?? 'BILINMEYEN';
      String onaranBayiId = vakaData['onaran_bayi_id'] ?? 'BILINMEYEN';
      
      String islemMesaji = "";

      switch (karar) {
        case KararTipi.INCELEME:
          batch.update(vakaRef, {
            'durum': 'İNCELEMEDE - EKSPERTİZ BEKLENİYOR',
            'karar_tarihi': FieldValue.serverTimestamp(),
          });
          islemMesaji = "İMECE DİVANI: Dosya ekspertiz ve kanıt incelemesine alındı.";
          break;

        case KararTipi.MUSTERI_HATASI:
          batch.update(vakaRef, {
            'durum': 'REDDEDİLDİ - KULLANICI HATASI',
            'karar_tarihi': FieldValue.serverTimestamp(),
          });
          islemMesaji = "İMECE DİVANI: Kullanıcı hatası tespit edildi. Usta muaf tutuldu.";
          break;

        case KararTipi.PARCA_GARANTI:
          batch.update(vakaRef, {
            'durum': 'YÖNLENDİRİLDİ - PARÇA GARANTİSİ',
            'karar_tarihi': FieldValue.serverTimestamp(),
          });
          islemMesaji = "İMECE DİVANI: Parça kaynaklı hata. Tedarikçi/Garanti sürecine aktarıldı.";
          break;

        case KararTipi.ARABULUCU:
          // ⚖️ HAKEM KARARI: Adminin belirlediği tutar üzerinden işlem yapılır
          double gaziPayi = onaylananTutar * 0.12;
          double onaranBayiHakedis = onaylananTutar - gaziPayi;

          // 1. Hatalı Bayiden Kesinti
          DocumentReference hataliBayiRef = db.collection('kullanicilar').doc(hataliBayiId);
          batch.update(hataliBayiRef, {'toplam_hakedis': FieldValue.increment(-onaylananTutar)});

          // 2. Onaran Bayiye Ödül
          DocumentReference onaranBayiRef = db.collection('kullanicilar').doc(onaranBayiId);
          batch.update(onaranBayiRef, {'toplam_hakedis': FieldValue.increment(onaranBayiHakedis)});

          // 3. Karargah Finans Merkezine Yatırım
          DocumentReference finansRef = db.collection('finansal_islemler').doc();
          batch.set(finansRef, {
            'islem_tipi': 'IMECE_CEZASI',
            'brut_tutar': onaylananTutar,
            'gazi_payi_12': gaziPayi,
            'hatali_bayi_id': hataliBayiId,
            'onaran_bayi_id': onaranBayiId,
            'vaka_id': belgeId,
            'tarih': FieldValue.serverTimestamp(),
          });

          // 4. Vaka Güncellemesi
          batch.update(vakaRef, {
            'durum': 'ONAYLANDI - ARABULUCU TRANSFERİ',
            'onaylanan_tutar': onaylananTutar,
            'karar_tarihi': FieldValue.serverTimestamp(),
          });

          islemMesaji = "İMECE ARABULUCU: Karargah kararıyla ₺$onaylananTutar transferine hükmedildi.";
          break;
      }

      // 5. Matrix İstihbarat Logu
      DocumentReference logRef = db.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'İMECE_DİVANI',
        'seviye': karar == KararTipi.ARABULUCU ? 'KRİTİK' : 'BİLGİ',
        'islem_detayi': islemMesaji,
        'vaka_id': belgeId,
        'tarih': FieldValue.serverTimestamp(),
      });

      // Tetiği Çek (Atomik İşlem)
      await batch.commit();

      if (!mounted) return;
      _siberUyari("ADALET MÜHRÜ BASILDI: İşlem Başarılı!", SiberTema.kuantumCyan);

    } catch (e) {
      if (!mounted) return;
      _siberUyari("SİBER AĞ HATASI: İşlem Gerçekleştirilemedi! $e", SiberTema.kanKirmizi);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _arabulucuDiyaloguAc(String belgeId, Map<String, dynamic> vakaData) {
    double talepEdilen = (vakaData['tazminat_tutari'] ?? 0).toDouble();
    TextEditingController tutarController = TextEditingController(text: talepEdilen.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: SiberTema.altinSari.withOpacity(0.5))),
          title: const Row(
            children: [
              Icon(Icons.balance, color: SiberTema.altinSari),
              SizedBox(width: 10),
              Text("SİBER HAKEM KARARI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Talep Edilen: ₺\${talepEdilen.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text("Adil Görülen Onarım Bedelini Giriniz:", style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 8),
              TextField(
                controller: tutarController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 24, fontWeight: FontWeight.w900),
                decoration: InputDecoration(
                  prefixText: "₺ ",
                  prefixStyle: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 24, fontWeight: FontWeight.w900),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.3))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.altinSari)),
                ),
              ),
              const SizedBox(height: 12),
              const Text("Sisteme girilen bu tutar üzerinden %12 Karargah payı kesilecek ve para transferi anında gerçekleşecektir.", style: TextStyle(color: Colors.white38, fontSize: 10, fontStyle: FontStyle.italic)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İPTAL", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: SiberTema.altinSari, foregroundColor: Colors.black),
              onPressed: () {
                double girilenTutar = double.tryParse(tutarController.text) ?? 0.0;
                if (girilenTutar > 0) {
                  Navigator.pop(context);
                  _kuantumHukmuVer(belgeId, vakaData, KararTipi.ARABULUCU, onaylananTutar: girilenTutar);
                }
              },
              icon: const Icon(Icons.gavel, size: 16),
              label: const Text("MÜHRÜ VUR & AKTAR", style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );
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
          title: const Text("SİBER MAHKEME & HAKEM DİVANI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
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
        if (snapshot.hasError) return Center(child: Text("Siber Ağ Hatası: \${snapshot.error}", style: const TextStyle(color: SiberTema.kanKirmizi)));

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.balance, color: Colors.white.withOpacity(0.2), size: 60),
                const SizedBox(height: 16),
                Text("DİVAN TEMİZ. Bekleyen Dava Yok.", style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                      const Text("TALEP EDİLEN BEDEL", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Text("₺\${tutar.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kanKirmizi, fontSize: 22, fontWeight: FontWeight.w900)),
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

            // 3. ADMİN KARAR MERKEZİ (4'LÜ HAKEM SİSTEMİ)
            const Center(child: Text("HAKEM KARARI & SİBER MÜHÜR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2))),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildHakemButonu(
                    "EKSPERTİZ İSTE", 
                    Icons.search, 
                    Colors.orangeAccent, 
                    () => _kuantumHukmuVer(belgeId, vakaData, KararTipi.INCELEME)
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildHakemButonu(
                    "MÜŞTERİ HATASI", 
                    Icons.person_off, 
                    SiberTema.kanKirmizi, 
                    () => _kuantumHukmuVer(belgeId, vakaData, KararTipi.MUSTERI_HATASI)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildHakemButonu(
                    "PARÇA GARANTİSİ", 
                    Icons.handyman, 
                    SiberTema.kuantumCyan, 
                    () => _kuantumHukmuVer(belgeId, vakaData, KararTipi.PARCA_GARANTI)
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SiberTema.altinSari, 
                      foregroundColor: SiberTema.oledBlack, 
                      padding: const EdgeInsets.symmetric(vertical: 14), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), 
                      elevation: 10, 
                      shadowColor: SiberTema.altinSari.withOpacity(0.5)
                    ),
                    onPressed: () => _arabulucuDiyaloguAc(belgeId, vakaData),
                    icon: const Icon(Icons.balance, size: 18),
                    label: const Text("ARABULUCU (HAKEM)", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHakemButonu(String baslik, IconData ikon, Color renk, VoidCallback onTapped) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: renk,
        padding: const EdgeInsets.symmetric(vertical: 14), 
        side: BorderSide(color: renk.withOpacity(0.5)), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
      ),
      onPressed: onTapped,
      icon: Icon(ikon, size: 16),
      label: Text(baslik, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
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