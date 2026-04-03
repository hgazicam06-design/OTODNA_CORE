// lib/auth/otodna_auth_gate.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 SENİN GERÇEK KUANTUM EKRANLARININ İMPORTLARI
import '../admin/master_gate.dart';
import '../bayi/firma_paneli_screen.dart';
import '../kullanici/siber_komuta_merkezi_screen.dart';

/// 🛡️ KUANTUM KİMLİK DOĞRULAMA KAPISI (OtoDnaAuthGate)
/// Tablet, Double-Din Araç Ekranı ve Mobil uyumlu otonom yönlendirme motoru.
class OtoDnaAuthGate extends StatelessWidget {
  const OtoDnaAuthGate({super.key});

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _kuantumCyan = Color(0xFF00FFC2);
  static const Color _kanKirmizi = Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    // 1. FİREBASE SİBER KİMLİK MOTORUNU DİNLE
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {

        // DURUM 1: AĞ BAĞLANTISI BEKLENİYOR
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: _oledBlack,
            body: Center(child: CircularProgressIndicator(color: _kuantumCyan)),
          );
        }

        // DURUM 2: KULLANICI GİRİŞ YAPMAMIŞ (LOGIN EKRANINA AT)
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          // TODO: Giriş Ekranın (SiberGirisScreen) hazır olduğunda buraya yönlendir
          return Scaffold(
            backgroundColor: _oledBlack,
            body: Center(
              // Tablet/Double-Din Uyum Kalkanı
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kuantumCyan.withOpacity(0.3)),
                  ),
                  child: const Text(
                    "SİBER RADAR: Kimlik Doğrulaması Bekleniyor...\n(Lütfen Ağ'a Giriş Yapın)",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _kuantumCyan, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
            ),
          );
        }

        // DURUM 3: GİRİŞ YAPILMIŞ -> VERİTABANINDAN SİCİL VE ROL KONTROLÜ
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('kullanicilar').doc(authSnapshot.data!.uid).get(),
          builder: (context, userSnapshot) {

            // Veri çekilirken Kuantum bekleme animasyonu
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: _oledBlack,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: _kuantumCyan),
                      SizedBox(height: 16),
                      Text("Kuantum Sicil Kontrolü Yapılıyor...", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                ),
              );
            }

            // Hata veya veritabanında kaydı olmayan kullanıcı kontrolü
            if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
              return Scaffold(
                backgroundColor: _oledBlack,
                body: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: _kanKirmizi.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _kanKirmizi),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, color: _kanKirmizi, size: 60),
                          const SizedBox(height: 16),
                          const Text("KRİTİK İHLAL: Siber Kimlik Veritabanında Bulunamadı!", textAlign: TextAlign.center, style: TextStyle(color: _kanKirmizi, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: _kanKirmizi, foregroundColor: Colors.white),
                              onPressed: () => FirebaseAuth.instance.signOut(),
                              child: const Text("AĞDAN ÇIK VE TEKRAR DENE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            // 4. VERİLERİ PARÇALA VE ANALİZ ET
            var userData = userSnapshot.data!.data() as Map<String, dynamic>;
            String role = userData['rol'] ?? "USER";
            bool isBlacklisted = userData['isBlacklisted'] ?? false;

            // ⛔ 5. KARALİSTE (BLACKLIST) SAVUNMA HATTI (EN KRİTİK GÜVENLİK)
            if (isBlacklisted) {
              return Scaffold(
                backgroundColor: _oledBlack,
                body: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: _kanKirmizi.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _kanKirmizi, width: 2),
                        boxShadow: [BoxShadow(color: _kanKirmizi.withOpacity(0.2), blurRadius: 30)],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.gavel, color: _kanKirmizi, size: 80),
                          const SizedBox(height: 16),
                          const Text("SİSTEME ERİŞİM ENGELLENDİ", style: TextStyle(color: _kanKirmizi, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          const SizedBox(height: 12),
                          const Text("Hesabınız Blacklist'e (Karaliste) alınmıştır. Tüm yetkileriniz Karargah tarafından donduruldu.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, height: 1.5)),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: _kanKirmizi, foregroundColor: Colors.white),
                              onPressed: () => FirebaseAuth.instance.signOut(), // Zorla Çıkış Yaptır
                              child: const Text("AĞDAN ZORUNLU ÇIKIŞ YAP", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            // 🚀 6. GÜVENLİK GEÇİLDİ -> GERÇEK PANELLERE OTONOM YÖNLENDİRME
            if (role == "ADMIN") {
              return const MasterGateScreen(); // Şifreli Admin Karargahı
            } else if (role == "BAYI") {
              return const FirmaPaneliScreen(); // Bayi İşletim Paneli
            } else {
              return const SiberKomutaMerkeziScreen(); // Standart Kullanıcı
            }
          },
        );
      },
    );
  }
}