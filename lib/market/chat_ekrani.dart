import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// 🔥 SİBER KÖPRÜLER
import '../../core/siber_tema.dart';

class OtoDnaChatScreen extends StatefulWidget {
  final String chatId;
  final String aktifKullaniciId;
  final String saticiAdi;
  final String urunAdi;
  final String urunFiyati;

  const OtoDnaChatScreen({
    super.key,
    required this.chatId,
    required this.aktifKullaniciId,
    this.saticiAdi = "OtoDNA Güvenceli Satıcı",
    this.urunAdi = "Kripto Havuz İşlemi",
    this.urunFiyati = "---",
  });

  @override
  State<OtoDnaChatScreen> createState() => _OtoDnaChatScreenState();
}

class _OtoDnaChatScreenState extends State<OtoDnaChatScreen> {
  static const _neonGreen = SiberTema.kuantumCyan;
  static const _cyberBlack = SiberTema.oledBlack;

  final TextEditingController _mesajController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? _karsiKullaniciId;

  @override
  void initState() {
    super.initState();
    _karsiKullaniciyiBul();
  }

  // Ticaret havuzundan karşı tarafın kimliğini çeker
  Future<void> _karsiKullaniciyiBul() async {
    try {
      DocumentSnapshot doc = await _db.collection('ticaret_havuzu').doc(widget.chatId).get();
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        String aliciId = data['alici_id'] ?? '';
        String saticiId = data['satici_id'] ?? '';

        setState(() {
          _karsiKullaniciId = (widget.aktifKullaniciId == aliciId) ? saticiId : aliciId;
        });
      }
    } catch (e) {
      debugPrint("Karşı kullanıcı bulunamadı.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cyberBlack,
      body: Container(
        decoration: SiberTema.siberArkaPlan,
        child: SafeArea(
          child: Column(
            children: [
              _buildSiberAppBar(),
              _buildSadeHavuzPanosu(),
              Expanded(child: _buildMesajListesi()),
              _buildAksiyonButonlari(),
              _buildMesajGondermeAlani(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── ÜST BAR (SADE VE ŞIK) ───
  Widget _buildSiberAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            border: const Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new, color: _neonGreen, size: 20),
              ),
              const SizedBox(width: 16),
              const CircleAvatar(
                backgroundColor: _neonGreen,
                radius: 18,
                child: Icon(Icons.person, color: Colors.black, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.saticiAdi, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                    const SizedBox(height: 2),
                    
                    // KARA LİSTE KONTROLÜ (SADE ROZET)
                    if (_karsiKullaniciId != null)
                      StreamBuilder<DocumentSnapshot>(
                        stream: _db.collection('kullanicilar').doc(_karsiKullaniciId).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.exists) {
                            var kData = snapshot.data!.data() as Map<String, dynamic>;
                            bool karaListedeMi = (kData['hesap_durumu'] == 'KARA_LISTE');

                            if (karaListedeMi) {
                              return Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: SiberTema.kanKirmizi, size: 12),
                                  const SizedBox(width: 4),
                                  Text("KARA LİSTE KULLANICISI", style: TextStyle(color: SiberTema.kanKirmizi.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                ],
                              );
                            }
                          }
                          return const Row(
                            children: [
                              Icon(Icons.circle, color: _neonGreen, size: 8),
                              SizedBox(width: 4),
                              Text("Kuantum Ağına Bağlı", style: TextStyle(color: _neonGreen, fontSize: 11, fontFamily: 'Avenir')),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── CANLI SİBER HAVUZ (SADELEŞTİRİLMİŞ) ───
  Widget _buildSadeHavuzPanosu() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _db.collection('ticaret_havuzu').doc(widget.chatId).snapshots(),
      builder: (context, snapshot) {
        int havuzDurumu = 1; 
        if (snapshot.hasData && snapshot.data!.exists) {
          havuzDurumu = (snapshot.data!.data() as Map<String, dynamic>)['havuz_durumu'] ?? 1;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
            boxShadow: [BoxShadow(color: _neonGreen.withOpacity(0.05), blurRadius: 20)],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: _neonGreen.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.shield_outlined, color: _neonGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.urunAdi, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(
                      havuzDurumu == 1 ? "Ödeme Kasa'da güvende. Kargolama bekleniyor." : "Teslim alındı. 15 Günlük İade Sürecinde.",
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(widget.urunFiyati, style: const TextStyle(color: _neonGreen, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        );
      },
    );
  }

  // ─── MESAJ LİSTESİ (GLASSMORPHISM BALONCUKLAR) ───
  Widget _buildMesajListesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db
          .collection('ticaret_havuzu')
          .doc(widget.chatId)
          .collection('mesajlar')
          .orderBy('zaman_damgasi', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: _neonGreen));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Siber Sohbet Başladı", style: TextStyle(color: Colors.white38)));

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
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: SiberTema.siberGold.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.siberGold.withOpacity(0.3))),
                  child: Text(msj["metin"] ?? "", style: const TextStyle(color: SiberTema.siberGold, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
                  color: isMe ? _neonGreen.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                    bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                  ),
                  border: isMe ? Border.all(color: _neonGreen.withOpacity(0.3)) : Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(msj["metin"] ?? "", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.4)),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(saat, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9)),
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

  // ─── AKSİYON BUTONLARI ───
  Widget _buildAksiyonButonlari() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12)
              ),
              icon: const Icon(Icons.camera_alt, size: 16),
              label: const Text("Foto Yükle", style: TextStyle(fontSize: 12)),
              onPressed: () => _sistemMesajiGonder("📸 Satıcı ürünü paketlerken fotoğraf yükledi."),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _neonGreen,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12)
              ),
              icon: const Icon(Icons.check_circle, size: 16),
              label: const Text("Teslim Aldım", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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

  // ─── SADE VE ŞIK KLAVYE ALANI ───
  Widget _buildMesajGondermeAlani() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
              child: TextField(
                controller: _mesajController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: "Siber Ağa Mesaj Gönder...",
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _mesajGonder,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _neonGreen.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: _neonGreen.withOpacity(0.5))
              ),
              child: const Icon(Icons.send, color: _neonGreen, size: 20),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _mesajGonder() async {
    String metin = _mesajController.text.trim();
    if (metin.isEmpty) return;

    // AI SANSÜR MOTORU
    bool ihlalVar = metin.contains(RegExp(r'[0-9]{10}')) || metin.toLowerCase().contains("iban") || (metin.toLowerCase().contains("tr") && metin.contains(RegExp(r'[0-9]{5}')));
    if (ihlalVar) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🚨 SİBER İHLAL: İletişim bilgisi veya IBAN paylaşılamaz!", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: SiberTema.kanKirmizi));
      _mesajController.clear();
      _sistemMesajiGonder("⚠️ SİSTEM UYARISI: Güvenlik kalkanı ihlal girişimi engelledi.");
      return;
    }

    _mesajController.clear();
    try {
      await _db.collection('ticaret_havuzu').doc(widget.chatId).collection('mesajlar').add({
        "gonderen_id": widget.aktifKullaniciId, "tip": "kullanici", "metin": metin, "zaman_damgasi": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Hata: $e");
    }
  }

  Future<void> _sistemMesajiGonder(String metin) async {
    try {
      await _db.collection('ticaret_havuzu').doc(widget.chatId).collection('mesajlar').add({
        "gonderen_id": "SISTEM", "tip": "sistem", "metin": metin, "zaman_damgasi": FieldValue.serverTimestamp(),
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