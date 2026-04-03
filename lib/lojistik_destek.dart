// lib/screens/lojistik_destek.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM LOJİSTİK VE CANLI DESTEK MERKEZİ (SiberLojistikTakip)
/// Müşteri, bayi ve Karargah (Admin) arasında 3'lü Kriptolu iletişim hattı kurar.
class SiberLojistikTakip extends StatefulWidget {
  final String siparisId;
  final String kullaniciId; // Mesajı gönderenin kimliği

  const SiberLojistikTakip({super.key, required this.siparisId, required this.kullaniciId});

  @override
  State<SiberLojistikTakip> createState() => _SiberLojistikTakipState();
}

class _SiberLojistikTakipState extends State<SiberLojistikTakip> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _mesajCtrl = TextEditingController();

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _oledBlack = Color(0xFF000000);
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);

  // ── 🚀 İMECE S.O.S MOTORU TETİKLEYİCİSİ ──
  Future<void> _imeceAlarmiVer() async {
    HapticFeedback.heavyImpact();
    developer.log("🚨 SİBER ALARM: ${widget.siparisId} için İmece (Yol Yardım / Sorun) S.O.S sinyali fırlatıldı!");

    try {
      await _db.collection('imece_alarmlari').add({
        'siparis_id': widget.siparisId,
        'kullanici_id': widget.kullaniciId,
        'durum': 'ACIL_MUDEHALE_BEKLIYOR',
        'zaman_damgasi': FieldValue.serverTimestamp(),
      });
      _siberUyariGoster("İMECE SİNYALİ GÖNDERİLDİ!", "Karargah ve en yakın bayiler alarma geçirildi.", Colors.redAccent);
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ!", error: e);
      _siberUyariGoster("BAĞLANTI HATASI", "S.O.S sinyali Karargaha iletilemedi.", Colors.redAccent);
    }
  }

  // ── 💬 KRİPTOLU SOHBET MOTORU (MESAJ GÖNDERME) ──
  Future<void> _mesajFirlat() async {
    String mesaj = _mesajCtrl.text.trim();
    if (mesaj.isEmpty) return;

    HapticFeedback.lightImpact();
    _mesajCtrl.clear();

    try {
      await _db.collection('siparisler').doc(widget.siparisId).collection('kripto_sohbet').add({
        'gonderen_id': widget.kullaniciId,
        'mesaj_metni': mesaj,
        'zaman_damgasi': FieldValue.serverTimestamp(),
      });
      developer.log("💬 SİBER HAT: Mesaj fırlatıldı.");
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Mesaj fırlatılamadı!", error: e);
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
        title: const Text("LOJİSTİK VE DESTEK HATTI", style: TextStyle(color: _kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kuantumCyan),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. CANLI KARGO DURUMU RADARI
            _buildSiberKargoRadari(),

            // 2. İMECE (S.O.S) FÜZESİ
            _buildImeceYardimButonu(),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Divider(color: Colors.white24, height: 1),
            ),

            // 3. ÜÇLÜ KRİPTOLU MUHATAP HATTI (Müşteri - Bayi - Admin)
            _buildSohbetBasligi(),
            Expanded(child: _buildCanliSohbetAkisi()),
            _buildMesajAteslemeMotoru(),
          ],
        ),
      ),
    );
  }

  // ── 🛡️ ARAYÜZ MOTORLARI ──

  Widget _buildSiberKargoRadari() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _db.collection('siparisler').doc(widget.siparisId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink(); // Veri yoksa alanı gizle
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        String durum = data['kargo_durumu'] ?? "BİLİNMİYOR";
        String takipKodu = data['kargo_takip_kodu'] ?? "KOD BEKLENİYOR";
        Color durumRengi = (durum == "YOLDA" || durum == "TESLİM EDİLDİ") ? _kuantumCyan : Colors.orangeAccent;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _matGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kuantumCyan.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: _kuantumCyan.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.radar, color: _kuantumCyan),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("LOJİSTİK DURUMU: $durum", style: TextStyle(color: durumRengi, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text("SİBER BARKOD: $takipKodu", style: const TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImeceYardimButonu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          onPressed: _imeceAlarmiVer,
          icon: const Icon(Icons.sos, color: Colors.white, size: 28),
          label: const Text("İMECE S.O.S ALARMI VER", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 10,
            shadowColor: Colors.redAccent.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSohbetBasligi() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.admin_panel_settings, color: _kuantumCyan, size: 16),
          const SizedBox(width: 8),
          const Expanded(child: Text("KARARGAH GÖZETİMİNDE KRİPTOLU HAT", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2))),
        ],
      ),
    );
  }

  Widget _buildCanliSohbetAkisi() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _matGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('siparisler').doc(widget.siparisId).collection('kripto_sohbet')
            .orderBy('zaman_damgasi', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _kuantumCyan));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("SİBER ONAY: İletişim hattı temiz ve dinlemeye hazır.", style: TextStyle(color: Colors.white30, fontSize: 11)));
          }

          return ListView.builder(
            reverse: true, // En yeni mesaj en altta görünür
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var mesajVerisi = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              bool benGonderdim = mesajVerisi['gonderen_id'] == widget.kullaniciId;

              return Align(
                alignment: benGonderdim ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: benGonderdim ? _kuantumCyan.withOpacity(0.1) : Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: benGonderdim ? _kuantumCyan.withOpacity(0.5) : Colors.white24),
                  ),
                  child: Text(
                    mesajVerisi['mesaj_metni'] ?? "",
                    style: TextStyle(color: benGonderdim ? _kuantumCyan : Colors.white, fontSize: 13),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMesajAteslemeMotoru() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _matGrey,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white24),
              ),
              child: TextField(
                controller: _mesajCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "Karargaha veya bayiye yaz...",
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _mesajFirlat,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _kuantumCyan,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: _kuantumCyan.withOpacity(0.4), blurRadius: 10)],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}