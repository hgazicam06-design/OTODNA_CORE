import 'package:otodna/core/siber_tema.dart';
// lib/core/siber_yetki_kalkani.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🔥 DÜZELTİLEN SİBER KÖPRÜLER
import 'providers/siber_kimlik_provider.dart';
import 'siber_tema.dart';

/// 🛡️ KUANTUM YETKİ VE KISITLAMA MATRİSİ
/// Hangi eylemlerin kilitlenebilir olduğunu belirler.
enum SiberYetki {
  aracEkle,      // 🟢 Her zaman serbest (Aracını eklesin, Garajı kullansın)
  alisverisYap,  // 🟢 Her zaman serbest (Teklif istesin, parça alsın)
  randevuAl,     // 🟢 Her zaman serbest (Ama usta adamın kısıtlı olduğunu görecek)
  yorumYap,      // 🔴 Kara listedeyse YASAK!
  forumKatil,    // 🔴 Kara listedeyse YASAK! (Sohbete/Foruma giremez)
  ilanVer,       // 🔴 Kara listedeyse YASAK! (Satılık Araç veya Parça ekleyemez)
  vitrinAc       // 🔴 Kara listedeyse YASAK! (Bayi paneli kullanamaz)
}

/// 🛡️ HAYALET MODU (GHOST MODE) KALKANI
/// Herhangi bir butonu veya ekranı bu widget ile sarmalarsan, kullanıcının
/// siciline bakar. Eğer kara listedeyse o butonu anında kan kırmızısı bir kilide dönüştürür.
class SiberYetkiKalkani extends ConsumerWidget {
  final SiberYetki islemTuru;
  final Widget child; // İzin varsa gösterilecek orijinal ekran veya buton
  final bool isButtonMode; // Sadece butonu mu kilitleyeceğiz yoksa tüm ekranı mı?

  SiberYetkiKalkani({
    super.key,
    required this.islemTuru,
    required this.child,
    this.isButtonMode = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Karargah Nöbetçisinden adamın sicilini çek (.snapshots sayesinde anlık güncellenir)
    final sicil = ref.watch(siberSicilProvider).value;

    if (sicil == null) return SizedBox();

    // 2. Kullanıcının durumu 'KARA_LISTE' veya 'KISITLI' ise yakala
    bool isKisitli = sicil['hesap_durumu'] == 'KARA_LISTE' || sicil['hesap_durumu'] == 'KISITLI';

    // 3. Karargah Kararı: Bu işlem kısıtlı bir kullanıcıya yasak mı?
    bool islemYasakliMi = false;
    if (isKisitli) {
      if (islemTuru == SiberYetki.yorumYap ||
          islemTuru == SiberYetki.forumKatil ||
          islemTuru == SiberYetki.ilanVer ||
          islemTuru == SiberYetki.vitrinAc) {
        islemYasakliMi = true; // Sesi kesildi, kilit vuruldu!
      }
    }

    // 4. İhlal yoksa (veya Alışveriş gibi serbest bir işlemse) orijinal widget'ı göster
    if (!islemYasakliMi) {
      return child;
    }

    // 5. 🛑 İHLAL VAR VE İŞLEM YASAKLI! KİLİT SİSTEMİNİ DEVREYE SOK
    return isButtonMode ? _buildKilitliButon() : _buildKilitliEkran();
  }

  // 🔒 YASAKLI BUTON (Örn: Randevu Al butonu yerine bu çıkar)
  Widget _buildKilitliButon() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: SiberTema.kanKirmizi.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, color: SiberTema.kanKirmizi, size: 20),
          SizedBox(width: 10),
          Text(
            "SİBER KİLİT: YETKİ YOK",
            style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir', fontSize: 12),
          ),
        ],
      ),
    );
  }

  // 🛑 YASAKLI EKRAN (Örn: İlan Verme Sayfasına girmeye çalışırsa bu çıkar)
  Widget _buildKilitliEkran() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24),
        margin: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: SiberTema.kanKirmizi.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: SiberTema.kanKirmizi, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.gavel_rounded, color: SiberTema.kanKirmizi, size: 60),
            SizedBox(height: 16),
            Text("KARARGAH KISITLAMASI", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
            SizedBox(height: 12),
            Text(
              "Hesabınız Karargah kuralları ihlali sebebiyle 'KISITLI' duruma düşürülmüştür. OtoDNA ağında araç satışı yapamaz, vitrin açamaz ve yorum bırakamazsınız. Sadece yedek parça mağazasını ve kendi araç profilinizi kullanabilirsiniz.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, height: 1.5, fontFamily: 'Avenir'),
            ),
          ],
        ),
      ),
    );
  }
}