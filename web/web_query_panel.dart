// lib/web/web_query_panel.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM WEB SORGULAMA RADARI (SiberWebSorguPaneli)
/// Plaka veya Şase numarası ile Karargah veri tabanında otonom araç taraması yapar.
class SiberWebSorguPaneli extends StatefulWidget {
  const SiberWebSorguPaneli({super.key});

  @override
  State<SiberWebSorguPaneli> createState() => _SiberWebSorguPaneliState();
}

class _SiberWebSorguPaneliState extends State<SiberWebSorguPaneli> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController _plakaCtrl = TextEditingController();
  final TextEditingController _saseCtrl = TextEditingController();

  bool _islemSuruyor = false;

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _kuantumCyan = Color(0xFF00FFC2);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kanKirmizi = Colors.redAccent;

  // ── 🚀 FİREBASE İSTİHBARAT ARAMA MOTORU ──
  Future<void> _siberSorguyuAtesle() async {
    String plaka = _plakaCtrl.text.trim().toUpperCase();
    String sase = _saseCtrl.text.trim().toUpperCase();

    if (plaka.isEmpty && sase.isEmpty) {
      _siberUyariGoster("SİBER İHLAL", "Tarama başlatmak için Plaka veya Şase numarası girilmelidir!", _kanKirmizi);
      return;
    }

    if (_islemSuruyor) return;
    setState(() => _islemSuruyor = true);

    developer.log("📡 SİBER RADAR: İstihbarat taraması başlatıldı. Hedef: ${plaka.isNotEmpty ? plaka : sase}");

    try {
      QuerySnapshot sorguSonucu;

      // Şase önceliklidir (Daha kesindir), Şase yoksa Plakadan arar
      if (sase.isNotEmpty) {
        sorguSonucu = await _db.collection('arac_kimlikleri').where('sase_no', isEqualTo: sase).limit(1).get();
      } else {
        sorguSonucu = await _db.collection('arac_kimlikleri').where('plaka', isEqualTo: plaka).limit(1).get();
      }

      if (sorguSonucu.docs.isNotEmpty) {
        developer.log("✅ HEDEF TESPİT EDİLDİ: Araç Matrix'te bulundu.");
        var aracVerisi = sorguSonucu.docs.first.data() as Map<String, dynamic>;

        // SİBER NOT: Araç bulunduğunda sonuç ekranına/rapora yönlendirme işlemi buraya yazılacak.
        _siberUyariGoster("HEDEF BULUNDU", "Araç Karargah kayıtlarında tespit edildi. Rapor hazırlanıyor...", _kuantumCyan);

        // Örn: Navigator.push(context, MaterialPageRoute(builder: (_) => SiberRaporEkrani(aracVerisi: aracVerisi)));
      } else {
        developer.log("🚨 KAYIT YOK: Araç Matrix'te bulunamadı.");
        _siberUyariGoster("HEDEF BULUNAMADI", "Bu araç Karargah Kuantum Ağına henüz kayıt edilmemiş.", Colors.orangeAccent);
      }

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Sorgulama yapılamadı!", error: e);
      _siberUyariGoster("BAĞLANTI HATASI", "Karargah sunucularına ulaşılamıyor.", _kanKirmizi);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _matGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _plakaCtrl.dispose();
    _saseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🛡️ SİBER CAM EFEKTİ (Glassmorphism)
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05), // Yarı saydam siber cam
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kuantumCyan.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(color: _kuantumCyan.withOpacity(0.05), blurRadius: 30, spreadRadius: -5)
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Web'de geniş ekran mı yoksa mobil görünüm mü olduğunu otonom kontrol eder
              bool isDesktop = constraints.maxWidth > 800;

              Widget formIcerigi = isDesktop
                  ? _buildDesktopLayout()
                  : _buildMobileLayout();

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.radar, color: _kuantumCyan, size: 28),
                      SizedBox(width: 12),
                      Text("KARARGAH İSTİHBARAT ARAMASI", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  formIcerigi,
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── 🌐 GENİŞ EKRAN (WEB) MİMARİSİ ──
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _buildSiberGirdiAlan("PLAKA İLE SORGULA", "Örn: 34 DNA 192", Icons.pin_outlined, _plakaCtrl),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Text("VEYA", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12)),
        ),
        Expanded(
          child: _buildSiberGirdiAlan("ŞASE NO (17 Karakter)", "Örn: WVWZZZ...", Icons.fingerprint, _saseCtrl),
        ),
        const SizedBox(width: 24),
        _buildAteslemeButonu(yukseklik: 65, genislik: 200),
      ],
    );
  }

  // ── 📱 DAR EKRAN (MOBİL WEB) MİMARİSİ ──
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildSiberGirdiAlan("PLAKA İLE SORGULA", "Örn: 34 DNA 192", Icons.pin_outlined, _plakaCtrl),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text("VEYA", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12)),
        ),
        _buildSiberGirdiAlan("ŞASE NO (17 Karakter)", "Örn: WVWZZZ...", Icons.fingerprint, _saseCtrl),
        const SizedBox(height: 24),
        _buildAteslemeButonu(yukseklik: 60, genislik: double.infinity),
      ],
    );
  }

  // Özel İnput Kalkanı
  Widget _buildSiberGirdiAlan(String baslik, String ipucu, IconData ikon, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(baslik, style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _matGrey.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 2, fontWeight: FontWeight.bold),
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              prefixIcon: Icon(ikon, color: _kuantumCyan, size: 22),
              hintText: ipucu,
              hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 1, fontSize: 13),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
            ),
          ),
        ),
      ],
    );
  }

  // Ateşleme Butonu
  Widget _buildAteslemeButonu({required double yukseklik, required double genislik}) {
    return SizedBox(
      height: yukseklik,
      width: genislik,
      child: _islemSuruyor
          ? Container(
        decoration: BoxDecoration(color: _matGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kuantumCyan)),
        child: const Center(child: CircularProgressIndicator(color: _kuantumCyan)),
      )
          : ElevatedButton.icon(
        icon: const Icon(Icons.manage_search, color: Colors.black, size: 24),
        label: const Text("ARACI BUL", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kuantumCyan,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 15,
          shadowColor: _kuantumCyan.withOpacity(0.4),
        ),
        onPressed: _siberSorguyuAtesle,
      ),
    );
  }
}