// lib/screens/ekspertiz_detay_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE SERVİSLER
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../services/ekspertiz_muhur_servisi.dart';

class EkspertizDetayScreen extends StatefulWidget {
  final String raporId;
  final String kullaniciId;

  const EkspertizDetayScreen({super.key, required this.raporId, required this.kullaniciId});

  @override
  State<EkspertizDetayScreen> createState() => _EkspertizDetayScreenState();
}

class _EkspertizDetayScreenState extends State<EkspertizDetayScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final EkspertizMuhurServisi _muhurServisi = EkspertizMuhurServisi();

  Timer? _sayac;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Ekran açıkken her dakika durumu kontrol edip UI'ı yenilemek için canlı radar
    _sayac = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sayac?.cancel();
    super.dispose();
  }

  // 💰 ÜCRETLİ PDF SATIN ALMA TETİKLEYİCİSİ
  Future<void> _pdfSatinAl() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      // Örnek Fiyat: 499 TL
      await _muhurServisi.ucretliPdfTalebiOlustur(
          raporId: widget.raporId,
          kullaniciId: widget.kullaniciId,
          ucret: 499.0
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("SİBER ONAY: Ödeme alındı. PDF hazırlanıyor...", style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: SiberTema.kuantumCyan,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("ÖDEME HATASI: İşlem tamamlanamadı.", style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: SiberTema.kanKirmizi,
      ));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("SİCİL VE MÜHÜR MERKEZİ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          // 📡 Rapor verisi anlık Firebase'den okunuyor
          stream: _db.collection('ekspertiz_raporlari').doc(widget.raporId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
            if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: Text("SİBER İHLAL: Rapor Bulunamadı", style: TextStyle(color: SiberTema.kanKirmizi)));

            var raporData = snapshot.data!.data() as Map<String, dynamic>;
            Timestamp? olusturulmaTarihi = raporData['olusturulma_tarihi'];
            bool isMuhurlu = _muhurServisi.isRaporMuhurlendi(olusturulmaTarihi);
            bool pdfSatildiMi = raporData['pdf_satildi'] ?? false;

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🛡️ DİJİTAL MÜHÜR DURUM KARTI
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: isMuhurlu ? SiberTema.kuantumCyan.withOpacity(0.1) : SiberTema.matGrey.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isMuhurlu ? SiberTema.kuantumCyan : Colors.orangeAccent, width: 2),
                        boxShadow: [
                          if (isMuhurlu) BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.2), blurRadius: 20)
                        ]
                    ),
                    child: Column(
                      children: [
                        Icon(isMuhurlu ? Icons.lock : Icons.lock_open, color: isMuhurlu ? SiberTema.kuantumCyan : Colors.orangeAccent, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          isMuhurlu ? "SİCİL MÜHÜRLENDİ (DEĞİŞTİRİLEMEZ)" : "2 SAATLİK İTİRAZ SÜRESİ AKTİF",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: isMuhurlu ? SiberTema.kuantumCyan : Colors.orangeAccent, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isMuhurlu
                              ? "Bu rapor Kuantum Ağına kilitlenmiştir. Kilometre veya parça durumu geriye dönük değiştirilemez."
                              : "Rapor oluşturulduktan 2 saat sonra kalıcı olarak mühürlenecek ve PDF erişimine açılacaktır.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white54, fontSize: 11, height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 📄 RAPOR İÇERİĞİ (Siber Cam Kabuk)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: SiberTema.matGrey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: ListView(
                        children: [
                          const Text("ARAÇ BİLGİLERİ", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          _buildBilgiSatiri("Şase No", raporData['sase_no'] ?? "Bilinmiyor"),
                          _buildBilgiSatiri("Kilometre", "${raporData['kilometre'] ?? 0} KM"),
                          const Divider(color: Colors.white12, height: 30),
                          const Text("SİBER TESPİTLER", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text(raporData['rapor_detayi'] ?? "Henüz detay girilmedi.", style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🚀 ATEŞLEME BUTONU (PDF OLUŞTURMA)
                  SizedBox(
                    height: 65,
                    width: double.infinity,
                    child: _isProcessing
                        ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                        : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isMuhurlu ? SiberTema.kuantumCyan : SiberTema.matGrey,
                        foregroundColor: isMuhurlu ? SiberTema.oledBlack : Colors.white38,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: isMuhurlu ? 10 : 0,
                        shadowColor: SiberTema.kuantumCyan.withOpacity(0.5),
                      ),
                      onPressed: isMuhurlu ? (pdfSatildiMi ? () {} : _pdfSatinAl) : null,
                      icon: Icon(pdfSatildiMi ? Icons.download : Icons.picture_as_pdf, size: 24),
                      label: Text(
                        !isMuhurlu
                            ? "MÜHÜR BEKLENİYOR..."
                            : (pdfSatildiMi ? "PDF'İ İNDİR" : "RESMİ ÇIKTIYI AL (₺499)"),
                        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBilgiSatiri(String baslik, String deger) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(deger, style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }
}