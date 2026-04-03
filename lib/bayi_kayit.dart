// lib/screens/bayi_kayit.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Siber Titreşim (Haptic) eklendi
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM BAYİ KAYIT VE SİBER İMECE SÖZLEŞMESİ (BayiKayitFormu)
/// Ustaların uzmanlık alanlarını seçtiği ve adli yaptırımlı sözleşmeyi onaylayıp Karargaha mühürlendiği terminal.
class BayiKayitFormu extends StatefulWidget {
  final String ustaId; // Kayıt olan ustanın geçici kimliği (Auth'tan gelir)

  const BayiKayitFormu({super.key, required this.ustaId});

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
    "HİBRİT / EV BATARYA": false, // Yeni nesil eklendi
  };

  bool _sozlesmeOnay = false;
  bool _islemSuruyor = false;

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  // ── 🚀 FİREBASE MÜHÜRLEME PROTOKOLÜ ──
  Future<void> _kayitTamamla() async {
    HapticFeedback.lightImpact(); // İlk dokunuş

    // En az 1 uzmanlık seçili olmalı
    bool uzmanlikSeciliMi = _uzmanliklar.values.any((element) => element == true);

    if (!uzmanlikSeciliMi) {
      HapticFeedback.heavyImpact(); // Kritik İhlal Titreşimi
      _siberUyariGoster("SİBER İHLAL", "Karargaha katılmak için en az BİR (1) uzmanlık alanı seçmelisiniz.", Colors.orangeAccent);
      return;
    }

    setState(() => _islemSuruyor = true);
    developer.log("🚀 SİBER MÜHÜR: Bayi başvurusu ve sözleşme Karargaha iletiliyor...");

    try {
      // Sadece 'true' olan uzmanlıkları filtrele
      List<String> secilenUzmanliklar = _uzmanliklar.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // Firebase'e Gerçek Kayıt
      await _db.collection('bayi_basvurulari').doc(widget.ustaId).set({
        'usta_id': widget.ustaId,
        'uzmanlik_alanlari': secilenUzmanliklar,
        'sozlesme_onay': true,
        'onay_tarihi': FieldValue.serverTimestamp(),
        'basvuru_durumu': 'ONAY_BEKLIYOR', // Admin Onayına Düşer
      });

      HapticFeedback.vibrate(); // Başarı Titreşimi
      developer.log("✅ ONAY: Başvuru başarıyla mühürlendi.");
      _siberUyariGoster("MÜHÜRLENDİ!", "Siber İmece Sözleşmesi ve Uzmanlıklarınız Karargaha iletildi.", _kuantumCyan);

      // İşlem başarılıysa ekranı kapat veya yönlendir
      if (mounted) Navigator.pop(context);

    } catch (e) {
      HapticFeedback.heavyImpact(); // Ağ Çökme Titreşimi
      developer.log("AĞ ÇÖKTÜ!", error: e);
      _siberUyariGoster("BAĞLANTI HATASI", "Başvuru Karargaha iletilemedi.", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _matGrey,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _oledBlack,
      appBar: AppBar(
        title: const Text("BAYİ KAYIT & SÖZLEŞME", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kuantumCyan),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            // 1. UZMANLIK SEÇİMİ
            const Text("ATÖLYE UZMANLIK ALANLARINIZI SEÇİN", style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: _matGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: _uzmanliklar.keys.map((String key) {
                  return CheckboxListTile(
                    title: Text(key, style: TextStyle(color: _uzmanliklar[key]! ? _kuantumCyan : Colors.white, fontSize: 13, letterSpacing: 1, fontWeight: FontWeight.bold)),
                    value: _uzmanliklar[key],
                    activeColor: _kuantumCyan,
                    checkColor: Colors.black,
                    side: const BorderSide(color: Colors.white30),
                    onChanged: (bool? val) {
                      HapticFeedback.selectionClick(); // Siber Seçim Titreşimi
                      setState(() => _uzmanliklar[key] = val!);
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),

            // 2. OTODNA SİBER İMECE SÖZLEŞMESİ
            const Text("YASAL PROTOKOL", style: TextStyle(color: Colors.redAccent, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              height: 180,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
              ),
              child: const SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Text(
                  "OTODNA SİBER İMECE SÖZLEŞMESİ:\n\n"
                      "1. Hatalı işlemlerden ve yanlış ekspertiz beyanlarından doğan Müşteri zararları 'İmece Havuzu' üzerinden mahsuplaşılır.\n\n"
                      "2. Havuz borcu ödenmez veya Karargah kuralları ihlal edilirse sistemden süresiz men ve adli yaptırım uygulanır.\n\n"
                      "3. Yetkinlik dışı (yanlış) uzmanlık beyanı, Usta DNA Puanını doğrudan düşürür ve 'Kara Liste' algoritmasını tetikler.\n\n"
                      "4. Bu sözleşme IP adresi ve cihaz kimliği ile dijital olarak mühürlenir.",
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.6, letterSpacing: 0.5),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 3. ONAY MEKANİZMASI
            Container(
              decoration: BoxDecoration(
                color: _sozlesmeOnay ? _kuantumCyan.withOpacity(0.1) : _matGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _sozlesmeOnay ? _kuantumCyan : Colors.white24, width: 2),
              ),
              child: SwitchListTile(
                title: Text(
                  "SÖZLEŞME ŞARTLARINI VE ADLİ YAPTIRIMLARI KABUL EDİYORUM.",
                  style: TextStyle(color: _sozlesmeOnay ? _kuantumCyan : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, height: 1.5),
                ),
                value: _sozlesmeOnay,
                activeColor: _kuantumCyan,
                activeTrackColor: _kuantumCyan.withOpacity(0.3),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.white10,
                onChanged: (bool val) {
                  HapticFeedback.lightImpact(); // Şalter Titreşimi
                  setState(() => _sozlesmeOnay = val);
                },
              ),
            ),

            const SizedBox(height: 40),

            // 4. MÜHÜRLEME BUTONU
            SizedBox(
              height: 60,
              child: _islemSuruyor
                  ? const Center(child: CircularProgressIndicator(color: _kuantumCyan))
                  : ElevatedButton.icon(
                icon: const Icon(Icons.security, color: Colors.black),
                label: const Text("SİSTEME KAYDOL VE MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _sozlesmeOnay ? _kuantumCyan : Colors.white10,
                  foregroundColor: _sozlesmeOnay ? Colors.black : Colors.white30,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: _sozlesmeOnay ? 10 : 0,
                  shadowColor: _kuantumCyan.withOpacity(0.5),
                ),
                onPressed: _sozlesmeOnay ? _kayitTamamla : null, // Onay yoksa buton fiziksel olarak kilitlenir
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}