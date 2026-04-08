import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 🛰️ DİKKAT: Bu importların çalışması için dosyaların belirtilen klasörlerde olması şarttır!
import '../../screens/market/urun_giris_terminali.dart';
import '../../../uploaded/home_screen.dart'; // Eğer ana sayfa buradaysa yolu kontrol et
import '../../../uploaded/dealer_dashboard.dart'; // Bayi Paneli

/// 🛰️ OTODNA KUANTUM YÖNLENDİRME ZIRHI
/// Tek Domain üzerinden Web/Mobil pürüzsüz geçiş sağlar.
class SiberRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // Siber terminalden rotaları izlemek için aktif
    routes: [
      // 🦅 ANA KARARGAH (Ana Ekran)
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text("OtoDNA SİBER MERKEZ YÜKLENİYOR...", style: TextStyle(color: Color(0xFF00FFC2)))),
        ),
      ),

      // 🛍️ OTOMARKET BOYUTU
      GoRoute(
        path: '/market',
        builder: (context, state) => const UrunGirisTerminali(),
        routes: [
          // Alt Rota: urun-ekle (Web'de: domain.com/market/urun-ekle)
          GoRoute(
            path: 'urun-ekle',
            builder: (context, state) => const UrunGirisTerminali(),
          ),
        ],
      ),

      // 🏢 BAYİ PANELİ (Dealer Dashboard)
      GoRoute(
        path: '/bayi-paneli',
        builder: (context, state) => const DealerDashboard(),
      ),

      // 🚗 OTOGALERİ BOYUTU
      GoRoute(
        path: '/galeri',
        builder: (context, state) => const Scaffold(
          backgroundColor: Color(0xFF000000),
          body: Center(child: Text("OtoDNA GALERİ - YAKINDA", style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold))),
        ),
      ),
    ],
    // ⚠️ KOORDİNAT HATASI (404) DURUMUNDA DEVREYE GİREN SİBER KALKAN
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 80),
            const SizedBox(height: 20),
            Text(
              "SİBER HATA: ${state.error}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text("MERKEZE DÖN"),
            )
          ],
        ),
      ),
    ),
  );
}