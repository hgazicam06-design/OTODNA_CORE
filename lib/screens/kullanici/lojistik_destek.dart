import 'package:otodna/core/siber_tema.dart';
// lib/screens/kullanici/lojistik_destek.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

import '../../../../core/responsive_kalkan.dart';

/// 🛡️ PLAZA LOJİSTİK VE CANLI DESTEK MERKEZİ (SiberLojistikTakip)
/// Müşteri, bayi ve Merkez (Admin) arasında 3'lü iletişim hattı kurar.
class SiberLojistikTakip extends StatefulWidget {
  final String siparisId;
  final String kullaniciId; // Mesajı gönderenin kimliği

  SiberLojistikTakip({super.key, required this.siparisId, required this.kullaniciId});

  @override
  State<SiberLojistikTakip> createState() => _SiberLojistikTakipState();
}

class _SiberLojistikTakipState extends State<SiberLojistikTakip> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _mesajCtrl = TextEditingController();

  final Color primaryTeal = Colors.teal.shade700;
  final Color dangerColor = Colors.redAccent;
  final Color textColor = Color(0xFF1E293B);
  final Color bgColor = Color(0xFFFAFAFC);

  // ── 🚀 S.O.S MOTORU (ATOMİK İŞLEM) ──
  Future<void> _imeceAlarmiVer() async {
    HapticFeedback.heavyImpact();
    developer.log("🚨 ACİL DURUM: ${widget.siparisId} için Yol Yardım / S.O.S sinyali fırlatıldı!");

    try {
      WriteBatch batch = _db.batch();

      DocumentReference alarmRef = _db.collection('imece_alarmlari').doc();
      batch.set(alarmRef, {
        'siparis_id': widget.siparisId,
        'kullanici_id': widget.kullaniciId,
        'durum': 'ACIL_MUDEHALE_BEKLIYOR',
        'zaman_damgasi': FieldValue.serverTimestamp(),
      });

      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'S.O.S_TETIKLENDI',
        'islem_detayi': 'PLAZA ACİL: ${widget.kullaniciId} kimlikli kullanıcı ${widget.siparisId} için acil durum sinyali gönderdi.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      _plazaUyariGoster("S.O.S SİNYALİ GÖNDERİLDİ!", "Merkez ve en yakın bayiler alarma geçirildi.", dangerColor);
    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ!", error: e);
      _plazaUyariGoster("BAĞLANTI HATASI", "S.O.S sinyali Merkeze iletilemedi.", dangerColor);
    }
  }

  // ── 💬 SOHBET MOTORU (MESAJ GÖNDERME) ──
  Future<void> _mesajGonder() async {
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
      developer.log("💬 PLAZA HATTI: Mesaj gönderildi.");
    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: Mesaj gönderilemedi!", error: e);
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _plazaUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            SizedBox(height: 4),
            Text(mesaj, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text("LOJİSTİK VE DESTEK HATTI", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          iconTheme: IconThemeData(color: primaryTeal),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // 1. CANLI KARGO DURUMU RADARI
              _buildPlazaKargoRadari(),

              // 2. S.O.S BUTONU
              _buildSosyYardimButonu(),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
              ),

              // 3. İLETİŞİM HATTI
              _buildSohbetBasligi(),
              Expanded(child: _buildCanliSohbetAkisi()),
              _buildMesajGondermeMotoru(),
            ],
          ),
        ),
      ),
    );
  }

  // ── 🛡️ ARAYÜZ MOTORLARI ──

  Widget _buildPlazaKargoRadari() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _db.collection('siparisler').doc(widget.siparisId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return SizedBox.shrink();
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;
        String durum = data['kargo_durumu'] ?? "BİLİNMİYOR";
        String takipKodu = data['kargo_takip_kodu'] ?? "KOD BEKLENİYOR";
        Color durumRengi = (durum == "YOLDA" || durum == "TESLİM EDİLDİ") ? primaryTeal : Colors.orange;

        return Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 15, offset: Offset(0, 5))]
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: primaryTeal.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                ),
                child: Icon(Icons.radar, color: primaryTeal),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("LOJİSTİK DURUMU: $durum", style: TextStyle(color: durumRengi, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                    SizedBox(height: 4),
                    Text("BARKOD NO: $takipKodu", style: TextStyle(color: Colors.white54, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSosyYardimButonu() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton.icon(
          onPressed: _imeceAlarmiVer,
          icon: Icon(Icons.sos, color: SiberTema.kuantumCyan, size: 28),
          label: Text("ACİL DURUM / S.O.S ALARMI VER", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
          style: ElevatedButton.styleFrom(
            backgroundColor: dangerColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildSohbetBasligi() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.admin_panel_settings, color: primaryTeal, size: 16),
          SizedBox(width: 8),
          Expanded(child: Text("PLAZA MERKEZ GÖZETİMİNDE İLETİŞİM", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir'))),
        ],
      ),
    );
  }

  Widget _buildCanliSohbetAkisi() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10)]
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('siparisler').doc(widget.siparisId).collection('kripto_sohbet')
            .orderBy('zaman_damgasi', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryTeal));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Merkez bağlantısı kuruldu.\nİletişime geçebilirsiniz.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')));
          }

          return ListView.builder(
            reverse: true,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var mesajVerisi = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              bool benGonderdim = mesajVerisi['gonderen_id'] == widget.kullaniciId;

              return Align(
                alignment: benGonderdim ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: benGonderdim ? primaryTeal : Colors.grey.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(benGonderdim ? 16 : 4),
                      bottomRight: Radius.circular(benGonderdim ? 4 : 16),
                    ),
                    boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.05), blurRadius: 5, offset: Offset(0, 2))]
                  ),
                  child: Text(
                    mesajVerisi['mesaj_metni'] ?? "",
                    style: TextStyle(color: benGonderdim ? Colors.white : textColor, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMesajGondermeMotoru() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05)))
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: TextField(
                  controller: _mesajCtrl,
                  style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                  decoration: InputDecoration(
                    hintText: "Merkeze veya bayiye yaz...",
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 12, fontFamily: 'Avenir', fontWeight: FontWeight.bold),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            GestureDetector(
              onTap: _mesajGonder,
              child: Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primaryTeal,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.3), blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Icon(Icons.send_rounded, color: SiberTema.kuantumCyan, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}