import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Görsel ağa eklendi.", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF00FFC2), duration: Duration(seconds: 1)));
    }
  }

  // 🌟 GERÇEK FİREBASE KAYIT MOTORU (SİBER MÜHÜR)
  Future<void> _ilaniYayinaAl() async {
    FocusScope.of(context).unfocus();

    if (_aciklamaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen alıcılar için bir donanım açıklaması girin.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
      return;
    }
    if (_anaFoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("En azından Ana Kapak Fotoğrafını yüklemelisiniz.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.orangeAccent));
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
        "lokasyon": "Siber Kuantum Ağı",
        "kayit_tarihi": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // 💎 TESLA MİMARİSİ: ŞIK BAŞARI DİYALOGU
      showDialog(
        context: context, barrierDismissible: false,
        builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF111111),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF00FFC2).withOpacity(0.3))),
            title: const Row(children: [Icon(Icons.check_circle_outline, color: Color(0xFF00FFC2), size: 28), SizedBox(width: 12), Text("MÜHÜRLENDİ", style: TextStyle(color: Color(0xFF00FFC2), fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1))]),
            content: Column(
              mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${widget.secilenArac.join(' ')} aracınız Kuantum Ağına başarıyla yüklendi ve yayına alındı.", style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("İLAN ID: ${yeniIlan.id.substring(0,6).toUpperCase()}", style: const TextStyle(color: Color(0xFF00FFC2), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const SizedBox(height: 12),
                      const Text("SATIS FIYATI", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Text("₺${widget.yapayZekaFiyati.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      const Text("HAVUZ GUVENCESI", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Text(_havuzKabul ? 'Aktif' : 'Pasif', style: TextStyle(color: _havuzKabul ? Colors.greenAccent : Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text("KARARGAHA DÖN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1))
              )
            ]
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Siber Ağa bağlanırken hata oluştu: $e", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 TESLA / APPLE ULTRA-MİNİMALİST PALET
    const bgColor = Color(0xFF000000);
    const surfaceColor = Color(0xFF111111);
    const accentColor = Colors.white;
    const primaryCyan = Color(0xFF00FFC2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: accentColor, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text('A D I M   3 / 3', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 4)),
          centerTitle: true
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Vitrin & Detaylar", style: TextStyle(color: accentColor, fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -1)),
                  const SizedBox(height: 8),
                  Text("${widget.secilenArac.join(' > ')}\nAracınızın görsellerini ve son donanım detaylarını ağa yükleyin.", style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
                  const SizedBox(height: 40),

                  // Fiyat Bilgisi (Sade ve Vurucu)
                  const Text("Belirlenen Satış Fiyatı", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text("₺${widget.yapayZekaFiyati.toStringAsFixed(0)}", style: const TextStyle(color: primaryCyan, fontSize: 40, fontWeight: FontWeight.w600, letterSpacing: -1)),
                  const SizedBox(height: 40),

                  const Text("Siber Vitrin Görselleri", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
                  const SizedBox(height: 16),

                  // Fotoğraf Hazneleri
                  Row(
                    children: [
                      Expanded(flex: 2, child: _buildFotoKutusu(index: 1, isMain: true, seciliFoto: _anaFoto)),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Column(children: [_buildFotoKutusu(index: 2, isMain: false, seciliFoto: _yanFoto1), const SizedBox(height: 12), _buildFotoKutusu(index: 3, isMain: false, seciliFoto: _yanFoto2)]),
                      )
                    ],
                  ),
                  const SizedBox(height: 40),

                  // İlan Açıklaması (Premium Input)
                  const Text("Donanım & Açıklama", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
                    child: TextField(
                        controller: _aciklamaController,
                        maxLines: 5,
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                        decoration: const InputDecoration(
                            hintText: "Aracınızın ekstra donanımlarını, değişen parçalarını veya öne çıkan özelliklerini buraya detaylıca yazın...",
                            hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                            border: InputBorder.none
                        )
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 15 Günlük Havuz Toggle (Minimalist)
                  Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _havuzKabul ? primaryCyan.withOpacity(0.5) : Colors.transparent)
                      ),
                      child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: _havuzKabul ? primaryCyan.withOpacity(0.1) : Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                              child: Icon(Icons.shield_outlined, color: _havuzKabul ? primaryCyan : Colors.white54, size: 24),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Güvenli Havuz'a Katıl", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                      SizedBox(height: 4),
                                      Text("İlanınızda 15 günlük 'Güvenli Havuz' rozeti çıkar, alıcı güveni artar.", style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.4))
                                    ]
                                )
                            ),
                            Switch(
                                value: _havuzKabul,
                                activeColor: primaryCyan,
                                activeTrackColor: primaryCyan.withOpacity(0.3),
                                inactiveThumbColor: Colors.white54,
                                inactiveTrackColor: Colors.white12,
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
            decoration: const BoxDecoration(
              color: bgColor,
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryCyan,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSaving ? null : _ilaniYayinaAl,
                    child: _isSaving
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : const Text("İLANI YAYINA AL", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5))
                )
            ),
          )
        ],
      ),
    );
  }

  // 💎 TESLA MİMARİSİ: MAT VE ŞIK FOTOĞRAF KUTULARI
  Widget _buildFotoKutusu({required int index, required bool isMain, required File? seciliFoto}) {
    return GestureDetector(
      onTap: () => _galeridenFotoSec(index),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: seciliFoto != null ? const Color(0xFF00FFC2).withOpacity(0.5) : Colors.white.withOpacity(0.05), width: 1)
          ),
          child: seciliFoto != null
              ? Image.file(seciliFoto, fit: BoxFit.cover)
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: Colors.white24, size: isMain ? 32 : 24),
                if (isMain) const SizedBox(height: 12),
                if (isMain) const Text("Ana Kapak Fotoğrafı", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5))
              ],
            ),
          ),
        ),
      ),
    );
  }
}