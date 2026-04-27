// lib/screens/bayi/hizli_kayit_formu.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA BAĞLANTISI (2 Kat Yukarı)
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

/// 🛡️ KUANTUM HIZLI KAYIT FORMU (HizliKayitFormu)
/// Davetle gelen firmaları (Beyinci, Kurtarıcı vb.) sisteme katar ve Karargaha ATOMİK mühürler.
class HizliKayitFormu extends StatefulWidget {
  final String ustaId; // Referans veya kayıt olanın kimliği

  const HizliKayitFormu({super.key, required this.ustaId});

  @override
  State<HizliKayitFormu> createState() => _HizliKayitFormuState();
}

class _HizliKayitFormuState extends State<HizliKayitFormu> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _firmaAdiCtrl = TextEditingController();

  // ── SİBER İSTİHBARAT DEĞİŞKENLERİ (GENİŞLETİLMİŞ AĞ) ──
  final Map<String, bool> _sektorler = {
    "Mekanik Servis": false,
    "Elektrik & Beyin (ECU)": false,
    "Şase ve Kaporta": false,
    "Fırın Boya & Mikron Testi": false,
    "Rot Balans & Alt Takım": false,
    "Lastik ve Jant": false,
    "Egzoz Emisyon & DPF": false,
    "Oto Cam & Kilit": false,
    "Oto Kuaför & Seramik Kaplama": false,
    "Ekspertiz Merkezi": false,
    "Hibrit / EV Batarya Servisi": false, // Yeni Nesil Karargah Hedefi
    "Yedek Parça Tedarikçisi": false,
    "Sigorta ve Kasko Acentesi": false,
    "Rent a Car (Araç Kiralama)": false,
    "Sürücü Kursu": false,
    "Kurtarıcı (Yol Yardım)": false,
  };

  bool _sozlesmeOnay = false;
  bool _islemSuruyor = false;

  // ── 🚀 FİREBASE ATOMİK MÜHÜRLEME PROTOKOLÜ (WRITEBATCH) ──
  Future<void> _kayitTamamla() async {
    HapticFeedback.lightImpact();

    String firmaAdi = _firmaAdiCtrl.text.trim();
    bool sektorSeciliMi = _sektorler.values.any((element) => element == true);

    if (firmaAdi.isEmpty || !sektorSeciliMi || !_sozlesmeOnay) {
      HapticFeedback.heavyImpact();
      _siberUyariGoster(
        "SİBER İHLAL",
        "Firma adı, en az bir sektör ve Karargah sözleşmesi zorunludur.",
        SiberTema.kanKirmizi,
      );
      return;
    }

    setState(() => _islemSuruyor = true);
    developer.log("🚀 SİBER MÜHÜR: Hızlı kayıt işlemi başlatıldı...");

    try {
      List<String> secilenSektorler = _sektorler.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // 🛡️ ATOMİK ZIRH DEVREDE
      WriteBatch batch = _db.batch();

      // 1. Bayi Başvurusunu Kilitler
      DocumentReference bayiRef = _db.collection('bayi_basvurulari').doc(widget.ustaId);
      batch.set(bayiRef, {
        'usta_id': widget.ustaId,
        'firma_adi': firmaAdi,
        'uzmanlik_alanlari': secilenSektorler,
        'sozlesme_onay': true,
        'onay_tarihi': FieldValue.serverTimestamp(),
        'basvuru_durumu': 'ONAY_BEKLIYOR',
        'kayit_turu': 'HIZLI_DAVET',
      }, SetOptions(merge: true));

      // 2. Kara Kutuya Rapor Düşer
      DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'HIZLI_BAYI_KAYDI',
        'seviye': 'BİLGİ',
        'islem_detayi': 'SİBER BÜYÜME: $firmaAdi firması (${secilenSektorler.join(", ")}) hızlı davet linkiyle Karargaha katılım sağladı.',
        'vaka_id': widget.ustaId,
        'kullanici_id': widget.ustaId,
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit(); // Füzeleri ateşle!

      HapticFeedback.vibrate();
      developer.log("✅ ONAY: Hızlı kayıt başarıyla Karargaha mühürlendi.");

      if (mounted) {
        _siberUyariGoster("MÜHÜRLENDİ!", "Firma bilgileriniz Ankara Karargahına iletildi.", SiberTema.kuantumCyan);
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
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: SiberTema.textMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firmaAdiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("KARARGAHA KATIL", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bilgiMetni("SİBER PROTOKOL: Davetiniz onaylandı. Lütfen firmanızı Kuantum Ağına mühürleyin."),
                const SizedBox(height: 24),

                // FİRMA ADI
                const Text("FİRMA BİLGİSİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: SiberTema.matGrey.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SiberTema.textMuted, width: 1.5),
                  ),
                  child: TextField(
                    controller: _firmaAdiCtrl,
                    style: const TextStyle(color: SiberTema.textMain, fontSize: 14, letterSpacing: 1, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.business_outlined, color: SiberTema.kuantumCyan, size: 22),
                      hintText: "Örn: Siber Motor Servisi",
                      hintStyle: TextStyle(color: Colors.white30, letterSpacing: 1, fontSize: 12),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // SEKTÖR SEÇİCİ
                const Text("HİZMET / UZMANLIK ALANLARI", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                _sektorSecici(),

                const SizedBox(height: 24),
                _konumButonu(),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Divider(color: SiberTema.textMuted, height: 1),
                ),

                _sozlesmeOnayKutusu(),
                const SizedBox(height: 30),

                // 🚀 MÜHÜRLEME BUTONU
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: _islemSuruyor
                      ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                      : ElevatedButton.icon(
                    icon: const Icon(Icons.fingerprint, color: SiberTema.oledBlack, size: 28),
                    label: const Text("SİSTEME KAYDOL VE MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: SiberTema.oledBlack)),
                    style: SiberTema.kuantumButonStili(),
                    onPressed: _kayitTamamla,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── 🔧 YARDIMCI WIDGET'LAR ──
  Widget _bilgiMetni(String metin) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: SiberTema.kuantumCyan.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5)
    ),
    child: Row(
      children: [
        const Icon(Icons.shield_outlined, color: SiberTema.kuantumCyan, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Text(metin, style: const TextStyle(color: SiberTema.textMuted, fontSize: 11, height: 1.5, letterSpacing: 0.5, fontWeight: FontWeight.bold))),
      ],
    ),
  );

  Widget _sektorSecici() => Container(
    decoration: BoxDecoration(
      color: SiberTema.matGrey.withOpacity(0.8),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: SiberTema.textMuted),
    ),
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: const Icon(Icons.category_outlined, color: SiberTema.kuantumCyan),
        title: const Text("Sektörünüzü Seçin", style: TextStyle(color: SiberTema.textMain, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        iconColor: SiberTema.kuantumCyan,
        collapsedIconColor: Colors.white54,
        children: _sektorler.keys.map((String key) {
          return CheckboxListTile(
            title: Text(key, style: TextStyle(color: _sektorler[key]! ? SiberTema.kuantumCyan : Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
            value: _sektorler[key],
            activeColor: SiberTema.kuantumCyan,
            checkColor: Colors.black,
            side: const BorderSide(color: Colors.white30),
            onChanged: (bool? val) {
              HapticFeedback.selectionClick();
              setState(() => _sektorler[key] = val!);
            },
          );
        }).toList(),
      ),
    ),
  );

  Widget _konumButonu() => Container(
    decoration: BoxDecoration(color: SiberTema.matGrey.withOpacity(0.8), borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.textMuted)),
    child: ListTile(
      leading: const Icon(Icons.location_on_outlined, color: Colors.orangeAccent),
      title: const Text("KARARGAH LOKASYONU (GPS)", style: TextStyle(color: SiberTema.textMain, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
      subtitle: const Text("Konumunuzu Mühürleyin", style: TextStyle(color: SiberTema.textMuted, fontSize: 10)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 14),
      onTap: () {
        HapticFeedback.lightImpact();
        developer.log("SİBER GPS: Konum seçici tetiklendi (Simülasyon)");
        _siberUyariGoster("SİBER LOKASYON", "Konumunuz otonom olarak mühürlendi.", SiberTema.kuantumCyan);
      },
    ),
  );

  Widget _sozlesmeOnayKutusu() => Container(
    decoration: BoxDecoration(
      color: _sozlesmeOnay ? SiberTema.kuantumCyan.withOpacity(0.1) : SiberTema.matGrey,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _sozlesmeOnay ? SiberTema.kuantumCyan : Colors.white24, width: 2),
    ),
    child: SwitchListTile(
      title: Text(
        "OTODNA SİBER İMECE SÖZLEŞMESİNİ KABUL EDİYORUM.",
        style: TextStyle(color: _sozlesmeOnay ? SiberTema.kuantumCyan : Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, height: 1.5),
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
  );
}