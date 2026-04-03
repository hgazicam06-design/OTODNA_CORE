import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SiberKasaScreen extends StatefulWidget {
  const SiberKasaScreen({super.key});

  @override
  State<SiberKasaScreen> createState() => _SiberKasaScreenState();
}

class _SiberKasaScreenState extends State<SiberKasaScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  bool _isRequesting = false;

  void _siberUyari(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF00FFC2),
    ));
  }

  // IBAN'A PARA ÇEKME TALEBİ MOTORU
  void _paraCekmeTalebiOlustur(double cekilebilirBakiye) {
    if (cekilebilirBakiye <= 0) {
      _siberUyari("Çekilebilir bakiyeniz bulunmuyor!", isError: true);
      return;
    }

    final ibanCtrl = TextEditingController();

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: Color(0xFF1E293B), borderRadius: BorderRadius.vertical(top: Radius.circular(24)), border: Border(top: BorderSide(color: Color(0xFF00FFC2), width: 2))),
          child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [Icon(Icons.account_balance, color: Color(0xFF00FFC2), size: 32), SizedBox(width: 12), Text("IBAN'a Aktar", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 16),
              Text("Çekilebilir Tutar: ₺${cekilebilirBakiye.toStringAsFixed(2)}\nBu tutar Kuantum Merkez (%12 vb.) kesintileri düşülmüş NET HAKEDİŞİNİZDİR.", style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
              const SizedBox(height: 24),
              TextField(
                controller: ibanCtrl, style: const TextStyle(color: Colors.white, letterSpacing: 2),
                decoration: InputDecoration(hintText: 'TR', labelText: 'IBAN Numarası', labelStyle: const TextStyle(color: Color(0xFF00FFC2)), filled: true, fillColor: const Color(0xFF0F172A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFC2), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () async {
                    if (ibanCtrl.text.length < 24) {
                      _siberUyari("Lütfen geçerli bir IBAN girin!", isError: true);
                      return;
                    }
                    Navigator.pop(context);
                    setState(() => _isRequesting = true);

                    try {
                      // 1. Talebi İlet
                      await _db.collection('para_cekme_talepleri').add({
                        'bayi_id': _currentUser!.uid,
                        'iban': ibanCtrl.text.trim(),
                        'tutar': cekilebilirBakiye,
                        'durum': 'İnceleniyor', // Admin Paneline düşecek
                        'tarih': FieldValue.serverTimestamp(),
                      });

                      // 2. Bakiyeyi Sıfırla (Kullanıcı Tablosundan)
                      await _db.collection('kullanicilar').doc(_currentUser!.uid).update({
                        'bakiye': 0.0
                      });

                      _siberUyari("Para Çekme Talebiniz Finans Merkezine İletildi! 💸");
                    } catch (e) {
                      _siberUyari("Ağ Hatası: $e", isError: true);
                    } finally {
                      setState(() => _isRequesting = false);
                    }
                  },
                  child: const Text("Talebi Gönder", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F172A);
    const primaryCyan = Color(0xFF00FFC2);
    const cardColor = Color(0xFF1E293B);

    if (_currentUser == null) return const Scaffold(backgroundColor: bgColor, body: Center(child: Text("Kimlik Hatası!")));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor, elevation: 0,
        title: const Text('Siber Kasa & Finans', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true, iconTheme: const IconThemeData(color: primaryCyan),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: _db.collection('kullanicilar').doc(_currentUser!.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: primaryCyan));

            double mevcutBakiye = 0.0;
            if (snapshot.hasData && snapshot.data!.exists) {
              mevcutBakiye = (snapshot.data!.data() as Map<String, dynamic>)['bakiye']?.toDouble() ?? 0.0;
            }

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 💳 DİJİTAL CÜZDAN KARTI
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [primaryCyan, Color(0xFF008080)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [Icon(Icons.account_balance_wallet, color: Colors.black54), SizedBox(width: 8), Text("Çekilebilir Net Bakiye", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 14))]),
                        const SizedBox(height: 16),
                        Text("₺${mevcutBakiye.toStringAsFixed(2)}", style: const TextStyle(color: Colors.black, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: bgColor, foregroundColor: primaryCyan, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                onPressed: _isRequesting ? null : () => _paraCekmeTalebiOlustur(mevcutBakiye),
                                icon: _isRequesting ? const SizedBox() : const Icon(Icons.outbound, size: 18),
                                label: _isRequesting ? const CircularProgressIndicator(color: primaryCyan) : const Text("IBAN'A AKTAR", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text("Son Finansal Hareketler", style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // GEÇMİŞ PARA ÇEKME TALEPLERİ LİSTESİ
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: _db.collection('para_cekme_talepleri').where('bayi_id', isEqualTo: _currentUser!.uid).orderBy('tarih', descending: true).snapshots(),
                        builder: (context, requestSnapshot) {
                          if (requestSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: primaryCyan));
                          if (!requestSnapshot.hasData || requestSnapshot.data!.docs.isEmpty) return const Center(child: Text("Henüz bir işlem hareketiniz yok.", style: TextStyle(color: Colors.white24)));

                          var talepler = requestSnapshot.data!.docs;

                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: talepler.length,
                            itemBuilder: (context, index) {
                              var talep = talepler[index].data() as Map<String, dynamic>;
                              bool isCompleted = talep['durum'] == 'Ödendi';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1), shape: BoxShape.circle), child: Icon(isCompleted ? Icons.check : Icons.hourglass_top, color: isCompleted ? Colors.green : Colors.orange, size: 20)),
                                        const SizedBox(width: 16),
                                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(isCompleted ? "Gönderildi" : "İnceleniyor", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(height: 4), Text("IBAN: ${talep['iban']?.toString().substring(0, 8)}...", style: const TextStyle(color: Colors.white54, fontSize: 11))]),
                                      ],
                                    ),
                                    Text("-₺${talep['tutar']}", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }
}