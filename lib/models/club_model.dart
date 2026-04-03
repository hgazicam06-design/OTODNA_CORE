import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ---------------------------------------------------------
// 1. KUANTUM KULÜP VERİ MODELİ (FİREBASE UYUMLU)
// ---------------------------------------------------------
class VehicleClub {
  final String? id; // Firebase Document ID
  final String modelName; // Örn: "BMW F30 Türkiye"
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

  // 🚀 FİREBASE'E YAZMA MOTORU (Yeni Kulüp Kurulduğunda)
  Map<String, dynamic> toMap() {
    return {
      'model_name': modelName,
      'leader_id': leaderId,
      'co_leader_id': coLeaderId,
      'uye_sayisi': uyeSayisi,
      'kurulus_tarihi': FieldValue.serverTimestamp(),
    };
  }

  // 📥 FİREBASE'DEN OKUMA MOTORU
  factory VehicleClub.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VehicleClub(
      id: doc.id,
      modelName: data['model_name'] ?? 'Bilinmeyen Kulüp',
      leaderId: data['leader_id'] ?? '',
      coLeaderId: data['co_leader_id'] ?? '',
      uyeSayisi: data['uye_sayisi'] ?? 0,
    );
  }
}

// ---------------------------------------------------------
// 2. BAŞKANIN SİBER YETKİ PANELİ (FİREBASE TETİKLEYİCİLERİ)
// ---------------------------------------------------------
class ClubAdminPanel extends StatelessWidget {
  final VehicleClub kulup;
  final String aktifKullaniciId;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ClubAdminPanel({
    super.key,
    required this.kulup,
    required this.aktifKullaniciId
  });

  // Siber Renk Paleti
  static const _neonGreen = Color(0xFF00FFCC);
  static const _cyberCard = Color(0xFF1E1E2E);

  // 🔇 FİREBASE SUSTURMA MOTORU
  Future<void> _uyeyiSustur(BuildContext context) async {
    // TODO: Açılır pencereden seçilen üyenin ID'sini al ve Firebase'de is_muted = true yap
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("🚨 Siber Yetki Kullanıldı: Üye başarıyla susturuldu!"),
      backgroundColor: Colors.redAccent,
    ));
  }

  // 📢 FİREBASE DUYURU MOTORU
  Future<void> _duyuruYap(BuildContext context) async {
    // TODO: Firebase 'kulup_duyurulari' koleksiyonuna mesaj at, tüm üyelere anında bildirim (FCM) gitsin
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("📢 Duyuru Kuantum Ağına gönderildi!"),
      backgroundColor: _neonGreen,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // 🛡️ SİBER GÜVENLİK KALKANI: Bu paneli sadece Başkan ve Başkan Yardımcısı görebilir!
    bool yetkiliMi = (aktifKullaniciId == kulup.leaderId || aktifKullaniciId == kulup.coLeaderId);

    if (!yetkiliMi) {
      return const SizedBox.shrink(); // Yetkisi yoksa paneli tamamen gizle (Hayalet Mod)
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: _cyberCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _neonGreen.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: _neonGreen.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _neonGreen.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Row(
              children: [
                Icon(Icons.admin_panel_settings, color: _neonGreen),
                SizedBox(width: 8),
                Text("KULÜP KOMUTA MERKEZİ", style: TextStyle(color: _neonGreen, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.mic_off, color: Colors.redAccent),
            title: const Text("Üyeyi Sustur", style: TextStyle(color: Colors.white)),
            subtitle: const Text("Kuralları ihlal edeni ağdan düşür", style: TextStyle(color: Colors.grey, fontSize: 12)),
            onTap: () => _uyeyiSustur(context),
          ),
          const Divider(color: Colors.white12, height: 1),
          ListTile(
            leading: const Icon(Icons.event, color: Colors.blueAccent),
            title: const Text("Etkinlik Oluştur", style: TextStyle(color: Colors.white)),
            subtitle: const Text("Buluşma veya konvoy düzenle", style: TextStyle(color: Colors.grey, fontSize: 12)),
            onTap: () {}, // Firebase Etkinlik Motoru bağlanacak
          ),
          const Divider(color: Colors.white12, height: 1),
          ListTile(
            leading: const Icon(Icons.campaign, color: Colors.amber),
            title: const Text("Kuantum Duyurusu Yap", style: TextStyle(color: Colors.white)),
            subtitle: const Text("Tüm üyelere anlık (Push) bildirim at", style: TextStyle(color: Colors.grey, fontSize: 12)),
            onTap: () => _duyuruYap(context),
          ),
          const Divider(color: Colors.white12, height: 1),
          ListTile(
            leading: const Icon(Icons.person_add, color: _neonGreen),
            title: const Text("Üye Onay Paneli", style: TextStyle(color: Colors.white)),
            trailing: const CircleAvatar(backgroundColor: Colors.redAccent, radius: 10, child: Text("3", style: TextStyle(color: Colors.white, fontSize: 10))), // Bekleyen onay sayısı (Dinamik olacak)
            onTap: () {}, // Firebase Onay listesi ekranına geçecek
          ),
        ],
      ),
    );
  }
}