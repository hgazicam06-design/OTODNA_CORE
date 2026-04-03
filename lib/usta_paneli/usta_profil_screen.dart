import 'package:flutter/material.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM USTA & BAYİ PROFİL TERMİNALİ (UstaProfilScreen)
/// Ustanın DNA Skorunu, Etik Sözleşmesini ve 5 Kademeli Rozet Sistemini OLED Ekranda gösterir.
class UstaProfilScreen extends StatelessWidget {
  final String firmaAdi;
  final int rozetYildizi; // 5: Altın, 4: Gümüş, 3: Bronz, 2: Standart, 1: Blacklist
  final int yesilTikSayisi;
  final int kirmiziCarpiSayisi;
  final String lokasyon;

  const UstaProfilScreen({
    super.key,
    this.firmaAdi = "Gazi Auto & Kuantum Garaj",
    this.rozetYildizi = 5,
    this.yesilTikSayisi = 1240,
    this.kirmiziCarpiSayisi = 45,
    this.lokasyon = "İskitler MİA, Ankara", // Karargah istihbaratı
  });

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ (RENKLER) ──
  static const Color _kuantumTurkuaz = Color(0xFF00FFC2);
  static const Color _oledSiyah = Color(0xFF000000);
  static const Color _matGriKart = Color(0xFF111111);

