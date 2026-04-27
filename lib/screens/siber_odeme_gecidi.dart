// lib/screens/siber_odeme_gecidi.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🛡️ SİBER ÖDEME GEÇİDİ (PayTR / Stripe 3D Secure Simülasyonu)
/// Kuantum şifreleme mantığıyla çalışan zırhlı kredi kartı ve sanal POS arayüzü.
class SiberOdemeGecidi extends StatefulWidget {
  final String bayiId;
  final double tutar;
  final String islemTuru; // Örn: "BILANCO_KILIDI", "ULTRA_ABONELIK"
  final String islemBaslik;

  const SiberOdemeGecidi({
    super.key,
    required this.bayiId,
    required this.tutar,
    required this.islemTuru,
    required this.islemBaslik,
  });

  @override
  State<SiberOdemeGecidi> createState() => _SiberOdemeGecidiState();
}

class _SiberOdemeGecidiState extends State<SiberOdemeGecidi> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _kartSahibiCtrl = TextEditingController();
  final TextEditingController _kartNoCtrl = TextEditingController();
  final TextEditingController _ayYilCtrl = TextEditingController();
  final TextEditingController _cvcCtrl = TextEditingController();
  final TextEditingController _smsKoduCtrl = TextEditingController();

  bool _isProcessing = false;
  bool _is3DSecure = false; // SMS ekranına geçiş

  // 🚀 1. AŞAMA: Bankaya Bağlanma ve 3D Secure Talebi
  Future<void> _odemeyiBaslat() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();
    developer.log("SİBER POS: 3D Secure bağlantısı kuruluyor... (${widget.tutar} ₺)");

    // Banka bağlantı simülasyonu
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
      _is3DSecure = true; // SMS onay ekranını aç
    });

    _siberUyariGoster("3D SECURE ONAYI", "Bankanızdan gelen 6 haneli SMS şifresini giriniz.", SiberTema.altinSari);
  }

  // 🛡️ 2. AŞAMA: 3D Secure Onayı ve Karargaha Mühürleme
  Future<void> _smsOnaylaVeMuhurle() async {
    if (_smsKoduCtrl.text.length < 6) {
      _siberUyariGoster("HATALI ŞİFRE", "Lütfen 6 haneli SMS kodunu eksiksiz girin.", SiberTema.kanKirmizi);
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();
    developer.log("SİBER POS: Ödeme onaylanıyor ve Kuantum Ağına işleniyor...");

    // Ödeme onayı simülasyonu
    await Future.delayed(const Duration(seconds: 2));

    try {
      WriteBatch batch = _db.batch();

      // 1. İşlem türüne göre ilgili zırhı aç
      DocumentReference userRef = _db.collection('kullanicilar').doc(widget.bayiId);
      if (widget.islemTuru == 'BILANCO_KILIDI') {
        batch.update(userRef, {'ciro_kilidi_acik': true});
      } else if (widget.islemTuru.contains('ABONELIK')) {
        batch.update(userRef, {'abonelik_paketi': widget.islemTuru.replaceAll('_ABONELIK', '')});
      }

      // 2. Ödeme Logunu (Faturasını) Kaydet
      DocumentReference odemeRef = _db.collection('siber_odemeler').doc();
      batch.set(odemeRef, {
        'odeme_id': odemeRef.id,
        'bayi_id': widget.bayiId,
        'tutar': widget.tutar,
        'islem_turu': widget.islemTuru,
        'durum': 'BAŞARILI',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (mounted) {
        _siberUyariGoster("ÖDEME BAŞARILI", "Siber kilitler açıldı. Güvenli Karargaha yönlendiriliyorsunuz.", SiberTema.kuantumCyan);
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context, true); // True döndürerek başarılı olduğunu bildir
      }
    } catch (e) {
      developer.log("ÖDEME HATASI", error: e);
      _siberUyariGoster("SİBER AĞ ÇÖKTÜ", "Ödeme alınamadı. Lütfen tekrar deneyin.", SiberTema.kanKirmizi);
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("SİBER ÖDEME GEÇİDİ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, fontFamily: 'Avenir')),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: _is3DSecure ? _build3DSecureEkrani() : _buildKrediKartiEkrani(),
          ),
        ),
      ),
    );
  }

  // 💳 KREDİ KARTI FORMU (AŞAMA 1)
  Widget _buildKrediKartiEkrani() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: SiberTema.siberCamZirh(renk: Colors.black),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BAŞLIK VE TUTAR
            Center(
              child: Column(
                children: [
                  const Icon(Icons.security, color: SiberTema.altinSari, size: 40),
                  const SizedBox(height: 12),
                  Text(widget.islemBaslik, textAlign: TextAlign.center, style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Text("₺${widget.tutar.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // KART GİRİŞLERİ
            _buildSiberInput(controller: _kartSahibiCtrl, hint: "KART ÜZERİNDEKİ İSİM", isRequired: true),
            _buildSiberInput(controller: _kartNoCtrl, hint: "KART NUMARASI (16 Hane)", isNumber: true, isRequired: true),
            Row(
              children: [
                Expanded(child: _buildSiberInput(controller: _ayYilCtrl, hint: "AY / YIL", isRequired: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildSiberInput(controller: _cvcCtrl, hint: "CVC", isNumber: true, isRequired: true)),
              ],
            ),
            const SizedBox(height: 32),

            // ÖDEME BUTONU
            SizedBox(
              width: double.infinity,
              height: 55,
              child: _isProcessing
                  ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                  : ElevatedButton.icon(
                      style: SiberTema.kuantumButonStili(),
                      icon: const Icon(Icons.lock_outline, color: Colors.white),
                      label: const Text("GÜVENLİ ÖDEME YAP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      onPressed: _odemeyiBaslat,
                    ),
            ),
            const SizedBox(height: 16),
            const Center(child: Text("256-Bit Kuantum Şifreleme ile Korunmaktadır", style: TextStyle(color: SiberTema.textMuted, fontSize: 9, letterSpacing: 1))),
          ],
        ),
      ),
    );
  }

  // 📱 3D SECURE SMS EKRANI (AŞAMA 2)
  Widget _build3DSecureEkrani() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: SiberTema.siberCamZirh(renk: Colors.black),
      child: Column(
        children: [
          const Icon(Icons.phonelink_ring, color: SiberTema.kuantumCyan, size: 50),
          const SizedBox(height: 16),
          const Text("3D SECURE ONAYI", style: TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 8),
          const Text("Bankanız tarafından telefonunuza gönderilen 6 haneli doğrulama kodunu giriniz. (Test için '123456' yazabilirsiniz)", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMuted, fontSize: 11)),
          const SizedBox(height: 32),
          
          _buildSiberInput(controller: _smsKoduCtrl, hint: "6 Haneli SMS Kodu", isNumber: true, isRequired: true),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: _isProcessing
                ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                : ElevatedButton.icon(
                    style: SiberTema.kuantumButonStili(),
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                    label: const Text("ONAYLA VE MÜHÜRLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    onPressed: _smsOnaylaVeMuhurle,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiberInput({required TextEditingController controller, required String hint, bool isNumber = false, bool isRequired = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: SiberTema.matGrey.withOpacity(0.5), borderRadius: BorderRadius.circular(8), border: Border.all(color: SiberTema.textMuted)),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: SiberTema.textMain, fontSize: 14, fontFamily: 'monospace', letterSpacing: 1.5),
        textAlign: TextAlign.center,
        validator: isRequired ? (v) => v == null || v.isEmpty ? "Zorunlu Alan" : null : null,
        decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white30, fontSize: 11, fontFamily: 'Avenir', letterSpacing: 1), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
      ),
    );
  }

  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: SiberTema.matGrey, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)), content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')), const SizedBox(height: 4), Text(mesaj, style: const TextStyle(color: SiberTema.textMuted, fontSize: 12, fontFamily: 'Avenir'))])));
  }
}
