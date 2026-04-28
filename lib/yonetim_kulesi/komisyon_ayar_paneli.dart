import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otodna/core/siber_tema.dart';
import 'package:otodna/core/responsive_kalkan.dart';

/// 💰 SİBER KOMİSYON AYAR PANELİ (FİNANS MOTORU KONTROLÜ)
/// Sistemdeki "Gazi Payı" (platform hizmet bedeli) ve diğer komisyon oranlarının anlık değiştiği terminal.
class KomisyonAyarPaneli extends StatefulWidget {
  const KomisyonAyarPaneli({super.key});

  @override
  State<KomisyonAyarPaneli> createState() => _KomisyonAyarPaneliState();
}

class _KomisyonAyarPaneliState extends State<KomisyonAyarPaneli> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Varsayılan Değerler (OtoDNA Ağ Kesintisi %12 vs)
  double _hizmetBedeliYuzdesi = 10.0;
  double _vergiKesintisiYuzdesi = 2.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _ayarlariYukle();
  }

  Future<void> _ayarlariYukle() async {
    try {
      var doc = await _db.collection('sistem_ayarlari').doc('finans_motoru').get();
      if (doc.exists) {
        setState(() {
          _hizmetBedeliYuzdesi = (doc.data()?['hizmet_bedeli_yuzdesi'] ?? 10.0).toDouble();
          _vergiKesintisiYuzdesi = (doc.data()?['vergi_kesintisi_yuzdesi'] ?? 2.0).toDouble();
        });
      } else {
        // Doküman yoksa varsayılanları oluştur
        await _ayarlariKaydet(gosterSnackbar: false);
      }
    } catch (e) {
      // Offline modda varsayılanları kullan
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _ayarlariKaydet({bool gosterSnackbar = true}) async {
    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);

    try {
      await _db.collection('sistem_ayarlari').doc('finans_motoru').set({
        'hizmet_bedeli_yuzdesi': _hizmetBedeliYuzdesi,
        'vergi_kesintisi_yuzdesi': _vergiKesintisiYuzdesi,
        'guncellenme_tarihi': FieldValue.serverTimestamp(),
      });

      // Kritik Log Düş
      await _db.collection('sistem_loglari').add({
        'islem_turu': 'FINANS_MOTORU_GUNCELLEMESI',
        'islem_detayi': 'Sistem genel komisyon oranları değiştirildi. Yeni Hizmet Bedeli: %$_hizmetBedeliYuzdesi, Yeni Vergi: %$_vergiKesintisiYuzdesi',
        'tarih': FieldValue.serverTimestamp(),
      });

      if (gosterSnackbar && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("YENİ FİNANS PROTOKOLLERİ MÜHÜRLENDİ! 🛡️", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: SiberTema.kuantumCyan,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("KAYIT HATASI", style: TextStyle(color: Colors.white)),
          backgroundColor: SiberTema.kanKirmizi,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double toplamAgiKesintisi = _hizmetBedeliYuzdesi + _vergiKesintisiYuzdesi;

    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => context.pop()),
          title: Text("FİNANS MOTORU KONTROLÜ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 2.0, fontSize: 13)),
          centerTitle: true,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: SiberTema.siberKutuZirhi,
                      child: Column(
                        children: [
                          Icon(Icons.account_balance, color: SiberTema.siberGold, size: 48),
                          const SizedBox(height: 16),
                          Text("TOPLAM AĞ KESİNTİSİ", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2.0, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            "%${toplamAgiKesintisi.toStringAsFixed(1)}",
                            style: TextStyle(color: SiberTema.siberGold, fontSize: 40, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Bu oran tüm B2B ticaretlerden ve parça satışlarından anlık olarak tahsil edilecektir. İşçilik bedelleri %100 bayiye aittir.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    _buildAyarKarti(
                      "OtoDNA Platform Hizmet Bedeli",
                      "Sistemin komisyon oranı.",
                      _hizmetBedeliYuzdesi,
                      SiberTema.kuantumCyan,
                      (val) => setState(() => _hizmetBedeliYuzdesi = val),
                    ),
                    
                    const SizedBox(height: 20),

                    _buildAyarKarti(
                      "Yasal Vergi Kesintisi",
                      "Mecburi devlet vergilendirme oranı.",
                      _vergiKesintisiYuzdesi,
                      SiberTema.kanKirmizi,
                      (val) => setState(() => _vergiKesintisiYuzdesi = val),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: SiberTema.kuantumButonStili(renk: SiberTema.siberGold),
                        icon: Icon(Icons.shield, color: SiberTema.oledBlack),
                        label: const Text("YENİ PROTOKOLLERİ MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                        onPressed: _ayarlariKaydet,
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAyarKarti(String baslik, String aciklama, double deger, Color renk, ValueChanged<double> onChanged) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SiberTema.oledBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: renk.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(baslik, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text("%${deger.toStringAsFixed(1)}", style: TextStyle(color: renk, fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 8),
          Text(aciklama, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: renk,
              inactiveTrackColor: Colors.white12,
              thumbColor: renk,
              overlayColor: renk.withOpacity(0.2),
              trackHeight: 4.0,
            ),
            child: Slider(
              value: deger,
              min: 0.0,
              max: 30.0,
              divisions: 60, // 0.5 adımlarla
              onChanged: (val) {
                HapticFeedback.selectionClick();
                onChanged(val);
              },
            ),
          )
        ],
      ),
    );
  }
}
