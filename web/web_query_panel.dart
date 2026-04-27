// lib/web/web_query_panel.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🔥 SİBER KÖPRÜ
import '../core/siber_tema.dart';

/// 🛡️ DİJİTAL WEB SORGULAMA PANELİ (Platinum)
/// Plaka veya Şase numarası ile veri tabanında otonom araç taraması yapar.
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

  // ── 🎨 KURUMSAL TASARIM DOKTRİNİ ──
  static const Color _kuantumCyan = Color(0xFF005A64); // Primary Teal
  static const Color _matGrey = Colors.white; // Surface Color
  static const Color _kanKirmizi = Color(0xFFD32F2F); // Danger Red
  static const Color _textMain = Color(0xFF1E293B);
  static const Color _textMuted = Color(0xFF64748B);

  // ── 🚀 FİREBASE İSTİHBARAT ARAMA MOTORU ──
  Future<void> _siberSorguyuAtesle() async {
    String plaka = _plakaCtrl.text.trim().toUpperCase();
    String sase = _saseCtrl.text.trim().toUpperCase();

    if (plaka.isEmpty && sase.isEmpty) {
      _siberUyariGoster("SİSTEM UYARISI", "Tarama başlatmak için Plaka veya Şase numarası girilmelidir!", _kanKirmizi);
      return;
    }

    if (_islemSuruyor) return;
    setState(() => _islemSuruyor = true);

    developer.log("📡 DİJİTAL SORGULAMA: İstihbarat taraması başlatıldı. Hedef: ${plaka.isNotEmpty ? plaka : sase}");

    try {
      QuerySnapshot sorguSonucu;

      // Şase önceliklidir (Daha kesindir), Şase yoksa Plakadan arar
      if (sase.isNotEmpty) {
        sorguSonucu = await _db.collection('arac_kimlikleri').where('sase_no', isEqualTo: sase).limit(1).get();
      } else {
        sorguSonucu = await _db.collection('arac_kimlikleri').where('plaka', isEqualTo: plaka).limit(1).get();
      }

      if (sorguSonucu.docs.isNotEmpty) {
        developer.log("✅ HEDEF TESPİT EDİLDİ: Araç bulundu.");
        var aracVerisi = sorguSonucu.docs.first.data() as Map<String, dynamic>;

        _siberUyariGoster("HEDEF BULUNDU", "Araç Kurumsal kayıtlarda tespit edildi. Rapor hazırlanıyor...", _kuantumCyan);
      } else {
        developer.log("🚨 KAYIT YOK: Araç bulunamadı.");
        _siberUyariGoster("HEDEF BULUNAMADI", "Bu araç platforma henüz kayıt edilmemiş.", const Color(0xFFF57F17));
      }

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Sorgulama yapılamadı!", error: e);
      _siberUyariGoster("BAĞLANTI HATASI", "Kurumsal sunuculara ulaşılamıyor.", _kanKirmizi);
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
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: _textMain, fontSize: 12, fontFamily: 'Avenir')),
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
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: _matGrey,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30, offset: const Offset(0, 10))
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
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
                  Text("OTODNA DİJİTAL SORGULAMA", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2, fontFamily: 'Avenir')),
                ],
              ),
              const SizedBox(height: 24),
              formIcerigi,
            ],
          );
        },
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
          child: Text("VEYA", style: TextStyle(color: _textMuted, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12, fontFamily: 'Avenir')),
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
          child: Text("VEYA", style: TextStyle(color: _textMuted, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12, fontFamily: 'Avenir')),
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
        Text(baslik, style: const TextStyle(color: _textMuted, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6F8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.05), width: 1.5),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: _textMain, fontSize: 15, letterSpacing: 2, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              prefixIcon: Icon(ikon, color: _kuantumCyan, size: 22),
              hintText: ipucu,
              hintStyle: const TextStyle(color: _textMuted, letterSpacing: 1, fontSize: 13, fontFamily: 'Avenir'),
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
        icon: const Icon(Icons.manage_search, color: Colors.white, size: 24),
        label: const Text("ARACI BUL", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14, fontFamily: 'Avenir')),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kuantumCyan,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 10,
          shadowColor: _kuantumCyan.withOpacity(0.3),
        ),
        onPressed: _siberSorguyuAtesle,
      ),
    );
  }
}