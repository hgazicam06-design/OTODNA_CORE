import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/siber_tema.dart';
import '../../models/arac_model.dart';

class SiberAracKayitTerminali extends StatefulWidget {
  const SiberAracKayitTerminali({super.key});

  @override
  State<SiberAracKayitTerminali> createState() => _SiberAracKayitTerminaliState();
}

class _SiberAracKayitTerminaliState extends State<SiberAracKayitTerminali> {
  static const Color primaryCyan = SiberTema.kuantumCyan;
  static const Color siberGold = SiberTema.siberGold;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _plakaController = TextEditingController();
  final TextEditingController _saseController = TextEditingController();
  final TextEditingController _markaController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _renkController = TextEditingController();

  bool _isProcessing = false;

  // 🛡️ KULLANIM SINIFLANDIRMASI (SIBER GÜMRÜK)
  String _kullanimTuru = "Hususi"; // "Hususi", "Ticari"
  String? _sahiplikYapisi;
  String? _operasyonAlani;
  
  final List<String> _sahiplikYapiListesi = ["Şahıs Şirketi", "Kurumsal Şirket", "Kamu/Belediye"];
  
  final Map<String, List<String>> _operasyonKategorileri = {
    "Yolcu Taşımacılığı": ["Taksi", "Okul Servisi", "Personel Servisi", "VIP / Turizm", "Şehirler Arası Otobüs"],
    "Yük ve Lojistik Taşımacılığı": ["Şehir İçi Dağıtım", "Damperli/Hafriyat", "Uluslararası Nakliye (TIR)", "Frigofirik"],
    "Özel Hizmet": ["Kiralık Araç (Rent A Car)", "Sürücü Kursu"],
  };

  Future<void> _araciKarargahaMuhurle() async {
    if (_plakaController.text.trim().isEmpty || _saseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("SİBER İHLAL: Plaka ve Şase numarası zorunludur!"), backgroundColor: SiberTema.kanKirmizi)
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      if (_kullanimTuru == "Ticari" && (_sahiplikYapisi == null || _operasyonAlani == null)) {
        throw Exception("Ticari araçlar için Sahiplik Yapısı ve Operasyon Alanı seçimi zorunludur!");
      }

      User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("Siber Kimlik Doğrulanamadı!");

      // Kullanıcının ad soyad bilgisini Karargahtan çek
      DocumentSnapshot userDoc = await _db.collection('users').doc(currentUser.uid).get();
      String userName = "OtoDNA Kullanıcısı";
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        userName = data['ad_soyad'] ?? data['email'] ?? "Gizli Kullanıcı";
      }

      String muhurluSase = _saseController.text.trim().toUpperCase();

      AracModel yeniArac = AracModel(
        sahibiUid: currentUser.uid,
        kullaniciAdi: userName,
        ad: userName.split(' ').first,
        soyad: userName.split(' ').length > 1 ? userName.split(' ').last : '',
        dogumTarihi: DateTime(1990), // Varsayılan veya Profil'den alınabilir
        plaka: _plakaController.text.trim().toUpperCase(),
        il: 'Bilinmiyor',
        ilce: 'Bilinmiyor',
        postaKodu: '00000',
        marka: _markaController.text.trim().toUpperCase(),
        model: _modelController.text.trim().toUpperCase(),
        renk: _renkController.text.trim().toUpperCase(),
        saseNo: muhurluSase,
        dnaSkoru: 100, // Fabrika Çıkış / Karargah Standart Skoru
        kritikHataVarMi: false,
        muayeneDurumu: "🟢 OTODNA ONAYLIDIR", // Başlangıç Referansı
        kullanimTuru: _kullanimTuru,
        sahiplikYapisi: _sahiplikYapisi,
        operasyonAlani: _operasyonAlani,
      );

      // Kuantum Zırhlı Kayıt (Atomik)
      WriteBatch batch = _db.batch();
      
