import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

// 🔥 SİBER KÖPRÜLER
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String raporId;

  ServiceDetailScreen({super.key, required this.raporId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🏢 FİLDİŞİ SEDEF PALET
  final Color bgColor = Color(0xFFFDFBF7);
  final Color surfaceColor = Colors.white;
  final Color primaryTeal = Colors.teal.shade700;
  final Color textMain = Color(0xFF1E293B);
  final Color textMuted = Color(0xFF64748B);
  final Color dangerColor = SiberTema.kanKirmizi;

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
        content: Text(mesaj, style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        backgroundColor: dangerColor,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(
            "DNA RAPORU: ${_raporData?['plaka'] ?? 'TARANIYOR...'}",
            style: TextStyle(color: textMain, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, fontFamily: 'Avenir'),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryTeal))
            : SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAracKarti(),
              SizedBox(height: 32),
              Text(
                "📋 EKSPERTİZ VE KONTROL NOKTALARI",
                style: TextStyle(color: textMuted, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, fontFamily: 'Avenir'),
              ),
              SizedBox(height: 16),
              _buildKontrolListesi(),
              SizedBox(height: 40),
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
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryTeal.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 30)],
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
                      style: TextStyle(color: textMain, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Avenir'),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.speed, color: primaryTeal, size: 14),
                        SizedBox(width: 6),
                        Text(
                          "${_raporData?['km'] ?? '0'} KM",
                          style: TextStyle(color: textMuted, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                        ),
                        SizedBox(width: 12),
                        Text("|", style: TextStyle(color: textMuted.withOpacity(0.5))),
                        SizedBox(width: 12),
                        Text(
                          "YIL: ${_raporData?['yil'] ?? '-'}",
                          style: TextStyle(color: textMuted, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryTeal.withOpacity(0.3)),
                ),
                child: Text(
                  _raporData?['plaka'] ?? "-",
                  style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Avenir'),
                ),
              )
            ],
          ),
          SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.05)),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.verified_user, color: Colors.blue.shade700, size: 16),
              SizedBox(width: 8),
              Text(
                "RAPOR TARİHİ: ${_raporData?['tarih'] ?? 'Belirtilmedi'}",
                style: TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.bold),
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
      return Center(child: Text("Kontrol verisi bulunamadı.", style: TextStyle(color: textMuted.withOpacity(0.5))));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: kontroller.length,
      itemBuilder: (context, index) {
        var item = kontroller[index];
        bool isOk = item['durum'] == 'OK';

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isOk ? primaryTeal.withOpacity(0.3) : dangerColor.withOpacity(0.3)),
            boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10)]
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isOk ? primaryTeal.withOpacity(0.1) : dangerColor.withOpacity(0.1),
                  shape: BoxShape.circle
                ),
                child: Icon(
                  isOk ? Icons.check_circle_outline : Icons.highlight_off,
                  color: isOk ? primaryTeal : dangerColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (item['parca'] ?? "Bilinmeyen Parça").toUpperCase(),
                      style: TextStyle(color: textMain, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir'),
                    ),
                    if (item['not'] != null)
                      Text(
                        item['not'],
                        style: TextStyle(color: textMuted, fontSize: 12),
                      ),
                  ],
                ),
              ),
              if (!isOk)
                TextButton(
                  onPressed: () => _yedekParcaBul(item['parca']),
                  child: Text(
                    "MARKET'TE BUL",
                    style: TextStyle(color: Colors.amber.shade700, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0
            ),
            icon: Icon(Icons.picture_as_pdf, color: SiberTema.kuantumCyan, size: 20),
            label: Text(
              "SİBER MÜHÜRLÜ PDF OLUŞTUR",
              style: TextStyle(fontWeight: FontWeight.w900, color: SiberTema.textMain, letterSpacing: 1.5, fontFamily: 'Avenir'),
            ),
            onPressed: () => print("PDF Motoru Ateşlendi..."),
          ),
        ),
        SizedBox(height: 20),
        Center(
          child: Text(
            "Bu rapor OtoDNA Kuantum Ağı tarafından siber mühürle doğrulanmıştır.",
            textAlign: TextAlign.center,
            style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ),
      ],
    );
  }

  void _yedekParcaBul(String parcaAdi) {
    // Gelecek operasyon: Murat Plaza veya Genel Market filtresi
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("$parcaAdi için sisteme %12 kâr payı entegre ediliyor...", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.amber.shade700,
    ));
  }
}