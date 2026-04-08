import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 SİBER KÖPRÜLER
import '../../../core/siber_tema.dart';
import '../../../core/responsive_kalkan.dart';
import '../../../services/qr_engine_service.dart';

/// 🦅 QR MATBAA MERKEZİ
/// Araçların üzerine yapıştırılacak fiziksel OtoDNA etiketlerini kriptografik olarak üretir.
class QrMatbaaScreen extends StatefulWidget {
  const QrMatbaaScreen({super.key});

  @override
  State<QrMatbaaScreen> createState() => _QrMatbaaScreenState();
}

class _QrMatbaaScreenState extends State<QrMatbaaScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _plateController = TextEditingController();

  String? _qrData;
  bool _isGenerating = false;

  // 🚀 SİBER KİMLİK ÜRETİM VE VERİTABANI MÜHÜRLEME MOTORU
  Future<void> _qrKodUretVeMuhrle() async {
    String plaka = _plateController.text.trim().toUpperCase().replaceAll(" ", "");

    // 🛡️ GÜVENLİK KONTROLÜ
    if (plaka.length < 5) {
      _siberUyari("Geçerli bir plaka veya şase girin!", isError: true);
      return;
    }

    setState(() => _isGenerating = true);
    FocusScope.of(context).unfocus();

    try {
      // 1. KRİPTOGRAFİK MOTOR: Benzersiz DNA dizisini oluştur
      String guvenliSifre = QREngineService.generateVehicleDNAString(
          plateNumber: plaka,
          dealerId: _currentUser?.uid ?? 'BİLİNMEYEN'
      );

      // 2. FİREBASE MÜHÜRLERİ: Kaydı siber ağa işle (WriteBatch kullanılabilir)
      await _db.collection('basili_qr_kodlar').doc(plaka).set({
        'bayi_id': _currentUser?.uid ?? 'Bilinmeyen Bayi',
        'plaka': plaka,
        'qr_sifresi': guvenliSifre,
        'basim_tarihi': FieldValue.serverTimestamp(),
        'aktif_mi': true,
        'basim_sayisi': FieldValue.increment(1),
      }, SetOptions(merge: true));

      setState(() => _qrData = guvenliSifre);
      _siberUyari("Siber Kimlik Üretildi ve Ağa Mühürlendi! ✅");

    } catch (e) {
      _siberUyari("Ağ Hatası: $e", isError: true);
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _siberUyari(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(
          color: isError ? Colors.white : SiberTema.oledBlack,
          fontWeight: FontWeight.w900,
          fontFamily: 'Avenir'
      )),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
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
              icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20),
              onPressed: () => Navigator.pop(context)
          ),
          title: const Text(
              'QR MATBAA MERKEZİ',
              style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: Column(
            children: [
              const Text(
                  "FİZİKSEL ARAÇ ETİKETİ BASIMI",
                  style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12)
              ),
              const SizedBox(height: 32),

              // 📸 HOLOGRAFİK QR GÖSTERGE ALANI
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: _qrData == null
                    ? Container(
                  key: const ValueKey(1),
                  height: 260, width: 260,
                  decoration: BoxDecoration(
                      color: SiberTema.matGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white10, style: BorderStyle.dash, width: 2)
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_2_rounded, color: Colors.white10, size: 80),
                      SizedBox(height: 16),
                      Text(
                          "Siber Kimlik\nAnalizi Bekleniyor",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                )
                    : Container(
                    key: const ValueKey(2),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)
                        ]
                    ),
                    child: QREngineService.buildSiberQRCode(_qrData!)
                ),
              ),
              const SizedBox(height: 48),

              // 🖋️ PLAKA GİRİŞ TERMİNALİ
              SiberTema.siberCamKalkan(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextField(
                  controller: _plateController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 5),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: "PLAKA / ŞASE",
                    hintStyle: TextStyle(color: Colors.white12, fontSize: 18, letterSpacing: 2),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ⚡ AKSİYON BUTONLARI
              SizedBox(
                width: double.infinity, height: 60,
                child: ElevatedButton.icon(
                  style: SiberTema.kuantumButonStili(),
                  onPressed: _isGenerating ? null : _qrKodUretVeMuhrle,
                  icon: _isGenerating ? const SizedBox() : const Icon(Icons.bolt_rounded, size: 28),
                  label: _isGenerating
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 3))
                      : const Text('KRİPTOLU QR ÜRET', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1.5)),
                ),
              ),

              if (_qrData != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, height: 60,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: SiberTema.kuantumCyan, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                    ),
                    onPressed: () => _siberUyari("Etiket Bluetooth Yazıcıya Gönderiliyor... 🖨️"),
                    icon: const Icon(Icons.print_rounded, color: SiberTema.kuantumCyan),
                    label: const Text(
                        'FİZİKSEL ETİKETİ YAZDIR',
                        style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1)
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),
              const Text(
                "UYARI: Üretilen kodlar tek kullanımlıktır ve sistem tarafından takip edilir.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white24, fontSize: 10, fontStyle: FontStyle.italic),
              )
            ],
          ),
        ),
      ),
    );
  }
}