import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrKimlikScreen extends StatefulWidget {
  const QrKimlikScreen({super.key});

  @override
  State<QrKimlikScreen> createState() => _QrKimlikScreenState();
}

class _QrKimlikScreenState extends State<QrKimlikScreen> with SingleTickerProviderStateMixin {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = const Color(0xFF000000);
  final Color surfaceColor = const Color(0xFF111111);
  final Color primaryCyan = const Color(0xFF00FFC2);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Güvenlik Kalkanı Yanıp Sönme Efekti (Kuantum Nabzı)
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
          backgroundColor: bgColor,
          body: const Center(child: Text("SİBER KİMLİK HATASI! AĞA ERİŞİM YOK.", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 1)))
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Q R   K A L K A N I', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Firebase'den kullanıcının aracını çekiyoruz
          stream: _db.collection('araclar').where('sahibiUid', isEqualTo: _currentUser!.uid).limit(1).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryCyan));
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("QR Kimlik oluşturmak için önce garajınıza araç mühürlemelisiniz.", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)));

            var aracData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
            String plaka = aracData['plaka'] ?? 'PLAKA YOK';

            // Kuantum Güvenlik Şifresi (Usta okuttuğunda arka planda bu veriyi çözecek)
            String qrVerisi = "OTODNA_SECURE_${plaka}_${DateTime.now().millisecondsSinceEpoch}";

            return Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: primaryCyan.withOpacity(0.05), shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.3))),
                      child: Icon(Icons.lock_person_outlined, color: primaryCyan, size: 40),
                    ),
                    const SizedBox(height: 24),
                    const Text("SİBER ANAHTAR AKTİF", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 12),
                    const Text("Servis danışmanına veya ustaya bu Kuantum QR'ı okutarak aracınızın genetik dosyasına güvenli erişim yetkisi verebilirsiniz.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5)),
                    const SizedBox(height: 48),

                    // 💎 NABIZ GİBİ ATAN QR KOD HOLOGRAMI
                    AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                                color: Colors.white, // QR okuyucular için zemin beyaz kalmalı
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(color: primaryCyan.withOpacity(0.2 * _pulseController.value), blurRadius: 50, spreadRadius: 15 * _pulseController.value)
                                ]
                            ),
                            child: QrImageView(
                              data: qrVerisi,
                              version: QrVersions.auto,
                              size: 200.0,
                              backgroundColor: Colors.white,
                              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                            ),
                          );
                        }
                    ),

                    const SizedBox(height: 48),

                    // 💎 PLAKA VE ZAMANLAYICI KARTI
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
                      child: Column(
                        children: [
                          const Text("HEDEF PLAKA", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          const SizedBox(height: 8),
                          Text(plaka.toUpperCase(), style: TextStyle(color: primaryCyan, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 3)),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.white12)),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.timer_outlined, color: Colors.orangeAccent, size: 18),
                              SizedBox(width: 8),
                              Expanded(child: Text("Güvenlik ihlalini önlemek için bu kod 3 dakika içinde kendini imha edecektir.", style: TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold, height: 1.4))),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }
      ),
    );
  }
}