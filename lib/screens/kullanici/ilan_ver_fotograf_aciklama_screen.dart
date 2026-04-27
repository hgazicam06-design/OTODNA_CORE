import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/responsive_kalkan.dart';

class IlanVerFotografAciklamaScreen extends StatefulWidget {
  final List<String> secilenArac;
  final double yapayZekaFiyati;

  const IlanVerFotografAciklamaScreen({super.key, required this.secilenArac, required this.yapayZekaFiyati});

  @override
  State<IlanVerFotografAciklamaScreen> createState() => _IlanVerFotografAciklamaScreenState();
}

class _IlanVerFotografAciklamaScreenState extends State<IlanVerFotografAciklamaScreen> {
  final TextEditingController _aciklamaController = TextEditingController();
  bool _havuzKabul = true;
  bool _isSaving = false;

  File? _anaFoto;
  File? _yanFoto1;
  File? _yanFoto2;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _aciklamaController.dispose();
    super.dispose();
  }

  Future<void> _galeridenFotoSec(int index) async {
    final XFile? secilenGorsel = await _picker.pickImage(source: ImageSource.gallery);

    if (secilenGorsel != null) {
      setState(() {
        if (index == 1) _anaFoto = File(secilenGorsel.path);
        else if (index == 2) _yanFoto1 = File(secilenGorsel.path);
        else if (index == 3) _yanFoto2 = File(secilenGorsel.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Görsel ağa eklendi.", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontFamily: 'Avenir')), backgroundColor: Colors.teal.shade700, duration: const Duration(seconds: 1)));
    }
  }

  // 🌟 GERÇEK FİREBASE KAYIT MOTORU (PLAZA MÜHÜRÜ)
  Future<void> _ilaniYayinaAl() async {
    FocusScope.of(context).unfocus();

    if (_aciklamaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen alıcılar için bir donanım açıklaması girin.", style: TextStyle(color: SiberTema.textMain, fontFamily: 'Avenir')), backgroundColor: Colors.redAccent));
      return;
    }
    if (_anaFoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("En azından Ana Kapak Fotoğrafını yüklemelisiniz.", style: TextStyle(color: SiberTema.textMain, fontFamily: 'Avenir')), backgroundColor: Colors.orangeAccent));
      return;
    }

    setState(() => _isSaving = true);

    try {
      String marka = widget.secilenArac.isNotEmpty ? widget.secilenArac[0] : "Bilinmeyen Marka";
      String model = widget.secilenArac.length > 1 ? widget.secilenArac.sublist(1).join(" ") : "Bilinmeyen Model";

      DocumentReference yeniIlan = await FirebaseFirestore.instance.collection('araclar').add({
        "marka": marka,
        "model": model,
        "fiyat": widget.yapayZekaFiyati.toInt(),
        "aciklama": _aciklamaController.text.trim(),
        "havuz_guvencesi": _havuzKabul,
        "durum": "Sahibinden",
        "dna_skoru": 95,
        "km": 0,
        "lokasyon": "OtoDNA Plaza Ağı",
        "kayit_tarihi": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      final Color primaryTeal = Colors.teal.shade700;

      // 💎 PLAZA MİMARİSİ: ŞIK BAŞARI DİYALOGU
      showDialog(
        context: context, barrierDismissible: false,
        builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            title: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.check_circle_outline, color: primaryTeal, size: 28)), const SizedBox(width: 12), Text("MÜHÜRLENDİ", style: TextStyle(color: primaryTeal, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))]),
            content: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${widget.secilenArac.join(' ')} aracınız Plaza Ağına başarıyla yüklendi ve yayına alındı.", style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFFFAFAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("İLAN ID: ${yeniIlan.id.substring(0,6).toUpperCase()}", style: TextStyle(color: primaryTeal, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                      const SizedBox(height: 16),
                      const Text("SATIŞ FİYATI", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                      Text("₺${widget.yapayZekaFiyati.toStringAsFixed(0)}", style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                      const SizedBox(height: 12),
                      const Text("HAVUZ GÜVENCESİ", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                      Text(_havuzKabul ? 'Aktif' : 'Pasif', style: TextStyle(color: _havuzKabul ? Colors.green : Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: Text("PLAZAYA DÖN", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, fontFamily: 'Avenir'))
              )
            ]
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ağa bağlanırken hata oluştu: $e", style: const TextStyle(color: SiberTema.textMain, fontFamily: 'Avenir')), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFFAFAFC);
    const Color textColor = Color(0xFF1E293B);
    final Color primaryTeal = Colors.teal.shade700;

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => Navigator.pop(context)),
            title: Text('A D I M   3 / 3', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 4, fontFamily: 'Avenir')),
            centerTitle: true
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Vitrin & Detaylar", style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1, fontFamily: 'Avenir')),
                    const SizedBox(height: 8),
                    Text("${widget.secilenArac.join(' > ')}\nAracınızın görsellerini ve son donanım detaylarını ağa yükleyin.", style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                    const SizedBox(height: 40),

                    // Fiyat Bilgisi
                    const Text("Belirlenen Satış Fiyatı", style: TextStyle(color: Colors.white45, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                    const SizedBox(height: 8),
                    Text("₺${widget.yapayZekaFiyati.toStringAsFixed(0)}", style: TextStyle(color: primaryTeal, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1, fontFamily: 'Avenir')),
                    const SizedBox(height: 40),

                    Text("Vitrin Görselleri", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                    const SizedBox(height: 16),

                    // Fotoğraf Hazneleri
                    Row(
                      children: [
                        Expanded(flex: 2, child: _buildFotoKutusu(index: 1, isMain: true, seciliFoto: _anaFoto, primaryTeal: primaryTeal)),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: Column(children: [_buildFotoKutusu(index: 2, isMain: false, seciliFoto: _yanFoto1, primaryTeal: primaryTeal), const SizedBox(height: 12), _buildFotoKutusu(index: 3, isMain: false, seciliFoto: _yanFoto2, primaryTeal: primaryTeal)]),
                        )
                      ],
                    ),
                    const SizedBox(height: 40),

                    // İlan Açıklaması
                    Text("Donanım & Açıklama", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 5)]),
                      child: TextField(
                          controller: _aciklamaController,
                          maxLines: 5,
                          style: TextStyle(color: textColor, fontSize: 14, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                          decoration: const InputDecoration(
                              hintText: "Aracınızın ekstra donanımlarını, değişen parçalarını veya öne çıkan özelliklerini buraya detaylıca yazın...",
                              hintStyle: TextStyle(color: Colors.white26, fontSize: 13, fontFamily: 'Avenir'),
                              border: InputBorder.none
                          )
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 15 Günlük Havuz Toggle
                    Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _havuzKabul ? primaryTeal.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05), width: _havuzKabul ? 2 : 1),
                            boxShadow: [
                              if (_havuzKabul) BoxShadow(color: primaryTeal.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))
                              else BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))
                            ]
                        ),
                        child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: _havuzKabul ? primaryTeal.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05), shape: BoxShape.circle),
                                child: Icon(Icons.shield_outlined, color: _havuzKabul ? primaryTeal : Colors.black38, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Güvenli Havuz'a Katıl", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Avenir')),
                                        const SizedBox(height: 4),
                                        const Text("İlanınızda 15 günlük 'Güvenli Havuz' rozeti çıkar, alıcı güveni artar.", style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.4, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))
                                      ]
                                  )
                              ),
                              Switch(
                                  value: _havuzKabul,
                                  activeColor: Colors.white,
                                  activeTrackColor: primaryTeal,
                                  inactiveThumbColor: Colors.white,
                                  inactiveTrackColor: Colors.black26,
                                  onChanged: (val) => setState(() => _havuzKabul = val)
                              )
                            ]
                        )
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // SABİT ALT BUTON ALANI
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, -5))]
              ),
              child: SafeArea(
                child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _isSaving ? null : _ilaniYayinaAl,
                        child: _isSaving
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("İLANI YAYINA AL", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, fontFamily: 'Avenir'))
                    )
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // 💎 PLAZA MİMARİSİ: MAT VE ŞIK FOTOĞRAF KUTULARI
  Widget _buildFotoKutusu({required int index, required bool isMain, required File? seciliFoto, required Color primaryTeal}) {
    return GestureDetector(
      onTap: () => _galeridenFotoSec(index),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: seciliFoto != null ? primaryTeal.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05), width: seciliFoto != null ? 2 : 1),
              boxShadow: seciliFoto != null ? [BoxShadow(color: primaryTeal.withValues(alpha: 0.1), blurRadius: 10)] : [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 5)]
          ),
          child: seciliFoto != null
              ? Image.file(seciliFoto, fit: BoxFit.cover)
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), shape: BoxShape.circle), child: const Icon(Icons.add_a_photo_outlined, color: Colors.white26, size: 24)),
                if (isMain) const SizedBox(height: 12),
                if (isMain) const Text("Ana Kapak", style: TextStyle(color: Colors.white45, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, fontFamily: 'Avenir'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}