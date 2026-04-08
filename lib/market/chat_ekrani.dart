import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// 🔥 SİBER KÖPRÜLER
import '../../core/siber_tema.dart';

class OtoDnaChatScreen extends StatefulWidget {
  final String chatId; // Gerçek veritabanındaki odanın kimliği
  final String aktifKullaniciId; // Mesajı atan kişi
  final String saticiAdi;
  final String urunAdi;
  final String urunFiyati;

  const OtoDnaChatScreen({
    super.key,
    required this.chatId,
    required this.aktifKullaniciId,
    this.saticiAdi = "Murat Plaza & Oto Çıkma", // Kuralımız gereği vitrin ismi
    this.urunAdi = "BMW F30 Orijinal Sol Far (Çıkma)",
    this.urunFiyati = "12.500 TL",
  });

  @override
  State<OtoDnaChatScreen> createState() => _OtoDnaChatScreenState();
}

class _OtoDnaChatScreenState extends State<OtoDnaChatScreen> {
  // Siber Renk Paleti (SiberTema'dan besleniyor)
  static const _neonGreen = SiberTema.kuantumCyan;
  static const _cyberBlack = SiberTema.oledBlack;
  static const _cyberCard = Color(0xFF1E1E2E);
  static const _karsiMesaj = Color(0xFF2A2A3A);

