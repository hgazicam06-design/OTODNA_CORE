import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'dart:developer' as developer;
import 'package:otodna/core/siber_tema.dart'; // Tema eklendi

/// 🛡️ KUANTUM DİNAMİK EKSPERTİZ VE TEST MOTORU (OtoDnaKategoriMotoru)
/// Aracın cinsine ve YAKIT tipine göre otonom test modülleri üretir ve Karargaha mühürler.
class OtoDnaKategoriMotoru extends StatefulWidget {
  OtoDnaKategoriMotoru({super.key});

  @override
  State<OtoDnaKategoriMotoru> createState() => _OtoDnaKategoriMotoruState();
}

class _OtoDnaKategoriMotoruState extends State<OtoDnaKategoriMotoru> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _kullanici = FirebaseAuth.instance.currentUser;

  // ── SİBER İSTİHBARAT DEĞİŞKENLERİ ──
  String? secilenAracTipi;
  String? secilenYakitTipi;

  String? secilenMarka;
  String? secilenModel;
  String? secilenYil;
  String? _tarananSase;

  bool _sorgulaniyor = false;
  bool _muhurleniyor = false;
  Map<String, dynamic>? _hamVinVerisi;

  // Ustanın girdiği test sonuçlarını tutan Kuantum Hafıza
  final Map<String, String> _denetimRaporu = {};

  // 🎯 KARARGAH DOKTRİNİ: Detaylı ve Keskin Araç Sınıflandırması
  final List<String> aracTipleri = [
    'Otomobil', 'SUV / Arazi Aracı', 'Panelvan / Kamyonet', 'Minibüs',
    'Kamyon', 'Otobüs', 'İş Makinesi', 'Traktör / Zirai', 'Motosiklet'
  ];

  final List<String> yakitTipleri = ['Benzin', 'Dizel', 'Elektrik (EV)', 'LPG & CNG', 'Hibrit'];

  // ── 🎨 PLAZA ARAYÜZ (UI) İNŞASI ───────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC), // Fildişi Sedef Arka Plan
      appBar: AppBar(
        title: Text('EKSPERTİZ MOTORU',
            style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5, fontFamily: 'Avenir')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: SiberTema.textMain),
        centerTitle: true,
      ),
      body: _sorgulaniyor
          ? Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 📡 SİBER HUB ENTEGRASYONU
            _buildSiberButon(
              "ŞASE (VIN) İLE OTOMATİK DOLDUR",
              Icons.qr_code_scanner,
              SiberTema.kuantumCyan,
              _saseSorgulaDialog,
            ),

            if (_hamVinVerisi != null) _buildVinSonucKarti(),

            const SizedBox(height: 24),

            // 2. ⚙️ KADEMELİ SEÇİM MOTORU
            Text("ARAÇ CİNSİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildSiberAramaKutusu(aracTipleri, secilenAracTipi, (val) {
              setState(() {
                secilenAracTipi = val;
                secilenYakitTipi = null;
                _denetimRaporu.clear();
              });
            }),

            const SizedBox(height: 16),

            if (secilenAracTipi != null && secilenAracTipi != 'Motosiklet') ...[
              Text("YAKIT / ENERJİ TİPİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildSiberAramaKutusu(yakitTipleri, secilenYakitTipi, (val) {
                setState(() {
                  secilenYakitTipi = val;
                  _denetimRaporu.clear();
                });
              }),
            ],

            const SizedBox(height: 20),
            Divider(color: Colors.black.withOpacity(0.05), thickness: 1.0, height: 30),

            // 3. 🧠 YAPAY ZEKA DİNAMİK USTA MODÜLLERİ
            Text("📋 AKTİF DENETİM MODÜLLERİ",
                style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 14)),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: _dinamikModulleriUret(),
              ),
            ),

            if (secilenAracTipi != null && (secilenAracTipi == 'Motosiklet' || secilenYakitTipi != null))
              _buildMuhurleButonu(),
          ],
        ),
      ),
    );
  }

  // ── 📡 SİBER HUB / CANLI FİREBASE ALGORİTMALARI ────────────────────────
  void _saseSorgulaDialog() {
    final saseCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        title: Text("ŞASE (VIN) TARAYICI", style: TextStyle(color: SiberTema.textMain, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: saseCtrl,
          textCapitalization: TextCapitalization.characters,
          style: TextStyle(color: SiberTema.textMain, fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "17 HANELİ ŞASE GİRİN",
            hintStyle: TextStyle(color: SiberTema.textMuted.withOpacity(0.5)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: SiberTema.textMuted.withOpacity(0.3))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: SiberTema.kuantumCyan, width: 2)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("İPTAL", style: TextStyle(color: SiberTema.textMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kuantumCyan, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _canliSaseCek(saseCtrl.text.trim().toUpperCase());
            },
            child: const Text("SORGULA", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // 🚀 MAKET YIKILDI: DOĞRUDAN KUANTUM AĞINDAN SORGULAMA
  Future<void> _canliSaseCek(String vin) async {
    if (vin.isEmpty || vin.length != 17) {
      _siberBildirim("ŞASE NUMARASI 17 HANELİ OLMALIDIR!", isError: true);
      return;
    }

    setState(() => _sorgulaniyor = true);
    developer.log("SİBER RADAR: $vin numaralı şase Kuantum Ağında taranıyor...");

    try {
      QuerySnapshot snapshot = await _db.collection('araclar').where('sase_no', isEqualTo: vin).limit(1).get();

      if (snapshot.docs.isEmpty) {
        throw Exception("Bu araca ait kayıt bulunamadı. Lütfen aracı sisteme kaydedin.");
      }

      var data = snapshot.docs.first.data() as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _hamVinVerisi = {
            "ÜRETİCİ": data['marka'] ?? "BİLİNMİYOR",
            "MODEL": data['model'] ?? "BİLİNMİYOR",
            "YIL": data['yil'] ?? "BİLİNMİYOR",
            "ARAÇ TİPİ": data['arac_tipi'] ?? "Otomobil",
            "YAKIT TİPİ": data['yakit_tipi'] ?? "Benzin",
          };
          _tarananSase = vin;
          secilenAracTipi = data['arac_tipi'];
          secilenYakitTipi = data['yakit_tipi'];
          _denetimRaporu.clear();
        });
        _siberBildirim("ARAÇ BİLGİLERİ EŞLEŞTİRİLDİ! ✅");
      }
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Şase bulunamadı!", error: e);
      _siberBildirim(e.toString().replaceAll("Exception: ", ""), isError: true);
    } finally {
      if (mounted) setState(() => _sorgulaniyor = false);
    }
  }

  // ── ⛓️ ATOMİK MÜHÜRLEME (WRITEBATCH) ───────────────────────────────────
  Future<void> _raporuKarargahaMuhurle() async {
    if (_denetimRaporu.isEmpty) {
      _siberBildirim("HATA: En az bir modülü denetlemelisiniz!", isError: true);
      return;
    }

    setState(() => _muhurleniyor = true);
    String ustaId = _kullanici?.uid ?? "ANONIM_USTA";

    try {
      developer.log("SİBER HAREKAT: Rapor atomik füzelerle kasaya kilitleniyor...");

      WriteBatch batch = _db.batch();

      // 1. Raporu Ekspertiz Arşivine Mühürle
      DocumentReference raporRef = _db.collection('ekspertiz_raporlari').doc();
      batch.set(raporRef, {
        'rapor_id': raporRef.id,
        'usta_id': ustaId,
        'sase_no': _tarananSase ?? 'MANUEL_GIRIS',
        'arac_tipi': secilenAracTipi,
        'yakit_tipi': secilenYakitTipi,
        'test_sonuclari': _denetimRaporu,
        'tarih': FieldValue.serverTimestamp(),
        'durum': 'SISTEM_ONAYLI',
      });

      // 2. Kara Kutuya (Sistem Logları) Fişi Kes
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'YENI_EKSPERTIZ_RAPORU',
        'islem_detayi': '$ustaId ID\'li personel, ${_tarananSase ?? "Manuel"} şaseli araç için denetim raporu onayladı.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      developer.log("SİBER ONAY: ✅ Rapor başarıyla onaylandı!");
      _siberBildirim("RAPOR ONAYLANDI VE SİSTEME İŞLENDİ.");

      // İşlem sonrası ekranı temizle
      if (mounted) {
        setState(() {
          _denetimRaporu.clear();
          _hamVinVerisi = null;
          _tarananSase = null;
        });
      }
    } catch (e) {
      developer.log("HATA: Mühürleme başarısız!", error: e);
      _siberBildirim("HATA: Rapor kaydedilemedi. Bağlantınızı kontrol edin!", isError: true);
    } finally {
      if (mounted) setState(() => _muhurleniyor = false);
    }
  }

  // ── 🔧 ARAYÜZ YARDIMCILARI (PLAZA KART STİLİ) ─────────────────────────
  Widget _buildVinSonucKarti() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: SiberTema.siberKutuZirhi,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car_filled, color: SiberTema.kuantumCyan, size: 20),
              const SizedBox(width: 8),
              Text("SİSTEM ARAÇ VERİSİ", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
          Divider(color: Colors.black.withOpacity(0.05), height: 20),
          ..._hamVinVerisi!.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text("${e.key}: ", style: TextStyle(color: SiberTema.textMuted, fontSize: 12, letterSpacing: 1)),
                Expanded(child: Text("${e.value}", style: TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.bold))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSiberAramaKutusu(List<String> items, String? selectedValue, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          isExpanded: true,
          value: selectedValue,
          icon: Icon(Icons.keyboard_arrow_down, color: SiberTema.textMuted),
          style: TextStyle(color: SiberTema.textMain, fontSize: 14, fontWeight: FontWeight.w600),
          hint: Text("Seçiniz...", style: TextStyle(color: SiberTema.textMuted.withOpacity(0.7), fontSize: 13)),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  List<Widget> _dinamikModulleriUret() {
    List<Widget> moduller = [];
    if (secilenAracTipi == null) {
      return [Padding(padding: const EdgeInsets.all(20), child: Text("SİSTEM BEKLEMEDE... LÜTFEN ARAÇ TİPİ SEÇİN.", style: TextStyle(color: SiberTema.textMuted, letterSpacing: 1.0, fontSize: 12)))];
    }

    if (secilenYakitTipi == 'Elektrik (EV)' || secilenYakitTipi == 'Hibrit') {
      moduller.add(_buildKayitMotoruKarti("YÜKSEK VOLTAJ BATARYASI (%SOH)", "BATARYA_SOH", Icons.battery_charging_full, zorunluFoto: true));
      moduller.add(_buildKayitMotoruKarti("İNVERTÖR & ELEKTRİK SOKETLERİ", "EV_INVERTOR", Icons.electrical_services));
    }
    if (secilenYakitTipi == 'Benzin' || secilenYakitTipi == 'Dizel' || secilenYakitTipi == 'LPG & CNG' || secilenYakitTipi == 'Hibrit') {
      moduller.add(_buildKayitMotoruKarti("MOTOR MEKANİK & SIVI KAÇAKLARI", "ICE_MOTOR", Icons.build, zorunluFoto: true));
    }
    if (secilenYakitTipi == 'Benzin' || secilenYakitTipi == 'LPG & CNG' || secilenYakitTipi == 'Hibrit') {
      moduller.add(_buildKayitMotoruKarti("ATEŞLEME SİSTEMİ (BUJİ/BOBİN)", "BENZIN_ATESLEME", Icons.local_fire_department_outlined));
    }
    if (secilenYakitTipi == 'Dizel') {
      moduller.add(_buildKayitMotoruKarti("DPF (PARTİKÜL) & ADBLUE SİSTEMİ", "DIZEL_DPF", Icons.filter_alt_outlined, zorunluFoto: true));
      moduller.add(_buildKayitMotoruKarti("TURBO & ENJEKTÖR KONTROLÜ", "DIZEL_TURBO", Icons.settings_input_component));
    }
    if (secilenYakitTipi != 'Elektrik (EV)' && secilenAracTipi != 'Motosiklet') {
      moduller.add(_buildKayitMotoruKarti("EGZOZ EMİSYON KONTROLÜ", "ICE_EGZOZ", Icons.cloud_outlined));
    }
    if (secilenYakitTipi == 'LPG & CNG') {
      moduller.add(_buildKayitMotoruKarti("LPG/CNG TANK TARİHİ & SIZDIRMAZLIK", "LPG_TANK", Icons.warning_amber_rounded, isCritical: true, zorunluFoto: true));
    }
    if (['Kamyon', 'Otobüs'].contains(secilenAracTipi)) {
      moduller.add(_buildKayitMotoruKarti("HAVALI FREN & SÜSPANSİYON SİSTEMİ", "AGIR_FREN", Icons.air_outlined, isCritical: true, zorunluFoto: true));
      moduller.add(_buildKayitMotoruKarti("TAKOGRAF & HIZ SINIRLAYICI KONTROLÜ", "AGIR_TAKOGRAF", Icons.speed_outlined));
    }
    if (['Minibüs', 'Panelvan / Kamyonet'].contains(secilenAracTipi)) {
      moduller.add(_buildKayitMotoruKarti("MAKAS, DİNGİL & YÜK ALANI KONTROLÜ", "TICARI_MAKAS", Icons.local_shipping_outlined, zorunluFoto: true));
    }
    if (['İş Makinesi', 'Traktör / Zirai'].contains(secilenAracTipi)) {
      moduller.add(_buildKayitMotoruKarti("HİDROLİK SİSTEMLER & PİSTONLAR", "HIDROLIK_SISTEM", Icons.precision_manufacturing_outlined, isCritical: true, zorunluFoto: true));
      moduller.add(_buildKayitMotoruKarti("AĞIR HİZMET ŞANZIMAN & GÜÇ AKTARIM", "AGIR_SANZIMAN", Icons.settings_applications_outlined));
    }
    if (secilenAracTipi == 'Motosiklet') {
      moduller.add(_buildKayitMotoruKarti("ZİNCİR & DİŞLİ / KAYIŞ SETİ", "MOTO_ZINCIR", Icons.settings_input_component_outlined));
      moduller.add(_buildKayitMotoruKarti("ÖN MAŞA KEÇE KONTROLÜ", "MOTO_MASA", Icons.two_wheeler_outlined));
    } else if (!['İş Makinesi', 'Traktör / Zirai'].contains(secilenAracTipi)) {
      moduller.add(_buildKayitMotoruKarti("KAPORTA, BOYA & MİKRON", "GENEL_KAPORTA", Icons.format_paint_outlined, zorunluFoto: true));
    }
    moduller.add(_buildKayitMotoruKarti("ŞASE, PODYE & ALT TAKIM", "GENEL_SASE", Icons.security, isCritical: true, zorunluFoto: true));

    return moduller;
  }

  Widget _buildKayitMotoruKarti(String baslik, String modulKodu, IconData ikon, {bool isCritical = false, bool zorunluFoto = false}) {
    String mevcutDurum = _denetimRaporu[modulKodu] ?? "BEKLIYOR";
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: mevcutDurum == "ONAYLANDI"
            ? Colors.green.withOpacity(0.05)
            : (mevcutDurum == "REDDEDILDI" || isCritical) ? SiberTema.kanKirmizi.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: mevcutDurum == "ONAYLANDI"
                ? Colors.green.withOpacity(0.5)
                : mevcutDurum == "REDDEDILDI" ? SiberTema.kanKirmizi.withOpacity(0.5) : (isCritical ? SiberTema.kanKirmizi.withOpacity(0.2) : const Color(0xFFE2E8F0))
        ),
        boxShadow: mevcutDurum == "BEKLIYOR" ? [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
        ] : null,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: mevcutDurum == "ONAYLANDI" ? Colors.green.withOpacity(0.1) : (mevcutDurum == "REDDEDILDI" || isCritical ? SiberTema.kanKirmizi.withOpacity(0.1) : const Color(0xFFFAFAFC)),
            borderRadius: BorderRadius.circular(8)
          ),
          child: Icon(ikon, color: mevcutDurum == "ONAYLANDI" ? Colors.green : (mevcutDurum == "REDDEDILDI" || isCritical ? SiberTema.kanKirmizi : SiberTema.textMuted), size: 22)
        ),
        title: Text(baslik, style: TextStyle(color: SiberTema.textMain, fontWeight: isCritical ? FontWeight.bold : FontWeight.w600, fontSize: 13)),
        subtitle: zorunluFoto ? Text("📸 KANIT YÜKLEMESİ ZORUNLUDUR", style: TextStyle(color: Colors.orange.shade700, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: Icon(mevcutDurum == "REDDEDILDI" ? Icons.close : Icons.close_outlined, color: mevcutDurum == "REDDEDILDI" ? SiberTema.kanKirmizi : SiberTema.textMuted.withOpacity(0.3)),
                onPressed: () => setState(() => _denetimRaporu[modulKodu] = "REDDEDILDI")
            ),
            IconButton(
                icon: Icon(mevcutDurum == "ONAYLANDI" ? Icons.check_circle : Icons.check_circle_outline, color: mevcutDurum == "ONAYLANDI" ? Colors.green : SiberTema.textMuted.withOpacity(0.3)),
                onPressed: () => setState(() => _denetimRaporu[modulKodu] = "ONAYLANDI")
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiberButon(String text, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          shadowColor: color.withOpacity(0.3),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildMuhurleButonu() {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 40),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: SiberTema.textMain, // Koyu Kurumsal Renk
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
          ),
          onPressed: _muhurleniyor ? null : _raporuKarargahaMuhurle,
          child: _muhurleniyor
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : const Text("TÜM RAPORU ONAYLA", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 14)),
        ),
      ),
    );
  }

  void _siberBildirim(String mesaj, {bool isError = false}) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }
}
