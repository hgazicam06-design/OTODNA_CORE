import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RandevuOnayScreen extends StatefulWidget {
  final String ustaId;
  final String islemTipi;
  final double kaporaBedeli;

  const RandevuOnayScreen({
    super.key,
    this.ustaId = "SİBER-USTA-001",
    this.islemTipi = "KUANTUM EKSPERTİZ",
    this.kaporaBedeli = 200.0
  });

  @override
  State<RandevuOnayScreen> createState() => _RandevuOnayScreenState();
}

class _RandevuOnayScreenState extends State<RandevuOnayScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;
  static const Color warningColor = Colors.orangeAccent;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  bool _isProcessing = false;

  // 🚀 FİREBASE: ATOMİK ÖDEME VE RANDEVU MOTORU
  Future<void> _odemeProtokolunuBaslat() async {
    if (_user == null) {
      _uyariGoster("SİBER İHLAL: Kimlik doğrulanamadı!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. Kuantum Ağına Güvenli Bağlantı Simülasyonu (İyzico / Kredi Kartı servisi buraya girecek)
      await Future.delayed(const Duration(seconds: 2));

      // 2. Firebase Atomik İşlem (WriteBatch) - Hem randevu oluştur hem bakiye düş
      WriteBatch batch = _db.batch();

      // Randevu Kaydı
      DocumentReference randevuRef = _db.collection('randevular').doc();
      batch.set(randevuRef, {
        'musteri_id': _user!.uid,
        'usta_id': widget.ustaId,
        'islem': widget.islemTipi,
        'kapora': widget.kaporaBedeli,
        'durum': 'ONAYLANDI',
        'tarih': FieldValue.serverTimestamp(),
      });

      // İşlem Logu (Kullanıcının cüzdanına yansıyacak olan kısım)
      DocumentReference islemRef = _db.collection('kullanicilar').doc(_user!.uid).collection('islemler').doc();
      batch.set(islemRef, {
        'baslik': 'SİBER TEMİNAT KESİNTİSİ',
        'alt_baslik': widget.islemTipi,
        'tutar': -widget.kaporaBedeli, // Eksi bakiye
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (!mounted) return;
      _uyariGoster("SÖZLEŞME MÜHÜRLENDİ! RANDEVU ONAYLANDI. 🦅");

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context); // İşlem bitince terminali kapat
      });

    } catch (e) {
      _uyariGoster("AĞ ÇÖKTÜ: Finansal Protokol İhlali!", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _uyariGoster(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1)),
        backgroundColor: isError ? dangerColor : primaryCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("SİBER SÖZLEŞME ONAYI", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // 🖥️ Web / Double Teyp Kalkanı
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. MÜHÜR LOGOSU
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryCyan.withOpacity(0.5), width: 2),
                        boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.15), blurRadius: 40, spreadRadius: 10)],
                      ),
                      child: const Icon(Icons.gavel, color: primaryCyan, size: 64),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text("AKILLI RANDEVU PROTOKOLÜ", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Text("İŞLEM: ${widget.islemTipi.toUpperCase()}", textAlign: TextAlign.center, style: const TextStyle(color: primaryCyan, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 48),

                  // 2. KESİN KURALLAR LİSTESİ (Cam Paneller)
                  _buildProtokolMaddesi(
                    Icons.diamond_outlined,
                    "SİBER TEMİNAT KESİNTİSİ",
                    "İşlem güvenliği için Kuantum Cüzdanınızdan ₺${widget.kaporaBedeli.toStringAsFixed(2)} kapora bloke edilecektir.",
                    primaryCyan,
                  ),
                  _buildProtokolMaddesi(
                    Icons.security,
                    "ANKARA MERKEZ GÜVENCESİ",
                    "Bloke edilen bu tutar havuzda tutulur ve işlem bittiğinde usta faturasından otomatik olarak düşülür.",
                    Colors.blueAccent,
                  ),
                  _buildProtokolMaddesi(
                    Icons.warning_amber_rounded,
                    "RANDEVU İHLAL CEZASI",
                    "Randevuya mazeretsiz gitmemeniz durumunda ₺100.00 tazminat olarak ustaya aktarılacak, kalan tutar iade edilecektir.",
                    warningColor,
                  ),

                  const SizedBox(height: 48),

                  // 3. FİNANSAL ATEŞLEME BUTONU
                  SizedBox(
                    height: 64,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _odemeProtokolunuBaslat,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        disabledBackgroundColor: primaryCyan.withOpacity(0.2),
                      ),
                      icon: _isProcessing
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Icon(Icons.fingerprint, size: 24),
                      label: Text(
                        _isProcessing ? "AĞ DOĞRULANIYOR..." : "PROTOKOLÜ KABUL ET VE ÖDE",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
                    ),
                  ),

                  // 4. MERKEZ BİLGİLENDİRMESİ
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Text(
                        "OtoDNA Kuantum Ağı %12 Finansal Kesinti Protokolü devrededir.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER PROTOKOL MADDELERİ
  Widget _buildProtokolMaddesi(IconData icon, String baslik, String icerik, Color vurguRengi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: vurguRengi.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: vurguRengi, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik, style: TextStyle(color: vurguRengi, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text(icerik, style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.5, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}