import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otodna/core/siber_tema.dart';
import 'package:otodna/core/responsive_kalkan.dart';

/// 🔧 USTA İŞ EMRİ TERMİNALİ (SİBER BAKIM KARNESİ)
/// Ustanın aracı teslim alıp, checklist üzerinden bakım aşamalarını onayladığı arayüz.
class IsEmriDetayScreen extends StatefulWidget {
  final String isEmriId;
  const IsEmriDetayScreen({super.key, required this.isEmriId});

  @override
  State<IsEmriDetayScreen> createState() => _IsEmriDetayScreenState();
}

class _IsEmriDetayScreenState extends State<IsEmriDetayScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _adimiTamamla(String isEmriId, String adimId, bool mevcutDurum) {
    HapticFeedback.selectionClick();
    // Normalde: _db.collection('is_emirleri').doc(isEmriId).collection('adimlar').doc(adimId).update({'tamamlandi': !mevcutDurum});
  }

  void _isiTamamla() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("İŞ EMRİ SİBER AĞA MÜHÜRLENDİ! 🛡️", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: SiberTema.kuantumCyan,
    ));
    context.pop();
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
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => context.pop()),
          title: Text("İŞ EMRİ: ${widget.isEmriId}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 2.0, fontSize: 14)),
          centerTitle: true,
          actions: [
            IconButton(icon: Icon(Icons.qr_code_scanner, color: SiberTema.kuantumCyan), onPressed: () {}),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ARAÇ KİMLİK KARTI
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: SiberTema.kuantumCyan.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.directions_car, color: SiberTema.kuantumCyan, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("34 DNA 2026", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                          const SizedBox(height: 4),
                          Text("TESLA MODEL S - PERİYODİK BAKIM", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              Text("SİBER CHECKLIST", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2.0, fontSize: 12)),
              const SizedBox(height: 16),

              // SİMÜLASYON CHECKLIST
              _buildSiberChecklistItem("Motor Yağı Değişimi", true),
              _buildSiberChecklistItem("Hava Filtresi Kontrolü", true),
              _buildSiberChecklistItem("Fren Balata Testi", false),
              _buildSiberChecklistItem("Batarya Kuantum Kalibrasyonu", false),
              
              const SizedBox(height: 40),

              // FOTOĞRAF KANITI EKLEME
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: SiberTema.siberKutuZirhi,
                child: Column(
                  children: [
                    Icon(Icons.add_a_photo_outlined, color: Colors.white38, size: 40),
                    const SizedBox(height: 12),
                    Text("Değişen Parça Görseli Yükle", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              ElevatedButton.icon(
                style: SiberTema.kuantumButonStili(),
                icon: const Icon(Icons.verified_user, color: Colors.black),
                label: const Text("TÜM İŞLEMLERİ ONAYLA", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                onPressed: _isiTamamla,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiberChecklistItem(String baslik, bool tamamlandi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: tamamlandi ? SiberTema.kuantumCyan.withOpacity(0.1) : SiberTema.oledBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tamamlandi ? SiberTema.kuantumCyan : Colors.white12),
      ),
      child: CheckboxListTile(
        value: tamamlandi,
        onChanged: (val) {
          setState(() {
            // Animasyonlu tıklama simulasyonu
          });
          _adimiTamamla(widget.isEmriId, "adim_id", tamamlandi);
        },
        activeColor: SiberTema.kuantumCyan,
        checkColor: Colors.black,
        title: Text(
          baslik,
          style: TextStyle(
            color: tamamlandi ? Colors.white : Colors.white70,
            fontWeight: tamamlandi ? FontWeight.w900 : FontWeight.bold,
            decoration: tamamlandi ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}
