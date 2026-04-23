import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

// ⚙️ MODELLER
import '../models/report_model.dart';

/// 🧬 DİJİTAL REFERANS VE EKSPERTİZ KOKPİTİ
/// Kuantum Konum ve Ticari Algoritmalarla donatılmış SaaS Ekspertiz Merkezi
class EkspertizKokpitiScreen extends StatefulWidget {
  final String aracId;
  final String saseNo;
  final String bayiAdi;
  
  // 🕸️ KUANTUM İSTİHBARAT AĞI BİLGİLERİ (Ustanın Profilinden Gelecek)
  final String countryId;
  final String regionId;
  final String cityId;
  final String districtId;

  const EkspertizKokpitiScreen({
    super.key,
    required this.aracId,
    required this.saseNo,
    required this.bayiAdi,
    required this.countryId,
    required this.regionId,
    required this.cityId,
    required this.districtId,
  });

  @override
  State<EkspertizKokpitiScreen> createState() => _EkspertizKokpitiScreenState();
}

class _EkspertizKokpitiScreenState extends State<EkspertizKokpitiScreen> {
  // Karargahın Kontrol Edeceği Kritik Parçalar
  final Map<String, Map<String, dynamic>> _kontrolListesi = {
    'Motor Bloğu & Pistonlar': {'durum': 'bekliyor', 'fotoUrl': null},
    'Şanzıman & Vites Geçişleri': {'durum': 'bekliyor', 'fotoUrl': null},
    'Fren Balataları & Diskler': {'durum': 'bekliyor', 'fotoUrl': null},
    'Şase & Taşıyıcı Direkler': {'durum': 'bekliyor', 'fotoUrl': null},
    'Süspansiyon & Amortisör': {'durum': 'bekliyor', 'fotoUrl': null},
    'Elektrik & Akü Sistemi': {'durum': 'bekliyor', 'fotoUrl': null},
  };

  bool _isSaving = false;
  final TextEditingController _ekspertizUcretiCtrl = TextEditingController(text: "5000");

  double get _ekspertizUcreti => double.tryParse(_ekspertizUcretiCtrl.text) ?? 0.0;
  double get _komisyonOrani => widget.bayiAdi.trim().toLowerCase() == "murat plaza" ? 0.30 : 0.12;
  double get _gaziPayi => _ekspertizUcreti * _komisyonOrani;
  double get _bayiHakedisi => _ekspertizUcreti - _gaziPayi;

  int get _hesaplananMotorSkoru {
    int saglamSayisi = _kontrolListesi.values.where((d) => d['durum'] == 'saglam').length;
    int toplam = _kontrolListesi.length;
    if (toplam == 0) return 0;
    return ((saglamSayisi / toplam) * 100).toInt();
  }

  // --- 📸 SİBER KAMERA ---
  Future<void> _fotografYukleSimulasyonu(String parcaAdi) async {
    _siberUyariVer("Kamera Açılıyor... Hasar tespit ediliyor.", false);
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(seconds: 1)); 
    setState(() {
      _kontrolListesi[parcaAdi]!['fotoUrl'] = 'https://siberkarargah.com/kanit/hasar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    });
    _siberUyariVer("KANIT ONAYLANDI: Fotoğraf ağa mühürlendi.", false);
  }

  // --- 🔴 FİREBASE: OTO DNA REPORT MÜHÜRLEME ---
  Future<void> _ekspertiziKuantumAgaMuhurle() async {
    setState(() => _isSaving = true);
    HapticFeedback.heavyImpact();

    try {
      bool kritikHataVarMi = false;
      Map<String, dynamic> kaportaDurumu = {};

      for (var entry in _kontrolListesi.entries) {
        String parcaAdi = entry.key;
        Map<String, dynamic> detay = entry.value;

        if (detay['durum'] == 'bekliyor') {
          _siberUyariVer("EKSİK KONTROL: Lütfen tüm donanımları test edin.", true);
          setState(() => _isSaving = false);
          return;
        }

        bool isArizali = detay['durum'] == 'arizali';
        if (isArizali) kritikHataVarMi = true;

        kaportaDurumu[parcaAdi] = isArizali ? "Ağır Hasarlı/Değişmiş" : "Orijinal";
      }

      // Modelin Oluşturulması
      OtoDNAReport rapor = OtoDNAReport(
        raporNo: "OTODNA-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}",
        saseNo: widget.saseNo,
        bayiAdi: widget.bayiAdi,
        countryId: widget.countryId,
        regionId: widget.regionId,
        cityId: widget.cityId,
        districtId: widget.districtId,
        motorPerformans: _hesaplananMotorSkoru,
        kaportaDurumu: kaportaDurumu,
        kritikHataVarMi: kritikHataVarMi,
        ekspertizUcreti: _ekspertizUcreti,
        komisyonOrani: _komisyonOrani,
      );

      // TODO: Firebase'e Yazma İşlemi (rapor.toMap())
      await Future.delayed(const Duration(seconds: 2)); // DB Simülasyonu

      if (!kritikHataVarMi) {
        _siberUyariVer("DİJİTAL REFERANS (DNA) OLUŞTURULDU VE MÜHÜRLENDİ! 🦅", false);
      } else {
        _siberUyariVer("🚨 RİSKLİ ARAÇ! Rapor Kuantum İstihbaratına Raporlandı.", true);
      }

      if (!mounted) return;
      Navigator.pop(context);

    } catch (e) {
      if (!mounted) return;
      _siberUyariVer("SİSTEM ÇÖKTÜ: ${e.toString()}", true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _siberUyariVer(String mesaj, bool isError) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir', fontSize: 12)),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.8),
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: const Text("🧬 DNA EKSPERTİZ TERMINALİ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 13, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // SİBER İSTİHBARAT RADAR BAŞLIĞI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white12, width: 1)),
                color: SiberTema.matGrey,
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: SiberTema.kanKirmizi, size: 16),
                  const SizedBox(width: 8),
                  Text("Adli Konum: ${widget.cityId} / ${widget.districtId}", style: const TextStyle(color: SiberTema.kanKirmizi, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const Spacer(),
                  const Icon(Icons.memory, color: SiberTema.kuantumCyan, size: 16),
                  const SizedBox(width: 8),
                  Text("%$_hesaplananMotorSkoru", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.w900)),
                ],
              ),
            ),

            // KONTROL LİSTESİ
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _kontrolListesi.length,
                itemBuilder: (context, index) {
                  String parcaAdi = _kontrolListesi.keys.elementAt(index);
                  Map<String, dynamic> detay = _kontrolListesi[parcaAdi]!;
                  return _buildKompaktSatir(parcaAdi, detay);
                },
              ),
            ),

