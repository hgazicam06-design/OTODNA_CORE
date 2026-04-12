import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class UstaPanelScreen extends StatefulWidget {
  const UstaPanelScreen({super.key});

  @override
  State<UstaPanelScreen> createState() => _UstaPanelScreenState();
}

class _UstaPanelScreenState extends State<UstaPanelScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _siberUyariGoster(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(fontWeight: FontWeight.w900, color: isError ? Colors.white : SiberTema.oledBlack, letterSpacing: 1, fontFamily: 'Avenir')),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 🔥 FİREBASE: İşlemi iptal et
  Future<void> _randevuIptalEt(String randevuId) async {
    try {
      await _db.collection('randevular').doc(randevuId).update({
        'durum': 'İPTAL EDİLDİ',
        'iptal_eden': 'USTA',
        'iptal_tarihi': FieldValue.serverTimestamp(),
      });
      _siberUyariGoster("İPTAL PROTOKOLÜ BAŞARIYLA UYGULANDI!", isError: true);
    } catch (e) {
      _siberUyariGoster("SİBER AĞ HATASI: İptal işlemi başarısız!", isError: true);
    }
  }

  // 🔥 FİREBASE: İşleme Al (Siber Kokpite Yönlendirir)
  void _islemeAl(String randevuId, String aracId, String plaka) {
    _siberUyariGoster("İŞLEM BAŞLATILIYOR: $plaka", isError: false);
    // 🚀 NOT: Burada ustanın araca müdahale edeceği Ekspertiz Kokpitine yönlendireceğiz.
    // Navigator.push(context, MaterialPageRoute(builder: (context) => EkspertizKokpitiScreen(aracId: aracId, bayiId: _auth.currentUser!.uid)));
  }

  @override
  Widget build(BuildContext context) {
    // 🧠 SİBER KİMLİK KONTROLÜ
    User? currentUser = _auth.currentUser;
    String ustaId = currentUser?.uid ?? "BILINMEYEN_USTA";

    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text("USTA KOMUTA MERKEZİ", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          actions: [
            IconButton(
              icon: const Icon(Icons.power_settings_new, color: SiberTema.kanKirmizi),
              onPressed: () => _siberUyariGoster("GÜVENLİ ÇIKIŞ PROTOKOLÜ BAŞLATILIYOR...", isError: true),
            )
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800), // 🖥️ Web / Tablet Kalkanı
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // =================================================================
                    // 1. OPTİK BARKOD TARAYICI (STOK & İŞLEM BAŞLATMA)
                    // =================================================================
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: InkWell(
                        onTap: () {
                          _siberUyariGoster("SİBER OPTİK TARAYICI BAŞLATILIYOR...");
                          // Navigator.pushNamed(context, '/qr_scanner');
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: SiberTema.altinSari.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: SiberTema.altinSari.withOpacity(0.5), width: 2),
                                boxShadow: [BoxShadow(color: SiberTema.altinSari.withOpacity(0.1), blurRadius: 20)],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(color: SiberTema.altinSari.withOpacity(0.1), shape: BoxShape.circle),
                                    child: const Icon(Icons.qr_code_scanner, color: SiberTema.altinSari, size: 32),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("HIZLI STOK VE ARAÇ TARAMA", style: TextStyle(color: SiberTema.altinSari, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                                        const SizedBox(height: 6),
                                        Text("Yedek parça barkodunu veya aracın OtoDNA mühürlü QR kodunu okutun.", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold, height: 1.5, fontFamily: 'Avenir')),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, color: SiberTema.altinSari, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // =================================================================
                    // 2. CANLI RANDEVU RADARI BAŞLIĞI
                    // =================================================================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.access_time_filled, color: SiberTema.kuantumCyan.withOpacity(0.5), size: 20),
                          const SizedBox(width: 12),
                          const Text("AKTİF SİBER RANDEVULAR (₺200 TEMİNATLI)", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Divider(color: Colors.white12, thickness: 1),
                    ),

                    // =================================================================
                    // 3. FİREBASE'DEN ÇEKİLEN CANLI RANDEVU AKIŞI
                    // =================================================================
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _db.collection('randevular')
                            .where('usta_id', isEqualTo: ustaId)
                            .where('durum', isEqualTo: 'ONAYLANDI')
                            .orderBy('tarih', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
                          }

                          // 🚨 VERİ YOKSA SADECE TEMİZ EKRAN (Sahte Veri Yasak!)
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.event_available, color: SiberTema.kuantumCyan.withOpacity(0.2), size: 64),
                                  const SizedBox(height: 16),
                                  Text("RADAR TEMİZ", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir')),
                                ],
                              ),
                            );
                          }

                          // 🚀 GERÇEK FİREBASE VERİ DÖNGÜSÜ
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              var doc = snapshot.data!.docs[index];
                              var data = doc.data() as Map<String, dynamic>;

                              // Tarihi / Saati string'e çevirme mantığı
                              String saatStr = "BİLİNMİYOR";
                              if (data['tarih'] != null) {
                                DateTime dt = (data['tarih'] as Timestamp).toDate();
                                saatStr = "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";
                              }

                              return _buildRandevuKarti(
                                doc.id,
                                data['arac_id'] ?? 'BILINMEYEN_ARAC',
                                data['musteri_isim'] ?? 'İSİMSİZ HEDEF',
                                data['islem'] ?? 'BELİRTİLMEMİŞ İŞLEM',
                                saatStr,
                                data['plaka'] ?? 'PLAKA YOK',
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER RANDEVU KARTI
  Widget _buildRandevuKarti(String randevuId, String aracId, String isim, String islem, String saat, String plaka) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SOL: KİMLİK MÜHRÜ VE SAAT
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.person, color: SiberTema.kuantumCyan, size: 24),
              ),
              const SizedBox(height: 12),
              Text(saat, style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(width: 20),

          // SAĞ: İŞLEM BİLGİLERİ VE PLAKA
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(isim.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir'))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white12)),
                      child: Text(plaka, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(islem.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold, height: 1.5, letterSpacing: 1, fontFamily: 'Avenir')),
                const SizedBox(height: 16),

                // MÜDAHALE BUTONLARI (FİREBASE CANLI BAĞLANTILI)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: SiberTema.kanKirmizi),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _randevuIptalEt(randevuId),
                        child: const Text("İPTAL ET", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: SiberTema.kuantumCyan,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _islemeAl(randevuId, aracId, plaka),
                        child: const Text("İŞLEME AL", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}