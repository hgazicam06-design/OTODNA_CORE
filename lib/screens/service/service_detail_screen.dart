import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 SİBER KÖPRÜLER
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String raporId;

  const ServiceDetailScreen({super.key, required this.raporId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Siber Renk Paleti (Merkezi temadan beslenir)
  final Color _primaryCyan = SiberTema.kuantumCyan;
  final Color _cyberBlack = SiberTema.oledBlack;
  final Color _alertRed = SiberTema.kanKirmizi;
  final Color _glassCard = SiberTema.matGrey;

  bool _isLoading = true;
  Map<String, dynamic>? _raporData;

  @override
  void initState() {
    super.initState();
    _raporVerileriniCek();
  }

  // 🚀 FİREBASE GERÇEK VERİ ÇEKME MOTORU
  Future<void> _raporVerileriniCek() async {
    try {
      var doc = await _db.collection('servis_raporlari').doc(widget.raporId).get();
      if (doc.exists) {
        setState(() {
          _raporData = doc.data();
          _isLoading = false;
        });
      } else {
        _siberHata("RAPOR BULUNAMADI!");
      }
    } catch (e) {
      _siberHata("SİNYAL KESİLDİ: $e");
    }
  }

  void _siberHata(String mesaj) {
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        backgroundColor: _alertRed,
      ));
    }
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "DNA RAPORU: ${_raporData?['plaka'] ?? 'TARANIYOR...'}",
            style: TextStyle(color: _primaryCyan, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, fontFamily: 'Avenir'),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: _primaryCyan))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAracKarti(),
              const SizedBox(height: 32),
              const Text(
                "📋 EKSPERTİZ VE KONTROL NOKTALARI",
                style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, fontFamily: 'Avenir'),
              ),
              const SizedBox(height: 16),
              _buildKontrolListesi(),
              const SizedBox(height: 40),
              _buildAksiyonButonlari(),
            ],
          ),
        ),
      ),
    );
  }

  // 🚗 ARAÇ KİMLİK KARTI (SİBER CAM EFEKTİ)
  Widget _buildAracKarti() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _glassCard.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _primaryCyan.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: _primaryCyan.withOpacity(0.05), blurRadius: 30)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (_raporData?['marka_model'] ?? "Bilinmeyen Ünite").toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Avenir'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.speed, color: _primaryCyan, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          "${_raporData?['km'] ?? '0'} KM",
                          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                        ),
                        const SizedBox(width: 12),
                        const Text("|", style: TextStyle(color: Colors.white24)),
                        const SizedBox(width: 12),
                        Text(
                          "YIL: ${_raporData?['yil'] ?? '-'}",
                          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _primaryCyan,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: _primaryCyan.withOpacity(0.3), blurRadius: 10)],
                ),
                child: Text(
                  _raporData?['plaka'] ?? "-",
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Avenir'),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.verified_user, color: Colors.blueAccent, size: 16),
              const SizedBox(width: 8),
              Text(
                "RAPOR TARİHİ: ${_raporData?['tarih'] ?? 'Belirtilmedi'}",
                style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  // 📋 KONTROL LİSTESİ (DİNAMİK VERİ)
  Widget _buildKontrolListesi() {
    List<dynamic> kontroller = _raporData?['kontroller'] ?? [];
    if (kontroller.isEmpty) {
      return const Center(child: Text("Kontrol verisi bulunamadı.", style: TextStyle(color: Colors.white24)));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kontroller.length,
      itemBuilder: (context, index) {
        var item = kontroller[index];
        bool isOk = item['durum'] == 'OK';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _glassCard.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isOk ? _primaryCyan.withOpacity(0.1) : _alertRed.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(
                isOk ? Icons.check_circle_outline : Icons.highlight_off,
                color: isOk ? _primaryCyan : _alertRed,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (item['parca'] ?? "Bilinmeyen Parça").toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir'),
                    ),
                    if (item['not'] != null)
                      Text(
                        item['not'],
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                  ],
                ),
              ),
              if (!isOk)
                TextButton(
                  onPressed: () => _yedekParcaBul(item['parca']),
                  child: const Text(
                    "MARKET'TE BUL",
                    style: TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  // 🚀 AKSİYON BUTONLARI (PDF VE TİCARET)
  Widget _buildAksiyonButonlari() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            style: SiberTema.kuantumButonStili(),
            icon: const Icon(Icons.picture_as_pdf, color: Colors.black),
            label: const Text(
              "SİBER MÜHÜRLÜ PDF OLUŞTUR",
              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.5, fontFamily: 'Avenir'),
            ),
            onPressed: () => print("PDF Motoru Ateşlendi..."),
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            "Bu rapor OtoDNA Kuantum Ağı tarafından siber mühürle doğrulanmıştır.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ),
      ],
    );
  }

  void _yedekParcaBul(String parcaAdi) {
    // Gelecek operasyon: Murat Plaza veya Genel Market filtresi
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("$parcaAdi için sisteme %12 kâr payı entegre ediliyor..."),
      backgroundColor: Colors.orangeAccent,
    ));
  }
}