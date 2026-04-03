import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  // 🚀 FİREBASE: AYARLARI CANLI GÜNCELLEME MOTORU
  Future<void> _ayarGuncelle(String ayarAnahtari, bool yeniDeger) async {
    if (_user == null) return;
    try {
      await _db.collection('kullanicilar').doc(_user!.uid).set({
        'ayarlar': {
          ayarAnahtari: yeniDeger,
        }
      }, SetOptions(merge: true)); // Sadece ilgili ayarı günceller, diğer verileri bozmaz
    } catch (e) {
      _uyariGoster("AĞ ÇÖKTÜ: Ayar mühürlenemedi!", isError: true);
    }
  }

  // 🚀 FİREBASE: SİBER ÇIKIŞ (LOGOUT) PROTOKOLÜ
  Future<void> _guvenliCikisYap() async {
    try {
      await _auth.signOut();
      if (!mounted) return;
      // Tüm rotaları sil ve Login ekranına fırlat
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    } catch (e) {
      _uyariGoster("SİBER HATA: Çıkış protokolü başarısız!", isError: true);
    }
  }

  void _uyariGoster(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1)),
        backgroundColor: isError ? dangerColor : primaryCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: Text("SİBER İHLAL: KULLANICI KİMLİĞİ BULUNAMADI!", style: TextStyle(color: dangerColor, fontWeight: FontWeight.bold))),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("SİSTEM AYARLARI", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // 🖥️ Web / Double Teyp Kalkanı
            child: StreamBuilder<DocumentSnapshot>(
                stream: _db.collection('kullanicilar').doc(_user!.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: primaryCyan));
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text("KARARGAH VERİSİ BULUNAMADI", style: TextStyle(color: Colors.white38)));
                  }

                  // 🧠 VERİTABANINDAN CANLI VERİLERİ ÇEK
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  String isim = data['isim_unvan'] ?? 'BİLİNMEYEN KİMLİK';
                  String rol = data['rol'] ?? 'KULLANICI';

                  // Ayarlar objesi yoksa varsayılan değerleri kullan
                  Map<String, dynamic> ayarlar = data['ayarlar'] ?? {};
                  bool qrKonumLoglama = ayarlar['qr_konum_loglama'] ?? true;
                  bool resmiHatirlaticilar = ayarlar['resmi_hatirlatici'] ?? true;
                  bool kulupBildirimleri = ayarlar['kulup_bildirim'] ?? false;
                  bool kampanyaTeklifleri = ayarlar['kampanya_teklif'] ?? true;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. CANLI PROFİL KARTI
                        _buildProfileCard(isim, rol),
                        const SizedBox(height: 40),

                        // 2. GÜVENLİK VE GİZLİLİK
                        _buildSectionTitle('GÜVENLİK VE GİZLİLİK', Icons.security),
                        _buildSwitchTile(
                          title: 'QR KONUM LOGLAMA',
                          subtitle: 'Aracınızın QR\'ı okutulduğunda konumu gizlice kaydeder.',
                          value: qrKonumLoglama,
                          onChanged: (val) => _ayarGuncelle('qr_konum_loglama', val),
                        ),
                        _buildActionTile(
                          title: 'ENGELLENEN CİHAZLAR',
                          subtitle: 'Sinyal göndermesini yasakladığınız radar kimlikleri.',
                          icon: Icons.block,
                          onTap: () => _uyariGoster("KARA LİSTE ERİŞİMİ YAKINDA AÇILACAK."),
                        ),
                        _buildActionTile(
                          title: 'İKİ ADIMLI DOĞRULAMA (2FA)',
                          subtitle: 'Kuantum hesap güvenliğinizi SMS ile artırın.',
                          icon: Icons.password,
                          onTap: () => _uyariGoster("2FA PROTOKOLÜ YAKINDA AÇILACAK."),
                        ),
                        const SizedBox(height: 40),

                        // 3. ARAÇ VE BİLDİRİMLER
                        _buildSectionTitle('ARAÇ VE BİLDİRİMLER', Icons.directions_car),
                        _buildSwitchTile(
                          title: 'RESMİ EVRAK RADARI',
                          subtitle: 'Muayene ve sigorta bitiş tarihlerinde otonom uyarır.',
                          value: resmiHatirlaticilar,
                          onChanged: (val) => _ayarGuncelle('resmi_hatirlatici', val),
                        ),
                        _buildSwitchTile(
                          title: 'ÖZEL KAMPANYA AĞI',
                          subtitle: 'OtoDNA Merkezinden kasko ve bakım teklifleri.',
                          value: kampanyaTeklifleri,
                          onChanged: (val) => _ayarGuncelle('kampanya_teklif', val),
                        ),
                        _buildSwitchTile(
                          title: 'KULÜP SİNYALLERİ',
                          subtitle: 'Siber forumdaki yeni mesajlar ve istihbaratlar.',
                          value: kulupBildirimleri,
                          onChanged: (val) => _ayarGuncelle('kulup_bildirim', val),
                        ),
                        const SizedBox(height: 40),

                        // 4. DESTEK VE BİLGİ
                        _buildSectionTitle('KARARGAH', Icons.info_outline),
                        _buildActionTile(
                          title: 'REFERANS PROTOKOLÜ (SÖZLEŞME)',
                          icon: Icons.article_outlined,
                          onTap: () {},
                        ),
                        _buildActionTile(
                          title: 'DESTEK VE MÜDAHALE EKİBİ',
                          icon: Icons.headset_mic_outlined,
                          onTap: () {},
                        ),
                        const SizedBox(height: 48),

                        // 5. ATEŞLEME (ÇIKIŞ YAP) BUTONU
                        SizedBox(
                          height: 64,
                          child: ElevatedButton.icon(
                            onPressed: _guvenliCikisYap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: dangerColor.withOpacity(0.1),
                              foregroundColor: dangerColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: dangerColor.withOpacity(0.5))),
                            ),
                            icon: const Icon(Icons.power_settings_new, size: 24),
                            label: const Text(
                              'SİSTEMDEN GÜVENLİ ÇIKIŞ YAP',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ALT SİBER MÜHÜR
                        Center(
                          child: Text(
                            'OTODNA KUANTUM AĞI V1.0.0\nANKARA MERKEZ KOMUTA',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 2, height: 1.5),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                }
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: CANLI PROFİL KARTI
  Widget _buildProfileCard(String isim, String rol) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryCyan.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: primaryCyan.withOpacity(0.5))),
            child: const Icon(Icons.person, color: primaryCyan, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isim.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.verified_user, color: primaryCyan, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'SİBER KİMLİK: ${rol.toUpperCase()}',
                      style: const TextStyle(color: primaryCyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _uyariGoster("KİMLİK GÜNCELLEME PROTOKOLÜ YAKINDA."),
            icon: const Icon(Icons.edit_square, color: Colors.white38),
          )
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: BÖLÜM BAŞLIKLARI
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 8),
      child: Row(
        children: [
          Icon(icon, color: primaryCyan.withOpacity(0.5), size: 18),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: CANLI ŞALTER KARTI (Switch)
  Widget _buildSwitchTile({required String title, required String subtitle, required bool value, required Function(bool) onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primaryCyan,
            activeTrackColor: primaryCyan.withOpacity(0.3),
            inactiveTrackColor: Colors.white12,
            inactiveThumbColor: Colors.white38,
          ),
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: TIKLANABİLİR İŞLEM KARTI
  Widget _buildActionTile({required String title, String? subtitle, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Row(
          children: [
            Icon(icon, color: Colors.white38, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold, height: 1.4)),
                  ]
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: primaryCyan, size: 16),
          ],
        ),
      ),
    );
  }
}