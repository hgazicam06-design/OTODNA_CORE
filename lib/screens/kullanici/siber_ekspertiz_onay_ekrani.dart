import 'package:flutter/material.dart';
import '../../core/siber_tema.dart';
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
          backgroundColor: const Color(0xFF121B2B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF00FFC2), width: 1.5)),
          title: const Column(
            children: [
              Icon(Icons.fingerprint, color: Color(0xFF00FFC2), size: 64),
              SizedBox(height: 16),
              Text("İKİ ANAHTAR BİRLEŞTİ!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: const Text(
            "GPS Mührünüz ustanın GPS mührüyle birleştirildi.\n\nRapor kilitlendi ve OtoDNA Yapay Zekası aracınızın DNA Skorunu başarıyla güncelledi.", 
            textAlign: TextAlign.center, 
            style: TextStyle(color: Colors.white70, fontSize: 12)
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialogu kapat
                Navigator.pop(context); // Ekrani kapat
              },
              child: const Text("CÜZDANA DÖN", style: TextStyle(color: Color(0xFF00FFC2), fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(sonuc['mesaj']), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.8),
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text("EKSPERTİZ ONAY MERKEZİ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // UYARI PANELİ
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orangeAccent)),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 32),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("USTA ONAYI BEKLENİYOR", style: TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text("Tarcanlar Merkez arabanızı test etti. Lütfen aşağıdaki bulguları inceleyip mührünüzü vurun. İki anahtar birleşmeden işlem Kuantum Ağına geçemez.", style: TextStyle(color: Colors.white70, fontSize: 10)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text("TEST BULGULARI (TASLAK)", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              
              // MOCK RAPOR (Gerçekte Firestore'dan çekilecek)
              _buildBulguKarti("Motor Bloğu & Yağ Kaçakları", "Kusursuz", true),
              _buildBulguKarti("Kaporta, Boya Değişen", "Sağ Arka Çamurluk Boyalı", true),
              _buildBulguKarti("Şase Direkleri, Podye ve Alt Takım", "Hasarlı / Riskli (Tutanak Eklendi)", false),
              
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SiberTema.kuantumCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _onaylaniyor ? null : _raporuMusteriOlarakOnayla,
                  icon: _onaylaniyor 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black))
                      : const Icon(Icons.fingerprint, size: 28),
                  label: Text(_onaylaniyor ? "MÜHÜRLENİYOR..." : "ONAYLA VE SİBER MÜHRÜ VUR", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 16),
              const Center(child: Text("Mühür vurulduktan sonra OtoDNA Skoru güncellenir.", style: TextStyle(color: Colors.white38, fontSize: 10))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulguKarti(String baslik, String sonuc, bool olumlu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
      child: Row(
        children: [
          Icon(olumlu ? Icons.check_circle : Icons.warning_rounded, color: olumlu ? Colors.greenAccent : SiberTema.kanKirmizi, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(sonuc, style: TextStyle(color: olumlu ? Colors.greenAccent : SiberTema.kanKirmizi, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
