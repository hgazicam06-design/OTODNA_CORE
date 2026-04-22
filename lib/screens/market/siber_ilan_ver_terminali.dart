import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/siber_tema.dart';
import '../../models/car_ad_model.dart';

class SiberIlanVerTerminali extends StatefulWidget {
  const SiberIlanVerTerminali({super.key});

  @override
  State<SiberIlanVerTerminali> createState() => _SiberIlanVerTerminaliState();
}

class _SiberIlanVerTerminaliState extends State<SiberIlanVerTerminali> {
  static const Color primaryCyan = SiberTema.kuantumCyan;
  static const Color siberGold = SiberTema.siberGold;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _markaModelController = TextEditingController();
  final TextEditingController _fiyatController = TextEditingController();
  final TextEditingController _kaporaController = TextEditingController();
  final TextEditingController _aciklamaController = TextEditingController();

  bool _isSecureDeposit = true;
  bool _otodnaOnayiVarMi = false;
  bool _isProcessing = false;

  Future<void> _ilaniKarargahaGonder() async {
    if (_markaModelController.text.isEmpty || _fiyatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen tüm zorunlu alanları doldurun."), backgroundColor: SiberTema.kanKirmizi));
      return;
    }

    setState(() => _isProcessing = true);

    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception("Siber Kimlik Bulunamadı!");

      // Satıcı Bilgisini Çek (Geçici Olarak Profil veya Varsayılan)
      DocumentSnapshot userDoc = await _db.collection('users').doc(user.uid).get();
      String saticiAdi = "OtoDNA Bireysel Satıcı";
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        saticiAdi = data['ad_soyad'] ?? saticiAdi;
      }

      double fiyat = double.tryParse(_fiyatController.text.trim()) ?? 0;
      double kapora = double.tryParse(_kaporaController.text.trim()) ?? 0;

      CarAd yeniIlan = CarAd(
        ownerId: user.uid,
        saticiAdi: saticiAdi,
        brandModel: _markaModelController.text.trim().toUpperCase(),
        price: fiyat,
        images: ["https://via.placeholder.com/600x400/111111/FFD700?text=SİBER+ARAÇ"], // Örnek Mock Resim
        isSecureDeposit: _isSecureDeposit,
        kaporaBedeli: kapora,
        otodnaReferansliMi: _otodnaOnayiVarMi,
        description: _aciklamaController.text.trim(),
        ilanDurumu: "Yayında",
      );

      WriteBatch batch = _db.batch();

      DocumentReference adRef = _db.collection('vehicles_ads').doc();
      batch.set(adRef, yeniIlan.toMap());

      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'YENI_ILAN_GIRISI',
        'islem_detayi': '${yeniIlan.brandModel} modeli ₺$fiyat fiyatla ilana eklendi.',
        'satici_uid': user.uid,
        'tarih': FieldValue.serverTimestamp()
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🚀 İlan Kuantum Pazaryerinde Yayınlandı!"), backgroundColor: primaryCyan));
        Navigator.pop(context); // Vitrine Geri Dön
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ağ Çöktü: $e"), backgroundColor: SiberTema.kanKirmizi));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: Container(decoration: SiberTema.siberArkaPlan)),
          SafeArea(
            child: Column(
              children: [
                _buildSiberAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNeonInput("Marka & Model (Örn: BMW 320i M Sport)", _markaModelController, Icons.directions_car),
                        const SizedBox(height: 16),
                        _buildNeonInput("Satış Fiyatı (₺)", _fiyatController, Icons.attach_money, isNumeric: true),
                        const SizedBox(height: 16),
                        _buildNeonInput("Araç Hakkında İstihbarat (Açıklama)", _aciklamaController, Icons.description, maxLines: 3),
                        
                        const SizedBox(height: 32),
                        const Text("SİBER GÜVENLİK AYARLARI", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir')),
                        const SizedBox(height: 16),
                        
                        _buildKaporaSwitch(),
                        if (_isSecureDeposit) ...[
                          const SizedBox(height: 16),
                          _buildNeonInput("Blokaj Edilecek Kapora Bedeli (₺)", _kaporaController, Icons.lock_outline, isNumeric: true),
                        ],
                        
                        const SizedBox(height: 16),
                        _buildOtoDNASwitch(),
                      ],
                    ),
                  ),
                ),
                _buildIlanVerButonu(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiberAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), border: const Border(bottom: BorderSide(color: Colors.white10))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18)),
              ),
              const Text('İ L A N   T E R M İ N A L İ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Avenir')),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: siberGold.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: siberGold.withOpacity(0.5))), child: const Icon(Icons.publish, color: siberGold, size: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKaporaSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Güvenli Kapora", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                Text("OtoDNA Havuzunda kilitlenir", style: TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'Avenir')),
              ],
            ),
          ),
          Switch(
            value: _isSecureDeposit,
            onChanged: (val) => setState(() => _isSecureDeposit = val),
            activeColor: siberGold,
          )
        ],
      ),
    );
  }

  Widget _buildOtoDNASwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: primaryCyan.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryCyan.withOpacity(0.3))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("OtoDNA Onayı İste", style: TextStyle(color: primaryCyan, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                Text("Karargah radarı aracı onaylarsa 'Yeşil Tik' alır", style: TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'Avenir')),
              ],
            ),
          ),
          Switch(
            value: _otodnaOnayiVarMi,
            onChanged: (val) => setState(() => _otodnaOnayiVarMi = val),
            activeColor: primaryCyan,
          )
        ],
      ),
    );
  }

  Widget _buildNeonInput(String hint, TextEditingController controller, IconData ikon, {int maxLines = 1, bool isNumeric = false}) {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Avenir', fontWeight: FontWeight.w600, letterSpacing: 1),
        decoration: InputDecoration(
          prefixIcon: maxLines == 1 ? Icon(ikon, color: Colors.white54, size: 18) : null,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12, letterSpacing: 1),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildIlanVerButonu() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), border: const Border(top: BorderSide(color: Colors.white10))),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryCyan,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          onPressed: _isProcessing ? null : _ilaniKarargahaGonder,
          child: _isProcessing 
              ? const CircularProgressIndicator(color: Colors.black)
              : const Text("AĞA YAYINLA", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
        ),
      ),
    );
  }
}
