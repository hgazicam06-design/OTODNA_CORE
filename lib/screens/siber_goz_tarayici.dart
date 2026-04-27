import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';

// SİBER TEMA ZIRHI (Eğer import rotası farklıysa güncelle)
import '../core/siber_tema.dart';

class SiberGozTarayici extends StatefulWidget {
  const SiberGozTarayici({super.key});

  @override
  State<SiberGozTarayici> createState() => _SiberGozTarayiciState();
}

class _SiberGozTarayiciState extends State<SiberGozTarayici> with SingleTickerProviderStateMixin {
  CameraController? _kameraKontrolcusu;
  bool _isKameraHazir = false;
  bool _isTaraniyor = false;

  // Radar Animasyonu Kontrolcüsü
  late AnimationController _radarController;
  late Animation<double> _radarAnimation;

  @override
  void initState() {
    super.initState();
    _siberKamerayiBaslat();

    // Radar çizgisi için yukarı-aşağı animasyon
    _radarController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _radarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _radarController, curve: Curves.easeInOut));
  }

  Future<void> _siberKamerayiBaslat() async {
    try {
      final kameralar = await availableCameras();
      if (kameralar.isEmpty) return;

      _kameraKontrolcusu = CameraController(
        kameralar.first, // Arka kamera
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _kameraKontrolcusu!.initialize();
      if (!mounted) return;
      setState(() => _isKameraHazir = true);
    } catch (e) {
      debugPrint("SİBER KAMERA HATASI: $e");
    }
  }

  @override
  void dispose() {
    _kameraKontrolcusu?.dispose();
    _radarController.dispose();
    super.dispose();
  }

  // SİBER TARAMA VE MATRİS ÇÖZÜMLEME SİMÜLASYONU
  void _parcayiMatristeAra() {
    setState(() => _isTaraniyor = true);

    // 🧠 İleride buraya Google ML Kit veya özel bir OCR/Obje Tanıma API'si gelecek.
    // Şimdilik Karargahın gücünü göstermek için 3 saniyelik bir siber analiz simüle ediyoruz.
    Timer(const Duration(seconds: 3), () {
      setState(() => _isTaraniyor = false);
      _siberSonucPaneliniAc();
    });
  }

  // TİCARİ AĞ GEÇİDİ (SONUÇ EKRANI)
  void _siberSonucPaneliniAc() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: SiberTema.oledBlack.withOpacity(0.8),
                border: Border(top: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 50, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 24),

                  // PARÇA KİMLİĞİ
                  Row(
                    children: [
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.memory, color: SiberTema.kuantumCyan, size: 32)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("BOSCH FREN BALATASI TAKIMI", style: TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1)),
                            Text("OEM Kodu: 8V0698151C", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir', letterSpacing: 2)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 32),

                  const Text("TİCARİ AĞ GEÇİDİ (En Yakın Tedarikçiler)", style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                  const SizedBox(height: 16),

                  // TİCARİ SEÇENEKLER (Bu butonlar ileride Oto Marketleri listeleyecek)
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildTicariAksiyonButonu(ikon: Icons.verified, baslik: "ORİJİNAL (SIFIR)", altBaslik: "Murat Plaza Garantili - %30 Marj", renk: Colors.blue),
                        const SizedBox(height: 12),
                        _buildTicariAksiyonButonu(ikon: Icons.settings_suggest, baslik: "YAN SANAYİ (MUADİL)", altBaslik: "A Kalite Onaylı Üretim", renk: Colors.orange),
                        const SizedBox(height: 12),
                        _buildTicariAksiyonButonu(ikon: Icons.recycling, baslik: "ÇIKMA PARÇA", altBaslik: "Test Edilmiş Orijinal Hurda", renk: Colors.green),
                        const SizedBox(height: 12),
                        _buildTicariAksiyonButonu(ikon: Icons.handshake, baslik: "İKİNCİ EL", altBaslik: "Kullanıcıdan Kullanıcıya", renk: Colors.purple),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTicariAksiyonButonu({required IconData ikon, required String baslik, required String altBaslik, required Color renk}) {
    return InkWell(
      onTap: () {
        // İleride haritada o marketi gösterecek rota
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: renk.withOpacity(0.05),
          border: Border.all(color: renk.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(ikon, color: renk, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1)),
                  Text(altBaslik, style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontFamily: 'Avenir')),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: renk.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isKameraHazir || _kameraKontrolcusu == null) {
      return Scaffold(backgroundColor: SiberTema.oledBlack, body: const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan)));
    }

    return Scaffold(
      backgroundColor: SiberTema.oledBlack,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. CANLI KAMERA GÖRÜNTÜSÜ
          CameraPreview(_kameraKontrolcusu!),

          // 2. SİBER CAM FİLTRESİ VE ODAK KUTUSU
          ColorFiltered(
            colorFilter: ColorFilter.mode(SiberTema.oledBlack.withOpacity(0.7), BlendMode.srcOut),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.white, backgroundBlendMode: BlendMode.dstOut),
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.white, // srcOut blend mode için beyaz olması gerekir (şeffaf yapar)
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. RADAR ANİMASYONU VE KÖŞE NİŞANGAHLARI
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              child: Stack(
                children: [
                  // Nişangah Köşeleri
                  _buildNisangahKosesi(Alignment.topLeft),
                  _buildNisangahKosesi(Alignment.topRight),
                  _buildNisangahKosesi(Alignment.bottomLeft),
                  _buildNisangahKosesi(Alignment.bottomRight),

                  // Hareketli Kuantum Tarama Çizgisi
                  if (_isTaraniyor)
                    AnimatedBuilder(
                      animation: _radarAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: _radarAnimation.value * (MediaQuery.of(context).size.width * 0.8 - 4),
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: SiberTema.kuantumCyan,
                              boxShadow: [BoxShadow(color: SiberTema.kuantumCyan, blurRadius: 20, spreadRadius: 5)],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          // 4. ÜST BİLGİ VE ÇIKIŞ
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.close, color: SiberTema.kuantumCyan, size: 32), onPressed: () => Navigator.pop(context)),
                    const SizedBox(width: 8),
                    const Text("SİBER GÖZ AKTİF", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 2)),
                  ],
                ),
              ),
            ),
          ),

          // 5. TARAMA BUTONU
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: GestureDetector(
                onTap: _isTaraniyor ? null : _parcayiMatristeAra,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isTaraniyor ? 80 : 100,
                  height: _isTaraniyor ? 80 : 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isTaraniyor ? SiberTema.oledBlack : SiberTema.kuantumCyan.withOpacity(0.2),
                    border: Border.all(color: SiberTema.kuantumCyan, width: _isTaraniyor ? 2 : 4),
                    boxShadow: _isTaraniyor ? [] : [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.5), blurRadius: 20)],
                  ),
                  child: Center(
                    child: _isTaraniyor
                        ? const CircularProgressIndicator(color: SiberTema.kuantumCyan)
                        : const Icon(Icons.document_scanner, color: SiberTema.kuantumCyan, size: 40),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNisangahKosesi(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: (alignment == Alignment.topLeft || alignment == Alignment.topRight) ? const BorderSide(color: SiberTema.kuantumCyan, width: 4) : BorderSide.none,
            bottom: (alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight) ? const BorderSide(color: SiberTema.kuantumCyan, width: 4) : BorderSide.none,
            left: (alignment == Alignment.topLeft || alignment == Alignment.bottomLeft) ? const BorderSide(color: SiberTema.kuantumCyan, width: 4) : BorderSide.none,
            right: (alignment == Alignment.topRight || alignment == Alignment.bottomRight) ? const BorderSide(color: SiberTema.kuantumCyan, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}