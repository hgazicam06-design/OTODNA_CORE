import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UstaPanelScreen extends StatefulWidget {
  const UstaPanelScreen({super.key});

  @override
  State<UstaPanelScreen> createState() => _UstaPanelScreenState();
}

class _UstaPanelScreenState extends State<UstaPanelScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color warningColor = Colors.orangeAccent;
  static const Color dangerColor = Colors.redAccent;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _uyariGoster(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1)),
        backgroundColor: isError ? dangerColor : primaryCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🧠 SİBER KİMLİK KONTROLÜ
    User? currentUser = _auth.currentUser;
    String ustaId = currentUser?.uid ?? "TEST_USTA_001"; // Auth yoksa test verisi çeker

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("USTA KOMUTA MERKEZİ", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new, color: dangerColor),
            onPressed: () => _uyariGoster("GÜVENLİ ÇIKIŞ PROTOKOLÜ BAŞLATILIYOR..."),
          )
        ],
      ),
      body: SafeArea(
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
                      _uyariGoster("SİBER OPTİK TARAYICI BAŞLATILIYOR...");
                      // Navigator.pushNamed(context, '/qr_scanner');
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: warningColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: warningColor.withOpacity(0.5), width: 2),
                        boxShadow: [BoxShadow(color: warningColor.withOpacity(0.1), blurRadius: 20)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: warningColor.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.qr_code_scanner, color: warningColor, size: 32),
                          ),
                          const SizedBox(width: 20),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("HIZLI STOK VE ARAÇ TARAMA", style: TextStyle(color: warningColor, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                                SizedBox(height: 6),
                                Text("Yedek parça barkodunu veya aracın OtoDNA mühürlü QR kodunu okutun.", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, height: 1.5)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: warningColor, size: 16),
                        ],
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
                      Icon(Icons.access_time_filled, color: primaryCyan.withOpacity(0.5), size: 20),
                      const SizedBox(width: 12),
                      const Text("AKTİF SİBER RANDEVULAR (₺200 TEMİNATLI)", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
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
                        return const Center(child: CircularProgressIndicator(color: primaryCyan));
                      }

                      // 🚨 EĞER VERİ YOKSA (VEYA YENİ HESAPSA) GÖSTERİLECEK SİBER MOCK VERİ
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          children: [
                            _buildRandevuKarti("AHMET YILMAZ", "FREN BALATASI VE DİSK DEĞİŞİMİ", "14:30", "34 DNA 2026"),
                            _buildRandevuKarti("MEHMET ÖZTÜRK", "PERİYODİK YAĞ BAKIMI", "16:00", "06 OTO 001"),
                          ],
                        );
                      }

                      // 🚀 GERÇEK FİREBASE VERİ DÖNGÜSÜ
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                          // Tarihi / Saati string'e çevirme mantığı
                          String saatStr = "BİLİNMİYOR";
                          if (data['tarih'] != null) {
                            DateTime dt = (data['tarih'] as Timestamp).toDate();
                            saatStr = "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";
                          }

                          return _buildRandevuKarti(
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
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER RANDEVU KARTI
  Widget _buildRandevuKarti(String isim, String islem, String saat, String plaka) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
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
                decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.person, color: primaryCyan, size: 24),
              ),
              const SizedBox(height: 12),
              Text(saat, style: const TextStyle(color: primaryCyan, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
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
                    Expanded(child: Text(isim.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white12)),
                      child: Text(plaka, style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(islem.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold, height: 1.5, letterSpacing: 1)),
                const SizedBox(height: 16),

                // MÜDAHALE BUTONLARI
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: dangerColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _uyariGoster("İPTAL PROTOKOLÜ BAŞLATILDI!"),
                        child: const Text("İPTAL ET", style: TextStyle(color: dangerColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: primaryCyan,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _uyariGoster("İŞLEM BAŞLATILDI!"),
                        child: const Text("İŞLEME AL", style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
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