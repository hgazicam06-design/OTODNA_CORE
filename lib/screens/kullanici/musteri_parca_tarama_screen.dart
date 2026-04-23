import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../core/siber_tema.dart';
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

  Future<void> _aiTaramaBaslat() async {
    if (!_adliProtokolOnaylandi) {
      _siberUyari("YASAL ONAY GEREKLİ", "Devam etmek için Adli Protokolü kabul etmeniz zorunludur.", Colors.orangeAccent);
      return;
    }

    HapticFeedback.heavyImpact();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 95); // Kalite yükseltildi
    
    if (image != null) {
      setState(() {
        _kutuFaturaFoto = File(image.path);
        _islemSuruyor = true;
      });

      try {
        Map<String, dynamic> taramaSonucu = await _torpidoServisi.aiOptikTarama(_kutuFaturaFoto!);
        bool seriNoKullanilmisMi = await _torpidoServisi.seriNoKullanilmisMi(taramaSonucu['benzersizSeriNo']);

        if (seriNoKullanilmisMi) {
          _siberUyari("🚨 KIZIL ALARM", "Bu parça daha önce kullanılmış (Çıkma Parça)! Ustaya bu parçayı taktırmayın.", SiberTema.kanKirmizi);
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
        _siberUyari("✅ GÜVENLİ PARÇA", "Parça orijinal. Bilgiler mühürlenmek üzere usta terminaline gönderiliyor.", SiberTema.kuantumCyan);

      } catch (e) {
        setState(() => _islemSuruyor = false);
        _siberUyari("TARAMA HATASI", e.toString().replaceAll("Exception: ", ""), SiberTema.kanKirmizi);
      }
    }
  }

  void _siberUyari(String baslik, String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.matGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Future<void> _ustayaGonder() async {
    // Gerçekte burada Firebase'e "Bekleyen İşlem" olarak atılır ve Ustanın ekranına düşer.
    HapticFeedback.vibrate();
    _siberUyari("🚀 İLETİLDİ", "İşlem yetkili ustanın onayına sunuldu. Usta işlemi bitirince İki Taraflı Mühür tamamlanacak.", SiberTema.kuantumCyan);
    Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("🔍 ŞEFFAF TARAMA", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2)),
          backgroundColor: Colors.black.withOpacity(0.8),
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          children: [
            const Text("SORUMLULUK SİZDE!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text("Aracınıza takılacak parçanın orijinal olduğundan emin olmak için kutusunu kendiniz tarayın. Sistem sahte parçayı anında tespit eder.", style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5)),
            const SizedBox(height: 24),

            // ⚖️ ADLİ PROTOKOL BEYANI
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SiberTema.kanKirmizi.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(unselectedWidgetColor: Colors.white54),
                    child: Checkbox(
                      value: _adliProtokolOnaylandi,
                      activeColor: SiberTema.kanKirmizi,
                      checkColor: Colors.white,
                      onChanged: (val) {
                        setState(() => _adliProtokolOnaylandi = val ?? false);
                      },
                    ),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        "DİKKAT: Bu sistemdeki veriler Adli Delil niteliğindedir. Olası kaza incelemelerinde hukuki sorumluluk işlemi onaylayan taraflara aittir. OtoDNA donanım ve görsel zafiyetlerinden sorumlu tutulamaz.",
                        style: TextStyle(color: Colors.white70, fontSize: 10, height: 1.5),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),

            if (!_taramaBasarili) ...[
              InkWell(
                onTap: _adliProtokolOnaylandi ? _aiTaramaBaslat : () {
                  _siberUyari("ONAY BEKLENİYOR", "Lütfen önce yukarıdaki hukuki metni okuyup onaylayın.", Colors.orangeAccent);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: _adliProtokolOnaylandi ? SiberTema.kuantumCyan.withOpacity(0.1) : Colors.white12,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _adliProtokolOnaylandi ? SiberTema.kuantumCyan : Colors.white24, width: 2),
                  ),
                  child: _islemSuruyor 
                    ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_scanner, color: _adliProtokolOnaylandi ? SiberTema.kuantumCyan : Colors.white38, size: 48),
                          const SizedBox(height: 12),
                          Text("YAPAY ZEKA İLE TARA", style: TextStyle(color: _adliProtokolOnaylandi ? SiberTema.kuantumCyan : Colors.white38, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        ],
                      ),
                ),
              )
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: SiberTema.kuantumCyan.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified_user, color: SiberTema.kuantumCyan),
                        SizedBox(width: 8),
                        Text("ORİJİNAL PARÇA ONAYI", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    _buildBilgiSatiri("OEM Kodu", _oemKodu!),
                    const SizedBox(height: 12),
                    _buildBilgiSatiri("Seri Numarası", _benzersizSeriNo!),
                    const SizedBox(height: 12),
                    _buildBilgiSatiri("Fatura", _irsaliyeFaturaNo!),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _ustayaGonder,
                icon: const Icon(Icons.send, color: Colors.black),
                label: const Text("USTAYA ONAYA GÖNDER", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SiberTema.kuantumCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        Text(baslik, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(deger, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
