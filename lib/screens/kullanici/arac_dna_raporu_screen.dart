import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

// 🚀 KARARGAH ZIRHLARI
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class AracDnaRaporuScreen extends StatefulWidget {
  final String saseNo; // Dışarıdan veya web'den şase no ile sorgulanacak
  
  const AracDnaRaporuScreen({super.key, required this.saseNo});

  @override
  State<AracDnaRaporuScreen> createState() => _AracDnaRaporuScreenState();
}

class _AracDnaRaporuScreenState extends State<AracDnaRaporuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Map<String, dynamic>? _aracVerisi;
  bool _yukleniyor = true;
  String _siberMuhur = "";

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _siberMuhurUret();
    _aracVerisiniCek();
  }

  void _siberMuhurUret() {
    var bytes = utf8.encode("${widget.saseNo}_${DateTime.now().millisecondsSinceEpoch}");
    _siberMuhur = "0x${sha256.convert(bytes).toString().substring(0, 16).toUpperCase()}";
  }

  Future<void> _aracVerisiniCek() async {
    try {
      var doc = await _db.collection('araclar').doc(widget.saseNo).get();
      if (doc.exists) {
        setState(() {
          _aracVerisi = doc.data();
          _yukleniyor = false;
        });
      } else {
        // Eğer db'de yoksa, test için MOCK data (Gerçekte hata verilir)
        setState(() {
          _aracVerisi = {
            "plaka": "SORGULANAN ARAÇ",
            "marka_model": "Kuantum Veritabanı",
            "dna_skoru": 88,
            "guncel_km": 42500,
            "sahibi_uid": "MOCK_OWNER",
          };
          _yukleniyor = false;
        });
      }
    } catch (e) {
      setState(() => _yukleniyor = false);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  // 💰 ÜCRETLİ SORGULAMA VE ARAÇ SAHİBİ ONAY SİSTEMİ (TWO-SIDED PRIVACY)
  void _satinAlmaVeOnayIstegiGonder() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: SiberTema.oledBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5))),
        title: const Row(
          children: [
            Icon(Icons.security, color: SiberTema.kuantumCyan, size: 28),
            SizedBox(width: 12),
            Text("GİZLİLİK KALKANI", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Bu aracın tüm genetik sicilini (Yağ bakımından fren balatasına, tramerden ekspertiz raporuna kadar) içeren Değiştirilemez PDF Raporunu almak üzeresiniz.", style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: SiberTema.kanKirmizi.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.3))),
              child: const Text("KİŞİSEL VERİLERİN KORUNMASI GEREĞİ: Bu raporun üretilebilmesi için aracın yasal sahibine bir 'Veri Paylaşım Onayı' bildirimi gönderilecektir.", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            const Text("HİZMET BEDELİ: 599 ₺", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İPTAL", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: SiberTema.kuantumButonStili(),
            onPressed: () async {
              Navigator.pop(context);
              
              // Gerçekte burada Cloud Function ile bildirim atılır.
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Araç Sahibine Onay İsteği Gönderildi! ⏳", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: SiberTema.altinSari));
              
              // Simülasyon: 3 Saniye sonra onaylandı varsayalım
              await Future.delayed(const Duration(seconds: 3));
              if (!mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Araç Sahibi ONAYLADI. Cüzdandan 599 ₺ çekildi. Rapor İndiriliyor! 📥", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: SiberTema.kuantumCyan, duration: Duration(seconds: 4)));
            },
            child: const Text("ONAY İSTE (599 ₺)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_yukleniyor) {
      return const Scaffold(backgroundColor: SiberTema.oledBlack, body: Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan)));
    }

    int dnaSkoru = (_aracVerisi?['dna_skoru'] ?? 100).toInt();
    Color siberRenk = dnaSkoru >= 80 ? SiberTema.kuantumCyan : (dnaSkoru >= 50 ? SiberTema.altinSari : SiberTema.kanKirmizi);

    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: SiberTema.matGrey.withOpacity(0.8),
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: siberRenk, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_user, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text("RESMİ DNA RAPORU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
            ],
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // =================================================================
                // 1. KİMLİK VE SİBER MÜHÜR
                // =================================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
                  child: Column(
                    children: [
                      Text("${_aracVerisi?['plaka']} - ${_aracVerisi?['marka_model']}".toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      Text("ŞASE: ${widget.saseNo.toUpperCase()}", style: const TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 2)),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white12)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.fingerprint, color: SiberTema.kuantumCyan, size: 16),
                          const SizedBox(width: 8),
                          Text("SİBER MÜHÜR: $_siberMuhur", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // =================================================================
                // 2. DEVASA ANA SKOR (IŞIMALI)
                // =================================================================
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      decoration: BoxDecoration(
                        color: SiberTema.matGrey,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: siberRenk.withOpacity(0.3), width: 2),
                        boxShadow: [BoxShadow(color: siberRenk.withOpacity(0.15 * _glowController.value), blurRadius: 40, spreadRadius: 5)],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.health_and_safety, color: siberRenk, size: 48),
                          const SizedBox(height: 16),
                          Text("%$dnaSkoru", style: TextStyle(color: siberRenk, fontSize: 72, fontWeight: FontWeight.w900, letterSpacing: -2)),
                          const SizedBox(height: 8),
                          const Text("GENEL DNA SAĞLIK SKORU", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // =================================================================
                // 3. DETAYLI BAKIM VE DEĞİŞİM BİLGİLERİ (Yağ, Balata vs.)
                // =================================================================
                const Align(alignment: Alignment.centerLeft, child: Text("KAYITLI SERVİS & BAKIM GEÇMİŞİ", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5))),
                const SizedBox(height: 16),
                
                _buildBakimSatiri("Motor Yağı & Filtreler", "Değişimi Yapıldı", "42.000 KM (3 Ay Önce)", SiberTema.kuantumCyan),
                _buildBakimSatiri("Ön ve Arka Fren Balataları", "BOSCH Marka İle Değişti", "40.500 KM (6 Ay Önce)", SiberTema.kuantumCyan),
                _buildBakimSatiri("Triger Kayış Seti", "Ağır Bakım Yapıldı", "120.000 KM (Öngörülen)", SiberTema.altinSari),
                _buildBakimSatiri("Tramer / Hasar Kaydı", "1 Adet Çarpma (4.500 ₺)", "2024 Yılı", SiberTema.kanKirmizi),
                const SizedBox(height: 40),

                // =================================================================
                // 4. SATIN ALMA BUTONU (599 TL)
                // =================================================================
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    style: SiberTema.kuantumButonStili(),
                    onPressed: _satinAlmaVeOnayIstegiGonder,
                    icon: const Icon(Icons.picture_as_pdf, size: 24, color: Colors.black),
                    label: const Text("TÜM SİCİLİ AL (599 ₺)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Bu rapor OtoDNA Kuantum Ağı tarafından kriptolanmıştır. Veri İzinsiz Çoğaltılamaz.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 9)),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBakimSatiri(String parca, String islem, String zaman, Color islemRengi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
      child: Row(
        children: [
          Icon(Icons.build_circle, color: islemRengi, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(parca, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(islem, style: TextStyle(color: islemRengi, fontSize: 11, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Text(zaman, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}