import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Kimlik Okuyucu Eklendi

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

      // Aracın var olan DNA'sını silmeden içine batarya verisini göm
      await FirebaseFirestore.instance.collection('araclar').doc(plakaID).set({
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
    const bgColor = Color(0xFF0F172A);
    const primaryCyan = Color(0xFF00FFC2);
    const cardColor = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan), onPressed: () => Navigator.pop(context)),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.electric_car, color: primaryCyan), SizedBox(width: 8),
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

            const Text("Hedef Araç Kimliği", style: TextStyle(color: primaryCyan, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildInputField("Plaka / Şase (Örn: 34DNA2026)", Icons.pin, _plakaController, isUppercase: true),

            const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: Colors.white12)),

            const Row(
              children: [
                Icon(Icons.battery_charging_full, color: primaryCyan, size: 18), SizedBox(width: 8),
                Text("Servis Ölçüm Verileri", style: TextStyle(color: primaryCyan, fontSize: 14, fontWeight: FontWeight.bold)),
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
                    backgroundColor: primaryCyan,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 10, shadowColor: primaryCyan.withOpacity(0.5)
                ),
                onPressed: _isSaving ? null : _evDnasiniMuhurle,
                icon: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: bgColor, strokeWidth: 2))
                    : const Icon(Icons.fingerprint, color: bgColor, size: 28),
                label: Text(
                    _isSaving ? "DNA İŞLENİYOR..." : "BATARYA VERİSİNİ MÜHÜRLE",
                    style: const TextStyle(color: bgColor, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // YARDIMCI WIDGET: Şık Veri Giriş Kutusu
  Widget _buildInputField(String hint, IconData icon, TextEditingController controller, {bool isNumber = false, bool isUppercase = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        textCapitalization: isUppercase ? TextCapitalization.characters : TextCapitalization.none,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(icon, color: const Color(0xFF00FFC2), size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
          border: InputBorder.none,
        ),
      ),
    );
  }
}