import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM ACİL DURUM MÜDAHALE BİRİMİ (BayiSOSMudahalePaneli)
/// Bayiye düşen S.O.S sinyallerini yönetir, resmi birimleri arar ve Karargah yol yardımını fırlatır.
class BayiSOSMudahalePaneli extends StatefulWidget {
  final String sinyalId; // Firebase sos_sinyalleri doc ID
  final String bayiId;   // Müdahale eden bayinin ID'si

  const BayiSOSMudahalePaneli({super.key, required this.sinyalId, required this.bayiId});

  @override
  State<BayiSOSMudahalePaneli> createState() => _BayiSOSMudahalePaneliState();
}

class _BayiSOSMudahalePaneliState extends State<BayiSOSMudahalePaneli> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _mudahaleEdiliyor = false;

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);
  static const Color _kanKirmizi = Colors.redAccent;

  // ── 📞 FİZİKSEL ARAMA VE NAVİGASYON MOTORLARI ──
  Future<void> _telefonAra(String numara) async {
    developer.log("SİBER HAT: $numara aranıyor...");
    final Uri launchUri = Uri(scheme: 'tel', path: numara);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      developer.log("AĞ ÇÖKTÜ: Arama modülü başlatılamadı.");
      _siberUyariGoster("ARAMA BAŞARISIZ", "Telefon modülü tetiklenemedi.", _kanKirmizi);
    }
  }

  Future<void> _haritadaAc(double lat, double lng) async {
    developer.log("SİBER RADAR: Lokasyona navigasyon başlatılıyor ($lat, $lng)...");
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      developer.log("HARİTA ÇÖKTÜ: Navigasyon açılamadı.");
      _siberUyariGoster("NAVİGASYON HATASI", "Harita modülü başlatılamadı.", _kanKirmizi);
    }
  }

  // ── 🚀 KARARGAH YOL YARDIM MÜHRÜ (ATOMİK ZIRH GİYDİRİLDİ) ──
  Future<void> _yolYardimFirlat(String saseNo) async {
    setState(() => _mudahaleEdiliyor = true);
    developer.log("🚀 SİBER MÜDAHALE: Yol yardım ekibi bölgeye yönlendiriliyor...");

    try {
      // ⛓️ ATOMİK ZIRH: WriteBatch Başlatıldı (İşlemi Yarıda Bırakma!)
      WriteBatch batch = _db.batch();

      // 1. Sinyali Güncelle (Müdahale Edildi Olarak Mühürle)
      DocumentReference sinyalRef = _db.collection('sos_alarmlari').doc(widget.sinyalId); // 'sos_sinyalleri' yerine radara uygun düzeltildi
      batch.update(sinyalRef, {
        'durum': 'MUDAHALE_EDILDI',
        'mudahale_eden_bayi': widget.bayiId,
        'mudahale_tarihi': FieldValue.serverTimestamp(),
      });

      // 2. Karargah Servis Havuzuna İş Emri Aç (Yol Yardım Talebi)
      DocumentReference arizaRef = _db.collection('ariza_kayitlari').doc();
      batch.set(arizaRef, {
        'ariza_id': arizaRef.id,
        'sase_no': saseNo,
        'bayi_id': widget.bayiId,
        'durum': 'YOL_YARDIMI_YOLDA',
        'islem_turu': 'ACIL_SOS_MUDAHALESI',
        'olusturulma_tarihi': FieldValue.serverTimestamp(),
        'not': 'SİBER BİLGİ: S.O.S Sinyali üzerine bölgeye yol yardım ekibi sevk edildi.'
      });

      // 3. Kara Kutuya (Sistem Logları) Fişi Kes (Kayıt Dışılığı Engelle!)
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'SOS_MUDAHALESI',
        'islem_detayi': 'SİBER HAREKAT: ${widget.bayiId} ID\'li Bayi, $saseNo şaseli aracın S.O.S sinyaline başarıyla müdahale etti ve yol yardım sevk etti.',
        'tarih': FieldValue.serverTimestamp(),
      });

      // FÜZELERİ ATEŞLE!
      await batch.commit();

      developer.log("✅ SİBER ONAY: Müdahale atomik olarak Karargaha şifrelendi.");
      _siberUyariGoster("EKİP SEVK EDİLDİ!", "Yol yardım müdahaleniz Karargaha mühürlendi.", _kuantumCyan);

      // Ekranda kalmaya gerek yok, radar ekranına dön
      if (mounted) Navigator.pop(context);

    } catch (e) {
      developer.log("AĞ ÇÖKTÜ!", error: e);
      _siberUyariGoster("BAĞLANTI HATASI", "Müdahale Karargaha iletilemedi! Lütfen tekrar deneyin.", _kanKirmizi);
    } finally {
      if (mounted) setState(() => _mudahaleEdiliyor = false);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _matGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _oledBlack,
      appBar: AppBar(
        title: const Text("ACİL DURUM MÜDAHALE", style: TextStyle(color: _kanKirmizi, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kanKirmizi),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        // Sinyal verilerini Firebase'den canlı çek
        future: _db.collection('sos_alarmlari').doc(widget.sinyalId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _kanKirmizi));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("SİNYAL KAYIP VEYA İPTAL EDİLMİŞ.", style: TextStyle(color: _kanKirmizi, fontWeight: FontWeight.bold, letterSpacing: 1.5)));
          }

          var sinyalVerisi = snapshot.data!.data() as Map<String, dynamic>;
          String saseNo = sinyalVerisi['sase_no'] ?? "BİLİNMİYOR";
          String konumAdresi = sinyalVerisi['adres'] ?? "GPS Konumu Alınıyor...";
          // SİBER NOT: Gerçek projede 'enlem' ve 'boylam' veritabanından gelir.
          double enlem = sinyalVerisi['enlem'] ?? 39.92077; // Ankara simülasyonu
          double boylam = sinyalVerisi['boylam'] ?? 32.85411;
          String musteriTelefon = sinyalVerisi['musteri_telefon'] ?? "";

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 🚨 1. SİBER İSTİHBARAT KARTI ──
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _kanKirmizi.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _kanKirmizi.withOpacity(0.5), width: 2),
                      boxShadow: [BoxShadow(color: _kanKirmizi.withOpacity(0.1), blurRadius: 30)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.radar, color: _kanKirmizi, size: 30),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                  "ARAÇ (DNA): $saseNo",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)
                              ),
                            ),
                            if (musteriTelefon.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.phone_in_talk, color: _kuantumCyan),
                                onPressed: () => _telefonAra(musteriTelefon),
                              )
                          ],
                        ),
                        const Divider(color: Colors.white24, height: 30),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, color: Colors.white54, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                  konumAdresi,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5, letterSpacing: 1)
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // RADAR YÖNLENDİRME (NAVİGASYON)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.explore_outlined, color: _kuantumCyan),
                            label: const Text("RADARLA BÖLGEYE GİT", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _kuantumCyan),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _haritadaAc(enlem, boylam),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ── 📞 2. RESMİ YARDIM BİRİMLERİ ──
                  const Text("RESMİ YARDIM BİRİMLERİ", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  _buildAcilButon(
                    label: "112 ACİL (AMBULANS / İTFAİYE)",
                    icon: Icons.medical_services_outlined,
                    renk: _kanKirmizi,
                    onTap: () => _telefonAra("112"),
                  ),
                  const SizedBox(height: 12),
                  _buildAcilButon(
                    label: "EMNİYET / TRAFİK POLİSİ",
                    icon: Icons.local_police_outlined,
                    renk: Colors.blueAccent,
                    onTap: () => _telefonAra("155"),
                  ),

                  const Spacer(),

                  // ── 🚀 3. OTODNA YOL YARDIM MÜDAHALESİ ──
                  SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: _mudahaleEdiliyor
                        ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
                        : ElevatedButton.icon(
                      onPressed: () => _yolYardimFirlat(saseNo),
                      icon: const Icon(Icons.car_crash_outlined, color: Colors.black, size: 28),
                      label: const Text("OTODNA YOL YARDIM GÖNDER", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent, // Yol Yardım Rengi
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 10,
                        shadowColor: Colors.orangeAccent.withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── 🔧 YARDIMCI WIDGET'LAR ──────────────────────────────────────────────
  Widget _buildAcilButon({required String label, required IconData icon, required Color renk, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _matGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: renk.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: renk, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)),
            ),
            const Icon(Icons.call_outlined, color: Colors.greenAccent, size: 24),
          ],
        ),
      ),
    );
  }
}