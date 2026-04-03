// lib/screens/kargo_takip.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM LOJİSTİK VE KARGO RADARI (SiberKargoTakipEkrani)
/// İlgili siparişin kargo durumunu canlı izler, Bayi ve Merkez Karargah (Admin) ile doğrudan siber hat kurar.
class SiberKargoTakipEkrani extends StatelessWidget {
  final String siparisId; // Takip edilecek siparişin Karargah kimliği

  const SiberKargoTakipEkrani({super.key, required this.siparisId});

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  // ── 🚀 SİBER HAT TETİKLEYİCİLERİ ──
  void _bayiyeSiberHatAc(BuildContext context, String bayiId) {
    HapticFeedback.heavyImpact();
    developer.log("📡 İLETİŞİM AĞI: $bayiId kodlu bayi ile doğrudan hat açılıyor...");
    // SİBER NOT: Navigator.push ile sohbet ekranına yönlendirme
    _siberUyariGoster(context, "BAYİ HATTI", "Bayi ile kriptolu bağlantı kuruluyor...", _kuantumCyan);
  }

  void _karargahaBaglan(BuildContext context) {
    HapticFeedback.heavyImpact();
    developer.log("🚨 ACİL HAT: Doğrudan Merkez Karargaha (Gazi'ye) bağlantı talebi!");
    _siberUyariGoster(context, "MERKEZ KARARGAH", "Gazi Komutaya bağlanılıyor. Lütfen hatta kalın.", Colors.redAccent);
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(BuildContext context, String baslik, String mesaj, Color renk) {
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
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      // 📡 SİBER NOT: Sipariş belgesini canlı dinliyoruz!
      stream: FirebaseFirestore.instance.collection('siparisler').doc(siparisId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 100,
            decoration: BoxDecoration(color: _matGrey, borderRadius: BorderRadius.circular(16)),
            child: const Center(child: CircularProgressIndicator(color: _kuantumCyan)),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _matGrey, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
            child: const Text("SİBER İHLAL: Kargo verisi bulunamadı!", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        String durum = data['kargo_durumu'] ?? "BİLİNMİYOR";
        String takipKodu = data['kargo_takip_kodu'] ?? "KOD BEKLENİYOR";
        String bayiId = data['bayi_id'] ?? "BILINMEYEN_BAYI";

        // Duruma göre otonom renk seçimi
        Color durumRengi = (durum == "YOLDA" || durum == "TESLİM EDİLDİ") ? _kuantumCyan : Colors.orangeAccent;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: _matGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kuantumCyan.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(color: _kuantumCyan.withOpacity(0.05), blurRadius: 20, spreadRadius: 2),
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
                      const Text("LOJİSTİK DURUMU", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(durum.toUpperCase(), style: TextStyle(color: durumRengi, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: _kuantumCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: _kuantumCyan.withOpacity(0.5))),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_scanner, color: _kuantumCyan, size: 16),
                        const SizedBox(width: 8),
                        Text(takipKodu, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                      ],
                    ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: Colors.white24, height: 1),
              ),

              Row(
                children: [
                  _buildSiberIletisimButonu(
                      metin: "BAYİYE YAZ",
                      ikon: Icons.store_mall_directory_outlined,
                      renk: Colors.white,
                      onTap: () => _bayiyeSiberHatAc(context, bayiId)
                  ),
                  const SizedBox(width: 12),
                  _buildSiberIletisimButonu(
                      metin: "KARARGAHA BAĞLAN",
                      ikon: Icons.support_agent_outlined,
                      renk: Colors.redAccent, // Admin hattı her zaman kırmızıdır!
                      onTap: () => _karargahaBaglan(context)
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildSiberIletisimButonu({required String metin, required IconData ikon, required Color renk, required VoidCallback onTap}) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(ikon, size: 18, color: renk),
        label: Text(metin, style: TextStyle(color: renk, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: renk.withOpacity(0.5), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: renk.withOpacity(0.05),
        ),
      ),
    );
  }
}