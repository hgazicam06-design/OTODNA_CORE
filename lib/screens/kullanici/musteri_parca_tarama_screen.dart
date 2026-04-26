import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../core/responsive_kalkan.dart';
import '../../services/torpido_servisi.dart';

/// 👁️ MÜŞTERİ OTONOM TARAMA EKRANI (İki Taraflı Mühür - Adım 1)
/// Müşteri ustanın dükkanındayken kendi takılacak parçasını kendisi tarar.
class MusteriParcaTaramaScreen extends StatefulWidget {
  final String aracId;
  final String musteriUid;

  const MusteriParcaTaramaScreen({
    super.key,
    required this.aracId,
    required this.musteriUid,
  });

  @override
  State<MusteriParcaTaramaScreen> createState() => _MusteriParcaTaramaScreenState();
}

class _MusteriParcaTaramaScreenState extends State<MusteriParcaTaramaScreen> {
  final TorpidoServisi _torpidoServisi = TorpidoServisi();
  final ImagePicker _picker = ImagePicker();

  File? _kutuFaturaFoto;
  bool _islemSuruyor = false;
  bool _taramaBasarili = false;
  bool _adliProtokolOnaylandi = false; // Yasal sözleşme onayı

  String? _oemKodu;
  String? _benzersizSeriNo;
  String? _irsaliyeFaturaNo;

  final Color primaryTeal = Colors.teal.shade700;
  final Color dangerColor = Colors.redAccent;
  final Color textColor = const Color(0xFF1E293B);
  final Color bgColor = const Color(0xFFFAFAFC);

  Future<void> _aiTaramaBaslat() async {
    if (!_adliProtokolOnaylandi) {
      _plazaUyari("YASAL ONAY GEREKLİ", "Devam etmek için Adli Protokolü kabul etmeniz zorunludur.", Colors.orange);
      return;
    }

    HapticFeedback.heavyImpact();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 95);
    
    if (image != null) {
      setState(() {
        _kutuFaturaFoto = File(image.path);
        _islemSuruyor = true;
      });

      try {
        Map<String, dynamic> taramaSonucu = await _torpidoServisi.aiOptikTarama(_kutuFaturaFoto!);
        bool seriNoKullanilmisMi = await _torpidoServisi.seriNoKullanilmisMi(taramaSonucu['benzersizSeriNo']);

        if (seriNoKullanilmisMi) {
          _plazaUyari("🚨 KRİTİK ALARM", "Bu parça daha önce kullanılmış (Çıkma Parça)! Ustaya bu parçayı taktırmayın.", dangerColor);
          setState(() => _islemSuruyor = false);
          return;
        }

        setState(() {
          _oemKodu = taramaSonucu['oemKodu'];
          _benzersizSeriNo = taramaSonucu['benzersizSeriNo'];
          _irsaliyeFaturaNo = taramaSonucu['irsaliyeFaturaNo'];
          _islemSuruyor = false;
          _taramaBasarili = true;
        });

        HapticFeedback.vibrate();
        _plazaUyari("✅ GÜVENLİ PARÇA", "Parça orijinal. Bilgiler mühürlenmek üzere usta terminaline gönderiliyor.", primaryTeal);

      } catch (e) {
        setState(() => _islemSuruyor = false);
        _plazaUyari("TARAMA HATASI", e.toString().replaceAll("Exception: ", ""), dangerColor);
      }
    }
  }

  void _plazaUyari(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: renk, width: 2)),
        behavior: SnackBarBehavior.floating,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  Future<void> _ustayaGonder() async {
    HapticFeedback.vibrate();
    _plazaUyari("🚀 İLETİLDİ", "İşlem yetkili ustanın onayına sunuldu. Usta işlemi bitirince Plaza Mührü tamamlanacak.", primaryTeal);
    Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text("ŞEFFAF TARAMA", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14, fontFamily: 'Avenir')),
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
          iconTheme: IconThemeData(color: primaryTeal),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          children: [
            Text("SORUMLULUK SİZDE!", style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: -0.5)),
            const SizedBox(height: 8),
            const Text("Aracınıza takılacak parçanın orijinal olduğundan emin olmak için kutusunu kendiniz tarayın. Sistem sahte parçayı anında tespit eder.", style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            const SizedBox(height: 32),

            // ⚖️ ADLİ PROTOKOL BEYANI
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: dangerColor.withValues(alpha: 0.3)),
                boxShadow: [BoxShadow(color: dangerColor.withValues(alpha: 0.05), blurRadius: 10)]
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(unselectedWidgetColor: Colors.black26),
                    child: Checkbox(
                      value: _adliProtokolOnaylandi,
                      activeColor: dangerColor,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (val) {
                        setState(() => _adliProtokolOnaylandi = val ?? false);
                      },
                    ),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        "DİKKAT: Bu sistemdeki veriler Adli Delil niteliğindedir. Olası kaza incelemelerinde hukuki sorumluluk işlemi onaylayan taraflara aittir. OtoDNA donanım ve görsel zafiyetlerinden sorumlu tutulamaz.",
                        style: TextStyle(color: Colors.black87, fontSize: 11, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),

            if (!_taramaBasarili) ...[
              InkWell(
                onTap: _adliProtokolOnaylandi ? _aiTaramaBaslat : () {
                  _plazaUyari("ONAY BEKLENİYOR", "Lütfen önce yukarıdaki hukuki metni okuyup onaylayın.", Colors.orange);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _adliProtokolOnaylandi ? primaryTeal.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05), width: 2),
                    boxShadow: _adliProtokolOnaylandi ? [BoxShadow(color: primaryTeal.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))] : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))]
                  ),
                  child: _islemSuruyor 
                    ? Center(child: CircularProgressIndicator(color: primaryTeal))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: _adliProtokolOnaylandi ? primaryTeal.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05), shape: BoxShape.circle),
                            child: Icon(Icons.qr_code_scanner, color: _adliProtokolOnaylandi ? primaryTeal : Colors.black26, size: 40)
                          ),
                          const SizedBox(height: 16),
                          Text("YAPAY ZEKA İLE TARA", style: TextStyle(color: _adliProtokolOnaylandi ? primaryTeal : Colors.black38, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                        ],
                      ),
                ),
              )
            ] else ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryTeal.withValues(alpha: 0.3)),
                  boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified_user, color: primaryTeal),
                        const SizedBox(width: 8),
                        Text("ORİJİNAL PARÇA ONAYI", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: Colors.black.withValues(alpha: 0.05), height: 1),
                    ),
                    _buildBilgiSatiri("OEM Kodu", _oemKodu!),
                    const SizedBox(height: 16),
                    _buildBilgiSatiri("Seri Numarası", _benzersizSeriNo!),
                    const SizedBox(height: 16),
                    _buildBilgiSatiri("Fatura Numarası", _irsaliyeFaturaNo!),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _ustayaGonder,
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text("USTAYA ONAYA GÖNDER", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 13, fontFamily: 'Avenir')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildBilgiSatiri(String baslik, String deger) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(baslik, style: const TextStyle(color: Colors.black45, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir', letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(deger, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
      ],
    );
  }
}
