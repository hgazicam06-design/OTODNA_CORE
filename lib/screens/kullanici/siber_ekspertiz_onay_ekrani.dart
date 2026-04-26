import 'package:flutter/material.dart';
import '../../core/responsive_kalkan.dart';
import '../../services/ekspertiz_muhur_servisi.dart';

class SiberEkspertizOnayEkrani extends StatefulWidget {
  final String saseNo;
  final String raporId;

  const SiberEkspertizOnayEkrani({super.key, required this.saseNo, required this.raporId});

  @override
  State<SiberEkspertizOnayEkrani> createState() => _SiberEkspertizOnayEkraniState();
}

class _SiberEkspertizOnayEkraniState extends State<SiberEkspertizOnayEkrani> {
  bool _onaylaniyor = false;
  final EkspertizMuhurServisi _servis = EkspertizMuhurServisi();

  final Color primaryTeal = Colors.teal.shade700;
  final Color dangerColor = Colors.redAccent;
  final Color warningColor = Colors.orange;
  final Color textColor = const Color(0xFF1E293B);
  final Color bgColor = const Color(0xFFFAFAFC);
  final Color surfaceColor = Colors.white;

  void _raporuMusteriOlarakOnayla() async {
    setState(() => _onaylaniyor = true);

    // Müşteri "Onayla" dediğinde ikinci anahtarı çeviriyoruz.
    final sonuc = await _servis.musteriOnaylaVeMuhrle(widget.raporId, "MUSTERI_UID_123", widget.saseNo);

    setState(() => _onaylaniyor = false);

    if (!mounted) return;

    if (sonuc['basarili']) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
          title: Column(
            children: [
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.fingerprint, color: primaryTeal, size: 64)),
              const SizedBox(height: 24),
              Text("İKİ ANAHTAR BİRLEŞTİ!", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Avenir')),
            ],
          ),
          content: const Text(
            "Müşteri onayınız ustanın mührüyle birleştirildi.\n\nRapor kilitlendi ve OtoDNA sistemleri aracınızın DNA Skorunu başarıyla güncelledi.", 
            textAlign: TextAlign.center, 
            style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir')
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                onPressed: () {
                  Navigator.pop(context); // Dialogu kapat
                  Navigator.pop(context); // Ekrani kapat
                },
                child: const Text("CÜZDANA DÖN", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, fontFamily: 'Avenir')),
              ),
            )
          ],
        ),
      );
    } else {
      _plazaUyariGoster("ONAY HATASI", sonuc['mesaj'], dangerColor);
    }
  }

  void _plazaUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 4),
            Text(mesaj, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => Navigator.pop(context)),
          title: Text("EKSPERTİZ ONAY MERKEZİ", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // UYARI PANELİ
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: warningColor.withValues(alpha: 0.3)), boxShadow: [BoxShadow(color: warningColor.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))]),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: warningColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.warning_amber_rounded, color: warningColor, size: 28)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("MÜŞTERİ ONAYI BEKLENİYOR", style: TextStyle(color: warningColor, fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 0.5)),
                          const SizedBox(height: 8),
                          const Text("Merkez Bayi aracınızı test etti. Lütfen aşağıdaki bulguları inceleyip mührünüzü vurun. İki anahtar birleşmeden işlem resmiyet kazanamaz.", style: TextStyle(color: Colors.black54, fontSize: 10, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),

              const Text("TEST BULGULARI (TASLAK)", style: TextStyle(color: Colors.black45, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
              const SizedBox(height: 16),
              
              // MOCK RAPOR (Gerçekte Firestore'dan çekilecek)
              _buildBulguKarti("Motor Bloğu & Yağ Kaçakları", "Kusursuz", true),
              _buildBulguKarti("Kaporta, Boya Değişen", "Sağ Arka Çamurluk Boyalı", true),
              _buildBulguKarti("Şase Direkleri, Podye ve Alt Takım", "Hasarlı / Riskli (Tutanak Eklendi)", false),
              
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _onaylaniyor ? null : _raporuMusteriOlarakOnayla,
                  icon: _onaylaniyor 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.fingerprint, size: 24),
                  label: Text(_onaylaniyor ? "SİSTEME İŞLENİYOR..." : "ONAYLA VE MÜHRÜ VUR", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                ),
              ),
              const SizedBox(height: 24),
              const Center(child: Text("Mühür vurulduktan sonra OtoDNA Skoru güncellenir ve rapor kilitlenir.", textAlign: TextAlign.center, style: TextStyle(color: Colors.black38, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulguKarti(String baslik, String sonuc, bool olumlu) {
    Color durumRengi = olumlu ? Colors.green : dangerColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: durumRengi.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(olumlu ? Icons.check_circle : Icons.warning_rounded, color: durumRengi, size: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                const SizedBox(height: 6),
                Text(sonuc, style: TextStyle(color: durumRengi, fontSize: 11, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
              ],
            ),
          )
        ],
      ),
    );
  }
}