            // 💰 KUANTUM FİNANS BİLANÇOSU (ŞEFFAF KOMİSYON)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                border: const Border(top: BorderSide(color: SiberTema.sariAltin, width: 2)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(child: Text("Ekspertiz Ücreti (TL):", style: TextStyle(color: Colors.white54, fontSize: 12))),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _ekspertizUcretiCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          style: const TextStyle(color: SiberTema.sariAltin, fontWeight: FontWeight.bold),
                          onChanged: (val) => setState(() {}),
                          decoration: const InputDecoration(isDense: true, enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24))),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("OtoDNA Payı (Gazi Kasası):", style: TextStyle(color: Colors.white54, fontSize: 12)),
                      Text("-${_gaziPayi.toStringAsFixed(2)} ₺", style: const TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Colors.white24, height: 1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("ESNAF NET HAKEDİŞİ:", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.bold)),
                      Text("${_bayiHakedisi.toStringAsFixed(2)} ₺", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ),
            ),

            // ONAY BUTONU
            Container(
              padding: const EdgeInsets.all(20),
              color: SiberTema.matGrey,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SiberTema.kuantumCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isSaving ? null : _ekspertiziKuantumAgaMuhurle,
                  icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)) : const Icon(Icons.fingerprint, size: 20),
                  label: Text(_isSaving ? "MÜHÜRLENİYOR..." : "DNA RAPORUNU AĞA İŞLE", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, fontFamily: 'Avenir')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKompaktSatir(String parcaAdi, Map<String, dynamic> detay) {
    bool isSaglam = detay['durum'] == 'saglam';
    bool isArizali = detay['durum'] == 'arizali';
    bool fotoYuklendi = detay['fotoUrl'] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSaglam ? SiberTema.kuantumCyan.withOpacity(0.3) : isArizali ? SiberTema.kanKirmizi.withOpacity(0.3) : Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(parcaAdi, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w600))),

          if (isArizali) ...[
            GestureDetector(
              onTap: () => _fotografYukleSimulasyonu(parcaAdi),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: fotoYuklendi ? SiberTema.kuantumCyan.withOpacity(0.1) : SiberTema.altinSari.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: fotoYuklendi ? SiberTema.kuantumCyan : SiberTema.altinSari),
                ),
                child: Icon(fotoYuklendi ? Icons.check_circle : Icons.camera_alt, color: fotoYuklendi ? SiberTema.kuantumCyan : SiberTema.altinSari, size: 18),
              ),
            ),
          ],

          // Yeşil Tık
          GestureDetector(
            onTap: () {
              setState(() {
                _kontrolListesi[parcaAdi]!['durum'] = 'saglam';
                _kontrolListesi[parcaAdi]!['fotoUrl'] = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSaglam ? SiberTema.kuantumCyan.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isSaglam ? SiberTema.kuantumCyan : Colors.white12),
              ),
              child: Icon(Icons.check, color: isSaglam ? SiberTema.kuantumCyan : Colors.white30, size: 20),
            ),
          ),
          const SizedBox(width: 8),

          // Kırmızı X
          GestureDetector(
            onTap: () => setState(() => _kontrolListesi[parcaAdi]!['durum'] = 'arizali'),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isArizali ? SiberTema.kanKirmizi.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: isArizali ? SiberTema.kanKirmizi : Colors.white12),
              ),
              child: Icon(Icons.close, color: isArizali ? SiberTema.kanKirmizi : Colors.white30, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}