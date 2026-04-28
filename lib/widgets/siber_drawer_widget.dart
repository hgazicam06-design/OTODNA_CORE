// lib/widgets/siber_drawer_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback için
import 'package:go_router/go_router.dart';

// GİDECEĞİ EKRANLARIN İMPORTLARI (Kendi proje yapına göre ayarla)
// import '../screens/bayi/firma_paneli_screen.dart';
// import '../screens/kullanici/siber_cuzdan_screen.dart';
// import '../screens/kullanici/siber_bildirim_merkezi_screen.dart';
// import '../admin/master_gate.dart';

/// 🛡️ KUANTUM GİZLİ GEÇİT VE YAN MENÜ (SiberDrawerWidget)
/// Karargahın farklı cephelerine (Müşteri, Bayi, Admin) ulaşımı sağlayan OLED siyahı terminal.
class SiberDrawerWidget extends StatelessWidget {
  // SİBER NOT: Gerçek veriler Firebase Auth'tan veya bir state yönetim aracından (Provider/Riverpod) alınır.
  final String kullaniciAdi;
  final String eposta;
  final String profilResimUrl;

  SiberDrawerWidget({
    super.key,
    this.kullaniciAdi = "MİSAFİR KULLANICI",
    this.eposta = "SİSTEME GİRİŞ YAPILMADI",
    this.profilResimUrl = "",
  });

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static Color _oledBlack = Color(0xFF000000);
  static Color _matGrey = Color(0xFF111111);
  static Color _kuantumCyan = Color(0xFF00FFC2);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _matGrey, // Ana arka plan Mat Gri
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── 1. KULLANICI PROFİL ALANI (HOLOGRAFİK BAŞLIK) ──
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              context.pop(); // Drawer'ı kapat
              context.push('/siber_profil_ayarlari');
            },
            child: Container(
              padding: EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              color: _oledBlack,
              border: Border(bottom: BorderSide(color: _kuantumCyan.withOpacity(0.5), width: 2)),
              boxShadow: [BoxShadow(color: _kuantumCyan.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)],
            ),
            child: Row(
              children: [
                // Siber Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _kuantumCyan, width: 2),
                    boxShadow: [BoxShadow(color: _kuantumCyan.withOpacity(0.3), blurRadius: 10)],
                    image: profilResimUrl.isNotEmpty
                        ? DecorationImage(image: NetworkImage(profilResimUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: profilResimUrl.isEmpty
                      ? Icon(Icons.person_outline, color: _kuantumCyan, size: 30)
                      : null,
                ),
                SizedBox(width: 16),

                // Kullanıcı Bilgileri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kullaniciAdi.toUpperCase(),
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        eposta.toUpperCase(),
                        style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),

          // ── 2. MENÜ ELEMANLARI (SİBER KÖPRÜLER) ──
          Expanded(
            child: ListView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 10),
              children: [
                // KULLANICI BÖLÜMÜ
                _buildMenubasligi("KİŞİSEL TERMİNAL"),
                _buildDrawerItem(context, Icons.account_balance_wallet_outlined, "SİBER CÜZDAN", _kuantumCyan, () {
                  context.push('/cuzdan');
                }),
                _buildDrawerItem(context, Icons.notifications_none, "BİLDİRİM MERKEZİ", _kuantumCyan, () {
                  context.push('/bildirim_merkezi');
                }),

                Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(color: Colors.white12, height: 30)),

                // KURUMSAL BÖLÜM
                _buildMenubasligi("KURUMSAL AĞ"),
                _buildDrawerItem(context, Icons.storefront_outlined, "BAYİ / USTA GİRİŞİ", Colors.amberAccent, () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => FirmaPaneliScreen()));
                }),

                Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Divider(color: Colors.white12, height: 30)),

                // GİZLİ ADMİN KAPISI
                _buildMenubasligi("SİSTEM KONTROL"),
                _buildDrawerItem(context, Icons.security, "SİBER KOMUTA (ADMİN)", Colors.redAccent, () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => MasterGateScreen()));
                }),

                SizedBox(height: 10),
                _buildDrawerItem(context, Icons.settings_outlined, "SİSTEM AYARLARI", Colors.white54, () {
                  context.push('/uygulama_ayarlari');
                }),
              ],
            ),
          ),

          // ── 3. ALT BİLGİ (SÜRÜM) ──
          Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.center,
            child: Text(
              "OTODNA KUANTUM AĞI V1.0",
              style: TextStyle(color: Colors.white30, fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  // ── 🔧 ARAYÜZ YARDIMCILARI ──────────────────────────────────────────────

  Widget _buildMenubasligi(String baslik) {
    return Padding(
      padding: EdgeInsets.only(left: 20, bottom: 8, top: 10),
      child: Text(
        baslik,
        style: TextStyle(color: Colors.white30, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData ikon, String baslik, Color renk, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(ikon, color: renk, size: 26),
      title: Text(
          baslik,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.5)
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.white24, size: 20),
      onTap: () {
        HapticFeedback.lightImpact(); // Siber dokunsal geri bildirim
        Navigator.pop(context); // Önce menüyü kapat
        onTap(); // Sonra rotaya git
      },
      splashColor: renk.withOpacity(0.2), // Tıklama efekti rengi
      hoverColor: renk.withOpacity(0.05),
    );
  }
}