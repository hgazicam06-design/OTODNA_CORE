// lib/screens/bayi_kayit.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HapticFeedback için gerekli zırh
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA BAĞLANTISI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../core/otodna_hizmet_kutuphanesi.dart';

/// 🛡️ KUANTUM BAYİ KAYIT VE SİBER İMECE SÖZLEŞMESİ (BayiKayitFormu)
/// Ustaların uzmanlık alanlarını seçtiği ve adli yaptırımlı sözleşmeyi onaylayıp Karargaha ATOMİK mühürlediği terminal.
class BayiKayitFormu extends StatefulWidget {
  final String ustaId; // Kayıt olan ustanın geçici kimliği (Auth'tan gelir)

  const BayiKayitFormu({super.key, required this.ustaId});

  @override
  State<BayiKayitFormu> createState() => _BayiKayitFormuState();
}

class _BayiKayitFormuState extends State<BayiKayitFormu> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── SİBER İSTİHBARAT DEĞİŞKENLERİ ──
  final Map<String, bool> _uzmanliklar = {};

  @override
  void initState() {
    super.initState();
    // Karargah kütüphanesindeki tüm branşları otonom olarak yükle
    for (String hizmet in SiberHizmetKutuphanesi.tumHizmetleriGetir()) {
      _uzmanliklar[hizmet] = false;
    }
  }

  bool _sozlesmeOnay = false;
  bool _islemSuruyor = false;

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
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

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

      // Hangi ana kategorilere ait olduklarını bul (Filtreleme için)
      List<String> secilenKategoriler = [];
      for (String brans in secilenUzmanliklar) {
        SiberHizmetKutuphanesi.masterListe.forEach((kategori, branslar) {
          if (branslar.contains(brans) && !secilenKategoriler.contains(kategori)) {
            secilenKategoriler.add(kategori);
          }
        });
      }

      // ⛓️ ATOMİK ZIRH DEVREDE (WriteBatch)
      WriteBatch batch = _db.batch();

      // 1. Başvuru Verisini Kilitler
      DocumentReference basvuruRef = _db.collection('bayi_basvurulari').doc(widget.ustaId);
      batch.set(basvuruRef, {
        'usta_id': widget.ustaId,
        'uzmanlik_alanlari': secilenUzmanliklar,
        'uzmanlik_kategorileri': secilenKategoriler,
        'sozlesme_onay': true,
        'onay_tarihi': FieldValue.serverTimestamp(),
        'basvuru_durumu': 'ONAY_BEKLIYOR',
      });

      // 2. Kara Kutuya Log Düşer
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'YENI_BAYI_TALEBI',
        'islem_detayi': 'SİBER İSTİHBARAT: Yeni usta (${widget.ustaId}) Siber İmece Sözleşmesini onaylayarak Karargaha katılım talebi fırlattı. Uzmanlık: ${secilenUzmanliklar.join(", ")}',
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

  // ── 🚀 YENİ BRANŞ TALEP MOTORU ──
  void _yeniBransTalepEt() {
    TextEditingController talepCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: SiberTema.matGrey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: SiberTema.kuantumCyan, width: 1.5)),
          title: const Text("YENİ UZMANLIK TALEBİ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontFamily: 'Avenir', fontSize: 14)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Kütüphanede bulunmayan branşınızı Karargah onayına gönderin. Onaylandıktan sonra profilinize işlenecektir.", style: TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'Avenir')),
              const SizedBox(height: 16),
              TextField(
                controller: talepCtrl,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: "Örn: Klasik Otomobil Restorasyonu",
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İPTAL", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                String talep = talepCtrl.text.trim();
                if (talep.isNotEmpty) {
                  Navigator.pop(context); // Dialog kapat
                  
                  try {
                    await _db.collection('talep_edilen_branslar').add({
                      'usta_id': widget.ustaId,
                      'brans_adi': talep,
                      'tarih': FieldValue.serverTimestamp(),
                      'durum': 'ONAY_BEKLIYOR'
                    });
                    _siberUyariGoster("KARARGAHA İLETİLDİ", "'$talep' uzmanlığı inceleme havuzuna gönderildi.", SiberTema.kuantumCyan);
                  } catch (e) {
                    _siberUyariGoster("SİBER İHLAL", "Talep gönderilemedi.", SiberTema.kanKirmizi);
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kuantumCyan, foregroundColor: Colors.black),
              child: const Text("KARARGAHA GÖNDER", style: TextStyle(fontWeight: FontWeight.w900)),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("BAYİ KAYIT & SÖZLEŞME", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14, fontFamily: 'Avenir')),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            // 1. UZMANLIK SEÇİMİ
            const Text("ATÖLYE UZMANLIK ALANLARINIZI SEÇİN", style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: SiberTema.matGrey.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: _uzmanliklar.keys.map((String key) {
                  return CheckboxListTile(
                    title: Text(key, style: TextStyle(color: _uzmanliklar[key]! ? SiberTema.kuantumCyan : Colors.white, fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                    value: _uzmanliklar[key],
                    activeColor: SiberTema.kuantumCyan,
                    checkColor: Colors.black,
                    side: const BorderSide(color: Colors.white30),
                    onChanged: (bool? val) {
                      HapticFeedback.selectionClick();
                      setState(() => _uzmanliklar[key] = val!);
                    },
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // ── 🚀 YENİ BRANŞ EKLEME BUTONU ──
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _yeniBransTalepEt,
                icon: const Icon(Icons.add_circle_outline, color: SiberTema.kuantumCyan, size: 16),
                label: const Text("LİSTEDE YOK MU? YENİ EKLE", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                style: TextButton.styleFrom(
                  backgroundColor: SiberTema.kuantumCyan.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5))),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 2. OTODNA SİBER İMECE SÖZLEŞMESİ
            const Text("YASAL PROTOKOL", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
            const SizedBox(height: 8),
            Container(
              height: 180,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SiberTema.kanKirmizi.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.5), width: 1.5),
              ),
              child: const SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Text(
                  "OTODNA SİBER İMECE SÖZLEŞMESİ:\n\n"
                      "1. Hatalı işlemlerden ve yanlış ekspertiz beyanlarından doğan Müşteri zararları 'İmece Havuzu' üzerinden mahsuplaşılır.\n\n"
                      "2. Havuz borcu ödenmez veya Karargah kuralları ihlal edilirse sistemden süresiz men ve adli yaptırım uygulanır.\n\n"
                      "3. Yetkinlik dışı (yanlış) uzmanlık beyanı, Usta DNA Puanını doğrudan düşürür ve 'Kara Liste' algoritmasını tetikler.\n\n"
                      "4. Bu sözleşme IP adresi ve cihaz kimliği ile dijital olarak mühürlenir.",
                  style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.6, letterSpacing: 0.5, fontFamily: 'Avenir'),
                ),
              ),
            ),

            const SizedBox(height: 20),

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
                  style: TextStyle(color: _sozlesmeOnay ? SiberTema.kuantumCyan : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, height: 1.5, fontFamily: 'Avenir'),
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

            const SizedBox(height: 40),

            // 4. MÜHÜRLEME BUTONU
            SizedBox(
              height: 60,
              child: _islemSuruyor
                  ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                  : ElevatedButton.icon(
                icon: const Icon(Icons.security, color: Colors.black, size: 24),
                label: const Text("SİSTEME KAYDOL VE MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}