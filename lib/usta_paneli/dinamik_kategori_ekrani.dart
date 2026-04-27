import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM DİNAMİK EKSPERTİZ VE TEST MOTORU (OtoDnaKategoriMotoru)
/// Aracın cinsine ve YAKIT tipine göre otonom test modülleri üretir ve Karargaha mühürler.
class OtoDnaKategoriMotoru extends StatefulWidget {
  const OtoDnaKategoriMotoru({super.key});

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

  // ── 🎨 KUANTUM ARAYÜZ (UI) İNŞASI ───────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // 🌑 TAM OLED SİYAHI
      appBar: AppBar(
        title: const Text('KUANTUM EKSPERTİZ MOTORU',
            style: TextStyle(color: Color(0xFF00FFC2), fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF00FFC2)),
      ),
      body: _sorgulaniyor
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FFC2)))
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 📡 SİBER HUB ENTEGRASYONU
            _buildSiberButon(
              "DNA (VIN) İLE OTOMATİK DOLDUR",
              Icons.qr_code_scanner,
              const Color(0xFF111111),
              _saseSorgulaDialog,
            ),

            if (_hamVinVerisi != null) _buildVinSonucKarti(),

            const SizedBox(height: 24),

            // 2. ⚙️ KADEMELİ SEÇİM MOTORU
            const Text("ARAÇ CİNSİ", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
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
              const Text("YAKIT / ENERJİ TİPİ", style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildSiberAramaKutusu(yakitTipleri, secilenYakitTipi, (val) {
                setState(() {
                  secilenYakitTipi = val;
                  _denetimRaporu.clear();
                });
              }),
            ],

            const SizedBox(height: 20),
            const Divider(color: Color(0xFF00FFC2), thickness: 1.0, height: 30),

            // 3. 🧠 YAPAY ZEKA DİNAMİK USTA MODÜLLERİ
            const Text("📋 AKTİF DENETİM MODÜLLERİ",
                style: TextStyle(color: Color(0xFF00FFC2), fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 14)),
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
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF00FFC2), width: 1)),
        title: const Text("DNA (VIN) TARAYICI", style: TextStyle(color: Colors.white, letterSpacing: 1.5)),
        content: TextField(
          controller: saseCtrl,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(color: Color(0xFF00FFC2), fontFamily: 'monospace', fontSize: 18),
          decoration: const InputDecoration(
            hintText: "17 HANELİ ŞASE GİRİN",
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FFC2))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("İPTAL", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FFC2), foregroundColor: Colors.black),
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
        throw Exception("Bu araca ait Karargah kaydı bulunamadı. Lütfen aracı sisteme kaydedin.");
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
        _siberBildirim("SİBER İSTİHBARAT ÇEKİLDİ! ✅");
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
      _siberBildirim("SİBER İHLAL: En az bir modülü denetlemelisiniz!", isError: true);
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
        'durum': 'KARARGAH_ONAYLI',
      });

      // 2. Kara Kutuya (Sistem Logları) Fişi Kes
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'YENI_EKSPERTIZ_RAPORU',
        'islem_detayi': 'SİBER BİLGİ: $ustaId ID\'li usta, ${_tarananSase ?? "Manuel"} şaseli araç için denetim raporu mühürledi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      developer.log("SİBER ONAY: ✅ Rapor Karargah kasasına başarıyla mühürlendi!");
      _siberBildirim("SİBER MÜHÜR VURULDU! RAPOR MERKEZE İLETİLDİ.");

      // İşlem sonrası ekranı temizle
      if (mounted) {
        setState(() {
          _denetimRaporu.clear();
          _hamVinVerisi = null;
          _tarananSase = null;
        });
      }
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Mühürleme başarısız!", error: e);
      _siberBildirim("KARARGAH HATASI: Rapor kilitlenemedi. Ağı kontrol edin!", isError: true);
    } finally {
      if (mounted) setState(() => _muhurleniyor = false);
    }
  }

  // ── 🔧 ARAYÜZ YARDIMCILARI VE SİBER CAM EFEKTİ ─────────────────────────
  Widget _buildVinSonucKarti() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00FFC2).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00FFC2).withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.data_object, color: Color(0xFF00FFC2), size: 18),
                    SizedBox(width: 8),
                    Text("KUANTUM FABRİKA VERİSİ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
                const Divider(color: Colors.white24, height: 20),
                ..._hamVinVerisi!.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Text("${e.key}: ", style: const TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 1)),
                      Expanded(child: Text("${e.value}", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSiberAramaKutusu(List<String> items, String? selectedValue, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF00FFC2).withValues(alpha: 0.3), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: const Color(0xFF111111),
          isExpanded: true,
          value: selectedValue,
          icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Color(0xFF00FFC2)),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          hint: const Text("TIKLAYIN VE SEÇİN...", style: TextStyle(color: Colors.white30, letterSpacing: 1.5, fontSize: 12)),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(letterSpacing: 1)));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  List<Widget> _dinamikModulleriUret() {
    List<Widget> moduller = [];
    if (secilenAracTipi == null) {
      return [const Padding(padding: EdgeInsets.all(20), child: Text("SİSTEM BEKLEMEDE... ARAÇ TİPİ SEÇİN.", style: TextStyle(color: Colors.white30, letterSpacing: 1.5)))];
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: mevcutDurum == "ONAYLANDI"
            ? const Color(0xFF00FFC2).withValues(alpha: 0.1)
            : (mevcutDurum == "REDDEDILDI" || isCritical) ? Colors.redAccent.withValues(alpha: 0.1) : const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: mevcutDurum == "ONAYLANDI"
                ? const Color(0xFF00FFC2)
                : mevcutDurum == "REDDEDILDI" ? Colors.redAccent : (isCritical ? Colors.redAccent.withValues(alpha: 0.5) : Colors.transparent)
        ),
      ),
      child: ListTile(
        leading: Icon(ikon, color: isCritical || mevcutDurum == "REDDEDILDI" ? Colors.redAccent : const Color(0xFF00FFC2), size: 28),
        title: Text(baslik, style: TextStyle(color: Colors.white, fontWeight: isCritical ? FontWeight.bold : FontWeight.w600, letterSpacing: 1)),
        subtitle: zorunluFoto ? const Text("📸 KANIT YÜKLEMESİ ZORUNLUDUR", style: TextStyle(color: Colors.orangeAccent, fontSize: 10, letterSpacing: 1)) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: Icon(mevcutDurum == "REDDEDILDI" ? Icons.close : Icons.close_outlined, color: mevcutDurum == "REDDEDILDI" ? Colors.redAccent : Colors.white30),
                onPressed: () => setState(() => _denetimRaporu[modulKodu] = "REDDEDILDI")
            ),
            IconButton(
                icon: Icon(mevcutDurum == "ONAYLANDI" ? Icons.check_circle : Icons.check_circle_outline, color: mevcutDurum == "ONAYLANDI" ? const Color(0xFF00FFC2) : Colors.white30),
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
        icon: Icon(icon, color: const Color(0xFF00FFC2)),
        label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: const Color(0xFF00FFC2).withValues(alpha: 0.5), width: 1.5)),
          elevation: 5,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildMuhurleButonu() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 40),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FFC2),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _muhurleniyor ? null : _raporuKarargahaMuhurle,
          child: _muhurleniyor
              ? const CircularProgressIndicator(color: Colors.black)
              : const Text("TÜM RAPORU MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 16)),
        ),
      ),
    );
  }

  void _siberBildirim(String mesaj, {bool isError = false}) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF00FFC2),
    ));
  }
}
