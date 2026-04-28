import 'package:otodna/core/siber_tema.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/siber_tema.dart';

class UstaKonseyiScreen extends StatefulWidget {
  UstaKonseyiScreen({super.key});

  @override
  State<UstaKonseyiScreen> createState() => _UstaKonseyiScreenState();
}

class _UstaKonseyiScreenState extends State<UstaKonseyiScreen> {
  static Color primaryCyan = SiberTema.kuantumCyan;
  static Color siberGold = SiberTema.siberGold;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _mesajController = TextEditingController();

  void _istihbaratGonder() async {
    if (_mesajController.text.trim().isEmpty) return;
    
    // 🔥 KARARGAH: Usta Konseyi Mesajını Ağa Mühürle
    try {
      await _db.collection('usta_konseyi_istihbarat').add({
        'mesaj': _mesajController.text.trim(),
        'gonderen_ad': 'Gazi Oto (Yetkili Bayi)', // Geçici MOCK
        'puan': 5,
        'tarih': FieldValue.serverTimestamp(),
        'begeni_sayisi': 0,
      });
      _mesajController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      debugPrint("SİBER HATA: İstihbarat iletilemedi!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. KUANTUM ARKA PLAN
          Positioned.fill(child: Container(decoration: SiberTema.siberArkaPlan)),

          // 2. ANA İÇERİK
          SafeArea(
            child: Column(
              children: [
                _buildSiberAppBar(),
                _buildUyariKalkani(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _db.collection('usta_konseyi_istihbarat').orderBy('tarih', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: primaryCyan));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildMockVeriler(); // Test için mock veri gösterimi
                      }

                      return ListView.builder(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        reverse: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var veri = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                          return _buildKonseyMesaji(
                            gonderen: veri['gonderen_ad'] ?? 'Gizli Ajan',
                            mesaj: veri['mesaj'] ?? '',
                            puan: (veri['puan'] ?? 5).toInt(),
                            begeni: (veri['begeni_sayisi'] ?? 0).toInt(),
                          );
                        },
                      );
                    },
                  ),
                ),
                _buildIstihbaratGirisTerminali(),
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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), border: Border(bottom: BorderSide(color: Colors.white10))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18)),
              ),
              Text('U S T A   K O N S E Y İ', style: TextStyle(color: siberGold, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3, fontFamily: 'Avenir')),
              Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: siberGold.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: siberGold.withOpacity(0.5))), child: Icon(Icons.shield_outlined, color: siberGold, size: 18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUyariKalkani() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: SiberTema.kanKirmizi.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: SiberTema.kanKirmizi, width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: SiberTema.kanKirmizi, size: 20),
          SizedBox(width: 12),
          Expanded(child: Text("SİBER PROTOKOL: Bu kanal sadece yetkili OtoDNA ustaları içindir. Müşteriler okuyamaz.", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, height: 1.4, fontFamily: 'Avenir'))),
        ],
      ),
    );
  }

  Widget _buildIstihbaratGirisTerminali() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), border: Border(top: BorderSide(color: Colors.white10))),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
                  child: TextField(
                    controller: _mesajController,
                    style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Avenir'),
                    decoration: InputDecoration(
                      hintText: "Konseye istihbarat ilet...",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13, fontFamily: 'Avenir'),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              GestureDetector(
                onTap: _istihbaratGonder,
                child: Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.5))),
                  child: Icon(Icons.send_rounded, color: primaryCyan, size: 20),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKonseyMesaji({required String gonderen, required String mesaj, required int puan, required int begeni}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: siberGold.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: siberGold.withOpacity(0.3))),
                child: Icon(Icons.engineering, color: siberGold, size: 16),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gonderen.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                    SizedBox(height: 4),
                    Row(
                      children: List.generate(5, (index) => Icon(index < puan ? Icons.star : Icons.star_border, color: siberGold, size: 10)),
                    )
                  ],
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.white24, size: 16)
            ],
          ),
          SizedBox(height: 16),
          Text(mesaj, style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5, fontFamily: 'Avenir')),
          Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.thumb_up_alt_outlined, color: primaryCyan, size: 16),
                  SizedBox(width: 8),
                  Text("$begeni Usta Onayladı", style: TextStyle(color: primaryCyan, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                ],
              ),
              Text("YANITLA", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMockVeriler() {
    return ListView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        _buildKonseyMesaji(
          gonderen: "Kuantum Motor Servisi",
          mesaj: "Arkadaşlar, 2018 model 1.6 TDi'larda EGR valfi kronik sorun yaratıyor. 10.000 bakımında muhakkak kontrol edin, Karargah skorunu düşürmesin.",
          puan: 5,
          begeni: 42,
        ),
        _buildKonseyMesaji(
          gonderen: "Gazi Otomotiv",
          mesaj: "Bosch marka fren balatalarının son partisinde ses yapma problemi var. TRW'ye geçiş yapmanızı öneririm.",
          puan: 5,
          begeni: 18,
        ),
      ],
    );
  }
}