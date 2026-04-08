import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io'; // IP ve Cihaz bilgisi için (Web'de farklı kütüphane gerekebilir)

// 🔥 SİBER KÖPRÜLER
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class VatandasQrIletisimScreen extends StatefulWidget {
  final String hedefPlaka;
  final String hedefSahipId;
  final String hedefSahipAdSoyad;

  const VatandasQrIletisimScreen({
    super.key,
    required this.hedefPlaka,
    required this.hedefSahipId,
    required this.hedefSahipAdSoyad,
  });

  @override
  State<VatandasQrIletisimScreen> createState() => _VatandasQrIletisimScreenState();
}

class _VatandasQrIletisimScreenState extends State<VatandasQrIletisimScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _mesajController = TextEditingController();

  String _seciliIhlal = "";
  bool _isSending = false;
  bool _bildirimGonderildi = false; // Tek Tik: ✓
  bool _bildirimUlasti = false;    // Çift Tik: ✓✓
  bool _bildirimOkundu = false;     // Mavi/Yeşil Çift Tik: ✓✓

  // 🛰️ SİBER İHLAL ŞABLONLARI
  final List<Map<String, dynamic>> _ihlalButonlari = [
    {"baslik": "YANLIŞ PARK", "icon": Icons.local_parking, "renk": Colors.orangeAccent},
    {"baslik": "KAZAYA KARIŞTI", "icon": Icons.car_crash, "renk": SiberTema.kanKirmizi},
    {"baslik": "CAMI AÇIK", "icon": Icons.window, "renk": Colors.lightBlueAccent},
    {"baslik": "FARLAR AÇIK", "icon": Icons.lightbulb, "renk": Colors.yellowAccent},
  ];

  // 🚀 SİNYAL FIRLATMA VE IP MÜHÜRLEME MOTORU
  Future<void> _sinyalFirlat() async {
    if (_seciliIhlal.isEmpty && _mesajController.text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      // 1. IP VE KONUM VERİSİ HAZIRLIĞI (Siber Güvenlik İçin)
      // Gerçek IP adresi için bir servis kullanılabilir, burada temsilidir.
      String gonderenIp = "192.168.1.X";

      // 2. BİLDİRİM DOKÜMANI OLUŞTUR (Canlı Takip İçin)
      DocumentReference bildirimRef = await _db
          .collection('kullanicilar')
          .doc(widget.hedefSahipId)
          .collection('gelen_ihbarlar')
          .add({
        'plaka': widget.hedefPlaka,
        'ihlal_tipi': _seciliIhlal,
        'ozel_mesaj': _mesajController.text,
        'gonderen_ip': gonderenIp,
        'tarih': FieldValue.serverTimestamp(),
        'durum': 'gonderildi', // ✓
        'sohbet_izni': false,
      });

      setState(() => _bildirimGonderildi = true); // Tek Tik

      // 3. CANLI DURUM TAKİBİ (Çift Tik ve Okundu Bilgisi İçin Dinleyici)
      bildirimRef.snapshots().listen((snapshot) {
        if (snapshot.exists) {
          var data = snapshot.data() as Map<String, dynamic>;
          setState(() {
            if (data['durum'] == 'ulasti') _bildirimUlasti = true; // ✓✓
            if (data['durum'] == 'okundu') _bildirimOkundu = true; // Mavi ✓✓
          });

          // Eğer araç sahibi sohbeti açarsa...
          if (data['sohbet_izni'] == true) {
            _sohbeteBaglan(bildirimRef.id);
          }
        }
      });

    } catch (e) {
      _siberHata("SİNYAL KESİLDİ!");
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _sohbeteBaglan(String bildirimId) {
    // Sohbet ekranına yönlendirme kodları buraya gelecek
    _siberHata("ARAÇ SAHİBİ SOHBETİ AÇTI! BAĞLANILIYOR...");
  }

  void _siberHata(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: SiberTema.kanKirmizi, content: Text(mesaj)));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: const Text("OTO-İHBAR TERMİNALİ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2))),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // 🪪 ARAÇ KİMLİK KARTI
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: SiberTema.matGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5)),
                    boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 20)]
                ),
                child: Column(
                  children: [
                    Text(widget.hedefPlaka, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 3)),
                    const Divider(color: Colors.white12, height: 20),
                    Text(widget.hedefSahipAdSoyad, style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 🔘 HIZLI İHLAL BUTONLARI
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.5),
                itemCount: _ihlalButonlari.length,
                itemBuilder: (context, index) {
                  var item = _ihlalButonlari[index];
                  bool secili = _seciliIhlal == item['baslik'];
                  return InkWell(
                    onTap: () => setState(() => _seciliIhlal = item['baslik']),
                    child: Container(
                      decoration: BoxDecoration(
                        color: secili ? item['renk'].withOpacity(0.2) : SiberTema.matGrey,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: secili ? item['renk'] : Colors.white10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item['icon'], color: secili ? item['renk'] : Colors.white38, size: 20),
                          const SizedBox(width: 8),
                          Text(item['baslik'], style: TextStyle(color: secili ? item['renk'] : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // ✍️ ÖZEL MESAJ ALANI
              TextField(
                controller: _mesajController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: SiberTema.siberInputDekorasyonu("Araç sahibine not bırakın..."),
              ),
              const SizedBox(height: 32),

              // 🚀 GÖNDER VE DURUM TAKİBİ
              SizedBox(
                width: double.infinity, height: 65,
                child: ElevatedButton(
                  style: SiberTema.kuantumButonStili(),
                  onPressed: _isSending ? null : _sinyalFirlat,
                  child: _isSending
                      ? const CircularProgressIndicator(color: SiberTema.oledBlack)
                      : const Text("ANONİM BİLDİRİM GÖNDER", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900)),
                ),
              ),

              const SizedBox(height: 24),

              // ✅ DURUM RADARI (TİK SİSTEMİ)
              if (_bildirimGonderildi)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("DURUM: ", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
                    _buildTikIcon(Icons.done, _bildirimGonderildi), // Tek Tik
                    _buildTikIcon(Icons.done_all, _bildirimUlasti), // Çift Tik
                    const SizedBox(width: 10),
                    if (_bildirimOkundu) const Text("OKUNDU", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.w900)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTikIcon(IconData icon, bool aktif) {
    return Icon(icon, size: 18, color: aktif ? (_bildirimOkundu ? SiberTema.kuantumCyan : Colors.white70) : Colors.white10);
  }
}