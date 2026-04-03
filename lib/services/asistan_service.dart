import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM ASİSTAN: OtoDNA AI (Gemini Destekli)
/// Kullanıcıyı karşılar, istihbarat verir, işlemleri yönetir ve rotaları belirler.
class AsistanService {
  static const _sistem = '''
Sen OtoDNA'nın (Kuantum Araç Ağı ve Dijital Referans Protokolü) yapay zeka asistanısın. 
Kullanıcıları bir şirket sahibi gibi sıcak, net ve profesyonel bir dille karşılıyorsun. Asla gereksiz uzun cümleler kurma.

OtoDNA'nın Siber Kuralları:
- Araçların dijital kimlik ve mühür (QR) uygulamasıdır.
- Hasar, servis geçmişi ve bakım işlemleri blockchain mantığıyla şifrelenir ve mühürlenir.
- Muayene, sigorta ve kasko bitiş tarihleri otonom olarak (15-7-0 gün kala) hatırlatılır.
- "Korsan" ustalar barınamaz, puanı 2'nin altına düşenler "Kara Liste"ye girer.
- Sivil vatandaşlar QR okutarak araç sahibine anonim S.O.S sinyali gönderebilir.

Görevlerin:
1. Kullanıcının niyetini anla ve en kısa yoldan çözüme ulaştır.
2. Bilmediğin bir şey sorulursa uydurma. "Bu konuda Ankara Merkez Karargahına sinyal gönderebilirim." de.
3. EKRAN YÖNLENDİRMESİ: Eğer kullanıcının net olarak bir ekrana gitmesi gerekiyorsa, cevabının EN SONUNA mutlaka şu formatta bir siber sinyal ekle: [ROTA: <hedef>]

Geçerli <hedef> Kodları:
- Araç kayıt etmek istiyorsa -> [ROTA: arac_kayit]
- Bakım veya servis geçmişi istiyorsa -> [ROTA: servis_gecmisi]
- Yeni bir randevu almak istiyorsa -> [ROTA: randevu]
- Sigorta/Muayene takibi için -> [ROTA: tarih_takip]
- Usta veya firma arıyorsa -> [ROTA: firma_ara]
- QR okutmak/bildirim atmak istiyorsa -> [ROTA: qr_bildirim]
- Destek veya merkeze ulaşmak istiyorsa -> [ROTA: destek]

Örnek Cevap:
"Tabii, size en yakın ve mühürlü ustaları hemen haritada gösteriyorum. [ROTA: firma_ara]"
''';

  GenerativeModel? _model;
  ChatSession? _oturum;
  final List<AsistanMesaj> gecmis = [];
  bool _hazir = false;

