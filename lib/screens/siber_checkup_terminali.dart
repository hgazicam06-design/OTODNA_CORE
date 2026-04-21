// lib/screens/siber_checkup_terminali.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🔥 SİBER KÖPRÜLER
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM ZORUNLU CHECK-UP VE İŞLEM KAYIT TERMİNALİ
/// Kullanıcı her arıza/işlem kaydı açtığında KM, Akü ve Yağ verilerini zorunlu günceller.
class SiberCheckupTerminali extends StatefulWidget {
  final String saseNo;
  final String islemTuru; // Örn: 'ARIZA_KAYDI', 'PERIYODIK_BAKIM'

  const SiberCheckupTerminali({
    super.key,
    required this.saseNo,
    required this.islemTuru,
  });

  @override
  State<SiberCheckupTerminali> createState() => _SiberCheckupTerminaliState();
}

class _SiberCheckupTerminaliState extends State<SiberCheckupTerminali> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _islemDetayController = TextEditingController();

  bool _isProcessing = false;

  // ⚡ SİBER SEVİYE MATRİSLERİ (Otonom Tik Sistemi)
  String _seciliAkuDurumu = '⚡ OPTİMUM';
  final List<String> _akuSeviyeleri = ['⚡ OPTİMUM', '⚠️ ZAYIF (Şarj Gerekli)', '🚨 KRİTİK (Değişim Şart)'];

  String _seciliYagDurumu = '🛢️ STANDART SEVİYE';
  final List<String> _yagSeviyeleri = ['🛢️ STANDART SEVİYE', '⚠️ EKSİLMİŞ', '🚨 RİSKLİ (Kaçak Olabilir)'];

  // ── 🚀 ATOMİK MÜHÜRLEME MOTORU ──
  Future<void> _kaydiMuhurle() async {
    if (_kmController.text.isEmpty || _islemDetayController.text.isEmpty) {
      _siberUyari("SİBER İHLAL: KM ve İşlem Detayı boş bırakılamaz!", true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      int guncelKm = int.parse(_kmController.text.replaceAll(RegExp(r'[^0-9]'), ''));

      // 🛡️ ATOMİK ZIRH: Tüm güncellemeler tek seferde (Ya hep ya hiç!)
      WriteBatch batch = _db.batch();

      // 1. İşlem / Arıza Kaydını Oluştur
      DocumentReference islemRef = _db.collection('islem_gecmisi').doc();
      batch.set(islemRef, {
        'sase_no': widget.saseNo,
        'islem_turu': widget.islemTuru,
        'detay': _islemDetayController.text,
        'kilometre': guncelKm,
        'aku_durumu': _seciliAkuDurumu,
        'yag_seviyesi': _seciliYagDurumu,
        'tarih': FieldValue.serverTimestamp(),
      });

      // 2. Aracın Ana Genetik Kodunu (DNA) Güncelle
      DocumentReference aracRef = _db.collection('araclar').doc(widget.saseNo);
      batch.update(aracRef, {
        'guncel_km': guncelKm,
        'son_aku_durumu': _seciliAkuDurumu,
        'son_yag_durumu': _seciliYagDurumu,
        'son_islem_tarihi': FieldValue.serverTimestamp(),
      });

      // 3. Karargah Kara Kutusuna Log At
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'ZORUNLU_CHECKUP_KAYDI',
        'sase_no': widget.saseNo,
        'islem_detayi': '${widget.islemTuru} eklendi. Yeni KM: $guncelKm. Akü: $_seciliAkuDurumu.',
        'tarih': FieldValue.serverTimestamp(),
        'otonom_kayit': true,
      });

      await batch.commit(); // Füzeleri ateşle!

      if (!mounted) return;
      _siberUyari("✅ SİBER ONAY: İşlem ve Araç Sağlık Verileri Matrix'e Mühürlendi!", false);

      Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));

    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: Kayıt işlemi başarısız!", error: e);
      _siberUyari("BAĞLANTI HATASI: İşlem kilitlenemedi.", true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _siberUyari(String mesaj, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: const TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, fontFamily: 'Avenir', fontSize: 11)),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
    ));
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
          title: Text("${widget.islemTuru.replaceAll('_', ' ')} KAYDI", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 18), onPressed: () => Navigator.pop(context)),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🛡️ BİLGİ BANDI
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3))),
                child: const Row(
                  children: [
                    Icon(Icons.health_and_safety, color: SiberTema.kuantumCyan, size: 24),
                    SizedBox(width: 12),
                    Expanded(child: Text("SİBER ZORUNLULUK: Kayıt oluşturabilmek için aracın güncel hayati verilerini (KM, Akü, Yağ) işaretlemeniz gerekmektedir.", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.bold, height: 1.5, fontFamily: 'Avenir'))),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── 1. KM VE DETAY GİRİŞİ ──
              TextFormField(
                controller: _kmController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir'),
                decoration: SiberTema.siberInputDecor("ŞU ANKİ KİLOMETRE (KM)", Icons.speed),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _islemDetayController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Avenir'),
                decoration: SiberTema.siberInputDecor("ARIZA / İŞLEM DETAYINI YAZIN", Icons.build_circle),
              ),
              const SizedBox(height: 32),

              // ── 2. AKÜ DURUMU (TIK SİSTEMİ) ──
              const Text("AKÜ DURUMU", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
              const SizedBox(height: 8),
              ..._akuSeviyeleri.map((seviye) => _buildTikKarti(seviye, _seciliAkuDurumu == seviye, (val) => setState(() => _seciliAkuDurumu = val))),

              const SizedBox(height: 24),

              // ── 3. YAĞ SEVİYESİ (TIK SİSTEMİ) ──
              const Text("MOTOR YAĞI SEVİYESİ", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
              const SizedBox(height: 8),
              ..._yagSeviyeleri.map((seviye) => _buildTikKarti(seviye, _seciliYagDurumu == seviye, (val) => setState(() => _seciliYagDurumu = val))),

              const SizedBox(height: 40),

              // 🚀 MÜHÜRLE BUTONU
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: SiberTema.kuantumButonStili(),
                  onPressed: _isProcessing ? null : _kaydiMuhurle,
                  icon: _isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 2))
                      : const Icon(Icons.fingerprint, color: SiberTema.oledBlack),
                  label: Text(_isProcessing ? "MÜHÜRLENİYOR..." : "KAYDI VE SAĞLIK VERİSİNİ MÜHÜRLE", style: const TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, fontFamily: 'Avenir')),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ⚡ İNTERAKTİF SİBER TİK KARTI
  Widget _buildTikKarti(String baslik, bool isSelected, Function(String) onTap) {
    Color durumRengi = baslik.contains('KRİTİK') || baslik.contains('RİSKLİ') ? SiberTema.kanKirmizi
        : baslik.contains('ZAYIF') || baslik.contains('EKSİLMİŞ') ? SiberTema.altinSari
        : SiberTema.kuantumCyan;

    return GestureDetector(
      onTap: () => onTap(baslik),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? durumRengi.withOpacity(0.1) : SiberTema.matGrey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? durumRengi : Colors.white.withOpacity(0.05), width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? durumRengi : Colors.white24, size: 20),
            const SizedBox(width: 12),
            Text(baslik, style: TextStyle(color: isSelected ? durumRengi : Colors.white70, fontSize: 13, fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }
}