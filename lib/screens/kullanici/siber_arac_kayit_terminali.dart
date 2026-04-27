import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/arac_model.dart';

class SiberAracKayitTerminali extends StatefulWidget {
  const SiberAracKayitTerminali({super.key});

  @override
  State<SiberAracKayitTerminali> createState() => _SiberAracKayitTerminaliState();
}

class _SiberAracKayitTerminaliState extends State<SiberAracKayitTerminali> {
  final Color primaryTeal = Colors.teal.shade700;
  final Color dangerColor = Colors.redAccent;
  final Color textColor = const Color(0xFF1E293B);
  final Color bgColor = const Color(0xFFFAFAFC);
  final Color warningColor = Colors.orange;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _plakaController = TextEditingController();
  final TextEditingController _saseController = TextEditingController();
  final TextEditingController _markaController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _renkController = TextEditingController();

  bool _isProcessing = false;

  // 🛡️ KULLANIM SINIFLANDIRMASI
  String _kullanimTuru = "Hususi"; // "Hususi", "Ticari"
  String? _sahiplikYapisi;
  String? _operasyonAlani;
  
  final List<String> _sahiplikYapiListesi = ["Şahıs Şirketi", "Kurumsal Şirket", "Kamu/Belediye"];
  
  final Map<String, List<String>> _operasyonKategorileri = {
    "Yolcu Taşımacılığı": ["Taksi", "Okul Servisi", "Personel Servisi", "VIP / Turizm", "Şehirler Arası Otobüs"],
    "Yük ve Lojistik Taşımacılığı": ["Şehir İçi Dağıtım", "Damperli/Hafriyat", "Uluslararası Nakliye (TIR)", "Frigofirik"],
    "Özel Hizmet": ["Kiralık Araç (Rent A Car)", "Sürücü Kursu"],
  };