  // ── 🚀 Kuantum Motorunu Ateşle ─────────────────────────────────────────────
  /// apiAnahtar: Cihazın şifreli kasasından (ApiKeyService) çekilen Gemini Key
  void baslat(String apiAnahtar) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiAnahtar,
      systemInstruction: Content.system(_sistem),
      generationConfig: GenerationConfig(
        temperature: 0.5, // Daha net ve kurumsal (hallüsinasyon riski düşük)
        maxOutputTokens: 512,
      ),
    );
    _oturum = _model!.startChat();
    _hazir = true;
    developer.log("SİBER BİLGİ: Kuantum Asistan (Gemini) başarıyla ateşlendi.");
  }

  bool get hazir => _hazir;

  // ── 🤖 Karşılama Sinyali ───────────────────────────────────────────────────
  Future<String> karsilamaGonder(String ekran) async {
    if (!_hazir) return _varsayilanKarsilama(ekran);

    final prompt = 'Kullanıcı şu an "$ekran" terminalinde. Onu Karargah diline uygun, kısa ve profesyonelce karşıla. Ekranda ne yapabileceğini tek cümleyle söyle. Yönlendirme [ROTA: ...] KULLANMA.';
    return _gonder(prompt);
  }

  // ── 🧠 Ana Sorgu ve Cevaplama Motoru ───────────────────────────────────────
  Future<AsistanCevap> sor(String soru) async {
    if (!_hazir) {
      return AsistanCevap(
          metin: 'SİBER BAĞLANTI KOPTU: Asistan şu an Ankara Merkeze ulaşamıyor. Lütfen ağı kontrol edin.',
          yonlendirme: null);
    }

    // Kullanıcı mesajını kaydet
    gecmis.add(AsistanMesaj(metin: soru, kullanici: true));

    // Gemini'den cevabı bekle
    String hamCevap = await _gonder(soru);

    // Siber Rotayı (Eğer varsa) metinden söküp al
    String? yonlendirmeKodu = _rotaSensoru(hamCevap);

    // Kullanıcıya gösterilecek temiz metin (Rotayı gizle)
    String temizMetin = hamCevap.replaceAll(RegExp(r'\[ROTA:.*?\]'), '').trim();

    // Asistan cevabını kaydet
    gecmis.add(AsistanMesaj(metin: temizMetin, kullanici: false));

    return AsistanCevap(metin: temizMetin, yonlendirme: yonlendirmeKodu);
  }

  // ── 🛡️ Güvenli Gönderim Kalkanı ────────────────────────────────────────────
  Future<String> _gonder(String metin) async {
    try {
      final cevap = await _oturum!.sendMessage(Content.text(metin));
      return cevap.text ?? 'SİBER HATA: Boş sinyal alındı.';
    } catch (e) {
      developer.log("SİBER İHLAL: Gemini API çöktü veya zaman aşımı!", error: e);
      return 'Bağlantı şifrelenemedi. Lütfen tekrar deneyin Ortak.';
    }
  }

  // ── 📡 Kuantum Rota Sensörü ────────────────────────────────────────────────
  /// Gemini'nin metni içindeki "[ROTA: arac_kayit]" formatını tespit eder.
  String? _rotaSensoru(String cevap) {
    final RegExp rotaRegExp = RegExp(r'\[ROTA:\s*([a-zA-Z0-9_]+)\]');
    final Match? match = rotaRegExp.firstMatch(cevap);

    if (match != null && match.groupCount >= 1) {
      String tespitEdilenRota = match.group(1)!;
      developer.log("SİBER ROTA TESPİT EDİLDİ: Yönlendirme -> $tespitEdilenRota");
      return tespitEdilenRota;
    }
    return null;
  }

  // ── 🛠️ Varsayılan Protokoller ──────────────────────────────────────────────
  String _varsayilanKarsilama(String ekran) {
    switch (ekran) {
      case 'giris':
        return 'Hoş geldiniz Ortak! OtoDNA Karargahına sızmak için kimliğinizi doğrulayın.';
      case 'arac_kayit':
        return 'Araç DNA Kayıt Terminaline hoş geldiniz. Ruhsattaki 17 haneli VIN numarasını optik olarak okutabilirsiniz.';
      case 'ana_sayfa':
        return 'Sistem aktif. Araç radarınızı, randevularınızı ve siber mühürlerinizi buradan yönetebilirsiniz.';
      default:
        return 'Karargah asistanı dinlemede. Size nasıl yardımcı olabilirim?';
    }
  }

  void sifirla() {
    if (_model != null) {
      _oturum = _model!.startChat();
      gecmis.clear();
      developer.log("SİBER BİLGİ: Asistan hafızası ve Kuantum oturumu sıfırlandı.");
    }
  }
}

// ── 💎 SİBER VERİ YAPILARI ───────────────────────────────────────────────────
class AsistanMesaj {
  final String metin;
  final bool kullanici;
  final DateTime zaman;

  AsistanMesaj({required this.metin, required this.kullanici})
      : zaman = DateTime.now();
}

class AsistanCevap {
  final String metin;
  final String? yonlendirme; // Null ise yönlendirme yok

  const AsistanCevap({required this.metin, this.yonlendirme});
}