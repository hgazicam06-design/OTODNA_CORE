import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrKimlikScreen extends StatefulWidget {
  QrKimlikScreen({super.key});

  @override
  State<QrKimlikScreen> createState() => _QrKimlikScreenState();
}

class _QrKimlikScreenState extends State<QrKimlikScreen> with SingleTickerProviderStateMixin {
  // 🏢 FİLDİŞİ SEDEF PALET (Siyah İptal)
  final Color bgColor = Color(0xFFFDFBF7);
  final Color surfaceColor = Colors.white;
  final Color primaryTeal = Colors.teal.shade700;
  final Color textMuted = Color(0xFF64748B);
  final Color textMain = Color(0xFF1E293B);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Güvenlik Kalkanı Yanıp Sönme Efekti (Kuantum Nabzı)
    _pulseController = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat(reverse: true);
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
          body: Center(child: Text("SİBER KİMLİK HATASI! AĞA ERİŞİM YOK.", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 1)))
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: textMain, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('Q R   K A L K A N I', style: TextStyle(color: textMain, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3, fontFamily: 'Avenir')),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Firebase'den kullanıcının aracını çekiyoruz
          stream: _db.collection('araclar').where('sahibiUid', isEqualTo: _currentUser!.uid).limit(1).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryTeal));
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Text("QR Kimlik oluşturmak için önce garajınıza araç mühürlemelisiniz.", style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.bold)));

            var aracData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
            String plaka = aracData['plaka'] ?? 'PLAKA YOK';

            // Kuantum Güvenlik Şifresi (Usta okuttuğunda arka planda bu veriyi çözecek)
            String qrVerisi = "OTODNA_SECURE_${plaka}_${DateTime.now().millisecondsSinceEpoch}";

            return Center(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(color: primaryTeal.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: primaryTeal.withOpacity(0.3))),
                      child: Icon(Icons.lock_person_outlined, color: primaryTeal, size: 40),
                    ),
                    SizedBox(height: 24),
                    Text("SİBER ANAHTAR AKTİF", style: TextStyle(color: textMain, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    SizedBox(height: 12),
                    Text("Servis danışmanına veya ustaya bu Kuantum QR'ı okutarak aracınızın genetik dosyasına güvenli erişim yetkisi verebilirsiniz.", textAlign: TextAlign.center, style: TextStyle(color: textMuted, fontSize: 11, height: 1.5)),
                    SizedBox(height: 48),

                    // 💎 NABIZ GİBİ ATAN QR KOD HOLOGRAMI
                    AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                                color: Colors.white, // QR okuyucular için zemin beyaz kalmalı
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(color: primaryTeal.withOpacity(0.2 * _pulseController.value), blurRadius: 50, spreadRadius: 15 * _pulseController.value)
                                ]
                            ),
                            child: QrImageView(
                              data: qrVerisi,
                              version: QrVersions.auto,
                              size: 200.0,
                              backgroundColor: Colors.white,
                              eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.white),
                              dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.white),
                            ),
                          );
                        }
                    ),

                    SizedBox(height: 48),

                    // 💎 PLAKA VE ZAMANLAYICI KARTI
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05)), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10)]),
                      child: Column(
                        children: [
                          Text("HEDEF PLAKA", style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          SizedBox(height: 8),
                          Text(plaka.toUpperCase(), style: TextStyle(color: primaryTeal, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 3)),
                          Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.white.withOpacity(0.05))),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.timer_outlined, color: Colors.orangeAccent, size: 18),
                              SizedBox(width: 8),
                              Expanded(child: Text("Güvenlik ihlalini önlemek için bu kod 3 dakika içinde kendini imha edecektir.", style: TextStyle(color: Colors.orange.shade700, fontSize: 10, fontWeight: FontWeight.bold, height: 1.4))),
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