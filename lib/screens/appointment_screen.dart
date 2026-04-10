import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

// 🔥 SİBER KÖPRÜLER
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class AppointmentScreen extends StatefulWidget {
  final String bayiId;
  final String bayiIsmi;
  final String aracId;

  const AppointmentScreen({
    super.key,
    required this.bayiId,
    required this.bayiIsmi,
    required this.aracId,
  });

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = SiberTema.oledBlack;
  final Color surfaceColor = SiberTema.matGrey.withOpacity(0.2);
  final Color primaryCyan = SiberTema.kuantumCyan;
  final Color dangerColor = SiberTema.kanKirmizi;

  final double caymaBedeli = 200.0;
  bool _isProcessing = false;

  // --- 🔴 FİREBASE: KUANTUM MÜHÜRLEME MOTORU (WRITEBATCH) ---
  Future<void> _odemeVeMuhurlemeBaslat() async {
    setState(() => _isProcessing = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final db = FirebaseFirestore.instance;
      final batch = db.batch();

      // 1. Randevu Talebi Oluştur
      final randevuRef = db.collection('randevular').doc();
      batch.set(randevuRef, {
        'randevu_id': randevuRef.id,
        'kullanici_id': user.uid,
        'bayi_id': widget.bayiId,
        'bayi_ismi': widget.bayiIsmi,
        'arac_id': widget.aracId,
        'tutar': caymaBedeli,
        'durum': 'Odendi_Mühürlendi',
        'tarih': FieldValue.serverTimestamp(),
        'kesinti_protokolu': 'Aktif',
      });

      // 2. Siber Finans Logu Oluştur
      final finansLogRef = db.collection('finansal_islemler').doc();
      batch.set(finansLogRef, {
        'islem_id': finansLogRef.id,
        'tur': 'Randevu_Guvence',
        'tutar': caymaBedeli,
        'gonderen_id': user.uid,
        'alici_id': 'OTODNA_HAVUZ',
        'tarih': FieldValue.serverTimestamp(),
        'aciklama': '${widget.bayiIsmi} için randevu güvence bedeli bloke edildi.',
      });

      // 🚀 ATOMİK İŞLEMİ FIRLAT
      await batch.commit();

      if (!mounted) return;
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.bayiIsmi.toUpperCase()} KUANTUM AĞINA MÜHÜRLENDİ! 🦅',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: primaryCyan,
        ),
      );

      // Ana ekrana dön veya detaylara git
      Navigator.pop(context);

    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SİBER İSTİHBARAT HATASI: $e'), backgroundColor: dangerColor),
      );
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
              onPressed: () => Navigator.pop(context)
          ),
          title: const Text('R A N D E V U   M Ü H R Ü',
              style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // 1. SİBER ADALET İKONU (Animasyonlu Efekt)
              _buildSiberGavel(),
              const SizedBox(height: 32),

              // 2. TUTAR VE BAŞLIK
              const Text(
                "SİBER GÜVENCE BEDELİ",
                style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              const SizedBox(height: 12),
              Text(
                "₺${caymaBedeli.toStringAsFixed(0)}",
                style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: -2),
              ),
              const SizedBox(height: 16),
              Text(
                "${widget.bayiIsmi} randevusunu Kuantum Ağına mühürlemek ve işlem sırasını rezerve etmek için yukarıdaki güvence bedeli bloke edilecektir.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // 3. İHLAL PROTOKOLÜ UYARISI
              _buildIhlalKalkanı(),
              const SizedBox(height: 40),

              // 4. GÜVENLİ MÜHÜRLEME BUTONU
              _buildMuhurleButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiberGavel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryCyan.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(color: primaryCyan.withOpacity(0.3), width: 2),
        boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.1), blurRadius: 40)],
      ),
      child: Icon(Icons.gavel_rounded, size: 64, color: primaryCyan),
    );
  }

  Widget _buildIhlalKalkanı() {
  return Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
  color: dangerColor.withOpacity(0.05),
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: dangerColor.withOpacity(0.3)),
  ),
  child: Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Icon(Icons.warning_amber_rounded, color: dangerColor, size: 24),
  const SizedBox(width: 16),
  const Expanded(
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Text(
  "İHLAL PROTOKOLÜ UYARISI",
  style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
  ),
  SizedBox(height: 8),
  Text(
  "Randevuya gelinmediği veya son anda iptal edildiği takdirde bu bedelin ₺100'si Usta Tazminatı, ₺100'si OtoDNA İşletme Bedeli olarak kesin kesintiye uğrayacaktır.",
  style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5, fontWeight: FontWeight.bold),
  ),
  ],
  ),
  ),
  ],
  ),
  );
  }

  Widget _buildMuhurleButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCyan,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: _isProcessing ? null : _odemeVeMuhurlemeBaslat,
        icon: _isProcessing
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
            : const Icon(Icons.lock_outline, size: 24),
        label: Text(
          _isProcessing ? "AĞA BAĞLANILIYOR..." : "₺200 ÖDE VE MÜHÜRLE",
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
      ),
    );
  }
}