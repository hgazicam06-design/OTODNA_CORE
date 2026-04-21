import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 🚀 KARARGAHIN GERÇEK CEPHE KÖPRÜLERİ (Hatasız Import Yolları)
import '../../screens/home_screen.dart';
import '../../screens/dashboard/dealer_dashboard.dart';

// 🔥 SİBER DÜZELTME: 'lib' kelimesi yoldan çıkartıldı. Doğrudan market klasörüne inildi!
import '../../market/oto_market_screen.dart';

/// 🛰️ OTODNA KUANTUM YÖNLENDİRME ZIRHI
/// Tek Domain üzerinden Web/Mobil pürüzsüz geçiş sağlar.
class SiberRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // Siber terminalden rotaları izlemek için aktif
    routes: [
      // 🦅 ANA KARARGAH (Sivil Giriş Ekranı)
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),

      // 🛍️ OTOMARKET BOYUTU
      GoRoute(
        path: '/market',
        builder: (context, state) => const OtoMarketScreen(),
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
          body: Center(
              child: Text(
                  "OtoDNA GALERİ - YAKINDA",
                  style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)
              )
          ),
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
              "SİBER HATA: ROTA BULUNAMADI\n${state.error}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FFC2),
                foregroundColor: Colors.black,
              ),
              onPressed: () => context.go('/'),
              child: const Text("MERKEZE DÖN", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    ),
  );
}