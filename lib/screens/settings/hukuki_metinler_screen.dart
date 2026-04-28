import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:otodna/core/responsive_kalkan.dart';

/// ⚖️ SİBER HUKUK TERMİNALİ (Hukuki Metinler ve Sözleşmeler)
class HukukiMetinlerScreen extends StatelessWidget {
  const HukukiMetinlerScreen({super.key});

  // ⚜️ RENK PALETİ (Fildişi Sedef & Metalik Gold)
  static const Color darkGold = Color(0xFFB8860B);
  static const Color bgIvory = Color(0xFFFAFAFC);
  static const Color textDark = Color(0xFF2C2519);
  static const Color cardWhite = Colors.white;

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgIvory,
        appBar: AppBar(
          backgroundColor: bgIvory,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: textDark, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.pop();
            },
          ),
          title: const Text(
            "YASAL SÖZLEŞMELER",
            style: TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              fontFamily: 'Avenir',
              letterSpacing: 2.0,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: darkGold.withOpacity(0.2), height: 1),
          ),
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            _buildSozlesmeKarti(
              context,
              baslik: "Kullanım Koşulları",
              tarih: "Son Güncelleme: 01.05.2026",
              icon: Icons.description_outlined,
            ),
            _buildSozlesmeKarti(
              context,
              baslik: "Gizlilik Politikası",
              tarih: "Son Güncelleme: 01.05.2026",
              icon: Icons.privacy_tip_outlined,
            ),
            _buildSozlesmeKarti(
              context,
              baslik: "KVKK Aydınlatma Metni",
              tarih: "Son Güncelleme: 01.05.2026",
              icon: Icons.policy_outlined,
            ),
            _buildSozlesmeKarti(
              context,
              baslik: "Açık Rıza Beyanı",
              tarih: "Pazarlama ve Veri İşleme Onayı",
              icon: Icons.check_circle_outline,
            ),
            _buildSozlesmeKarti(
              context,
              baslik: "Mesafeli Satış Sözleşmesi",
              tarih: "OtoMarket İşlemleri İçin Geçerli",
              icon: Icons.shopping_bag_outlined,
            ),
            _buildSozlesmeKarti(
              context,
              baslik: "İade Şartları ve Protokolü",
              tarih: "Garanti ve İade Süreçleri",
              icon: Icons.autorenew,
            ),
            
            const SizedBox(height: 40),
            const Icon(Icons.gavel, color: Colors.black12, size: 50),
            const SizedBox(height: 16),
            const Text(
              "Bu platformda gerçekleştirilen tüm eylemler OtoDNA A.Ş. Hukuk Birimi ve KVKK standartları tarafından korunmaktadır.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black38, fontSize: 10, letterSpacing: 1.5, height: 1.5, fontFamily: 'Avenir'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSozlesmeKarti(BuildContext context, {required String baslik, required String tarih, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: darkGold.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(icon, color: darkGold, size: 28),
        title: Text(
          baslik,
          style: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Avenir'),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            tarih,
            style: TextStyle(color: textDark.withOpacity(0.6), fontSize: 10, letterSpacing: 1.0, fontFamily: 'Avenir'),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.black26, size: 14),
        onTap: () {
          HapticFeedback.lightImpact();
          _hukukiDetayGoster(context, baslik);
        },
      ),
    );
  }

  // Örnek: Gerçek hayatta bu metinler veritabanından çekilir veya yerel PDF/String dosyalardan okunur.
  void _hukukiDetayGoster(BuildContext context, String baslik) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(baslik.toUpperCase(), style: const TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'))),
                      IconButton(icon: const Icon(Icons.close, color: Colors.black54), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: darkGold.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Text(
                          "DİKKAT: ŞABLON METİN\nBu metin yazılım geliştirme aşamasında oluşturulmuş bir taslaktır. Üretime (Production) çıkılmadan önce mutlaka Şirket Avukatları tarafından revize edilmesi zorunludur.\n\n"
                          "1. GİRİŞ\nOtoDNA A.Ş. olarak kişisel verilerinizin güvenliğine en üst düzeyde önem veriyoruz. 6698 sayılı Kişisel Verilerin Korunması Kanunu (KVKK) uyarınca...\n\n"
                          "2. İŞLENEN VERİLER\n- Kimlik Bilgileri\n- İletişim Bilgileri\n- Araç ve Plaka Bilgileri\n- IP ve Log Kayıtları\n\n"
                          "3. VERİ GÜVENLİĞİ VE SİBER ZIRH\nTüm verileriniz uçtan uca şifrelenmiş Firebase Firestore altyapısı üzerinde, Role-Based Access Control (RBAC) güvenlik kurallarıyla izole edilmiştir. Verilerinize sizin veya yetki verdiğiniz merciler dışında ulaşılamaz.\n\n"
                          "4. İPTAL VE İADE\nKullanıcı, platform üzerinde yaptığı işlemleri... (Devamı yasal danışmanlarca doldurulacaktır.)",
                          style: TextStyle(color: textDark.withOpacity(0.8), fontSize: 12, height: 1.6, fontFamily: 'Avenir'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
