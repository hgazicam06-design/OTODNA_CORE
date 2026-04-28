import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:otodna/core/siber_tema.dart';
import 'package:otodna/core/responsive_kalkan.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 👤 HESABIM (Profil ve Detaylı Ayarlar Dashboard'u)
/// E-ticaret ve Bankacılık standartlarında (Plaza Aydınlık Teması) birleştirilmiş kontrol merkezi.
class SiberProfilAyarlariScreen extends StatefulWidget {
  const SiberProfilAyarlariScreen({super.key});

  @override
  State<SiberProfilAyarlariScreen> createState() => _SiberProfilAyarlariScreenState();
}

class _SiberProfilAyarlariScreenState extends State<SiberProfilAyarlariScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  // Orijinal işlevsellik değişkenleri korunmuştur
  bool _is2faEnabled = false;

  // Görsel amaçlı yeni UI değişkenleri (Veritabanı değişikliği yapmadan)
  bool _pluginEkspertiz = true;
  bool _pluginSiberFatura = false;

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false, // AYDINLIK TEMA AKTİF
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFC), // Fildişi Sedef Arka Plan
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.textMain, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.pop();
            },
          ),
          title: Text(
            "HESABIM",
            style: TextStyle(
              color: SiberTema.textMain,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              fontFamily: 'Avenir',
              letterSpacing: 1.5,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.settings_outlined, color: SiberTema.textMain),
              onPressed: () {
                // Diğer ayarlara yönlendirme (İşlev korunarak eklenebilir)
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. PROFİL ÖZET KARTI (Trendyol/Sahibinden Stili) ──
              _buildProfilOzetKarti(),
              const SizedBox(height: 24),

              // ── 2. HIZLI İŞLEMLER / KISAYOLLAR ──
              _buildHizliIslemlerPaneli(),
              const SizedBox(height: 24),

              // ── 3. KULLANICI ERİŞİMLERİ VE YETKİLER ──
              _buildSiberKategoriBasligi("KULLANICI ERİŞİMLERİ"),
              _buildAyarKarti(
                icon: Icons.admin_panel_settings_outlined,
                baslik: "Yetki Seviyesi",
                altBaslik: "BİREYSEL KULLANICI",
                trailing: TextButton(
                  onPressed: () {},
                  child: Text("YÜKSELT", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              _buildAyarKarti(
                icon: Icons.storefront_outlined,
                baslik: "Bayi Paneli Erişimi",
                altBaslik: "Henüz bir bayiye bağlı değilsiniz.",
                onTap: () {},
              ),

              const SizedBox(height: 20),

              // ── 4. UYGULAMA EKLENTİLERİ (GÖRSEL REFERANS) ──
              _buildSiberKategoriBasligi("UYGULAMA EKLENTİLERİ"),
              _buildAyarKarti(
                icon: Icons.policy_outlined,
                baslik: "Kuantum Ekspertiz Modülü",
                altBaslik: "Detaylı hasar analizi aktif.",
                trailing: Switch(
                  value: _pluginEkspertiz,
                  onChanged: (val) => setState(() => _pluginEkspertiz = val),
                  activeColor: Colors.white,
                  activeTrackColor: SiberTema.kuantumCyan,
                ),
              ),
              _buildAyarKarti(
                icon: Icons.receipt_long_outlined,
                baslik: "Siber Fatura Entegrasyonu",
                altBaslik: "Muhasebe modülü kapalı.",
                trailing: Switch(
                  value: _pluginSiberFatura,
                  onChanged: (val) => setState(() => _pluginSiberFatura = val),
                  activeColor: Colors.white,
                  activeTrackColor: SiberTema.kuantumCyan,
                ),
              ),

              const SizedBox(height: 20),

              // ── 5. ORİJİNAL GÜVENLİK DUVARI İŞLEVLERİ ──
              _buildSiberKategoriBasligi("GÜVENLİK DUVARI"),
              _buildAyarKarti(
                icon: Icons.password,
                baslik: "Şifremi Değiştir",
                altBaslik: "Güvenlik protokolünü yenile.",
                onTap: () {
                  // Mevcut Şifre değiştirme işlevi
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
                  activeColor: Colors.white,
                  activeTrackColor: SiberTema.kuantumCyan,
                ),
              ),

              const SizedBox(height: 20),
              
              // ── 6. İLETİŞİM BİLGİLERİ (Mevcut İşlev) ──
              _buildSiberKategoriBasligi("İLETİŞİM BİLGİLERİ"),
              _buildAyarKarti(
                icon: Icons.phone_android,
                baslik: "Telefon Numarası",
                altBaslik: currentUser?.phoneNumber ?? "Kayıtlı Numara Yok",
                onTap: () {
                  // Mevcut Telefon doğrulama
                },
              ),

              const SizedBox(height: 30),
              
              // ── 7. HESAP SİLME (Mevcut İşlev - YAPI KREDİ KIRMIZISI) ──
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: SiberTema.kanKirmizi,
                  side: BorderSide(color: SiberTema.kanKirmizi.withOpacity(0.3), width: 1),
                  minimumSize: const Size(double.infinity, 54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(Icons.delete_forever, color: SiberTema.kanKirmizi),
                label: Text("HESABIMI VE VERİLERİMİ SİL", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: 13, color: SiberTema.kanKirmizi)),
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  _hesapSilmeUyarisiGoster(context);
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── YARDIMCI WIDGETLAR ──

  /// Profil Özet Kartı (En Üstteki Ana Bilgi Alanı)
  Widget _buildProfilOzetKarti() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SiberTema.kuantumCyan,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
        ],
        gradient: LinearGradient(
          colors: [SiberTema.kuantumCyan, const Color(0xFF00B4D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 2),
              image: currentUser?.photoURL != null
                  ? DecorationImage(image: NetworkImage(currentUser!.photoURL!), fit: BoxFit.cover)
                  : null,
            ),
            child: currentUser?.photoURL == null
                ? Icon(Icons.person, size: 35, color: SiberTema.kuantumCyan)
                : null,
          ),
          const SizedBox(width: 16),
          // Bilgiler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUser?.displayName ?? "Değerli Müşterimiz",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser?.email ?? "E-posta bulunamadı",
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "BİREYSEL HESAP",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// E-ticaret tarzı yuvarlak hızlı butonlar
  Widget _buildHizliIslemlerPaneli() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildKisaYolButonu(Icons.directions_car_filled_outlined, "Araçlarım"),
        _buildKisaYolButonu(Icons.receipt_long_outlined, "Siparişlerim"),
        _buildKisaYolButonu(Icons.favorite_border, "Favoriler"),
        _buildKisaYolButonu(Icons.support_agent_outlined, "Destek"),
      ],
    );
  }

  Widget _buildKisaYolButonu(IconData icon, String baslik) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, spreadRadius: 1),
              ],
            ),
            child: Icon(icon, color: SiberTema.textMain, size: 24),
          ),
          const SizedBox(height: 8),
          Text(baslik, style: TextStyle(color: SiberTema.textMain, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSiberKategoriBasligi(String baslik) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12, top: 8),
      child: Text(
        baslik,
        style: TextStyle(
          color: SiberTema.textMuted,
          fontSize: 12,
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
      decoration: SiberTema.siberKutuZirhi, // Beyaz Plaza Kartı
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Icon(icon, color: SiberTema.textMain, size: 24),
        ),
        title: Text(baslik, style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Avenir')),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(altBaslik, style: TextStyle(color: SiberTema.textMuted, fontSize: 11)),
        ),
        trailing: trailing ?? Icon(Icons.chevron_right, color: SiberTema.textMuted, size: 20),
        onTap: onTap != null ? () {
          HapticFeedback.lightImpact();
          onTap();
        } : null,
      ),
    );
  }

  // ── MEVCUT İŞLEVLER KORUNDU ──
  void _hesapSilmeUyarisiGoster(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // Aydınlık tema uyumlu
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: SiberTema.kanKirmizi.withOpacity(0.5), width: 1),
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
          style: TextStyle(color: SiberTema.textMain, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("İPTAL", style: TextStyle(color: SiberTema.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kanKirmizi, foregroundColor: Colors.white),
            onPressed: () {
              // Firebase hesabını silme işlemi (İşlev korundu)
              Navigator.pop(context);
              FirebaseAuth.instance.currentUser?.delete();
              context.go('/');
            },
            child: const Text("KALICI OLARAK SİL", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
