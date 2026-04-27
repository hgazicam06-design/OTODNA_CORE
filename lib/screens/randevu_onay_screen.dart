import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🦅 OTO DNA AKILLI RANDEVU VE FİNANSAL TEMİNAT PROTOKOLÜ
/// [2026-03-28] GÜNCELLEME: ATOMİK BATCH İŞLEMİ VE TAZMİNAT MOTORU
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
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;
  bool _isProcessing = false;

  // 🚀 FİREBASE: ATOMİK ÖDEME VE RANDEVU MÜHÜRLEME MOTORU
  Future<void> _odemeProtokolunuBaslat() async {
    if (_user == null) {
      _siberMesajGoster("SİBER İHLAL: Kimlik doğrulanamadı!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. KUANTUM AĞI DOĞRULAMA (Simülasyon - Ödeme Onayı)
      await Future.delayed(const Duration(seconds: 2));

      // 2. FİREBASE ATOMİK İŞLEM (WriteBatch)
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
        'ihlale_tabi': true, // Tazminat motoru için tetikleyici
      });

      // Müşteri Cüzdan Logu (Teminat Kesintisi)
      DocumentReference islemRef = _db.collection('kullanicilar').doc(_user!.uid).collection('islemler').doc();
      batch.set(islemRef, {
        'baslik': 'SİBER TEMİNAT KESİNTİSİ',
        'alt_baslik': widget.islemTipi,
        'tutar': -widget.kaporaBedeli,
        'tarih': FieldValue.serverTimestamp(),
        'tip': 'GİDER',
      });

      await batch.commit();

      if (!mounted) return;
      _siberMesajGoster("SÖZLEŞME MÜHÜRLENDİ! RANDEVU ONAYLANDI. 🦅");

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });

    } catch (e) {
      _siberMesajGoster("AĞ ÇÖKTÜ: Finansal Protokol İhlali!", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _siberMesajGoster(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
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
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text("SİBER SÖZLEŞME ONAYI", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
          centerTitle: true,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
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
                        color: SiberTema.matGrey.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 2),
                        boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 40)],
                      ),
                      child: const Icon(Icons.gavel, color: SiberTema.kuantumCyan, size: 64),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text("AKILLI RANDEVU PROTOKOLÜ", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMain, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Text("İŞLEM: ${widget.islemTipi.toUpperCase()}", textAlign: TextAlign.center, style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 48),

                  // 2. KESİN KURALLAR (Cam Paneller)
                  _buildProtokolMaddesi(
                    Icons.diamond_outlined,
                    "SİBER TEMİNAT KESİNTİSİ",
                    "İşlem güvenliği için Kuantum Cüzdanınızdan ₺${widget.kaporaBedeli.toStringAsFixed(2)} kapora bloke edilecektir.",
                    SiberTema.kuantumCyan,
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
                    "Randevuya mazeretsiz gidmemeniz durumunda ₺100.00 tazminat olarak ustaya aktarılacak, kalan tutar iade edilecektir.",
                    Colors.orangeAccent,
                  ),

                  const SizedBox(height: 48),

                  // 3. FİNANSAL ATEŞLEME BUTONU
                  SizedBox(
                    height: 64,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _odemeProtokolunuBaslat,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SiberTema.kuantumCyan,
                        foregroundColor: SiberTema.oledBlack,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      icon: _isProcessing
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 2))
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
                        style: TextStyle(color: SiberTema.textMuted, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)
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

  Widget _buildProtokolMaddesi(IconData icon, String baslik, String icerik, Color vurguRengi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                Text(icerik, style: const TextStyle(color: SiberTema.textMuted, fontSize: 11, height: 1.5, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}