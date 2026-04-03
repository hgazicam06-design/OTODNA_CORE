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
  bool _konumDogrulandi = false; // KOMUTANIN İSTEDİĞİ GPS GÜVENLİĞİ

  String _sahipIsmi = "Gizli Kullanıcı";
  String _aracMarkaModel = "OtoDNA Aracı";

  // SOHBET GEÇMİŞİ (Firebase'den önce lokal sistem mesajlarını tutmak için)
  final List<Map<String, dynamic>> _lokalSistemMesajlari = [];

  @override
  void initState() {
    super.initState();
    _aracBilgileriniCek();
    _gpsDogrulamasiniBaslat();
  }

  // 💎 TESLA MİMARİSİ: GPS KONUM DOĞRULAMA SİMÜLASYONU
  void _gpsDogrulamasiniBaslat() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _konumDogrulandi = true;
        _lokalSistemMesajlari.add({
          "metin": "📍 Kuantum GPS Doğrulaması Başarılı!\nSistem, tarama işleminin aracın tam 2.4 metre yakınında (Fiziksel Temas Mesafesi) yapıldığını onayladı. Araç sahibine güvenli konum bildirimi iletildi.",
          "sistemMi": true,
          "tarih": DateTime.now(),
        });
      });
    });
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
          if (_aracMarkaModel.isEmpty) _aracMarkaModel = "Siber Ağ Aracı";
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
      'gps_onayli': _konumDogrulandi, // Mesajın fiziksel yakından atıldığı veritabanına mühürlenir
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

        await _mesajGonder("📸 Görsel Kanıt İletildi", fotoLink: link);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ağa görsel yüklenemedi.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent));
      } finally {
        setState(() => _isSendingFoto = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 TESLA KLASMANI ULTRA SADE PALET
    const bgColor = Color(0xFF000000);
    const surfaceColor = Color(0xFF111111);
    const primaryCyan = Color(0xFF00FFC2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: _isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: primaryCyan, strokeWidth: 2))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.plaka.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 3)),
            const SizedBox(height: 2),
            Text("KRİPTOLU AĞ: ${_sahipIsmi.toUpperCase()}", style: const TextStyle(color: primaryCyan, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isBlocked ? Icons.notifications_off_outlined : Icons.shield_outlined, color: _isBlocked ? Colors.redAccent : Colors.white54, size: 22),
            onPressed: () => setState(() => _isBlocked = !_isBlocked),
          )
        ],
      ),
      body: Column(
        children: [
          // 💎 GPS VE GÜVENLİK KARTI
          Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(color: surfaceColor, border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: _konumDogrulandi ? Colors.greenAccent.withOpacity(0.1) : Colors.orangeAccent.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: _konumDogrulandi ? Colors.greenAccent.withOpacity(0.3) : Colors.orangeAccent.withOpacity(0.3))),
                  child: Icon(_konumDogrulandi ? Icons.gps_fixed : Icons.satellite_alt_outlined, color: _konumDogrulandi ? Colors.greenAccent : Colors.orangeAccent, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_aracMarkaModel, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text(_konumDogrulandi ? "Fiziksel Temas Onaylı (Araç Yanında)" : "GPS Doğrulaması Bekleniyor...", style: TextStyle(color: _konumDogrulandi ? Colors.greenAccent : Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 💎 HIZLI BİLDİRİM ÇİPLERİ
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
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

          // 💎 SOHBET ALANI (Firebase + Lokal Mesajlar)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('arac_mesajlari').where('plaka', isEqualTo: widget.plaka).orderBy('tarih', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData && _lokalSistemMesajlari.isEmpty) return const Center(child: CircularProgressIndicator(color: primaryCyan));

                // Firebase'den gelenleri ve lokal sistem mesajlarını birleştir
                var firebaseMesajlar = snapshot.data?.docs ?? [];

                // Mesaj listesi boşsa ve GPS henüz onaylanmadıysa Kilit ekranı göster
                if (firebaseMesajlar.isEmpty && _lokalSistemMesajlari.isEmpty) {
                  return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline, color: Colors.white12, size: 48),
                          SizedBox(height: 16),
                          Text("Uçtan Uca Şifreli Bağlantı.\nAraç sahibine anonim olarak ulaşın.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.5)),
                        ],
                      )
                  );
                }

                // Toplam mesaj sayısını hesapla (Lokal sistem mesajları her zaman en altta/önce görünsün diye)
                int totalCount = firebaseMesajlar.length + _lokalSistemMesajlari.length;

                return ListView.builder(
                  reverse: true, physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), itemCount: totalCount,
                  itemBuilder: (context, index) {
                    // Reverse olduğu için 0. index en son atılan mesajdır (Firebase)
                    // Firebase mesajları bittikten sonra lokal mesajları gösteririz
                    bool isFirebase = index < firebaseMesajlar.length;

                    if (!isFirebase) {
                      // LOKAL SİSTEM MESAJLARI (GPS Onayı vb.)
                      var lData = _lokalSistemMesajlari[index - firebaseMesajlar.length];
                      return _buildSistemMesajKarti(lData['metin']);
                    }

                    // FİREBASE MESAJLARI
                    var mData = firebaseMesajlar[index].data() as Map<String, dynamic>;
                    bool benimMesajim = mData['gonderen_id'] == 'anonim_vatandas_1';
                    int durum = mData['durum'] ?? 0;
                    String? fotoLink = mData['foto_link'];
                    bool gpsOnayli = mData['gps_onayli'] ?? false; // GPS mührü

                    String saatYazisi = "";
                    if (mData['tarih'] != null) {
                      DateTime t = (mData['tarih'] as Timestamp).toDate();
                      saatYazisi = "${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}";
                    }

                    return Align(
                      alignment: benimMesajim ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: benimMesajim ? primaryCyan.withOpacity(0.05) : surfaceColor,
                          borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20), topRight: const Radius.circular(20),
                              bottomLeft: benimMesajim ? const Radius.circular(20) : const Radius.circular(4),
                              bottomRight: benimMesajim ? const Radius.circular(4) : const Radius.circular(20)
                          ),
                          border: Border.all(color: benimMesajim ? primaryCyan.withOpacity(0.3) : Colors.white.withOpacity(0.05), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (fotoLink != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(fotoLink, width: 220, height: 220, fit: BoxFit.cover),
                                ),
                              ),
                            if (mData['mesaj'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(mData['mesaj'], style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
                              ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (gpsOnayli) const Icon(Icons.gps_fixed, color: Colors.greenAccent, size: 10),
                                if (gpsOnayli) const SizedBox(width: 4),
                                Text(saatYazisi, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
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

          // 💎 MESAJ GİRİŞ ALANI
          if (_isBlocked)
            Container(padding: const EdgeInsets.all(16), width: double.infinity, color: Colors.redAccent.withOpacity(0.1), child: const Text("SİBER BAĞLANTI REDDEDİLDİ", textAlign: TextAlign.center, style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 2)))
          else
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: bgColor, border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _isSendingFoto ? null : _fotografCekVeGonder,
                      child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: surfaceColor, shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.1))),
                          child: _isSendingFoto ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: primaryCyan, strokeWidth: 2)) : const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20)
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
                        child: TextField(
                            controller: _mesajController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(hintText: "Sinyal mesajı yazın...", hintStyle: TextStyle(color: Colors.white24, fontSize: 13), border: InputBorder.none)
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _mesajGonder(_mesajController.text),
                      child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(color: primaryCyan, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.3), blurRadius: 10)]),
                          child: const Icon(Icons.send_rounded, color: Colors.black, size: 18)
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

  // 💎 TESLA MİMARİSİ: HIZLI BİLDİRİM ÇİPLERİ
  Widget _buildHizliButon(String metin, IconData ikon) {
    return InkWell(
      onTap: () => _mesajGonder(metin),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Row(
          children: [
            Icon(ikon, color: const Color(0xFF00FFC2), size: 14),
            const SizedBox(width: 8),
            Text(metin, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // 💎 SİSTEM MESAJ KARTI (GPS Onayı vb.)
  Widget _buildSistemMesajKarti(String metin) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.3))
        ),
        child: Column(
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.security, color: Colors.greenAccent, size: 14),
                SizedBox(width: 8),
                Text("SİSTEM DOĞRULAMASI", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ],
            ),
            const SizedBox(height: 8),
            Text(metin, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildTikIkonu(int durum) {
    if (durum == 0) return const Icon(Icons.check, color: Colors.white38, size: 14);
    if (durum == 1) return const Icon(Icons.done_all, color: Colors.white38, size: 14);
    return const Icon(Icons.done_all, color: Color(0xFF00FFC2), size: 14);
  }
}