import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:otodna/core/siber_tema.dart';
import 'package:otodna/core/responsive_kalkan.dart';

/// 🛡️ UYGULAMA AYARLARI TERMINALI
/// Kullanıcının sistem tercihlerini ve eklentilerini yönettiği ana kontrol paneli.
class UygulamaAyarlariScreen extends StatefulWidget {
  const UygulamaAyarlariScreen({super.key});

  @override
  State<UygulamaAyarlariScreen> createState() => _UygulamaAyarlariScreenState();
}

class _UygulamaAyarlariScreenState extends State<UygulamaAyarlariScreen> {
  // Varsayılan ayarlar (Firebase veya LocalStorage ile bağlanmalı)
  bool _bildirimlerAcik = true;
  bool _konumErisimi = true;
  String _seciliDil = "TR";

  // Eklentiler
  bool _pluginEkspertiz = true;
  bool _pluginKuantumCuzdan = false;
  bool _pluginYapayZekaAsistan = true;
  bool _pluginSiberFatura = false;

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.textMain, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              if (context.canPop()) {
                context.pop();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            "SİSTEM AYARLARI",
            style: TextStyle(
              color: SiberTema.textMain,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              fontFamily: 'Avenir',
              letterSpacing: 1.5,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSiberKategoriBasligi("GÖRÜNÜM VE ARAYÜZ"),
              _buildAyarKarti(
                icon: Icons.language,
                baslik: "Sistem Dili",
                altBaslik: "Aktif Dil: $_seciliDil",
                trailing: Icon(Icons.chevron_right, color: SiberTema.textMuted),
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Dil Seçim Terminaline Yönlendir
                },
              ),

              const SizedBox(height: 24),
              _buildSiberKategoriBasligi("UYGULAMA EKLENTİLERİ (PLUGINS)"),
              _buildAyarKarti(
                icon: Icons.policy_outlined,
                baslik: "Kuantum Ekspertiz Modülü",
                altBaslik: "Araç değerleme ve hasar analizi.",
                trailing: _buildSiberSwitch(_pluginEkspertiz, (val) => setState(() => _pluginEkspertiz = val)),
              ),
              _buildAyarKarti(
                icon: Icons.account_balance_wallet_outlined,
                baslik: "Siber Cüzdan Entegrasyonu",
                altBaslik: "Kripto ve komisyon ödemeleri.",
                trailing: _buildSiberSwitch(_pluginKuantumCuzdan, (val) => setState(() => _pluginKuantumCuzdan = val)),
              ),
              _buildAyarKarti(
                icon: Icons.smart_toy_outlined,
                baslik: "Yapay Zeka Bakım Asistanı",
                altBaslik: "Otonom servis tahminleri.",
                trailing: _buildSiberSwitch(_pluginYapayZekaAsistan, (val) => setState(() => _pluginYapayZekaAsistan = val)),
              ),
              _buildAyarKarti(
                icon: Icons.receipt_long_outlined,
                baslik: "Siber Fatura & Vergi",
                altBaslik: "Otomatik muhasebe senkronizasyonu.",
                trailing: _buildSiberSwitch(_pluginSiberFatura, (val) => setState(() => _pluginSiberFatura = val)),
              ),

              const SizedBox(height: 24),
              _buildSiberKategoriBasligi("GİZLİLİK VE İZİNLER"),
              _buildAyarKarti(
                icon: Icons.notifications_active_outlined,
                baslik: "Anlık Bildirimler",
                altBaslik: "Durum güncellemeleri ve uyarılar.",
                trailing: _buildSiberSwitch(_bildirimlerAcik, (val) => setState(() => _bildirimlerAcik = val)),
              ),
              _buildAyarKarti(
                icon: Icons.gps_fixed,
                baslik: "Konum Radarı",
                altBaslik: "Acil durumlar ve en yakın servisler için.",
                trailing: _buildSiberSwitch(_konumErisimi, (val) => setState(() => _konumErisimi = val)),
              ),

              const SizedBox(height: 24),
              _buildSiberKategoriBasligi("YASAL BİLGİLER"),
              _buildAyarKarti(
                icon: Icons.gavel_outlined,
                baslik: "Hukuki Metinler",
                altBaslik: "Sözleşmeler, KVKK ve Kullanım Koşulları.",
                trailing: Icon(Icons.chevron_right, color: SiberTema.textMuted),
                onTap: () {
                  HapticFeedback.lightImpact();
                },
              ),
              _buildAyarKarti(
                icon: Icons.info_outline,
                baslik: "OtoDNA Platinum Core",
                altBaslik: "v3.1.0 (Build 9042)",
                trailing: Text("GÜNCEL", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, fontSize: 10)),
              ),

              const SizedBox(height: 50),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.shield_outlined, color: SiberTema.textMuted.withOpacity(0.3), size: 50),
                    const SizedBox(height: 10),
                    Text(
                      "OTODNA PLATINUM SYSTEMS\nTüm hakları gizli protokollerle korunmaktadır.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: SiberTema.textMuted.withOpacity(0.6),
                        fontSize: 10,
                        letterSpacing: 1.5,
                        height: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── YARDIMCI WIDGETLAR ──
  Widget _buildSiberKategoriBasligi(String baslik) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        baslik,
        style: TextStyle(
          color: SiberTema.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
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
      decoration: SiberTema.siberKutuZirhi, // Beyaz gölgeli kart (Plaza stili)
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: SiberTema.kuantumCyan.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: SiberTema.kuantumCyan, size: 22),
        ),
        title: Text(
          baslik,
          style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            altBaslik,
            style: TextStyle(color: SiberTema.textMuted, fontSize: 11),
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _buildSiberSwitch(bool deger, ValueChanged<bool> onChanged) {
    return Switch(
      value: deger,
      onChanged: (val) {
        HapticFeedback.lightImpact();
        onChanged(val);
      },
      activeColor: Colors.white,
      activeTrackColor: SiberTema.kuantumCyan,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: Color(0xFFE2E8F0),
    );
  }
}

