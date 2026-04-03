import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// SİBER TEMA ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class SurusAsistaniScreen extends StatefulWidget {
  final String aracId;
  final String plaka;

  const SurusAsistaniScreen({
    super.key,
    required this.aracId,
    required this.plaka,
  });

  @override
  State<SurusAsistaniScreen> createState() => _SurusAsistaniScreenState();
}

class _SurusAsistaniScreenState extends State<SurusAsistaniScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isHarcamaHesaplaniyor = false;

  // SİBER SENSÖRLER (Kontrolcüler)
  final TextEditingController _neredenCtrl = TextEditingController();
  final TextEditingController _nereyeCtrl = TextEditingController();
  final TextEditingController _mesafeKmCtrl = TextEditingController();
  final TextEditingController _yakitTuketimiCtrl = TextEditingController(); // Örn: 100km'de 6.5 Litre
  final TextEditingController _litreFiyatiCtrl = TextEditingController();

  double _hesaplananMaliyet = 0.0;

  // --- SİBER HESAPLAMA MOTORU ---
  void _maliyetiHesapla() {
    double km = double.tryParse(_mesafeKmCtrl.text) ?? 0.0;
    double tuketim = double.tryParse(_yakitTuketimiCtrl.text) ?? 0.0;
    double fiyat = double.tryParse(_litreFiyatiCtrl.text) ?? 0.0;

    if (km > 0 && tuketim > 0 && fiyat > 0) {
      setState(() {
        _hesaplananMaliyet = (km / 100) * tuketim * fiyat;
      });
    } else {
      _siberUyariVer("SİBER İHLAL: Lütfen KM, Tüketim ve Fiyat verilerini girin.", isError: true);
    }
  }

  // --- MATRİKSE SEYAHAT MÜHRÜ VURMA ---
  Future<void> _seyahatiKarargahaIsle() async {
    if (_neredenCtrl.text.isEmpty || _nereyeCtrl.text.isEmpty || _hesaplananMaliyet <= 0) {
      _siberUyariVer("SİBER İHLAL: Rota ve maliyet hesaplaması eksik!", isError: true);
      return;
    }

    setState(() => _isHarcamaHesaplaniyor = true);

    try {
      await _db.collection('seyahat_gecmisi').add({
        'arac_id': widget.aracId,
        'plaka': widget.plaka,
        'nereden': _neredenCtrl.text.toUpperCase(),
        'nereye': _nereyeCtrl.text.toUpperCase(),
        'mesafe_km': double.parse(_mesafeKmCtrl.text),
        'toplam_maliyet': _hesaplananMaliyet,
        'tarih': FieldValue.serverTimestamp(),
      });

      // Aracın güncel KM bilgisini Kuantum Ağı'nda güncelle
      await _db.collection('araclar').doc(widget.aracId).update({
        'guncel_km': FieldValue.increment(double.parse(_mesafeKmCtrl.text)),
      });

      if (!mounted) return;
      setState(() {
        _isHarcamaHesaplaniyor = false;
        _hesaplananMaliyet = 0.0;
      });

      _neredenCtrl.clear();
      _nereyeCtrl.clear();
      _mesafeKmCtrl.clear();
      _yakitTuketimiCtrl.clear();

      _siberUyariVer("SEYAHAT BAŞARIYLA MÜHÜRLENDİ! Araç KM'si güncellendi.", isError: false);
      FocusScope.of(context).unfocus(); // Klavyeyi indir

    } catch (e) {
      if (!mounted) return;
      setState(() => _isHarcamaHesaplaniyor = false);
      _siberUyariVer("SİBER AĞ HATASI: Veri buluta iletilemedi.", isError: true);
    }
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, fontFamily: 'Avenir', letterSpacing: 1)),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
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
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: Column(
            children: [
              Text("SÜRÜŞ ASİSTANI", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2, fontFamily: 'Avenir')),
              Text(widget.plaka, style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            ],
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KUANTUM HESAPLAYICI (SİBER CAM)
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.route, color: SiberTema.kuantumCyan, size: 28),
                              const SizedBox(width: 12),
                              const Text("ROTA VE MALİYET", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(child: _buildSiberGirdi("Nereden?", Icons.my_location, _neredenCtrl, TextInputType.text)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildSiberGirdi("Nereye?", Icons.flag, _nereyeCtrl, TextInputType.text)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildSiberGirdi("Mesafe (KM)", Icons.add_road, _mesafeKmCtrl, TextInputType.number)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildSiberGirdi("Litre Fiyatı (₺)", Icons.local_gas_station, _litreFiyatiCtrl, TextInputType.number)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSiberGirdi("Ort. Tüketim (L/100km)", Icons.speed, _yakitTuketimiCtrl, TextInputType.number),

                          const SizedBox(height: 24),

                          // HESAPLAMA EKRANI VE BUTON
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("TOPLAM MALİYET", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                                  Text("₺${_hesaplananMaliyet.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                                ],
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SiberTema.kuantumCyan.withOpacity(0.1),
                                  foregroundColor: SiberTema.kuantumCyan,
                                  side: const BorderSide(color: SiberTema.kuantumCyan, width: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _maliyetiHesapla,
                                child: const Text("HESAPLA", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Avenir', letterSpacing: 1)),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // KARARGAHA İŞLE BUTONU
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: SiberTema.kuantumButonStili(),
                              onPressed: (_hesaplananMaliyet > 0 && !_isHarcamaHesaplaniyor) ? _seyahatiKarargahaIsle : null,
                              child: _isHarcamaHesaplaniyor
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 2))
                                  : const Text("SEYAHATİ KARARGAHA MÜHÜRLE", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text("SON SEYAHAT KAYITLARI", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                ),
                const SizedBox(height: 16),

                // CANLI SEYAHAT VERİLERİ (FIREBASE STREAM)
                StreamBuilder<QuerySnapshot>(
                  stream: _db.collection('seyahat_gecmisi').where('arac_id', isEqualTo: widget.aracId).orderBy('tarih', descending: true).limit(5).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
                    if (snapshot.hasError) return const Center(child: Text("Siber Ağa Ulaşılamıyor.", style: TextStyle(color: SiberTema.kanKirmizi)));

                    final seyahatler = snapshot.data?.docs ?? [];

                    if (seyahatler.isEmpty) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(16)),
                          child: Text("Henüz Kuantum ağına mühürlenmiş bir seyahat bulunmuyor.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.4), fontFamily: 'Avenir')),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: seyahatler.length,
                      itemBuilder: (context, index) {
                        final veri = seyahatler[index].data() as Map<String, dynamic>;
                        final tarih = (veri['tarih'] as Timestamp?)?.toDate() ?? DateTime.now();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.swap_calls, color: SiberTema.kuantumCyan),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${veri['nereden']} ➔ ${veri['nereye']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Avenir', fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text("${veri['mesafe_km']} KM | ${tarih.day}.${tarih.month}.${tarih.year}", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontFamily: 'Avenir')),
                                  ],
                                ),
                              ),
                              Text("₺${veri['toplam_maliyet'].toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontFamily: 'Avenir', fontSize: 14)),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- SİBER GİRDİ ZIRHI ---
  Widget _buildSiberGirdi(String baslik, IconData ikon, TextEditingController kontrolcu, TextInputType klavye) {
    return TextField(
      controller: kontrolcu,
      keyboardType: klavye,
      style: const TextStyle(color: Colors.white, fontFamily: 'Avenir', fontWeight: FontWeight.bold, fontSize: 12),
      decoration: InputDecoration(
        labelText: baslik,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontFamily: 'Avenir', fontSize: 11),
        prefixIcon: Icon(ikon, color: SiberTema.kuantumCyan, size: 18),
        filled: true,
        fillColor: Colors.black.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.kuantumCyan, width: 2)),
      ),
    );
  }
}