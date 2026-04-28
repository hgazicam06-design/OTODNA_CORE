import 'package:otodna/core/siber_tema.dart';
// lib/screens/bayi_kayit.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA BAĞLANTISI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM BAYİ KAYIT VE SİBER İMECE SÖZLEŞMESİ (BayiKayitFormu)
/// Ustaların uzmanlık alanlarını seçtiği ve adli yaptırımlı sözleşmeyi onaylayıp Karargaha ATOMİK mühürlediği terminal.
class BayiKayitFormu extends StatefulWidget {
  final String ustaId; // Kayıt olan ustanın geçici kimliği (Auth'tan gelir)

  BayiKayitFormu({super.key, required this.ustaId});

  @override
  State<BayiKayitFormu> createState() => _BayiKayitFormuState();
}

class _BayiKayitFormuState extends State<BayiKayitFormu> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── SİBER İSTİHBARAT DEĞİŞKENLERİ ──
  final Map<String, bool> _uzmanliklar = {
    "MOTOR MEKANİK": false,
    "ŞASE VE KAPORTA": false,
    "OTO ELEKTRİK & BEYİN (ECU)": false,
    "ROT BALANS & ALT TAKIM": false,
    "EGZOZ EMİSYON & DPF": false,
    "HİBRİT / EV BATARYA": false,
  };

  bool _sozlesmeOnay = false;
  bool _islemSuruyor = false;

  // ── 🚀 FİREBASE ATOMİK MÜHÜRLEME PROTOKOLÜ ──
  Future<void> _kayitTamamla() async {
    HapticFeedback.lightImpact();

    bool uzmanlikSeciliMi = _uzmanliklar.values.any((element) => element == true);

    if (!uzmanlikSeciliMi) {
      HapticFeedback.heavyImpact();
      _siberUyariGoster("SİBER İHLAL", "Karargaha katılmak için en az BİR (1) uzmanlık alanı seçmelisiniz.", Colors.orangeAccent);
      return;
    }

    setState(() => _islemSuruyor = true);
    developer.log("🚀 SİBER MÜHÜR: Bayi başvurusu ve sözleşme Karargaha iletiliyor...");

    try {
      List<String> secilenUzmanliklar = _uzmanliklar.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // ⛓️ ATOMİK ZIRH DEVREDE (WriteBatch)
      WriteBatch batch = _db.batch();

      // 1. Başvuru Verisini Kilitler
      DocumentReference basvuruRef = _db.collection('bayi_basvurulari').doc(widget.ustaId);
      batch.set(basvuruRef, {
        'usta_id': widget.ustaId,
        'uzmanlik_alanlari': secilenUzmanliklar,
        'sozlesme_onay': true,
        'onay_tarihi': FieldValue.serverTimestamp(),
        'basvuru_durumu': 'ONAY_BEKLIYOR',
      });

      // 2. Siber Radara Log Düşer
      DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'BAYI_KAYIT_ONAY',
        'seviye': 'BİLGİ',
        'islem_detayi': 'YENİ BAYİ BAŞVURUSU: Siber İmece Sözleşmesi onaylandı. Uzmanlık: ${secilenUzmanliklar.join(", ")}',
        'vaka_id': widget.ustaId,
        'kullanici_id': widget.ustaId,
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Füzeleri ateşle!

      HapticFeedback.vibrate();
      developer.log("✅ ONAY: Başvuru başarıyla mühürlendi.");

      if (mounted) {
        _siberUyariGoster("MÜHÜRLENDİ!", "Siber İmece Sözleşmesi ve Uzmanlıklarınız Karargaha iletildi.", SiberTema.kuantumCyan);
        Navigator.pop(context);
      }

    } catch (e) {
      HapticFeedback.heavyImpact();
      developer.log("🚨 AĞ ÇÖKTÜ!", error: e);
      if (mounted) _siberUyariGoster("BAĞLANTI HATASI", "Başvuru Karargaha iletilemedi.", SiberTema.kanKirmizi);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
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
            SizedBox(height: 4),
            Text(mesaj, style: TextStyle(color: SiberTema.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("BAYİ KAYIT & SÖZLEŞME", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: ListView(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(20),
          children: [
            // 1. UZMANLIK SEÇİMİ
            Text("ATÖLYE UZMANLIK ALANLARINIZI SEÇİN", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w900)),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: SiberTema.matGrey.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SiberTema.textMuted),
              ),
              child: Column(
                children: _uzmanliklar.keys.map((String key) {
                  return CheckboxListTile(
                    title: Text(key, style: TextStyle(color: _uzmanliklar[key]! ? SiberTema.kuantumCyan : Colors.white, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold)),
                    value: _uzmanliklar[key],
                    activeColor: SiberTema.kuantumCyan,
                    checkColor: Colors.black,
                    side: BorderSide(color: Colors.white30),
                    onChanged: (bool? val) {
                      HapticFeedback.selectionClick();
                      setState(() => _uzmanliklar[key] = val!);
                    },
                  );
                }).toList(),
              ),
            ),

            SizedBox(height: 30),

            // 2. OTODNA SİBER İMECE SÖZLEŞMESİ
            Text("YASAL PROTOKOL", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w900)),
            SizedBox(height: 8),
            Container(
              height: 180,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SiberTema.kanKirmizi.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.5), width: 1.5),
              ),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Text(
                  "OTODNA SİBER İMECE SÖZLEŞMESİ:\n\n"
                      "1. Hatalı işlemlerden ve yanlış ekspertiz beyanlarından doğan Müşteri zararları 'İmece Havuzu' üzerinden mahsuplaşılır.\n\n"
                      "2. Havuz borcu ödenmez veya Karargah kuralları ihlal edilirse sistemden süresiz men ve adli yaptırım uygulanır.\n\n"
                      "3. Yetkinlik dışı (yanlış) uzmanlık beyanı, Usta DNA Puanını doğrudan düşürür ve 'Kara Liste' algoritmasını tetikler.\n\n"
                      "4. Bu sözleşme IP adresi ve cihaz kimliği ile dijital olarak mühürlenir.",
                  style: TextStyle(color: SiberTema.textMuted, fontSize: 11, height: 1.6, letterSpacing: 0.5),
                ),
              ),
            ),

            SizedBox(height: 20),

            // 3. ONAY MEKANİZMASI
            Container(
              decoration: BoxDecoration(
                color: _sozlesmeOnay ? SiberTema.kuantumCyan.withOpacity(0.1) : SiberTema.matGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _sozlesmeOnay ? SiberTema.kuantumCyan : Colors.white24, width: 2),
              ),
              child: SwitchListTile(
                title: Text(
                  "SÖZLEŞME ŞARTLARINI VE ADLİ YAPTIRIMLARI KABUL EDİYORUM.",
                  style: TextStyle(color: _sozlesmeOnay ? SiberTema.kuantumCyan : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, height: 1.5),
                ),
                value: _sozlesmeOnay,
                activeColor: SiberTema.kuantumCyan,
                activeTrackColor: SiberTema.kuantumCyan.withOpacity(0.3),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.white10,
                onChanged: (bool val) {
                  HapticFeedback.lightImpact();
                  setState(() => _sozlesmeOnay = val);
                },
              ),
            ),

            SizedBox(height: 40),

            // 4. MÜHÜRLEME BUTONU
            SizedBox(
              height: 60,
              child: _islemSuruyor
                  ? Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                  : ElevatedButton.icon(
                icon: Icon(Icons.security, color: Colors.white, size: 24),
                label: Text("SİSTEME KAYDOL VE MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _sozlesmeOnay ? SiberTema.kuantumCyan : Colors.white10,
                  foregroundColor: _sozlesmeOnay ? Colors.black : Colors.white30,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: _sozlesmeOnay ? 10 : 0,
                  shadowColor: SiberTema.kuantumCyan.withOpacity(0.5),
                ),
                onPressed: _sozlesmeOnay ? _kayitTamamla : null,
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}