  final TextEditingController _mesajController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cyberBlack,
      appBar: _buildSiberAppBar(),
      body: Column(
        children: [
          _buildHavuzDurumPanosu(), // Gerçek zamanlı Güvenli Havuz Panosu
          Expanded(child: _buildMesajListesi()), // Canlı Chat Alanı
          _buildAksiyonButonlari(), // Gerçek Veritabanı Tetikleyicileri
          _buildMesajGondermeAlani(), // Sansürlü Klavye Alanı
        ],
      ),
    );
  }

  // ─── ÜST BAR (APP BAR) ───
  AppBar _buildSiberAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      iconTheme: const IconThemeData(color: _neonGreen),
      title: Row(
        children: [
          const CircleAvatar(
            backgroundColor: _neonGreen,
            child: Icon(Icons.person, color: Colors.black),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.saticiAdi, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                const Row(
                  children: [
                    Icon(Icons.circle, color: _neonGreen, size: 10),
                    SizedBox(width: 4),
                    Text("Kuantum Ağına Bağlı", style: TextStyle(color: _neonGreen, fontSize: 12, fontFamily: 'Avenir')),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── CANLI SİBER HAVUZ (ESCROW) PANOSU ───
  Widget _buildHavuzDurumPanosu() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _db.collection('ticaret_havuzu').doc(widget.chatId).snapshots(),
      builder: (context, snapshot) {
        int havuzDurumu = 1; // Varsayılan: Kargoda/Bekliyor
        if (snapshot.hasData && snapshot.data!.exists) {
          havuzDurumu = (snapshot.data!.data() as Map<String, dynamic>)['havuz_durumu'] ?? 1;
        }

        return Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _cyberCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _neonGreen.withOpacity(0.5)),
            boxShadow: [BoxShadow(color: _neonGreen.withOpacity(0.1), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(widget.urunAdi, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Avenir'))),
                  Text(widget.urunFiyati, style: const TextStyle(color: _neonGreen, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Avenir')),
                ],
              ),
              const Divider(color: Colors.white24),
              Row(
                children: [
                  const Icon(Icons.security, color: _neonGreen, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      havuzDurumu == 1
                          ? "Ödeme OtoDNA Siber Kasa'da güvende. Satıcı kargolama yapacak."
                          : "Ürün teslim alındı. 15 Günlük İade Süreci Başladı!",
                      style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Avenir'),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // ─── GERÇEK ZAMANLI (CANLI) MESAJ LİSTESİ ───
  Widget _buildMesajListesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('ticaret_havuzu')
          .doc(widget.chatId)
          .collection('mesajlar')
          .orderBy('zaman_damgasi', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _neonGreen));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("OtoDNA Kriptolu Sohbet Başladı", style: TextStyle(color: Colors.white54, fontFamily: 'Avenir')));
        }

        var mesajlar = snapshot.data!.docs;
        WidgetsBinding.instance.addPostFrameCallback((_) => _listeyiEnAtaKaydir());

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: mesajlar.length,
          itemBuilder: (context, index) {
            var msj = mesajlar[index].data() as Map<String, dynamic>;
            bool isMe = msj["gonderen_id"] == widget.aktifKullaniciId;
            bool isSistem = msj["tip"] == "sistem";

            String saat = "";
            if (msj["zaman_damgasi"] != null) {
              DateTime dt = (msj["zaman_damgasi"] as Timestamp).toDate();
              saat = DateFormat('HH:mm').format(dt);
            }

            if (isSistem) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber)),
                  child: Text(msj["metin"] ?? "", style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir'), textAlign: TextAlign.center),
                ),
              );
            }

            return Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                decoration: BoxDecoration(
                  color: isMe ? _neonGreen.withOpacity(0.2) : _karsiMesaj,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                    bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                  ),
                  border: isMe ? Border.all(color: _neonGreen.withOpacity(0.5)) : Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(msj["metin"] ?? "", style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Avenir')),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(saat, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontFamily: 'Avenir')),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── AKSİYON BUTONLARI (FİREBASE TETİKLEYİCİLERİ) ───
  Widget _buildAksiyonButonlari() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: _cyberCard, side: BorderSide(color: _neonGreen.withOpacity(0.5))),
              icon: const Icon(Icons.camera_alt, color: _neonGreen, size: 18),
              label: const Text("Mühürlü Foto Çek", style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Avenir')),
              onPressed: () {
                _sistemMesajiGonder("📸 Satıcı ürünü paketlerken OtoDNA Mühürlü fotoğraf yükledi.");
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: _neonGreen),
              icon: const Icon(Icons.check_circle, color: Colors.black, size: 18),
              label: const Text("Teslim Aldım", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Avenir')),
              onPressed: () async {
                await _db.collection('ticaret_havuzu').doc(widget.chatId).set({'havuz_durumu': 2}, SetOptions(merge: true));
                _sistemMesajiGonder("✅ Alıcı ürünü teslim aldığını onayladı. 15 Günlük Güvenlik Sayacı başladı!");
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── YAPAY ZEKA KONTROLLÜ MESAJ GÖNDERME ALANI ───
  Widget _buildMesajGondermeAlani() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        color: _cyberCard,
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white24)),
              child: TextField(
                controller: _mesajController,
                style: const TextStyle(color: Colors.white, fontFamily: 'Avenir'),
                decoration: const InputDecoration(
                  hintText: "Kriptolu Mesaj yazın...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _mesajGonder,
            child: const CircleAvatar(
              backgroundColor: _neonGreen,
              radius: 22,
              child: Icon(Icons.send, color: Colors.black),
            ),
          )
        ],
      ),
    );
  }

  // ─── 🛡️ YAPAY ZEKA SANSÜR MOTORU VE GERÇEK FİREBASE GÖNDERİMİ ───
  Future<void> _mesajGonder() async {
    String metin = _mesajController.text.trim();
    if (metin.isEmpty) return;

    // SİBER KORUMA: Telefon numarası veya IBAN yakalayıcı
    bool ihlalVar = metin.contains(RegExp(r'[0-9]{10}')) ||
        metin.toLowerCase().contains("iban") ||
        (metin.toLowerCase().contains("tr") && metin.contains(RegExp(r'[0-9]{5}')));

    if (ihlalVar) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("🚨 SİBER GÜVENLİK İHLALİ: İletişim bilgisi paylaşmak yasaktır!", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        backgroundColor: Colors.redAccent,
      ));
      _mesajController.clear();
      _sistemMesajiGonder("⚠️ SİSTEM UYARISI: Güvenlik kalkanı ihlal girişimi engelledi.");
      return;
    }

    _mesajController.clear();

    try {
      await _db.collection('ticaret_havuzu').doc(widget.chatId).collection('mesajlar').add({
        "gonderen_id": widget.aktifKullaniciId,
        "tip": "kullanici",
        "metin": metin,
        "zaman_damgasi": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Hata: $e");
    }
  }

  Future<void> _sistemMesajiGonder(String metin) async {
    try {
      await _db.collection('ticaret_havuzu').doc(widget.chatId).collection('mesajlar').add({
        "gonderen_id": "SISTEM",
        "tip": "sistem",
        "metin": metin,
        "zaman_damgasi": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Hata: $e");
    }
  }

  void _listeyiEnAtaKaydir() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
}