import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// SİBER ZIRHLAR VE SERVİSLER
import '../services/torpido_servisi.dart';
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class TorpidoEklemeScreen extends StatefulWidget {
  final String kullaniciId;
  final String aracId;
  final String plaka;

  const TorpidoEklemeScreen({
    super.key,
    required this.kullaniciId,
    required this.aracId,
    required this.plaka,
  });

  @override
  State<TorpidoEklemeScreen> createState() => _TorpidoEklemeScreenState();
}

class _TorpidoEklemeScreenState extends State<TorpidoEklemeScreen> {
  final TorpidoServisi _torpidoServisi = TorpidoServisi();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = false;

  // SİBER RENK PALETİ
  final Color _bgKaranlik = const Color(0xFF050505);
  final Color _neonCyan = const Color(0xFF00F0FF);
  final Color _kanKirmizi = const Color(0xFFFF2A2A);

  Future<void> _belgeYukle(ImageSource source) async {
    Navigator.pop(context); // Seçim panelini kapat
    setState(() => _isLoading = true);

    final sonuc = await _torpidoServisi.torpidoyaBelgeEkle(
      kullaniciId: widget.kullaniciId,
      aracId: widget.aracId,
      source: source,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    _siberUyariVer(
      sonuc['mesaj'],
      isError: !sonuc['basarili'],
    );
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, fontFamily: 'Avenir', letterSpacing: 1)),
        backgroundColor: isError ? _kanKirmizi : _neonCyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _veriKaynagiSeciciyiAc() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _bgKaranlik.withOpacity(0.9),
                border: Border(top: BorderSide(color: _neonCyan.withOpacity(0.5), width: 2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 24),
                  const Text("SİBER TARAYICI KAYNAĞI", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                  const SizedBox(height: 24),

                  _buildSecimButonu(Icons.camera_outlined, "RADAR KAMERA", "Belgeyi anında tara ve kes", () => _belgeYukle(ImageSource.camera)),
                  const SizedBox(height: 12),
                  _buildSecimButonu(Icons.photo_library_outlined, "VERİ ARŞİVİ", "Galeriden mevcut belgeyi seç", () => _belgeYukle(ImageSource.gallery)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecimButonu(IconData ikon, String baslik, String altBaslik, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: _neonCyan.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _neonCyan.withOpacity(0.1), shape: BoxShape.circle), child: Icon(ikon, color: _neonCyan)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(baslik, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1)),
                  Text(altBaslik, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, fontFamily: 'Avenir')),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
          ],
        ),
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
          leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: _neonCyan), onPressed: () => Navigator.pop(context)),
          title: Column(
            children: [
              Text("AKILLI TORPİDO", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2, fontFamily: 'Avenir')),
              Text(widget.plaka, style: TextStyle(color: _neonCyan, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            ],
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: _neonCyan,
          foregroundColor: _bgKaranlik,
          onPressed: _isLoading ? null : _veriKaynagiSeciciyiAc,
          child: _isLoading ? const CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 3) : const Icon(Icons.document_scanner, size: 28),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05),
          ),
          child: StreamBuilder<DocumentSnapshot>(
            stream: _db.collection('araclar').doc(widget.aracId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: _neonCyan));
              if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) return _buildBosSiberKasa("Siber Ağ Bağlantısı Koptu!");

              final aracVerisi = snapshot.data!.data() as Map<String, dynamic>? ?? {};
              final List<dynamic> belgeler = aracVerisi['torpido_belgeleri'] ?? [];

              if (belgeler.isEmpty) return _buildBosSiberKasa("TORPİDO BOŞ\n(Belge mühürlenmedi)");

              return GridView.builder(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: belgeler.length,
                itemBuilder: (context, index) {
                  // Son yüklenen en üstte çıksın
                  final belge = belgeler[belgeler.length - 1 - index];
                  final String resimUrl = belge['resim_url'] ?? '';

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _neonCyan.withOpacity(0.2)),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: InteractiveViewer(
                                child: Image.network(
                                  resimUrl,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(child: CircularProgressIndicator(color: _neonCyan.withOpacity(0.5)));
                                  },
                                ),
                              ),
                            ),
                            // Mühür Tarihi Zırhı
                            Positioned(
                              bottom: 0, left: 0, right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [_bgKaranlik, Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                                ),
                                child: Center(
                                  child: Text(
                                    "Kayıtlı Belge",
                                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontFamily: 'Avenir', fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBosSiberKasa(String mesaj) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _neonCyan.withOpacity(0.2), width: 2)),
            child: Icon(Icons.document_scanner_outlined, size: 48, color: _neonCyan.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text(mesaj, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w900, fontFamily: 'Avenir', height: 1.5)),
        ],
      ),
    );
  }
}