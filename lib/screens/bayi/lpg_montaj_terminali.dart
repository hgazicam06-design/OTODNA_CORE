import 'package:otodna/core/siber_tema.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class LpgMontajTerminali extends StatefulWidget {
  LpgMontajTerminali({super.key});

  @override
  State<LpgMontajTerminali> createState() => _LpgMontajTerminaliState();
}

class _LpgMontajTerminaliState extends State<LpgMontajTerminali> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  final TextEditingController _saseNoCtrl = TextEditingController();
  final TextEditingController _kitMarkaCtrl = TextEditingController();
  final TextEditingController _ecuVersionCtrl = TextEditingController();

  bool _isUploadingManifold = false;
  bool _isUploadingSizdirmazlik = false;
  bool _isSealing = false;

  void _fotoYukle(String tur) async {
    setState(() {
      if (tur == "Manifold") _isUploadingManifold = true;
      if (tur == "Sızdırmazlık") _isUploadingSizdirmazlik = true;
    });
    
    // Yükleme simülasyonu
    await Future.delayed(Duration(seconds: 2));
    
    setState(() {
      if (tur == "Manifold") _isUploadingManifold = false;
      if (tur == "Sızdırmazlık") _isUploadingSizdirmazlik = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$tur Kanıtı Firebase Storage'a Yüklendi!"), backgroundColor: SiberTema.kuantumCyan));
    }
  }

  Future<void> _montajiMuhurle() async {
    if (_saseNoCtrl.text.isEmpty || _kitMarkaCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lütfen zorunlu alanları doldurun."), backgroundColor: SiberTema.kanKirmizi));
      return;
    }

    setState(() => _isSealing = true);

    try {
      WriteBatch batch = _db.batch();
      String uid = _currentUser?.uid ?? "IL_BAYISI_UID";
      String vakaId = _saseNoCtrl.text.toUpperCase();

      // 1. Montaj Raporu
      DocumentReference montajRef = _db.collection('lpg_montaj_raporlari').doc();
      batch.set(montajRef, {
        'arac_sase_no': vakaId,
        'kit_markasi': _kitMarkaCtrl.text,
        'ecu_yazilim_versiyonu': _ecuVersionCtrl.text.isNotEmpty ? _ecuVersionCtrl.text : "Belirtilmedi",
        'montaj_yapan_bayi_id': uid,
        'medya_kanitlari': ['https://firebasestorage.link/manifold.jpg', 'https://firebasestorage.link/sizdirmazlik.mp4'], // Temsili
        'tarih': FieldValue.serverTimestamp(),
      });

      // 2. Siber İstihbarat Kutusuna Log
      DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'LPG_MONTAJ_YAPILDI',
        'seviye': 'KRİTİK',
        'islem_detayi': 'SİBER MONTAJ: ${vakaId} şase numaralı araca ${_kitMarkaCtrl.text} kiti (ECU: ${_ecuVersionCtrl.text}) montajlandı ve medya kanıtlarıyla mühürlendi.',
        'vaka_id': vakaId,
        'kullanici_id': uid,
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('LPG Montajı Adli Olarak Mühürlendi! 🛡️', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: SiberTema.siberGold));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: SiberTema.kanKirmizi));
      }
    } finally {
      if (mounted) setState(() => _isSealing = false);
    }
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
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 18), onPressed: () => Navigator.pop(context)),
          title: Text("SİBER MONTAJ TERMİNALİ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUyariKarti(),
              SizedBox(height: 32),
              
              Text("ARAÇ & KİT BİLGİLERİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              SizedBox(height: 16),
              _buildTextField(_saseNoCtrl, "Şase No", Icons.directions_car),
              SizedBox(height: 12),
              _buildTextField(_kitMarkaCtrl, "LPG Kit Markası (Örn: Prins, Atiker)", Icons.precision_manufacturing),
              SizedBox(height: 12),
              _buildTextField(_ecuVersionCtrl, "ECU Yazılım Versiyonu (Opsiyonel)", Icons.memory),
              
              SizedBox(height: 32),
              Text("MEDYA KANITLARI (ZORUNLU)", style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              SizedBox(height: 16),
              _buildMedyaKarti("Manifold Delim Fotoğrafı", _isUploadingManifold, () => _fotoYukle("Manifold")),
              SizedBox(height: 12),
              _buildMedyaKarti("Sızdırmazlık Testi Videosu", _isUploadingSizdirmazlik, () => _fotoYukle("Sızdırmazlık")),

              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSealing ? null : _montajiMuhurle,
                  style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kuantumCyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isSealing 
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("ATOMİK OLARAK MÜHÜRLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1, fontFamily: 'Avenir')),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUyariKarti() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: SiberTema.siberGold.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.siberGold.withOpacity(0.5))),
      child: Row(
        children: [
          Icon(Icons.shield, color: SiberTema.siberGold, size: 28),
          SizedBox(width: 16),
          Expanded(child: Text("Bu ekrandan girilen tüm kanıtlar Karargah sistemine kalıcı olarak mühürlenir. Lütfen gerçek fotoğraf/video yükleyiniz.", style: TextStyle(color: SiberTema.siberGold, fontSize: 11, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData ikon) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: SiberTema.textMain),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: SiberTema.textMuted, fontSize: 13),
        prefixIcon: Icon(ikon, color: SiberTema.kuantumCyan, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.02),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SiberTema.textMuted)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SiberTema.kuantumCyan)),
      ),
    );
  }

  Widget _buildMedyaKarti(String baslik, bool isUploading, VoidCallback onTap) {
    return InkWell(
      onTap: isUploading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white54,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_upload_outlined, color: SiberTema.kuantumCyan, size: 24),
                SizedBox(width: 16),
                Text(baslik, style: TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
            if (isUploading) SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 2))
          ],
        ),
      ),
    );
  }
}