  Future<void> _araciMerkezeMuhurle() async {
    if (_plakaController.text.trim().isEmpty || _saseController.text.trim().isEmpty) {
      _plazaUyariGoster("EKSİK BİLGİ", "Plaka ve Şase numarası zorunludur!", dangerColor);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      if (_kullanimTuru == "Ticari" && (_sahiplikYapisi == null || _operasyonAlani == null)) {
        throw Exception("Ticari araçlar için Sahiplik Yapısı ve Operasyon Alanı seçimi zorunludur!");
      }

      User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("Kullanıcı Kimliği Doğrulanamadı!");

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
        dogumTarihi: DateTime(1990),
        plaka: _plakaController.text.trim().toUpperCase(),
        il: 'Bilinmiyor',
        ilce: 'Bilinmiyor',
        postaKodu: '00000',
        marka: _markaController.text.trim().toUpperCase(),
        model: _modelController.text.trim().toUpperCase(),
        renk: _renkController.text.trim().toUpperCase(),
        saseNo: muhurluSase,
        dnaSkoru: 100,
        kritikHataVarMi: false,
        muayeneDurumu: "🟢 OTODNA ONAYLIDIR",
        kullanimTuru: _kullanimTuru,
        sahiplikYapisi: _sahiplikYapisi,
        operasyonAlani: _operasyonAlani,
      );

      WriteBatch batch = _db.batch();
      
      DocumentReference aracRef = _db.collection('vehicles').doc(muhurluSase);
      batch.set(aracRef, yeniArac.toMap());

      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'YENI_ARAC_KAYDI',
        'islem_detayi': '${_plakaController.text.toUpperCase()} plakalı araç Plaza Ağına katıldı.',
        'sase_no': muhurluSase,
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (mounted) {
        _plazaUyariGoster("KAYIT BAŞARILI", "Araç OtoDNA Güvencesiyle Sisteme Eklendi!", primaryTeal);
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _plazaUyariGoster("SİSTEM HATASI", "İşlem başarısız! ${e.toString().replaceAll("Exception: ", "")}", dangerColor);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _plazaUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 4),
            Text(mesaj, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('ARAÇ KAYIT TERMİNALİ', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, fontFamily: 'Avenir')),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 18), onPressed: () => Navigator.pop(context)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.qr_code_scanner, color: primaryTeal, size: 18)
          )
        ],
      ),
      body: Column(
        children: [
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
    );
  }

  Widget _buildHolografikBaslik() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: primaryTeal.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.directions_car, color: primaryTeal, size: 64),
      ),
    );
  }

  Widget _buildTerminalFormu() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("KRİTİK DNA BİLGİLERİ", style: TextStyle(color: Colors.white45, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          const SizedBox(height: 16),
          _buildPlazaInput("Plaka", _plakaController, Icons.subtitles),
          const SizedBox(height: 16),
          _buildPlazaInput("Şase No (VIN) - 17 Hane", _saseController, Icons.fingerprint),
          const SizedBox(height: 32),
          
          const Text("DONANIM BİLGİLERİ", style: TextStyle(color: Colors.white45, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          const SizedBox(height: 16),
          _buildPlazaInput("Marka", _markaController, Icons.branding_watermark),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildPlazaInput("Model", _modelController, Icons.model_training)),
              const SizedBox(width: 16),
              Expanded(child: _buildPlazaInput("Renk", _renkController, Icons.color_lens)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPlazaInput(String hint, TextEditingController controller, IconData ikon) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.white.withValues(alpha: 0.05))
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: textColor, fontSize: 14, fontFamily: 'Avenir', fontWeight: FontWeight.w900, letterSpacing: 1),
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          prefixIcon: Icon(ikon, color: Colors.white38, size: 18),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white26, fontSize: 12, letterSpacing: 1, fontFamily: 'Avenir', fontWeight: FontWeight.bold),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildKullanimAmaciKarti() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("KULLANIM AMACI VE RİSK PROFİLİ", style: TextStyle(color: Colors.white45, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          const SizedBox(height: 16),
          // Ana Kullanım Türü Seçimi
          Row(
            children: [
              Expanded(child: _buildPlazaSecimKarti("Hususi", Icons.person, _kullanimTuru == "Hususi", () {
                setState(() {
                  _kullanimTuru = "Hususi";
                  _sahiplikYapisi = null;
                  _operasyonAlani = null;
                });
              })),
              const SizedBox(width: 12),
              Expanded(child: _buildPlazaSecimKarti("Ticari", Icons.local_shipping, _kullanimTuru == "Ticari", () {
                setState(() {
                  _kullanimTuru = "Ticari";
                });
              })),
            ],
          ),
          
          if (_kullanimTuru == "Ticari") ...[
            const SizedBox(height: 24),
            Text("SAHİPLİK YAPISI", style: TextStyle(color: primaryTeal, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sahiplikYapiListesi.map((yapi) => _buildPlazaChip(yapi, _sahiplikYapisi == yapi, () => setState(() => _sahiplikYapisi = yapi), primaryTeal)).toList(),
            ),
            
            const SizedBox(height: 24),
            Text("OPERASYON ALANI (RİSK GRUBU)", style: TextStyle(color: warningColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
            const SizedBox(height: 12),
            
            ..._operasyonKategorileri.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.key.toUpperCase(), style: const TextStyle(color: Colors.white45, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.value.map((alan) => _buildPlazaChip(alan, _operasyonAlani == alan, () => setState(() => _operasyonAlani = alan), warningColor)).toList(),
                  ),
                ],
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildPlazaSecimKarti(String baslik, IconData ikon, bool secili, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: secili ? primaryTeal.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: secili ? primaryTeal.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05), width: secili ? 2 : 1),
          boxShadow: secili ? null : [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 5)],
        ),
        child: Column(
          children: [
            Icon(ikon, color: secili ? primaryTeal : Colors.black26, size: 28),
            const SizedBox(height: 8),
            Text(baslik, style: TextStyle(color: secili ? primaryTeal : textColor, fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  Widget _buildPlazaChip(String etiket, bool secili, VoidCallback onTap, Color aktifRenk) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: secili ? aktifRenk : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: secili ? aktifRenk : Colors.black.withValues(alpha: 0.05)),
          boxShadow: secili ? [BoxShadow(color: aktifRenk.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))] : [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 5)],
        ),
        child: Text(etiket, style: TextStyle(color: secili ? Colors.white : Colors.black54, fontSize: 11, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
      ),
    );
  }

  Widget _buildMuhurleButonu() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, -5))]
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          onPressed: _isProcessing ? null : _araciMerkezeMuhurle,
          child: _isProcessing 
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("SİSTEME KAYDET", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
        ),
      ),
    );
  }
}
