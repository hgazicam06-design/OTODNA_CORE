import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/siber_tema.dart';
import '../services/services/appointment_service.dart';

class SiberRandevuTerminali extends StatefulWidget {
  final String bayiId;
  final String dukkanAdi;

  const SiberRandevuTerminali({super.key, required this.bayiId, required this.dukkanAdi});

  @override
  State<SiberRandevuTerminali> createState() => _SiberRandevuTerminaliState();
}

class _SiberRandevuTerminaliState extends State<SiberRandevuTerminali> {
  static const Color primaryCyan = SiberTema.kuantumCyan;
  static const Color dangerColor = SiberTema.kanKirmizi;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = true;
  bool _isBanned = false;
  int _ihlalSayisi = 0;

  final TextEditingController _saseController = TextEditingController();
  final TextEditingController _sikayetController = TextEditingController();
  DateTime _secilenTarih = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _sicilKontroluYap();
  }

  Future<void> _sicilKontroluYap() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _ihlalSayisi = data['randevu_ihlal_sayisi'] ?? 0;
        if (_ihlalSayisi >= 2) {
          _isBanned = true;
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _randevuOnayla() async {
    if (_saseController.text.isEmpty || _sikayetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen Şase ve Şikayet alanlarını doldurun!"), backgroundColor: dangerColor));
      return;
    }

    // 💰 200 TL HİZMET BEDELİ ONAY EKRANI (MOCK CÜZDAN)
    bool? odemeOnayi = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: primaryCyan.withOpacity(0.5))),
          title: const Row(
            children: [
              Icon(Icons.shield, color: primaryCyan),
              SizedBox(width: 8),
              Text("OtoDNA Güvencesi", style: TextStyle(color: primaryCyan, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            ],
          ),
          content: const Text(
            "Karargah ağı üzerinden ustadan güvenli hizmet almak için ₺200.00 tutarında sistem işlem bedeli alınacaktır. İşlemi onaylıyor musunuz?",
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5, fontFamily: 'Avenir'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("İPTAL ET", style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, foregroundColor: Colors.black),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("₺200 ÖDE VE ONAYLA", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (odemeOnayi == true) {
      // Ödeme Başarılı, Randevuyu Mühürle
      try {
        await AppointmentService.randevuKontrolVeAl(
          musteriId: _auth.currentUser!.uid,
          bayiId: widget.bayiId,
          dukkanAdi: widget.dukkanAdi,
          saseNo: _saseController.text.trim(),
          sikayetOzeti: _sikayetController.text.trim(),
          randevuTarihi: _secilenTarih,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Randevu ve Ödeme Karargaha İşlendi!"), backgroundColor: primaryCyan));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: dangerColor));
        }
      }
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
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: primaryCyan))
                    : _isBanned 
                      ? _buildSiberEngelKalkani() 
                      : _buildRandevuFormu(),
                ),
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
              Text(widget.dukkanAdi.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, fontFamily: 'Avenir')),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.5))), child: const Icon(Icons.calendar_month, color: primaryCyan, size: 18)),
            ],
          ),
        ),
      ),
    );
  }

  // 🚨 KULLANICI BANLANMIŞSA GÖSTERİLECEK KIRMIZI ZIRH
  Widget _buildSiberEngelKalkani() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: dangerColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: dangerColor.withOpacity(0.5), width: 2),
            boxShadow: [BoxShadow(color: dangerColor.withOpacity(0.2), blurRadius: 40)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block, color: dangerColor, size: 64),
              const SizedBox(height: 24),
              const Text("S İ B E R   E N G E L", style: TextStyle(color: dangerColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 3, fontFamily: 'Avenir')),
              const SizedBox(height: 16),
              Text(
                "Geçmişte $_ihlalSayisi kez randevunuza gitmediğiniz Karargah radarları tarafından tespit edilmiştir. Güvenlik protokolü gereği bu hesaptan randevu oluşturma yetkisi süresiz olarak kilitlenmiştir.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5, fontFamily: 'Avenir'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ KULLANICI BANLANMAMIŞSA GÖSTERİLECEK FORM
  Widget _buildRandevuFormu() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ARAÇ DNA BİLGİSİ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          const SizedBox(height: 12),
          _buildTextField(_saseController, "Şase No (VIN)"),
          
          const SizedBox(height: 24),
          const Text("ARIZA / İSTEK İSTİHBARATI", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          const SizedBox(height: 12),
          _buildTextField(_sikayetController, "Şikayetinizi detaylandırın...", maxLines: 4),

          const SizedBox(height: 24),
          const Text("HEDEF TARİH", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _secilenTarih,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(primary: primaryCyan, onPrimary: Colors.black, surface: Colors.black, onSurface: Colors.white),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() => _secilenTarih = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
              child: Row(
                children: [
                  const Icon(Icons.date_range, color: primaryCyan, size: 20),
                  const SizedBox(width: 12),
                  Text("${_secilenTarih.day.toString().padLeft(2,'0')}.${_secilenTarih.month.toString().padLeft(2,'0')}.${_secilenTarih.year}", style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Avenir', fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 48),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryCyan,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _randevuOnayla,
              child: const Text("₺200 SİBER ÖDEME VE RANDEVU", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontFamily: 'Avenir'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}