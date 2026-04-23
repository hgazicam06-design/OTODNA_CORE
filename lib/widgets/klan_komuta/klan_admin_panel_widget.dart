import 'package:flutter/material.dart';
import '../../models/club_model.dart';
import '../../core/siber_tema.dart';

/// 🛡️ KLAN SİBER YETKİ PANELİ
/// Global kulüp hiyerarşisini yöneten siber komuta merkezi.
class KlanAdminPanel extends StatelessWidget {
  final VehicleClub kulup;
  final String aktifKullaniciId;

  const KlanAdminPanel({
    super.key,
    required this.kulup,
    required this.aktifKullaniciId
  });

  // 🔇 FİREBASE SUSTURMA PROTOKOLÜ
  Future<void> _uyeyiSustur(BuildContext context) async {
    // Firebase entegrasyonu için WriteBatch kullanılacak
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("🚨 SİBER YETKİ: Üye ağdan izole edildi!"),
      backgroundColor: SiberTema.kanKirmizi,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // 📢 KUANTUM DUYURU PROTOKOLÜ
  Future<void> _duyuruYap(BuildContext context) async {
    // Cloud Functions üzerinden Push Notification tetiklenecek
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("📢 DUYURU: Kuantum Ağına yayınlandı!"),
      backgroundColor: SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // SİBER GÜVENLİK KALKANI (GLOBAL MODEL ÜZERİNDEN)
    bool yetkiliMi = kulup.isUserAuthorized(aktifKullaniciId);
    bool moderatorMu = kulup.isUserModerator(aktifKullaniciId);

    if (!yetkiliMi && !moderatorMu) {
      return const SizedBox.shrink(); // Yetkisizse gizle
    }

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SiberTema.matGrey,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 20, spreadRadius: 2)
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          
          if (yetkiliMi) ...[
            _buildActionItem(
              icon: Icons.mic_off_rounded,
              color: SiberTema.kanKirmizi,
              title: "Üyeyi İhraç Et / Sustur",
              subtitle: "Protokol ihlallerini cezalandır",
              onTap: () => _uyeyiSustur(context),
            ),
            _buildDivider(),
          ],
          
          _buildActionItem(
            icon: Icons.campaign_rounded,
            color: Colors.amberAccent,
            title: "Duyuru Yap",
            subtitle: "Tüm üyelere anlık bildirim at",
            onTap: () => _duyuruYap(context),
          ),
          
          if (yetkiliMi || moderatorMu) ...[
            _buildDivider(),
            _buildActionItem(
              icon: Icons.person_add_alt_1_rounded,
              color: SiberTema.kuantumCyan,
              title: "Üye Onay Paneli",
              subtitle: "Klan giriş taleplerini incele",
              trailing: _buildBadge("3"),
              onTap: () {},
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: SiberTema.kuantumCyan.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_rounded, color: SiberTema.kuantumCyan, size: 20),
          SizedBox(width: 10),
          Text(
            "KLAN KOMUTA MERKEZİ",
            style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.white12),
    );
  }

  Widget _buildDivider() => Divider(color: SiberTema.kuantumCyan.withOpacity(0.1), height: 1, indent: 60);

  Widget _buildBadge(String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: SiberTema.kanKirmizi, borderRadius: BorderRadius.circular(10)),
      child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
