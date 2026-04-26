import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AracIletisimScreen extends StatefulWidget {
  final String plaka;
  const AracIletisimScreen({super.key, required this.plaka});

  @override
  State<AracIletisimScreen> createState() => _AracIletisimScreenState();
}

class _AracIletisimScreenState extends State<AracIletisimScreen> {
  final TextEditingController _mesajController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _isBlocked = false;
  bool _isLoading = true;
  bool _isSendingFoto = false;

  String _sahipIsmi = "Gizli Kullanıcı";
  String _aracMarkaModel = "OtoDNA Aracı";

  // 🏢 PLAZA KALİTESİ PALET (Açık, Ferah ve Lüks)
  final Color bgColor = const Color(0xFFFAFAFC);
  final Color surfaceColor = Colors.white;
  final Color primaryTeal = Colors.teal.shade700;
  final Color textColor = const Color(0xFF1E293B);
  final Color subTextColor = Colors.black54;

  @override
  void initState() {
    super.initState();
    _aracBilgileriniCek();
  }

  Future<void> _aracBilgileriniCek() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('araclar').doc(widget.plaka).get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        String hamIsim = data['sahibi'] ?? "Bilinmiyor";

        setState(() {
          _sahipIsmi = _isimSoyisimMaskele(hamIsim);
          _aracMarkaModel = "${data['marka'] ?? ''} ${data['model'] ?? ''}".trim();
          if (_aracMarkaModel.isEmpty) _aracMarkaModel = "OtoDNA Aracı";
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _isimSoyisimMaskele(String tamIsim) {
    if (tamIsim.isEmpty || tamIsim == "Bilinmiyor" || tamIsim == "OtoDNA Bayi") return tamIsim;
    List<String> parcalar = tamIsim.trim().split(" ");
    if (parcalar.length == 1) return "${parcalar[0].substring(0, 1)}***";
    String isim = parcalar.sublist(0, parcalar.length - 1).join(" ");
    String soyisim = parcalar.last;
    return "$isim ${soyisim[0]}${List.filled(soyisim.length - 1, '*').join('')}";
  }

  Future<void> _mesajGonder(String mesajMetni, {String? fotoLink}) async {
    if ((mesajMetni.isEmpty && fotoLink == null) || _isBlocked) return;
    _mesajController.clear();
    FocusScope.of(context).unfocus();

    await FirebaseFirestore.instance.collection('arac_mesajlari').add({
      'plaka': widget.plaka,
      'gonderen_id': 'anonim_vatandas_1',
      'mesaj': mesajMetni,
      'foto_link': fotoLink,
      'tarih': FieldValue.serverTimestamp(),
      'durum': 0,
    });
  }

  Future<void> _fotografCekVeGonder() async {
    if (_isBlocked) return;
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 60);

    if (image != null) {
      setState(() => _isSendingFoto = true);
      try {
        File dosya = File(image.path);
        String dosyaAdi = "iletisim_${DateTime.now().millisecondsSinceEpoch}.jpg";
        Reference ref = FirebaseStorage.instance.ref().child('iletisim_dosyalari/${widget.plaka}/$dosyaAdi');

        UploadTask uploadTask = ref.putFile(dosya);
        TaskSnapshot snapshot = await uploadTask;
        String link = await snapshot.ref.getDownloadURL();

        await _mesajGonder("📷 Görsel Kanıt", fotoLink: link);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Görsel yüklenemedi.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
      } finally {
        setState(() => _isSendingFoto = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent, // Material 3 tint'i kapat
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 18), onPressed: () => Navigator.pop(context)),
        title: _isLoading
            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: primaryTeal, strokeWidth: 2))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("${widget.plaka} • $_aracMarkaModel", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5, fontFamily: 'Avenir')),
            const SizedBox(height: 2),
            Text("Kriptolu Bağlantı: $_sahipIsmi", style: TextStyle(color: primaryTeal, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Avenir')),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isBlocked ? Icons.notifications_off_outlined : Icons.notifications_active_outlined, color: _isBlocked ? Colors.redAccent : Colors.black45, size: 20),
            onPressed: () {
              setState(() => _isBlocked = !_isBlocked);
            },
          )
        ],
      ),
      body: Column(
        children: [
          // ZARİF BİLDİRİM ÇİPLERİ
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05)))),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildHizliButon("Hatalı Park", Icons.warning_amber_rounded),
                  _buildHizliButon("Kazaya Karıştı", Icons.car_crash_outlined),
                  _buildHizliButon("Farlar Açık", Icons.lightbulb_outline),
                  _buildHizliButon("Cam Açık", Icons.sensor_window_outlined),
                ],
              ),
            ),
          ),

          // SOHBET ALANI
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('arac_mesajlari').where('plaka', isEqualTo: widget.plaka).orderBy('tarih', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: primaryTeal));
                var mesajlar = snapshot.data!.docs;

                if (mesajlar.isEmpty) {
                  return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline, color: Colors.black12, size: 48),
                          const SizedBox(height: 16),
                          Text("Uçtan Uca Şifreli Bağlantı.\nAraç sahibine anonim olarak ulaşın.", textAlign: TextAlign.center, style: TextStyle(color: subTextColor, fontSize: 13, height: 1.5, fontFamily: 'Avenir')),
                        ],
                      )
                  );
                }

                return ListView.builder(
                  reverse: true, physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(20), itemCount: mesajlar.length,
                  itemBuilder: (context, index) {
                    var mData = mesajlar[index].data() as Map<String, dynamic>;
                    bool benimMesajim = mData['gonderen_id'] == 'anonim_vatandas_1';
                    int durum = mData['durum'] ?? 0;
                    String? fotoLink = mData['foto_link'];

                    String saatYazisi = "";
                    if (mData['tarih'] != null) {
                      DateTime t = (mData['tarih'] as Timestamp).toDate();
                      saatYazisi = "${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}";
                    }

                    return Align(
                      alignment: benimMesajim ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: benimMesajim ? primaryTeal : surfaceColor,
                          boxShadow: benimMesajim ? [BoxShadow(color: primaryTeal.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))],
                          borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                              bottomLeft: benimMesajim ? const Radius.circular(16) : const Radius.circular(4),
                              bottomRight: benimMesajim ? const Radius.circular(4) : const Radius.circular(16)
                          ),
                          border: benimMesajim ? null : Border.all(color: Colors.black.withValues(alpha: 0.05), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (fotoLink != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(fotoLink, width: 200, height: 200, fit: BoxFit.cover),
                                ),
                              ),
                            if (mData['mesaj'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(mData['mesaj'], style: TextStyle(color: benimMesajim ? Colors.white : textColor, fontSize: 14, letterSpacing: 0.3, fontFamily: 'Avenir', fontWeight: FontWeight.w500)),
                              ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(saatYazisi, style: TextStyle(color: benimMesajim ? Colors.white70 : Colors.black38, fontSize: 10, fontFamily: 'Avenir')),
                                const SizedBox(width: 6),
                                if (benimMesajim) _buildTikIkonu(durum),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // MESAJ GİRİŞ ALANI
          if (_isBlocked)
            Container(padding: const EdgeInsets.all(16), width: double.infinity, color: Colors.redAccent.withValues(alpha: 0.1), child: const Text("Bağlantı Reddedildi", textAlign: TextAlign.center, style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1)))
          else
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: bgColor, border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05)))),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _isSendingFoto ? null : _fotografCekVeGonder,
                      child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: surfaceColor, shape: BoxShape.circle, border: Border.all(color: Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)]),
                          child: _isSendingFoto ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: primaryTeal, strokeWidth: 2)) : const Icon(Icons.camera_alt_outlined, color: Colors.black54, size: 20)
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)]),
                        child: TextField(controller: _mesajController, style: TextStyle(color: textColor, fontSize: 14, fontFamily: 'Avenir', fontWeight: FontWeight.w500), decoration: InputDecoration(hintText: "Mesajınızı yazın...", hintStyle: TextStyle(color: Colors.black38, fontSize: 13, fontFamily: 'Avenir'), border: InputBorder.none)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _mesajGonder(_mesajController.text),
                      child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: primaryTeal, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 18)
                      ),
                    )
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildHizliButon(String metin, IconData ikon) {
    return InkWell(
      onTap: () => _mesajGonder(metin),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4)]),
        child: Row(
          children: [
            Icon(ikon, color: Colors.black54, size: 14),
            const SizedBox(width: 6),
            Text(metin, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  Widget _buildTikIkonu(int durum) {
    if (durum == 0) return const Icon(Icons.check, color: Colors.white70, size: 12);
    if (durum == 1) return const Icon(Icons.done_all, color: Colors.white70, size: 12);
    return const Icon(Icons.done_all, color: Colors.white, size: 12); // Okundu (Beyaz renk, çünkü arka plan teal)
  }
}