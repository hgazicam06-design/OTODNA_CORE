import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
class EvBataryaMuhurTerminali extends StatefulWidget {
  const EvBataryaMuhurTerminali({super.key});

  @override
  State<EvBataryaMuhurTerminali> createState() => _EvBataryaMuhurTerminaliState();
}

class _EvBataryaMuhurTerminaliState extends State<EvBataryaMuhurTerminali> {
  // GERÇEK VERİ GİRİŞ KONTROLCÜLERİ
  final TextEditingController _plakaController = TextEditingController();
  final TextEditingController _bataryaSagligiController = TextEditingController();
  final TextEditingController _tahminiMenzilController = TextEditingController();
  final TextEditingController _kalanOmurController = TextEditingController();
  final TextEditingController _sarjDongusuController = TextEditingController();

  bool _isSaving = false;

  // FİREBASE'E GERÇEK EV/HİBRİT VERİSİ YAZMA MOTORU 🌟
  Future<void> _evDnasiniMuhurle() async {
    if (_plakaController.text.isEmpty || _bataryaSagligiController.text.isEmpty || _tahminiMenzilController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Plaka, Batarya Sağlığı ve Menzil zorunludur! ⚡"), backgroundColor: Colors.redAccent));
      return;
    }

    setState(() => _isSaving = true);
    FocusScope.of(context).unfocus();

    String plakaID = _plakaController.text.trim().replaceAll(" ", "").toUpperCase();

    try {
      // 🧠 KUANTUM KİMLİK OKUYUCU: İşlemi yapan ustanın ID'sini al
      User? currentUser = FirebaseAuth.instance.currentUser;
      String ustaId = currentUser != null ? currentUser.uid : "Bilinmeyen Siber Usta";

      // ZIRH: Atomik WriteBatch işlemi başlatılıyor
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // 1. Aracın var olan DNA'sını silmeden içine batarya verisini göm (vehicles tablosu)
      DocumentReference aracRef = FirebaseFirestore.instance.collection('vehicles').doc(plakaID);
      batch.set(aracRef, {
        "motor_tipi": "Elektrikli / Hibrit",
        "ev_batarya_raporu": {
          "saglik_yuzdesi": int.tryParse(_bataryaSagligiController.text.trim()) ?? 100,
          "guncel_tahmini_menzil_km": int.tryParse(_tahminiMenzilController.text.trim()) ?? 0,
          "kalan_tahmini_omur_yil": double.tryParse(_kalanOmurController.text.trim()) ?? 0.0,
          "yapilan_sarj_dongusu": int.tryParse(_sarjDongusuController.text.trim()) ?? 0,
          "son_olcum_tarihi": FieldValue.serverTimestamp(),
          "olcum_yapan_bayi_id": ustaId // Sabit metin yerine GERÇEK KİMLİK!
        }
      }, SetOptions(merge: true));

      // 2. Siber Radara Bildir (EV Batarya Güncellemesi)
      DocumentReference logRef = FirebaseFirestore.instance.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'EV_BATARYA_EKSPERTIZ',
        'seviye': 'BİLGİ',
        'islem_detayi': 'EV BATARYA MÜHRÜ: $plakaID kimlikli araca yeni EV batarya verisi (Sağlık: %${_bataryaSagligiController.text.trim()}) işlendi.',
        'vaka_id': plakaID,
        'kullanici_id': ustaId,
        'tarih': FieldValue.serverTimestamp(),
      });

      // Füzeleri ateşle!
      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚡ EV Batarya DNA'sı Siber Ağa Mühürlendi!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF00FFC2)));

      // Formu temizle
      _plakaController.clear(); _bataryaSagligiController.clear();
      _tahminiMenzilController.clear(); _kalanOmurController.clear(); _sarjDongusuController.clear();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mühürleme Hatası: $e"), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _plakaController.dispose(); _bataryaSagligiController.dispose();
    _tahminiMenzilController.dispose(); _kalanOmurController.dispose(); _sarjDongusuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.electric_car, color: SiberTema.kuantumCyan), SizedBox(width: 8),
            Text("EV Batarya Mühür Terminali", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blueAccent.withOpacity(0.5))),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blueAccent), SizedBox(width: 12),
                  Expanded(child: Text("Bu terminalden girilen veriler, aracın mevcut DNA'sını silmeden doğrudan Batarya Raporu olarak eklenir.", style: TextStyle(color: Colors.white70, fontSize: 12))),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text("Hedef Araç Kimliği", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInputField("Plaka / Şase (Örn: 34DNA2026)", Icons.pin, _plakaController, isUppercase: true),

            const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: Colors.white12)),

            const Row(
              children: [
                Icon(Icons.battery_charging_full, color: SiberTema.kuantumCyan, size: 18), SizedBox(width: 8),
                Text("Servis Ölçüm Verileri", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildInputField("Batarya Sağlığı (%)", Icons.health_and_safety, _bataryaSagligiController, isNumber: true)),
                const SizedBox(width: 12),
                Expanded(child: _buildInputField("Güncel Menzil (KM)", Icons.map, _tahminiMenzilController, isNumber: true)),
              ],
            ),

            Row(
              children: [
                Expanded(child: _buildInputField("Tahmini Ömür (Yıl)", Icons.hourglass_bottom, _kalanOmurController, isNumber: true)),
                const SizedBox(width: 12),
                Expanded(child: _buildInputField("Şarj Döngüsü", Icons.loop, _sarjDongusuController, isNumber: true)),
              ],
            ),

            const SizedBox(height: 40),

            // FİREBASE MÜHÜR BUTONU
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: SiberTema.kuantumCyan,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 10, shadowColor: SiberTema.kuantumCyan.withOpacity(0.5)
                ),
                onPressed: _isSaving ? null : _evDnasiniMuhurle,
                icon: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 2))
                    : const Icon(Icons.fingerprint, color: SiberTema.oledBlack, size: 28),
                label: Text(
                    _isSaving ? "DNA İŞLENİYOR..." : "BATARYA VERİSİNİ MÜHÜRLE",
                    style: const TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  // YARDIMCI WIDGET: Şık Veri Giriş Kutusu
  Widget _buildInputField(String hint, IconData icon, TextEditingController controller, {bool isNumber = false, bool isUppercase = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        textCapitalization: isUppercase ? TextCapitalization.characters : TextCapitalization.none,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(icon, color: SiberTema.kuantumCyan, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
          border: InputBorder.none,
        ),
      ),
    );
  }
}