  @override
  Widget build(BuildContext context) {
    bool isBlacklisted = rozetYildizi <= 1;

    return Scaffold(
      backgroundColor: _oledSiyah,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isBlacklisted ? Colors.redAccent : _kuantumTurkuaz),
        actions: [
          IconButton(
              icon: Icon(Icons.share_outlined, color: isBlacklisted ? Colors.redAccent : _kuantumTurkuaz),
              onPressed: () {
                developer.log("SİBER SİNYAL: Profil paylaşım komutu tetiklendi.");
              }
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildSiberKapak(isBlacklisted),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIstatistikPanosu(isBlacklisted),
                  const SizedBox(height: 30),

                  _buildUzmanlikAlanlari(isBlacklisted),
                  const SizedBox(height: 30),

                  _buildOtoDnaEtikSozlesmesi(isBlacklisted),
                  const SizedBox(height: 40),

                  _buildAksiyonButonlari(isBlacklisted),
                  const SizedBox(height: 50),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ─── 1. 🛡️ SİBER KAPAK VE ROZET SİSTEMİ ──────────────────────────────────
  Widget _buildSiberKapak(bool isBlacklisted) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 30),
      decoration: BoxDecoration(
        color: _matGriKart,
        border: Border(
            bottom: BorderSide(
                color: isBlacklisted ? Colors.redAccent : _kuantumTurkuaz.withOpacity(0.5),
                width: 2
            )
        ),
      ),
      child: Column(
        children: [
          // Kuantum Profil Çerçevesi
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _oledSiyah,
              border: Border.all(color: isBlacklisted ? Colors.redAccent : _kuantumTurkuaz, width: 2),
              boxShadow: [
                BoxShadow(
                  color: isBlacklisted ? Colors.redAccent.withOpacity(0.3) : _kuantumTurkuaz.withOpacity(0.2),
                  blurRadius: 25,
                  spreadRadius: 2,
                )
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: _matGriKart,
              child: Icon(
                  isBlacklisted ? Icons.block : Icons.precision_manufacturing_outlined,
                  size: 50,
                  color: isBlacklisted ? Colors.redAccent : _kuantumTurkuaz
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
              firmaAdi.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: isBlacklisted ? Colors.redAccent : Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2
              )
          ),
          const SizedBox(height: 12),

          // 🏆 DİNAMİK ROZET MOTORU
          _buildRozetMotoru(),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined, color: Colors.white54, size: 16),
              const SizedBox(width: 6),
              Text(lokasyon, style: const TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRozetMotoru() {
    IconData ikon;
    Color renk;
    String unvan;

    switch (rozetYildizi) {
      case 5:
        ikon = Icons.workspace_premium_outlined; renk = Colors.amber; unvan = "ALTIN ROZET (KUSURSUZ)";
        break;
      case 4:
        ikon = Icons.shield_outlined; renk = Colors.grey[300]!; unvan = "GÜMÜŞ ROZET";
        break;
      case 3:
        ikon = Icons.verified_outlined; renk = Colors.deepOrangeAccent; unvan = "BRONZ ROZET";
        break;
      case 2:
        ikon = Icons.account_circle_outlined; renk = Colors.white54; unvan = "STANDART BAYİ";
        break;
      default:
        ikon = Icons.gpp_bad_outlined; renk = Colors.redAccent; unvan = "KARA LİSTE (BLACKLIST)";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: _oledSiyah,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: renk.withOpacity(0.5), width: 1.5)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, color: renk, size: 18),
          const SizedBox(width: 8),
          Text(unvan, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  // ─── 2. 📊 YEŞİL TIK VE KIRMIZI ÇARPI (DNA SKORU) ───────────────────────
  Widget _buildIstatistikPanosu(bool isBlacklisted) {
    return Row(
      children: [
        Expanded(
          child: _buildIstatistikKarti(
              Icons.check_circle_outline,
              yesilTikSayisi.toString(),
              "MÜHÜRLÜ İŞLEM (✅)",
              isBlacklisted ? Colors.white30 : _kuantumTurkuaz
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildIstatistikKarti(
              Icons.cancel_outlined,
              kirmiziCarpiSayisi.toString(),
              "KUSUR TESPİTİ (❌)",
              Colors.redAccent
          ),
        ),
      ],
    );
  }

  Widget _buildIstatistikKarti(IconData ikon, String sayi, String etiket, Color renk) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
          color: _matGriKart,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: renk.withOpacity(0.3), width: 1.5)
      ),
      child: Column(
        children: [
          Icon(ikon, color: renk, size: 32),
          const SizedBox(height: 12),
          Text(sayi, style: TextStyle(color: renk, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(etiket, style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1)),
        ],
      ),
    );
  }

  // ─── 3. ⚙️ UZMANLIK VE BRANŞLAR (NOKTA ATIŞI) ───────────────────────────
  Widget _buildUzmanlikAlanlari(bool isBlacklisted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            "UZMANLIK & BRANŞLAR",
            style: TextStyle(color: isBlacklisted ? Colors.redAccent : _kuantumTurkuaz, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: [
            _buildCip("BEYİN (ECU) UZMANI", isBlacklisted),
            _buildCip("OTO ELEKTRİK & ELEKTRONİK", isBlacklisted),
            _buildCip("SADECE VAG GRUBU", isBlacklisted),
            _buildCip("HİBRİT / EV BATARYA", isBlacklisted),
          ],
        ),
      ],
    );
  }

  Widget _buildCip(String metin, bool isBlacklisted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: _matGriKart,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isBlacklisted ? Colors.redAccent.withOpacity(0.3) : Colors.white24)
      ),
      child: Text(metin, style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)),
    );
  }

  // ─── 4. 📜 OTO DNA ETİK KURALLARI VE ŞEFFAF GARANTİ ─────────────────────
  Widget _buildOtoDnaEtikSozlesmesi(bool isBlacklisted) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isBlacklisted ? Colors.red.withOpacity(0.05) : _kuantumTurkuaz.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isBlacklisted ? Colors.redAccent.withOpacity(0.3) : _kuantumTurkuaz.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel_outlined, color: isBlacklisted ? Colors.redAccent : _kuantumTurkuaz, size: 22),
              const SizedBox(width: 10),
              const Text("OTODNA ETİK & GARANTİ BİLDİRGESİ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          const Text(
            "• NİYET BOZUKLUĞU YOKTUR: Araçlarda mekanik veya elektronik hatalar olabilir. Tüm tespitler tamamen tarafsızdır. Mümkün olduğunca hatalar kullanıcı hatası veya parça hatası olarak şeffafça gösterilir.\n\n"
                "• SIFIR KÖTÜLEME POLİTİKASI: Ustalarımız meslektaşlarını veya rakip firmaları asla kötülemez.\n\n"
                "• GARANTİ KOŞULLARI: Bu firmadan alınan sıfır parçalar 1 Yıl, çıkma parçalar 15 Gün OtoDNA Siber Kasa güvencesindedir.",
            style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.6, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  // ─── 5. 🚀 İLETİŞİM VE RANDEVU BUTONLARI (KARA LİSTE KİLİDİ) ────────────
  Widget _buildAksiyonButonlari(bool isBlacklisted) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: _matGriKart,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.white24)
                )
            ),
            icon: const Icon(Icons.directions_outlined, color: Colors.white),
            label: const Text("YOL TARİFİ", style: TextStyle(color: Colors.white, letterSpacing: 1, fontWeight: FontWeight.bold)),
            onPressed: () {
              developer.log("SİBER BİLGİ: Yol tarifi navigasyon modülü tetiklendi.");
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: isBlacklisted ? Colors.redAccent.withOpacity(0.1) : _kuantumTurkuaz,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: isBlacklisted ? Colors.redAccent : Colors.transparent, width: 2)
                )
            ),
            icon: Icon(isBlacklisted ? Icons.block : Icons.calendar_month_outlined, color: isBlacklisted ? Colors.redAccent : Colors.black),
            label: Text(
                isBlacklisted ? "İŞLEM YASAK" : "RANDEVU AL",
                style: TextStyle(color: isBlacklisted ? Colors.redAccent : Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1)
            ),
            // SİBER KİLİT: Eğer usta Blacklist'teyse buton tıklanamaz!
            onPressed: isBlacklisted ? null : () {
              developer.log("SİBER ONAY: Randevu modülüne geçiş yapılıyor...");
            },
          ),
        ),
      ],
    );
  }
}