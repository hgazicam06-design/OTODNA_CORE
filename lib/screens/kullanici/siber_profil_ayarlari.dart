import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:otodna/core/siber_tema.dart';
import 'package:otodna/core/responsive_kalkan.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 👤 SİBER PROFİL AYARLARI
/// Kullanıcının kişisel bilgilerini, güvenlik ayarlarını ve 2FA (İki Aşamalı Doğrulama) tercihlerini yönettiği ekran.
class SiberProfilAyarlariScreen extends StatefulWidget {
  const SiberProfilAyarlariScreen({super.key});

  @override
  State<SiberProfilAyarlariScreen> createState() => _SiberProfilAyarlariScreenState();
}

class _SiberProfilAyarlariScreenState extends State<SiberProfilAyarlariScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _is2faEnabled = false;

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.pop();
            },
          ),
          title: Text(
            "KİŞİSEL PROFİL",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              fontFamily: 'Avenir',
              letterSpacing: 2.0,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // PROFİL HOLOGRAFİSİ
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: SiberTema.kuantumCyan, width: 2),
                      boxShadow: [
                        BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
                      ],
                      image: currentUser?.photoURL != null
                          ? DecorationImage(image: NetworkImage(currentUser!.photoURL!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: currentUser?.photoURL == null
                        ? Icon(Icons.person, size: 50, color: SiberTema.kuantumCyan)
                        : null,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: SiberTema.oledBlack,
                      shape: BoxShape.circle,
                      border: Border.all(color: SiberTema.kuantumCyan),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, size: 16, color: SiberTema.kuantumCyan),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        // Fotoğraf yükleme işlemi
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Text(
                currentUser?.displayName ?? "GİZLİ KULLANICI",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 4),
              Text(
                currentUser?.email ?? "Bilinmeyen E-posta",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 30),

              // GÜVENLİK BÖLÜMÜ
              _buildSiberKategoriBasligi("GÜVENLİK DUVARI"),
              _buildAyarKarti(
                icon: Icons.password,
                baslik: "Şifremi Değiştir",
                altBaslik: "Güvenlik protokolünü yenile.",
                onTap: () {
                  // Şifre sıfırlama ekranı / dialogu
                },
              ),
              _buildAyarKarti(
                icon: Icons.security,
                baslik: "Siber 2FA Koruması",
                altBaslik: "Çift faktörlü kimlik doğrulama.",
                trailing: Switch(
                  value: _is2faEnabled,
                  onChanged: (val) {
                    HapticFeedback.lightImpact();
                    setState(() => _is2faEnabled = val);
                  },
                  activeColor: SiberTema.oledBlack,
                  activeTrackColor: SiberTema.kuantumCyan,
                ),
              ),

              const SizedBox(height: 30),
              
              // İLETİŞİM BİLGİLERİ
              _buildSiberKategoriBasligi("İLETİŞİM BİLGİLERİ"),
              _buildAyarKarti(
                icon: Icons.phone_android,
                baslik: "Telefon Numarası",
                altBaslik: currentUser?.phoneNumber ?? "Kayıtlı Numara Yok",
                onTap: () {
                  // Telefon numarası doğrulama akışı
                },
              ),

              const SizedBox(height: 40),
              
              // HESAP SİLME (KVKK)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SiberTema.kanKirmizi.withOpacity(0.1),
                  foregroundColor: SiberTema.kanKirmizi,
                  side: BorderSide(color: SiberTema.kanKirmizi),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.delete_forever),
                label: const Text("HESABIMI VE VERİLERİMİ SİL", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  _hesapSilmeUyarisiGoster(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiberKategoriBasligi(String baslik) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        baslik,
        style: TextStyle(
          color: SiberTema.kuantumCyan,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildAyarKarti({
    required IconData icon,
    required String baslik,
    required String altBaslik,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: SiberTema.siberKutuZirhi,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: Colors.white70, size: 28),
        title: Text(baslik, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(altBaslik, style: TextStyle(color: Colors.white54, fontSize: 11)),
        ),
        trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.white24, size: 20),
        onTap: onTap != null ? () {
          HapticFeedback.lightImpact();
          onTap();
        } : null,
      ),
    );
  }

  void _hesapSilmeUyarisiGoster(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SiberTema.oledBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: SiberTema.kanKirmizi, width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: SiberTema.kanKirmizi),
            const SizedBox(width: 10),
            Text("KRİTİK İŞLEM", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          "Hesabınızı sildiğinizde, Kuantum ağına bağlı tüm verileriniz (garaj, faturalar, profil) kalıcı olarak yok edilir. Bu işlem geri alınamaz.\n\nOnaylıyor musunuz?",
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("İPTAL", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kanKirmizi),
            onPressed: () {
              // Firebase hesabını silme işlemi
              Navigator.pop(context);
              FirebaseAuth.instance.currentUser?.delete();
              context.go('/');
            },
            child: Text("KALICI OLARAK SİL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
