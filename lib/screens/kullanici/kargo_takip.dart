// lib/screens/kullanici/kargo_takip.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ PLAZA LOJİSTİK VE KARGO TAKİBİ (SiberKargoTakipEkrani)
/// İlgili siparişin kargo durumunu canlı izler, Bayi ve Merkez (Admin) ile doğrudan hat kurar.
/// (Not: Bu bir Widget'tır, tam ekran değildir. Başka sayfaların içine gömülür.)
class SiberKargoTakipEkrani extends StatelessWidget {
  final String siparisId; // Takip edilecek siparişin kimliği

  const SiberKargoTakipEkrani({super.key, required this.siparisId});

  // ── 🚀 PLAZA İLETİŞİM TETİKLEYİCİLERİ ──
  void _bayiyeHatAc(BuildContext context, String bayiId) {
    HapticFeedback.heavyImpact();
    developer.log("📡 İLETİŞİM AĞI: $bayiId kodlu bayi ile doğrudan hat açılıyor...");
    _plazaUyariGoster(context, "BAYİ HATTI", "Bayi ile güvenli bağlantı kuruluyor...", Colors.teal.shade700);
  }

  void _merkezeBaglan(BuildContext context) {
    HapticFeedback.heavyImpact();
    developer.log("🚨 ACİL HAT: Doğrudan Plaza Merkezine bağlantı talebi!");
    _plazaUyariGoster(context, "MÜŞTERİ HİZMETLERİ", "OtoDNA Merkezine bağlanılıyor. Lütfen hatta kalın.", Colors.redAccent);
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _plazaUyariGoster(BuildContext context, String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryTeal = Colors.teal.shade700;
    final Color dangerColor = Colors.redAccent;
    final Color warningColor = Colors.orange;

    return StreamBuilder<DocumentSnapshot>(
      // 📡 Sipariş belgesini canlı dinliyoruz!
      stream: FirebaseFirestore.instance.collection('siparisler').doc(siparisId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 100,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black.withValues(alpha: 0.05))),
            child: Center(child: CircularProgressIndicator(color: primaryTeal)),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: dangerColor.withValues(alpha: 0.5)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)]),
            child: Text("SİSTEM İHLALİ: Kargo verisi bulunamadı!", style: TextStyle(color: dangerColor, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        String durum = data['kargo_durumu'] ?? "BİLİNMİYOR";
        String takipKodu = data['kargo_takip_kodu'] ?? "KOD BEKLENİYOR";
        String bayiId = data['bayi_id'] ?? "BILINMEYEN_BAYI";

        // Duruma göre otonom renk seçimi
        Color durumRengi = (durum == "YOLDA" || durum == "TESLİM EDİLDİ") ? primaryTeal : warningColor;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5)),
              ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("LOJİSTİK DURUMU", style: TextStyle(color: Colors.black45, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                      const SizedBox(height: 4),
                      Text(durum.toUpperCase(), style: TextStyle(color: durumRengi, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1, fontFamily: 'Avenir')),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: primaryTeal.withValues(alpha: 0.2))),
                    child: Row(
                      children: [
                        Icon(Icons.qr_code_scanner, color: primaryTeal, size: 18),
                        const SizedBox(width: 8),
                        Text(takipKodu, style: TextStyle(color: const Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, fontFamily: 'Avenir')),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Divider(color: Colors.black.withValues(alpha: 0.05), height: 1),
              ),

              Row(
                children: [
                  _buildPlazaIletisimButonu(
                      metin: "BAYİYE YAZ",
                      ikon: Icons.store_mall_directory_outlined,
                      renk: primaryTeal,
                      onTap: () => _bayiyeHatAc(context, bayiId)
                  ),
                  const SizedBox(width: 12),
                  _buildPlazaIletisimButonu(
                      metin: "MÜŞTERİ HİZMETLERİ",
                      ikon: Icons.support_agent_outlined,
                      renk: dangerColor,
                      onTap: () => _merkezeBaglan(context)
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlazaIletisimButonu({required String metin, required IconData ikon, required Color renk, required VoidCallback onTap}) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(ikon, size: 18, color: renk),
        label: Text(metin, style: TextStyle(color: renk, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5, fontFamily: 'Avenir'), textAlign: TextAlign.center),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: renk.withValues(alpha: 0.5), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: renk.withValues(alpha: 0.05),
        ),
      ),
    );
  }
}