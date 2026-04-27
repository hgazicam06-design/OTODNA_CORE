import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // 🚀 pubspec.yaml'da eklendiğinden emin ol!
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA (7D Zırh v2.0)
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

// 🚨 DİKKAT: Ekspertiz Kokpiti henüz oluşturulmadıysa altı kırmızı çizer!
// Şimdilik importu kapalı tutuyorum, dosyayı yapınca başındaki "//" işaretini kaldır.
// import '../bayi/ekspertiz_kokpiti_screen.dart';

class SiberGozTerminali extends StatefulWidget {
  const SiberGozTerminali({super.key});

  @override
  State<SiberGozTerminali> createState() => _SiberGozTerminaliState();
}

class _SiberGozTerminaliState extends State<SiberGozTerminali> {
  bool _isScanning = true;
  bool _isLoading = false;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 👁️ SİBER GÖZ: QR TARAMA VE DNA ÇEKME MOTORU ---
  Future<void> _aracDnaSifresiniCoz(String qrData) async {
    if (_isLoading) return; // Çift tetiklemeyi engelle

    setState(() {
      _isScanning = false;
      _isLoading = true;
    });

    try {
      // 1. AŞAMA: Siber Ağda Araç DNA'sını Ara
      final doc = await _db.collection('araclar').doc(qrData).get();

      if (doc.exists) {
        // 2. AŞAMA: Sistem Loglarına (Kara Kutu) Mühür Vur
        await _db.collection('sistem_loglari').add({
          'islem_turu': 'qr_tarama',
          'islem_detayi': 'SİBER GÖZ: $qrData plakalı aracın QR kodu başarıyla tarandı.',
          'tarih': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        _siberUyariVer("SİNYAL ALINDI: Araç DNA'sı Tanımlandı!", false);

        // 3. AŞAMA: Kuantum Sıçraması (Kokpite Yönlendir)
        // 🚨 NOT: EkspertizKokpitiScreen hazır olana kadar burayı geçici olarak pop() yapıyoruz.
        // Dosya hazır olduğunda alttaki yorumu açıp Navigator.pop satırını silebilirsin.

        Navigator.pop(context);

        /* Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EkspertizKokpitiScreen(
              aracId: qrData,
              bayiId: "BAYI_001", // Burası dinamik gelmeli!
            ),
          ),
        );
        */
      } else {
        _siberUyariVer("İHLAL: Geçersiz veya Kayıtsız QR Kod!", true);
        setState(() => _isScanning = true);
      }
    } catch (e) {
      _siberUyariVer("BAĞLANTI HATASI: Siber Ağda Kesinti!", true);
      setState(() => _isScanning = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _siberUyariVer(String mesaj, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'Avenir', fontSize: 12)),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan.withOpacity(0.8), // 🛠️ alarmRed yerine kanKirmizi kullanıldı
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: const Text("SİBER GÖZ: ARAÇ TANIMA", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14, fontFamily: 'Avenir')), // 🛠️ siberFont yerine Avenir kullanıldı
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // 📡 GERÇEK ZAMANLI RADAR TARAYICI
            if (_isScanning)
              MobileScanner(
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      _aracDnaSifresiniCoz(barcode.rawValue!);
                      break;
                    }
                  }
                },
              ),

            // 🛡️ 7D SİBER OVERLAY (Zırhlı Tarama Alanı)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: SiberTema.textMuted, width: 1)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Kuantum Çerçeve
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                          border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.1), blurRadius: 40, spreadRadius: 5),
                          ]
                      ),
                      child: Stack(
                        children: [
                          // Köşe Zırhları (Siber Detay)
                          Positioned(top: 0, left: 0, child: _buildKoseZirhi(0)),
                          Positioned(top: 0, right: 0, child: _buildKoseZirhi(1)),
                          Positioned(bottom: 0, left: 0, child: _buildKoseZirhi(2)),
                          Positioned(bottom: 0, right: 0, child: _buildKoseZirhi(3)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    const Text(
                      "QR KODU SİBER GÖZ HİZASINA GETİRİN",
                      style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 3, fontFamily: 'Avenir'), // 🛠️ siberFont düzeltildi
                    ),
                  ],
                ),
              ),
            ),

            // 📟 ALT BİLGİ PANELİ
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: _buildAltBilgiPaneli(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAltBilgiPaneli() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SiberTema.oledBlack.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SiberTema.textMuted, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.white54, blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildStatusLed(_isLoading),
              const SizedBox(width: 12),
              const Text("SİSTEM DURUMU:", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const Spacer(),
              Text(_isLoading ? "DNA ANALİZİ YAPILIYOR..." : "RADAR AKTİF", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
          if (_isLoading) ...[
            const SizedBox(height: 20),
            const LinearProgressIndicator(backgroundColor: Colors.white10, color: SiberTema.kuantumCyan, minHeight: 2),
          ]
        ],
      ),
    );
  }

  Widget _buildKoseZirhi(int index) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: (index == 0 || index == 1) ? const BorderSide(color: SiberTema.kuantumCyan, width: 4) : BorderSide.none,
          bottom: (index == 2 || index == 3) ? const BorderSide(color: SiberTema.kuantumCyan, width: 4) : BorderSide.none,
          left: (index == 0 || index == 2) ? const BorderSide(color: SiberTema.kuantumCyan, width: 4) : BorderSide.none,
          right: (index == 1 || index == 3) ? const BorderSide(color: SiberTema.kuantumCyan, width: 4) : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildStatusLed(bool active) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? const Color(0xFFFFB300) : SiberTema.kuantumCyan,
          boxShadow: [
            BoxShadow(color: active ? const Color(0xFFFFB300) : SiberTema.kuantumCyan, blurRadius: 10, spreadRadius: 1),
          ]
      ),
    );
  }
}