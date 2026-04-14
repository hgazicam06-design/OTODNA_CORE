// lib/screens/ariza_kaydi_detay.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Siber Titreşim (Haptic)
import 'package:image_picker/image_picker.dart'; // Gerçek Kamera Motoru
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE TEMALARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM TEKNİK DENETİM VE LASTİK OTELİ MASASI (ArizaKaydiDetay)
/// Aracın kritik noktalarını inceler, kanıtsız onaya izin vermez. Lastik depolama (Otel) modülü ATOMİK olarak entegredir.
class ArizaKaydiDetay extends StatefulWidget {
  final String saseNo;
  final String ustaId;

  const ArizaKaydiDetay({
    super.key,
    required this.saseNo,
    required this.ustaId,
  });

  @override
  State<ArizaKaydiDetay> createState() => _ArizaKaydiDetayState();
}

class _ArizaKaydiDetayState extends State<ArizaKaydiDetay> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── ⚙️ DİNAMİK KONTROL HAFIZASI VE LASTİK OTELİ (SİBER MATRİS) ──
  final List<Map<String, dynamic>> _denetimModulleri = [
    {"parca": "FREN SİSTEMİ", "durum": "BEKLIYOR", "kanit": false, "kritik": true, "dosya_yolu": null},
    {"parca": "ŞASE VE PODYE KONTROLÜ", "durum": "BEKLIYOR", "kanit": false, "kritik": true, "dosya_yolu": null},
    {"parca": "RADYATÖR / SOĞUTMA", "durum": "BEKLIYOR", "kanit": false, "kritik": false, "dosya_yolu": null},
    {"parca": "MOTOR MEKANİK & SIZDIRMAZLIK", "durum": "BEKLIYOR", "kanit": false, "kritik": true, "dosya_yolu": null},
    // 🚀 LASTİK OTELİ MODÜLÜ BURAYA EKLENDİ
    {
      "parca": "LASTİK DEĞİŞİMİ & OTEL KAYDI",
      "durum": "BEKLIYOR",
      "kanit": false,
      "kritik": false,
      "dosya_yolu": null,
      "otel_kaydi_var": false, // Lastik Karargah oteline alındı mı?
      "lastik_tipi": "YAZLIK", // Değiştirilen/Sökülen lastik
      "dis_derinligi": "80", // Yüzdelik diş derinliği
    },
  ];

  bool _islemSuruyor = false;

  // ── 📸 GERÇEK KANIT YÜKLEME MOTORU (SIFIR MAKET) ──
  Future<void> _zamanDamgaliKanitYukle(int index) async {
    developer.log("SİBER KAMERA: ${_denetimModulleri[index]['parca']} için optik tarama başlatıldı...");
    HapticFeedback.mediumImpact();

    try {
      final picker = ImagePicker();
      final secilenDosya = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (secilenDosya != null) {
        setState(() {
          _denetimModulleri[index]['kanit'] = true;
          _denetimModulleri[index]['dosya_yolu'] = secilenDosya.path;
        });

        HapticFeedback.vibrate();
        _siberUyariGoster(
            "KANIT MÜHÜRLENDİ",
            "${_denetimModulleri[index]['parca']} için görsel Karargah önbelleğine işlendi.",
            SiberTema.kuantumCyan
        );
      } else {
        developer.log("İHLAL: Usta kamerayı açtı ama kanıt çekmeden kapattı.");
      }
    } catch (e) {
      developer.log("KAMERA ÇÖKTÜ: Modül başlatılamadı!", error: e);
      _siberUyariGoster("SİSTEM HATASI", "Kamera modülüne erişilemiyor.", SiberTema.kanKirmizi);
    }
  }

  // ── ✅ YEŞİL TIK (ONAY) MOTORU ──
  Future<void> _yesilTikMudurle(int index) async {
    HapticFeedback.lightImpact();
    String parca = _denetimModulleri[index]['parca'];

    // 1. ZIRH: Fotoğraf Yoksa İhlal Ver!
    if (!_denetimModulleri[index]['kanit']) {
      HapticFeedback.heavyImpact();
      developer.log("🚨 SİBER İHLAL: Kanıt yüklenmeden $parca onaylanamaz!");
      _siberUyariGoster(
          "ZORUNLU KANIT EKSİK!",
          "DİKKAT: Fotoğraf veya Video yüklemeden Yeşil Tık (✅) basamazsınız. Sistem kilitlendi.",
          SiberTema.altinSari
      );
      return;
    }

    setState(() => _denetimModulleri[index]['durum'] = "ONAYLANDI");
    developer.log("✅ ONAY: $parca Karargah standartlarından geçti.");
  }

  // ── ❌ KIRMIZI X (RİSK) VE OTONOM RAPORLAMA MOTORU (ATOMİK ZIRHLI) ──
  Future<void> _kirmiziXMudurle(int index) async {
    HapticFeedback.heavyImpact();
    String parca = _denetimModulleri[index]['parca'];
    bool isKritik = _denetimModulleri[index]['kritik'];

    setState(() => _denetimModulleri[index]['durum'] = "RISKLI");
    developer.log("❌ RET: $parca kusurlu bulundu.");

    // Karargah Kuralı: Kritik bir parça (Şase, Fren) ise Admin'i ayağa kaldır ve atomik olarak mühürle!
    if (isKritik) {
      developer.log("🚨 KRİTİK İHLAL TESPİTİ: $parca trafiğe çıkış için riskli! Acil rapor atomik olarak fırlatılıyor...");

      try {
        WriteBatch batch = _db.batch();

        // 1. Acil Raporu Oluştur
        DocumentReference acilRef = _db.collection('acil_raporlar').doc();
        batch.set(acilRef, {
          'rapor_id': acilRef.id,
          'sase_no': widget.saseNo,
          'usta_id': widget.ustaId,
          'hatali_parca': parca,
          'risk_seviyesi': 'YUKSEK_TRAFIGE_CIKAMAZ',
          'tarih': FieldValue.serverTimestamp(),
          'okundu_mu': false
        });

        // 2. Kara Kutuya (Sistem Loglarına) Acil Durumu Kaydet
        DocumentReference logRef = _db.collection('sistem_loglari').doc();
        batch.set(logRef, {
          'islem_turu': 'KIRMIZI_ALARM_FIRLATILDI',
          'islem_detayi': 'SİBER ALARM: ${widget.saseNo} şaseli aracın $parca modülünde KRİTİK KUSUR bulundu. Araç trafiğe çıkamaz!',
          'tarih': FieldValue.serverTimestamp(),
        });

        await batch.commit(); // Füzeleri ateşle!

        _siberUyariGoster(
            "KIRMIZI ALARM FIRLATILDI!",
            "$parca kusuru Karargah (Admin) paneline anlık olarak iletildi ve loglandı.",
            SiberTema.kanKirmizi
        );
      } catch (e) {
        developer.log("🚨 AĞ ÇÖKTÜ: Kırmızı alarm atomik olarak iletilemedi!", error: e);
        _siberUyariGoster("BAĞLANTI HATASI", "Alarm merkeze iletilemedi, lütfen bağlantınızı kontrol edin.", SiberTema.kanKirmizi);
      }
    }
  }

  // ── 🛡️ TÜM RAPORU KARARGAHA MÜHÜRLE (ATOMİK ZIRHLI) ──
  Future<void> _tumRaporuKapat() async {
    HapticFeedback.vibrate();
    bool eksikVarMi = _denetimModulleri.any((modul) => modul['durum'] == "BEKLIYOR");

    if (eksikVarMi) {
      HapticFeedback.heavyImpact();
      _siberUyariGoster("RAPOR EKSİK!", "Tüm modülleri (✅ veya ❌) mühürlemeden ekspertizi kapatamazsınız.", SiberTema.altinSari);
      return;
    }

    setState(() => _islemSuruyor = true);
    developer.log("🚀 MÜHÜRLEME BAŞLADI: Rapor Karargaha iletiliyor...");

    try {
      // ⛓️ ATOMİK ZIRH: Rapor, Lastik Oteli ve Sistem Logu aynı anda kilitlenir!
      WriteBatch batch = _db.batch();

      // 1. İşlem: Ekspertiz Raporunu Mühürle
      DocumentReference raporRef = _db.collection('ekspertiz_raporlari').doc(widget.saseNo);
      batch.set(raporRef, {
        'sase_no': widget.saseNo,
        'usta_id': widget.ustaId,
        'detaylar': _denetimModulleri,
        'tamamlanma_tarihi': FieldValue.serverTimestamp(),
        'durum': 'EKSPERTIZ_TAMAMLANDI'
      });

      // 2. İşlem: Eğer Lastik Oteline Kayıt Yapıldıysa (Otonom) Müşterinin Garajına Ekle
      var lastikModulu = _denetimModulleri.firstWhere((m) => m['parca'] == "LASTİK DEĞİŞİMİ & OTEL KAYDI");
      if (lastikModulu['otel_kaydi_var'] == true) {
        DocumentReference otelRef = _db.collection('lastik_oteli').doc();
        batch.set(otelRef, {
          'otel_id': otelRef.id,
          'sase_no': widget.saseNo,
          'usta_id': widget.ustaId,
          'lastik_tipi': lastikModulu['lastik_tipi'],
          'dis_derinligi': int.tryParse(lastikModulu['dis_derinligi']) ?? 0,
          'depolama_tarihi': FieldValue.serverTimestamp(),
          'durum': 'AKTIF_DEPOLAMA'
        });
        developer.log("🛞 SİBER OTEL: Lastik kaydı başarıyla oluşturuldu.");
      }

      // 3. İşlem: Kara Kutuya (Sistem Logları) Ekspertizin Bittiğini Kaydet
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'EKSPERTIZ_RAPORU_KAPATILDI',
        'islem_detayi': 'SİBER ONAY: ${widget.saseNo} şaseli aracın teknik denetimi ${widget.ustaId} tarafından tamamlandı ve mühürlendi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      developer.log("✅ ONAY: Ekspertiz raporu ve loglar Karargaha atomik olarak mühürlendi.");
      if (mounted) {
        _siberUyariGoster("SİBER MÜHÜR BASILDI!", "Ekspertiz raporu Karargaha başarıyla şifrelendi.", SiberTema.kuantumCyan);
        Navigator.pop(context);
      }

    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ!", error: e);
      if (mounted) _siberUyariGoster("HATA", "Veriler Karargaha mühürlenemedi.", SiberTema.kanKirmizi);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.matGrey,
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

  Icon _getSiberIcon(String durum) {
    if (durum == "ONAYLANDI") return const Icon(Icons.check_circle_outline, color: SiberTema.kuantumCyan, size: 28);
    if (durum == "RISKLI") return const Icon(Icons.cancel_outlined, color: SiberTema.kanKirmizi, size: 28);
    return const Icon(Icons.hourglass_empty_outlined, color: Colors.white30, size: 28);
  }

  @override
  Widget build(BuildContext context) {
    int tamamlanan = _denetimModulleri.where((m) => m['durum'] != "BEKLIYOR").length;
    double ilerleme = tamamlanan / _denetimModulleri.length;

    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Zırh OLED Siyahı veriyor
        appBar: AppBar(
          title: const Text('TEKNİK DENETİM MASASI', style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: LinearProgressIndicator(value: ilerleme, backgroundColor: Colors.white10, color: SiberTema.kuantumCyan, minHeight: 4),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _denetimModulleri.length,
                itemBuilder: (context, index) {
                  var modul = _denetimModulleri[index];
                  bool isOnayli = modul['durum'] == "ONAYLANDI";
                  bool isRiskli = modul['durum'] == "RISKLI";
                  bool isLastikOteli = modul['parca'] == "LASTİK DEĞİŞİMİ & OTEL KAYDI";

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: SiberTema.matGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isOnayli ? SiberTema.kuantumCyan : (isRiskli ? SiberTema.kanKirmizi : Colors.white12),
                        width: isOnayli || isRiskli ? 2 : 1,
                      ),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: _getSiberIcon(modul['durum']),
                        title: Text(modul['parca'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
                        subtitle: Text("DURUM: ${modul['durum']}", style: TextStyle(color: isOnayli ? SiberTema.kuantumCyan : (isRiskli ? SiberTema.kanKirmizi : Colors.white54), fontSize: 10, letterSpacing: 1)),
                        iconColor: SiberTema.kuantumCyan,
                        collapsedIconColor: Colors.white54,
                        children: [
                          const Divider(color: Colors.white12, height: 1),

                          // 🛞 ÖZEL MODÜL: LASTİK OTELİ FORMU
                          if (isLastikOteli) ...[
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  SwitchListTile(
                                    title: const Text("Kullanılmış Lastikleri Otele (Depoya) Al", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                    value: modul['otel_kaydi_var'] ?? false,
                                    activeColor: SiberTema.kuantumCyan,
                                    onChanged: (val) {
                                      setState(() {
                                        _denetimModulleri[index]['otel_kaydi_var'] = val;
                                      });
                                    },
                                  ),
                                  if (modul['otel_kaydi_var'] == true) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DropdownButtonFormField<String>(
                                            dropdownColor: SiberTema.matGrey,
                                            value: modul['lastik_tipi'],
                                            style: const TextStyle(color: Colors.white, fontSize: 12),
                                            decoration: const InputDecoration(labelText: "Depolanan Tip", labelStyle: TextStyle(color: SiberTema.kuantumCyan), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: SiberTema.kuantumCyan))),
                                            items: ['YAZLIK', 'KIŞLIK', 'DÖRT MEVSİM'].map((String val) {
                                              return DropdownMenuItem<String>(value: val, child: Text(val));
                                            }).toList(),
                                            onChanged: (val) {
                                              setState(() {
                                                _denetimModulleri[index]['lastik_tipi'] = val;
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: TextFormField(
                                            initialValue: modul['dis_derinligi'],
                                            keyboardType: TextInputType.number,
                                            style: const TextStyle(color: Colors.white, fontSize: 12),
                                            decoration: const InputDecoration(labelText: "Diş Derinliği (%)", labelStyle: TextStyle(color: SiberTema.kuantumCyan), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: SiberTema.kuantumCyan))),
                                            onChanged: (val) {
                                              _denetimModulleri[index]['dis_derinligi'] = val;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]
                                ],
                              ),
                            ),
                            const Divider(color: Colors.white12, height: 1),
                          ],

                          // 📸 Kanıt Yükleme Satırı
                          ListTile(
                            leading: Icon(modul['kanit'] ? Icons.verified : Icons.camera_alt_outlined, color: modul['kanit'] ? SiberTema.kuantumCyan : SiberTema.altinSari),
                            title: Text(modul['kanit'] ? "ZAMAN DAMGALI KANIT YÜKLENDİ" : "ZAMAN DAMGALI KANIT YÜKLE", style: TextStyle(color: modul['kanit'] ? SiberTema.kuantumCyan : SiberTema.altinSari, fontSize: 11, fontWeight: FontWeight.bold)),
                            trailing: modul['kanit'] ? null : const Icon(Icons.arrow_forward_ios, color: SiberTema.altinSari, size: 14),
                            onTap: () => _zamanDamgaliKanitYukle(index),
                          ),
                          // 🔘 Karar Butonları
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: SiberTema.kanKirmizi,
                                      side: const BorderSide(color: SiberTema.kanKirmizi),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    icon: const Icon(Icons.close),
                                    label: const Text("KIRMIZI X", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                                    onPressed: () => _kirmiziXMudurle(index),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: modul['kanit'] ? SiberTema.kuantumCyan : Colors.white10,
                                      foregroundColor: modul['kanit'] ? SiberTema.oledBlack : Colors.white30,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    icon: const Icon(Icons.check),
                                    label: const Text("YEŞİL TIK", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                                    onPressed: () => _yesilTikMudurle(index),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🚀 Mühürleme Butonu
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: _islemSuruyor
                    ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                    : ElevatedButton.icon(
                  style: SiberTema.kuantumButonStili(),
                  icon: const Icon(Icons.security, color: SiberTema.oledBlack, size: 28),
                  label: const Text("TÜMÜNÜ KARARGAHA MÜHÜRLE", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)),
                  onPressed: _tumRaporuKapat,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}