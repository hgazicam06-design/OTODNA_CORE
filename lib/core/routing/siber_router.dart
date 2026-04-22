// lib/core/routing/siber_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 🔥 SİBER TERMİNALLERİN KÖPRÜLERİ (Gerçek İçe Aktarım Yolları)
import '../../auth/otodna_auth_gate.dart';
import '../../screens/login_screen.dart';
import '../../screens/siber_kokpit_screen.dart';
import '../../screens/arac_kayit_screen.dart';
import '../../screens/siber_market_vitrini.dart';
import '../../screens/siber_sepet_ekrani.dart';
import '../../screens/sos_protokolu_screen.dart';
import '../../screens/usta_arama_screen.dart';
import '../../screens/usta_panel_screen.dart';
import '../../screens/super_admin_screen.dart';
import '../../screens/support_screen.dart';
import '../../screens/dil_secim_terminali.dart';
import '../../bayi/bayi_merkez.dart';
import '../../bayi/belge_dogrulama.dart';

// 🚀 SONRADAN İNŞA EDİLEN SİBER MODÜLLER
import '../../screens/wallet_screen.dart';
import '../../screens/yedek_parca_ilan_ver_screen.dart';
import '../../screens/sohbet_listesi_screen.dart';
import '../../screens/sohbet_ekrani.dart';
import '../../screens/siber_goz_terminali.dart';
import '../../screens/surus_asistani_screen.dart';
import '../../screens/sorgu_sonuc_sayfasi.dart';
import '../../screens/yedek_parca_vitrini.dart';
import '../../screens/yorum_yap_screen.dart';

// Mevcut SiberRouter Yolları (Home & Dashboard)
import '../../screens/home_screen.dart';
import '../../screens/dashboard/dealer_dashboard.dart';
import '../../market/oto_market_screen.dart';

/// 🛰️ OTODNA KUANTUM YÖNLENDİRME ZIRHI
/// Tek Domain üzerinden Web/Mobil pürüzsüz geçiş sağlar.
class SiberRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // Siber terminalden rotaları izlemek için aktif
    routes: [
      // 🦅 ANA KARARGAH (Sivil Giriş Ekranı - Aslında Auth Gate)
      // DİKKAT: Sistemin güvenliği için ana giriş Auth Gate olmalıdır.
      GoRoute(
        path: '/',
        builder: (context, state) => const OtoDnaAuthGate(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dil_secimi',
        builder: (context, state) => const DilSecimTerminali(),
      ),

      // ── ANA KOKPİTLER VE PANELLER ──
      GoRoute(
        path: '/kokpit',
        builder: (context, state) => const SiberKokpitScreen(),
      ),
      GoRoute(
        path: '/super_admin',
        builder: (context, state) => const SuperAdminScreen(),
      ),
      GoRoute(
        path: '/usta_paneli',
        builder: (context, state) => const UstaPanelScreen(),
      ),
      GoRoute(
        path: '/bayi_merkez',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return BayiMerkezi(bayiId: args['bayiId'] ?? '');
        },
      ),
      GoRoute(
        path: '/belge_dogrulama',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return BelgeDogrulama(bayiId: args['bayiId'] ?? '');
        },
      ),

      // ── ARAÇ VE BİLGİ MERKEZLERİ ──
      GoRoute(
        path: '/arac_kayit',
        builder: (context, state) => const AracKayitScreen(),
      ),
      GoRoute(
        path: '/siber_goz',
        builder: (context, state) => const SiberGozTerminali(),
      ),
      GoRoute(
        path: '/sorgu_sonuc',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return SorguSonucSayfasi(
            sonuclar: args['sonuclar'] ?? {},
            saseNo: args['saseNo'] ?? 'BILINMEYEN_SASE',
          );
        },
      ),
      GoRoute(
        path: '/surus_asistani',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return SurusAsistaniScreen(
            aracId: args['aracId'] ?? 'BILINMEYEN_ID',
            plaka: args['plaka'] ?? 'PLAKA YOK',
          );
        },
      ),

      // ── TİCARET VE FİNANS AĞI ──
      GoRoute(
        path: '/market',
        builder: (context, state) => const SiberMarketVitrini(),
      ),
      GoRoute(
        path: '/oto_market', // Eski siber_router'dan gelen OtoMarketScreen
        builder: (context, state) => const OtoMarketScreen(),
      ),
      GoRoute(
        path: '/sepet',
        builder: (context, state) => const SiberSepetEkrani(),
      ),
      GoRoute(
        path: '/ilan_ver',
        builder: (context, state) => const YedekParcaIlanVerScreen(),
      ),
      GoRoute(
        path: '/cuzdan',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/yedek_parca_vitrini',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return YedekParcaVitriniScreen(
            aracId: args['aracId'] ?? 'BILINMEYEN_ARAC',
          );
        },
      ),

      // ── SİBER İLETİŞİM VE DESTEK TÜNELLERİ ──
      GoRoute(
        path: '/sohbet_listesi',
        builder: (context, state) => const SohbetListesiScreen(),
      ),
      GoRoute(
        path: '/sohbet_ekrani',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return SohbetEkrani(
            karsiTarafId: args['karsiTarafId'] ?? '',
            karsiTarafIsim: args['karsiTarafIsim'] ?? 'Bilinmeyen',
          );
        },
      ),
      GoRoute(
        path: '/usta_arama',
        builder: (context, state) => const UstaAramaScreen(),
      ),
      GoRoute(
        path: '/destek',
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: '/yorum_yap',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return YorumYapScreen(
            firmaId: args['firmaId'] ?? 'FİRMA_001',
            firmaAdi: args['firmaAdi'] ?? 'HEDEF FİRMA',
            islemId: args['islemId'] ?? 'SRV-2026-000',
          );
        },
      ),

      // ── ACİL DURUM VE S.O.S PROTOKOLLERİ ──
      GoRoute(
        path: '/sos_merkezi',
        builder: (context, state) => const SosProtokoluScreen(),
      ),

      // ── EKSTRA (Eski siber_router'dan kalanlar) ──
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/bayi-paneli',
        builder: (context, state) => const DealerDashboard(),
      ),
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
              "SİBER İHLAL: ROTA BULUNAMADI\n(${state.uri.toString()})",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w900,
                fontFamily: 'Avenir',
                letterSpacing: 2,
              ),
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