      DocumentReference aracRef = _db.collection('vehicles').doc(muhurluSase);
      batch.set(aracRef, yeniArac.toMap());

      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'YENI_ARAC_KAYDI',
        'islem_detayi': '${_plakaController.text.toUpperCase()} plakalı araç Kuantum Ağına katıldı.',
        'sase_no': muhurluSase,
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🚀 BAŞARILI: Araç Kuantum Ağına Mühürlendi!"), backgroundColor: primaryCyan)
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("SİBER HATA: İşlem başarısız! ${e.toString()}"), backgroundColor: SiberTema.kanKirmizi)
        );
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
                        _buildHolografikBaslik(),
                        const SizedBox(height: 32),
                        _buildKullanimAmaciKarti(),
                        const SizedBox(height: 24),
                        _buildTerminalFormu(),
                      ],
                    ),
                  ),
                ),
                _buildMuhurleButonu(),
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
              const Text('K A Y I T   T E R M İ N A L İ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Avenir')),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.5))), child: const Icon(Icons.qr_code_scanner, color: primaryCyan, size: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHolografikBaslik() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: primaryCyan.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: primaryCyan.withOpacity(0.3), width: 1.5),
          boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.1), blurRadius: 40)],
        ),
        child: const Icon(Icons.directions_car, color: primaryCyan, size: 64),
      ),
    );
  }

  Widget _buildTerminalFormu() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("KRİTİK DNA BİLGİLERİ", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir')),
              const SizedBox(height: 16),
              _buildNeonInput("Plaka", _plakaController, Icons.subtitles),
              const SizedBox(height: 16),
              _buildNeonInput("Şase No (VIN) - 17 Hane", _saseController, Icons.fingerprint),
              const SizedBox(height: 32),
              
              const Text("DONANIM BİLGİLERİ", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir')),
              const SizedBox(height: 16),
              _buildNeonInput("Marka", _markaController, Icons.branding_watermark),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildNeonInput("Model", _modelController, Icons.model_training)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildNeonInput("Renk", _renkController, Icons.color_lens)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeonInput(String hint, TextEditingController controller, IconData ikon) {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Avenir', fontWeight: FontWeight.w600, letterSpacing: 1),
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          prefixIcon: Icon(ikon, color: Colors.white54, size: 18),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12, letterSpacing: 1),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildKullanimAmaciKarti() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("KULLANIM AMACI VE RİSK PROFİLİ", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir')),
              const SizedBox(height: 16),
              // Ana Kullanım Türü Seçimi (Pinterest Stili)
              Row(
                children: [
                  Expanded(child: _buildSiberSecimKarti("Hususi", Icons.person, _kullanimTuru == "Hususi", () {
                    setState(() {
                      _kullanimTuru = "Hususi";
                      _sahiplikYapisi = null;
                      _operasyonAlani = null;
                    });
                  })),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSiberSecimKarti("Ticari", Icons.local_shipping, _kullanimTuru == "Ticari", () {
                    setState(() {
                      _kullanimTuru = "Ticari";
                    });
                  })),
                ],
              ),
              
              if (_kullanimTuru == "Ticari") ...[
                const SizedBox(height: 24),
                const Text("SAHİPLİK YAPISI", style: TextStyle(color: primaryCyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _sahiplikYapiListesi.map((yapi) => _buildSiberChip(yapi, _sahiplikYapisi == yapi, () => setState(() => _sahiplikYapisi = yapi))).toList(),
                ),
                
                const SizedBox(height: 24),
                const Text("OPERASYON ALANI (RİSK GRUBU)", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 12),
                
                ..._operasyonKategorileri.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.key.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: entry.value.map((alan) => _buildSiberChip(alan, _operasyonAlani == alan, () => setState(() => _operasyonAlani = alan))).toList(),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiberSecimKarti(String baslik, IconData ikon, bool secili, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: secili ? primaryCyan.withOpacity(0.2) : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: secili ? primaryCyan : Colors.white10, width: secili ? 2 : 1),
          boxShadow: secili ? [BoxShadow(color: primaryCyan.withOpacity(0.3), blurRadius: 15)] : [],
        ),
        child: Column(
          children: [
            Icon(ikon, color: secili ? primaryCyan : Colors.white54, size: 28),
            const SizedBox(height: 8),
            Text(baslik, style: TextStyle(color: secili ? Colors.white : Colors.white54, fontSize: 12, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildSiberChip(String etiket, bool secili, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: secili ? SiberTema.matGrey : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: secili ? primaryCyan : Colors.white10),
        ),
        child: Text(etiket, style: TextStyle(color: secili ? primaryCyan : Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMuhurleButonu() {
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
          onPressed: _isProcessing ? null : _araciKarargahaMuhurle,
          child: _isProcessing 
              ? const CircularProgressIndicator(color: Colors.black)
              : const Text("KARARGAHA MÜHÜRLE", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
        ),
      ),
    );
  }
}
