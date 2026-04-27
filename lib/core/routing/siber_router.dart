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

// 🔥 KUANTUM AĞI - YENİ ENTEGRE EDİLEN EKRANLAR
import '../../screens/kullanici/siber_radar_screen.dart';
import '../../screens/kullanici/siber_sos_merkezi_screen.dart';
import '../../screens/kullanici/tuvturk_randevu_screen.dart';
import '../../screens/kullanici/yedek_parca_market_screen.dart';
import '../../screens/kullanici/yol_bilgisayari_screen.dart';
import '../../screens/kurumsal/kurumsal_baglayicilar_screen.dart';

// Mevcut SiberRouter Yolları (Home & Dashboard)
import '../../screens/home_screen.dart';
import '../../screens/dashboard/dealer_dashboard.dart';
import '../../market/oto_market_screen.dart';

// 💎 FİLDİŞİ SEDEF & PLAZA EKRANLARI (YENİ EKLENENLER)
import '../../screens/musteri/musteri_harita_screen.dart';
import '../../screens/musteri/musteri_garaj_screen.dart';
import '../../screens/musteri/qr_kimlik_screen.dart';
import '../../screens/musteri/home_page.dart';
import '../../screens/qr/kargo_teslimat_qr_screen.dart';
import '../../screens/qr/qr_matbaa_screen.dart';
import '../../screens/qr/vatandas_qr_iletisim_screen.dart';
import '../../screens/market/siber_ikinci_el_market.dart';
import '../../screens/market/siber_ilan_detay_screen.dart';
import '../../screens/market/siber_ilan_ver_terminali.dart';
import '../../screens/muayene/dijital_muayene_terminali.dart';
import '../../screens/lojistik/otodna_cigir_screen.dart';
import '../../screens/lojistik/surucu_kokpiti_screen.dart';
import '../../models/car_ad_model.dart'; // SiberIlanDetayScreen için gerekli

/// 🛰️ OTODNA KUANTUM YÖNLENDİRME ZIRHI
/// Tek Domain üzerinden Web/Mobil pürüzsüz geçiş sağlar.
class SiberRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // Siber terminalden rotaları izlemek için aktif
    routes: [
      // 🦅 ANA KARARGAH (Sivil Giriş Ekranı - Aslında Auth Gate)
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
        path: '/oto_market',
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
      GoRoute(
        path: '/siber_sos',
        builder: (context, state) => const SiberSosMerkeziScreen(),
      ),

      // ── YENİ KUANTUM EKRANLARI ──
      GoRoute(
        path: '/siber_radar',
        builder: (context, state) => const SiberRadarScreen(),
      ),
      GoRoute(
        path: '/tuvturk_randevu',
        builder: (context, state) => const TuvturkRandevuScreen(),
      ),
      GoRoute(
        path: '/yedek_parca_ag',
        builder: (context, state) => const YedekParcaMarketScreen(),
      ),
      GoRoute(
        path: '/yol_bilgisayari',
        builder: (context, state) => const YolBilgisayariScreen(),
      ),
      GoRoute(
        path: '/kurumsal_baglayicilar',
        builder: (context, state) => const KurumsalBaglayicilarScreen(),
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

      // ── 💎 YENİ FİLDİŞİ SEDEF VE PLAZA ROTALARI ──
      GoRoute(
        path: '/musteri_harita',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return MusteriHaritaScreen(ilkAramaKelimesi: args['ilkAramaKelimesi']);
        },
      ),
      GoRoute(
        path: '/musteri_garaj',
        builder: (context, state) => const MusteriGarajScreen(),
      ),
      GoRoute(
        path: '/qr_kimlik',
        builder: (context, state) => const QrKimlikScreen(),
      ),
      GoRoute(
        path: '/home_page_design',
        builder: (context, state) => const HomePageDesign(),
      ),
      GoRoute(
        path: '/kargo_qr',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return KargoTeslimatQrScreen(kullaniciId: args['kullaniciId'] ?? 'BİLİNMEYEN_KULLANICI');
        },
      ),
      GoRoute(
        path: '/qr_matbaa',
        builder: (context, state) => const QrMatbaaScreen(),
      ),
      // 🌐 WEB DEEP LINK: Vatandaşın normal kamerasıyla okutacağı QR URL'i
      GoRoute(
        path: '/qr/:plaka',
        builder: (context, state) {
          final plaka = state.pathParameters['plaka'] ?? 'BİLİNMİYOR';
          // Not: Gerçek senaryoda plaka ile Firestore'dan araç sahibini çeken bir FutureBuilder eklenebilir.
          // Şimdilik siber kalkan devreye girip anonim bilgileri dolduruyor.
          return VatandasQrIletisimScreen(
            hedefPlaka: plaka,
            hedefSahipId: 'ANONIM_SAHIP_ID',
            hedefSahipAdSoyad: 'GİZLİ ARAÇ SAHİBİ',
          );
        },
      ),
      GoRoute(
        path: '/ikinci_el_market',
        builder: (context, state) => const SiberIkinciElMarket(),
      ),
      GoRoute(
        path: '/ilan_detay',
        builder: (context, state) {
          final ad = state.extra as CarAd;
          return SiberIlanDetayScreen(ad: ad);
        },
      ),
      GoRoute(
        path: '/ilan_ver_terminali',
        builder: (context, state) => const SiberIlanVerTerminali(),
      ),
      GoRoute(
        path: '/dijital_muayene',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          return DijitalMuayeneTerminali(
            aracId: args['aracId'] ?? 'BİLİNMEYEN_ARAC',
            plaka: args['plaka'] ?? 'PLAKA YOK',
          );
        },
      ),
      GoRoute(
        path: '/cigir_yolcu',
        builder: (context, state) => const OtoDnaCigirScreen(),
      ),
      GoRoute(
        path: '/surucu_kokpiti',
        builder: (context, state) => const SurucuKokpitiScreen(),
      ),
    ],
    // ⚠️ KOORDİNAT HATASI (404) DURUMUNDA DEVREYE GİREN SİBER KALKAN
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
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
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
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