import 'package:flutter/material.dart';

// 🔥 SİBER TERMİNALLERİN KÖPRÜLERİ
import '../auth/otodna_auth_gate.dart';
import '../screens/login_screen.dart';
import '../screens/auth/siber_kayit_screen.dart';
import '../screens/auth/siber_sms_screen.dart';
import '../screens/auth/sifre_sifirla_screen.dart';
import '../screens/auth/two_factor_auth_screen.dart';
import '../screens/siber_kokpit_screen.dart';
import '../screens/arac_kayit_screen.dart';
import '../screens/siber_market_vitrini.dart';
import '../screens/siber_sepet_ekrani.dart';
import '../screens/siber_sos_merkezi.dart';
import '../screens/sos_protokolu_screen.dart';
import '../screens/usta_arama_screen.dart';
import '../screens/usta_panel_screen.dart';
import '../admin/super_admin_screen.dart';
import '../screens/support_screen.dart';

// 🚀 SONRADAN İNŞA EDİLEN SİBER MODÜLLER (YENİ EKLENDİ)
import '../screens/wallet_screen.dart';
import '../screens/yedek_parca_ilan_ver_screen.dart';
import '../screens/sohbet_listesi_screen.dart';
import '../screens/sohbet_ekrani.dart';
import '../screens/siber_goz_terminali.dart';
import '../screens/surus_asistani_screen.dart';
import '../screens/torpido_ekleme_screen.dart';
import '../screens/sorgu_sonuc_sayfasi.dart';
import '../screens/yedek_parca_vitrini.dart'; // 🛡️ YENİ EKLENDİ
import '../screens/yorum_yap_screen.dart'; // 🛡️ YENİ EKLENDİ

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
      case '/kayit':
        return MaterialPageRoute(builder: (_) => const SiberKayitScreen());
      case '/sms_dogrulama':
        return MaterialPageRoute(builder: (_) => const SiberSmsScreen());
      case '/sifre_sifirla':
        return MaterialPageRoute(builder: (_) => const SifreSifirlaScreen());
      case '/2fa':
        return MaterialPageRoute(builder: (_) => const TwoFactorAuthScreen());

    // ── ANA KOKPİTLER VE PANELLER ──
      case '/kokpit':
        return MaterialPageRoute(builder: (_) => const SiberKokpitScreen());
      case '/super_admin':
        return MaterialPageRoute(builder: (_) => const SuperAdminScreen());
      case '/usta_paneli':
        return MaterialPageRoute(builder: (_) => const UstaPanelScreen());

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
      case '/torpido_ekleme':
        return MaterialPageRoute(
          builder: (_) => TorpidoEklemeScreen(
            kullaniciId: args['kullaniciId'] ?? 'BILINMEYEN_KULLANICI',
            aracId: args['aracId'] ?? 'BILINMEYEN_ARAC',
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
      case '/yedek_parca_vitrini': // 🛡️ YENİ KÖPRÜ
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
      case '/yorum_yap': // 🛡️ YENİ KÖPRÜ
        return MaterialPageRoute(
          builder: (_) => YorumYapScreen(
            firmaId: args['firmaId'] ?? 'FİRMA_001',
            firmaAdi: args['firmaAdi'] ?? 'HEDEF FİRMA',
            islemId: args['islemId'] ?? 'SRV-2026-000',
          ),
        );

    // ── ACİL DURUM VE S.O.S PROTOKOLLERİ ──
      case '/sos_merkezi':
      // En gelişmiş, 5 Saniye Radarlı SOS Protokolüne bağlandı!
        return MaterialPageRoute(builder: (_) => const SosProtokoluScreen());

    // ── SİBER İHLAL (BİLİNMEYEN ROTA) KALKANI ──
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                "SİBER İHLAL: ROTA BULUNAMADI (${settings.name})",
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 2),
              ),
            ),
          ),
        );
    }
  }
}