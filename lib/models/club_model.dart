import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 OTODNA KUANTUM KULÜP VERİ MODELİ
/// Kullanıcıların marka/model bazlı birleştiği dijital klan yapısı.
class VehicleClub {
  final String? id;
  final String modelName;
  final String leaderId;
  final String coLeaderId;
  final int uyeSayisi;

  VehicleClub({
    this.id,
    required this.modelName,
    required this.leaderId,
    required this.coLeaderId,
    this.uyeSayisi = 0,
  });

  // 🚀 FİREBASE'E ATOMİK YAZMA MOTORU (YENİ KULÜP KURULUŞU)
  Map<String, dynamic> toMap() {
    return {
      'model_name': modelName,
      'leader_id': leaderId,
      'co_leader_id': coLeaderId,
      'uye_sayisi': uyeSayisi,
      'kurulus_tarihi': FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN ANALİTİK OKUMA MOTORU
  factory VehicleClub.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return VehicleClub(
      id: doc.id,
      modelName: data['model_name'] ?? 'BİLİNMEYEN KLAN',
      leaderId: data['leader_id'] ?? '',
      coLeaderId: data['co_leader_id'] ?? '',
      uyeSayisi: (data['uye_sayisi'] ?? 0).toInt(),
    );
  }

  // 🛡️ YETKİ KONTROL MOTORU
  bool isUserAuthorized(String userId) {
    return userId == leaderId || userId == coLeaderId;
  }
}

/// 🛡️ BAŞKANIN SİBER YETKİ PANELİ
/// Kulüp hiyerarşisini yöneten siber komuta merkezi.
class ClubAdminPanel extends StatelessWidget {
  final VehicleClub kulup;
  final String aktifKullaniciId;

  const ClubAdminPanel({
    super.key,
    required this.kulup,
    required this.aktifKullaniciId
  });

  static const _neonGreen = Color(0xFF00FFCC);
  static const _cyberCard = Color(0xFF11111E); // Derin Karargah Siyahı

  // 🔇 FİREBASE SUSTURMA PROTOKOLÜ
  Future<void> _uyeyiSustur(BuildContext context) async {
    // Firebase entegrasyonu için WriteBatch kullanılacak
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("🚨 SİBER YETKİ: Üye ağdan izole edildi!"),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // 📢 KUANTUM DUYURU PROTOKOLÜ
  Future<void> _duyuruYap(BuildContext context) async {
    // Cloud Functions üzerinden Push Notification tetiklenecek
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("📢 DUYURU: Kuantum Ağına yayınlandı!"),
      backgroundColor: _neonGreen,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // SİBER GÜVENLİK KALKANI (MODEL ÜZERİNDEN)
    if (!kulup.isUserAuthorized(aktifKullaniciId)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cyberCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _neonGreen.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: _neonGreen.withOpacity(0.05), blurRadius: 20, spreadRadius: 2)
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildActionItem(
            icon: Icons.mic_off_rounded,
            color: Colors.redAccent,
            title: "Üyeyi Sustur",
            subtitle: "Protokol ihlallerini cezalandır",
            onTap: () => _uyeyiSustur(context),
          ),
          _buildDivider(),
          _buildActionItem(
            icon: Icons.campaign_rounded,
            color: Colors.amberAccent,
            title: "Duyuru Yap",
            subtitle: "Tüm üyelere anlık bildirim at",
            onTap: () => _duyuruYap(context),
          ),
          _buildDivider(),
          _buildActionItem(
            icon: Icons.person_add_alt_1_rounded,
            color: _neonGreen,
            title: "Üye Onay Paneli",
            subtitle: "Klan giriş taleplerini incele",
            trailing: _buildBadge("3"),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: _neonGreen.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_rounded, color: _neonGreen, size: 20),
          SizedBox(width: 10),
          Text(
            "KLAN KOMUTA MERKEZİ",
            style: TextStyle(color: _neonGreen, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 13),
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

  Widget _buildDivider() => Divider(color: _neonGreen.withOpacity(0.1), height: 1, indent: 60);

  Widget _buildBadge(String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10)),
      child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}