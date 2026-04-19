// lib/screens/ekspertiz_kokpiti_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

// ⚙️ ARKA PLAN MOTORLARI
import '../services/muayene_ekrani.dart';
import '../commerce/eco_system_gate.dart';

class EkspertizKokpitiScreen extends StatefulWidget {
  final String aracId;
  final String bayiId;

  const EkspertizKokpitiScreen({
    super.key,
    required this.aracId,
    required this.bayiId,
  });

  @override
  State<EkspertizKokpitiScreen> createState() => _EkspertizKokpitiScreenState();
}

class _EkspertizKokpitiScreenState extends State<EkspertizKokpitiScreen> {
  // Arka plan Kuantum Motorlarını Çağır
  final EkspertizServisi _ekspertizServisi = EkspertizServisi();
  final OtoDnaEcoSystem _ecoSystem = OtoDnaEcoSystem();

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

  // --- 📸 FİREBASE: SİMÜLE EDİLMİŞ FOTOĞRAF YÜKLEME ---
  Future<void> _fotografYukleSimulasyonu(String parcaAdi) async {
    _siberUyariVer("Kamera Açılıyor... Hasar tespit ediliyor.", false);
    await Future.delayed(const Duration(seconds: 1)); // Gerçek kamera gecikmesi simülasyonu
    setState(() {
      _kontrolListesi[parcaAdi]!['fotoUrl'] = 'https://siberkarargah.com/kanit/hasar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    });
    _siberUyariVer("KANIT ONAYLANDI: Hasar fotoğrafı ağa mühürlendi.", false);
  }

  // --- 🔴 FİREBASE: GERÇEK MÜHÜRLEME PROTOKOLÜ ---
  Future<void> _ekspertiziKuantumAgaMuhurle() async {
    setState(() => _isSaving = true);

    try {
      bool kritikHataVarMi = false;

      // Tüm listeyi tara ve senin EkspertizServisi motoruna yolla
      for (var entry in _kontrolListesi.entries) {
        String parcaAdi = entry.key;
        Map<String, dynamic> detay = entry.value;

        if (detay['durum'] == 'bekliyor') {
          _siberUyariVer("EKSİK KONTROL: Lütfen tüm parçaları test edin.", true);
          setState(() => _isSaving = false);
          return;
        }

        bool isSafe = detay['durum'] == 'saglam';
        String fotoUrl = detay['fotoUrl'] ?? (isSafe ? 'GEREK_YOK' : '');

        // 🚀 1. DÜZELTME: Senin motorun bir şey dönmüyor (void), Hata varsa throw fırlatıyor.
        await _ekspertizServisi.kontrolNoktasiGuncelle(
          aracId: widget.aracId,
          bayiId: widget.bayiId,
          parcaAdi: parcaAdi,
          isSafe: isSafe,
          detay: isSafe ? "Sorunsuz" : "Ağır Hasar Tespit Edildi",
          fotoUrl: fotoUrl,
        );

        // Eğer parça arızalıysa, Karargah Ticaret Motorunu (%12 Pay) anında tetikle!
        if (!isSafe) {
          kritikHataVarMi = true;
          // 🚀 2. DÜZELTME: Senin Ticaret motorun benden "bayiId" istiyordu, eklendi!
          await _ecoSystem.parcaOner(
            plakaID: widget.aracId,
            sorunluParca: parcaAdi,
            parcaSatisFiyati: 4500.00,
            saticiBayiAdi: "Murat Plaza",
            bayiId: widget.bayiId,
          );
        }
      }

      // Tüm kontroller bittiyse ve araç sağlamsa Dijital Referans Mührünü Vur
      if (!kritikHataVarMi) {
        await _ecoSystem.ilanaKoy(widget.aracId);
        _siberUyariVer("DİJİTAL REFERANS (DNA) OLUŞTURULDU VE MÜHÜRLENDİ! 🦅", false);
      } else {
        _siberUyariVer("🚨 ARAÇ TRAFİĞE KAPATILDI! Yedek parça siparişi geçildi.", true);
      }

      if (!mounted) return;
      Navigator.pop(context);

    } catch (e) {
      // Motorlarından fırlatılan "SİBER İHLAL" Exception'ları buraya düşecek!
      if (!mounted) return;
      String hataMesaji = e.toString().replaceAll("Exception: ", "");
      _siberUyariVer(hataMesaji, true);
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: const Text("DİJİTAL REFERANS PROTOKOLÜ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white12, width: 1)),
                color: SiberTema.matGrey,
              ),
              child: const Row(
                children: [
                  Icon(Icons.radar, color: SiberTema.altinSari, size: 16),
                  SizedBox(width: 8),
                  Text("ARAÇ DNA TARAMASI DEVAM EDİYOR...", style: TextStyle(color: SiberTema.altinSari, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                ],
              ),
            ),

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

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SiberTema.matGrey,
                border: const Border(top: BorderSide(color: Colors.white12, width: 1)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 20, offset: const Offset(0, -10))],
              ),
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
                  icon: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Icon(Icons.fingerprint, size: 20),
                  label: Text(
                      _isSaving ? "MÜHÜRLENİYOR..." : "DNA RAPORUNU AĞA İŞLE",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, fontFamily: 'Avenir')
                  ),
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
          Expanded(
            child: Text(
              parcaAdi,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Avenir',
              ),
            ),
          ),

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
                child: Icon(
                  fotoYuklendi ? Icons.check_circle : Icons.camera_alt,
                  color: fotoYuklendi ? SiberTema.kuantumCyan : SiberTema.altinSari,
                  size: 18,
                ),
              ),
            ),
          ],

          // Yeşil Tık (✅) Butonu
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

          // Kırmızı X (❌) Butonu
          GestureDetector(
            onTap: () {
              setState(() {
                _kontrolListesi[parcaAdi]!['durum'] = 'arizali';
              });
            },
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