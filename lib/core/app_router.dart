// lib/core/app_router.dart
import 'package:flutter/material.dart';

// 🔥 SİBER TERMİNALLERİN KÖPRÜLERİ
import '../auth/otodna_auth_gate.dart';
import '../screens/login_screen.dart';
import '../screens/siber_kokpit_screen.dart';
import '../screens/arac_kayit_screen.dart';
import '../screens/siber_market_vitrini.dart';
import '../screens/siber_sepet_ekrani.dart';
import '../screens/sos_protokolu_screen.dart';
import '../screens/usta_arama_screen.dart';
import '../screens/usta_panel_screen.dart';
import '../screens/super_admin_screen.dart';
import '../screens/support_screen.dart';
import '../screens/dil_secim_terminali.dart'; // ✅ YENİ EKLENDİ
import '../bayi/bayi_merkez.dart';
import '../bayi/belge_dogrulama.dart';

// 🚀 SONRADAN İNŞA EDİLEN SİBER MODÜLLER
import '../screens/wallet_screen.dart';
import '../screens/yedek_parca_ilan_ver_screen.dart';
import '../screens/sohbet_listesi_screen.dart';
import '../screens/sohbet_ekrani.dart';
import '../screens/siber_goz_terminali.dart';
import '../screens/surus_asistani_screen.dart';
import '../screens/sorgu_sonuc_sayfasi.dart';
import '../screens/yedek_parca_vitrini.dart';
import '../screens/yorum_yap_screen.dart';

class KuantumRota {
  static Route<dynamic> atesle(RouteSettings settings) {
    // 🧠 Argümanları (Sayfalar arası taşınan verileri) yakalamak için zırh
    final args = settings.arguments as Map<String, dynamic>? ?? {};

    switch (settings.name) {
    // ── ANA GÜVENLİK VE GİRİŞ KAPILARI ──
      case '/':
        return MaterialPageRoute(builder: (_) => const OtoDnaAuthGate());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/dil_secimi': // ✅ SİBER DİL KÖPRÜSÜ AKTİF EDİLDİ
        return MaterialPageRoute(builder: (_) => const DilSecimTerminali());

    // ── ANA KOKPİTLER VE PANELLER ──
      case '/kokpit':
        return MaterialPageRoute(builder: (_) => const SiberKokpitScreen());
      case '/super_admin':
        return MaterialPageRoute(builder: (_) => const SuperAdminScreen());
      case '/usta_paneli':
        return MaterialPageRoute(builder: (_) => const UstaPanelScreen());
      case '/bayi_merkez':
        return MaterialPageRoute(
          builder: (_) => BayiMerkezi(bayiId: args['bayiId'] ?? ''),
        );
      case '/belge_dogrulama':
        return MaterialPageRoute(
          builder: (_) => BelgeDogrulama(bayiId: args['bayiId'] ?? ''),
        );

    // ── ARAÇ VE BİLGİ MERKEZLERİ ──
      case '/arac_kayit':
        return MaterialPageRoute(builder: (_) => const AracKayitScreen());
      case '/siber_goz':
        return MaterialPageRoute(builder: (_) => const SiberGozTerminali());
      case '/sorgu_sonuc':
        return MaterialPageRoute(
          builder: (_) => SorguSonucSayfasi(
            sonuclar: args['sonuclar'] ?? {},
            saseNo: args['saseNo'] ?? 'BILINMEYEN_SASE',
          ),
        );
      case '/surus_asistani':
        return MaterialPageRoute(
          builder: (_) => SurusAsistaniScreen(
            aracId: args['aracId'] ?? 'BILINMEYEN_ID',
            plaka: args['plaka'] ?? 'PLAKA YOK',
          ),
        );

    // ── TİCARET VE FİNANS AĞI ──
      case '/market':
        return MaterialPageRoute(builder: (_) => const SiberMarketVitrini());
      case '/sepet':
        return MaterialPageRoute(builder: (_) => const SiberSepetEkrani());
      case '/ilan_ver':
        return MaterialPageRoute(builder: (_) => const YedekParcaIlanVerScreen());
      case '/cuzdan':
        return MaterialPageRoute(builder: (_) => const WalletScreen());
      case '/yedek_parca_vitrini':
        return MaterialPageRoute(
          builder: (_) => YedekParcaVitriniScreen(
            aracId: args['aracId'] ?? 'BILINMEYEN_ARAC',
          ),
        );

    // ── SİBER İLETİŞİM VE DESTEK TÜNELLERİ ──
      case '/sohbet_listesi':
        return MaterialPageRoute(builder: (_) => const SohbetListesiScreen());
      case '/sohbet_ekrani':
        return MaterialPageRoute(
          builder: (_) => SohbetEkrani(
            karsiTarafId: args['karsiTarafId'] ?? '',
            karsiTarafIsim: args['karsiTarafIsim'] ?? 'Bilinmeyen',
          ),
        );
      case '/usta_arama':
        return MaterialPageRoute(builder: (_) => const UstaAramaScreen());
      case '/destek':
        return MaterialPageRoute(builder: (_) => const SupportScreen());
      case '/yorum_yap':
        return MaterialPageRoute(
          builder: (_) => YorumYapScreen(
            firmaId: args['firmaId'] ?? 'FİRMA_001',
            firmaAdi: args['firmaAdi'] ?? 'HEDEF FİRMA',
            islemId: args['islemId'] ?? 'SRV-2026-000',
          ),
        );

    // ── ACİL DURUM VE S.O.S PROTOKOLLERİ ──
      case '/sos_merkezi':
        return MaterialPageRoute(builder: (_) => const SosProtokoluScreen());

    // ── SİBER İHLAL (BİLİNMEYEN ROTA) KALKANI ──
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                "SİBER İHLAL: ROTA BULUNAMADI (${settings.name})",
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Avenir',
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        );
    }
  }
}