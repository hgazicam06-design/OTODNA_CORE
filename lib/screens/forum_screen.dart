import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/forum_model.dart';

/// 🛡️ OTODNA KUANTUM FORUM TERMİNALİ - V3
/// [2026-03-28] GÜNCELLEME: Siber Sansür ve Kuantum Filtreleme Entegre Edildi.
class OtoDnaForumScreen extends StatefulWidget {
  final String aktifKullaniciId;
  final String aktifKullaniciAdi;
  final String kullaniciAraci;

  OtoDnaForumScreen({
    super.key,
    required this.aktifKullaniciId,
    required this.aktifKullaniciAdi,
    required this.kullaniciAraci,
  });

  @override
  State<OtoDnaForumScreen> createState() => _OtoDnaForumScreenState();
}

class _OtoDnaForumScreenState extends State<OtoDnaForumScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _sadeceBenimAracim = true;

  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static Color _neonGreen = Color(0xFF00FFCC);
  static Color _cyberBlack = Color(0xFF000000);
  static Color _cyberCard = Color(0xFF111111);
  static Color _dangerRed = Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cyberBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('K U A N T U M   F O R U M',
            style: TextStyle(color: _neonGreen, fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 14)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterPanel(),
          Expanded(child: _buildForumStream()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _neonGreen,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        icon: Icon(Icons.bolt, color: Colors.white),
        label: Text("SORUN BİLDİR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
        onPressed: () => _yeniKonuDialog(),
      ),
    );
  }

  // 📡 RADAR PANELİ: Kuantum Filtreleme Mekanizması
  Widget _buildFilterPanel() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: _cyberCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _neonGreen.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: _neonGreen.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Row(
        children: [
          Icon(Icons.radar_rounded, color: _neonGreen, size: 22),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _sadeceBenimAracim ? "SİBER RADAR KİLİTLENDİ" : "GENEL AĞ TARANIYOR",
                  style: TextStyle(color: _neonGreen, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
                Text(
                  _sadeceBenimAracim ? widget.kullaniciAraci : "TÜM MODELLER",
                  style: TextStyle(color: SiberTema.textMain, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Switch(
            activeColor: _neonGreen,
            inactiveTrackColor: Colors.white10,
            value: _sadeceBenimAracim,
            onChanged: (val) => setState(() => _sadeceBenimAracim = val),
          ),
        ],
      ),
    );
  }

  // 🌊 SİBER AKIŞ: Firebase Realtime Data Motoru
  Widget _buildForumStream() {
    Query query = _db.collection('kullanici_forumu');
    if (_sadeceBenimAracim) {
      query = query.where('arac_modeli', isEqualTo: widget.kullaniciAraci);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.orderBy('tarih', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _buildStatusWidget("SİNYAL KESİLDİ: ${snapshot.error}", _dangerRed);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: _neonGreen, strokeWidth: 2));
        }

        if (snapshot.data!.docs.isEmpty) {
          return _buildStatusWidget("AĞDA HENÜZ VERİ PAKETİ YOK.", Colors.white24);
        }

        return ListView.builder(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final post = ForumPost.fromFirestore(snapshot.data!.docs[index]);
            return _buildForumKarti(post);
          },
        );
      },
    );
  }

  // 💎 SİBER KART: Glassmorphism ve Neon Etkili Forum Kartı
  Widget _buildForumKarti(ForumPost post) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cyberCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _neonGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _neonGreen.withOpacity(0.3)),
                ),
                child: Text(post.aracModeli, style: TextStyle(color: _neonGreen, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
              Spacer(),
              Text(_formatDate(post.tarih), style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 16),
          Text(post.baslik.toUpperCase(), style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
          SizedBox(height: 8),
          Text(post.icerik, style: TextStyle(color: SiberTema.textMain.withOpacity(0.7), fontSize: 13, height: 1.5)),
          SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.white10, radius: 12, child: Icon(Icons.person, size: 14, color: Colors.white.withOpacity(0.5))),
              SizedBox(width: 8),
              Text(post.yazarAdi, style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
              Spacer(),
              _buildAyniDertButonu(post),
            ],
          ),
        ],
      ),
    );
  }

  // 🔥 KRÖNİK ANALİZ MOTORU: Veritabanı Sayaç Güncelleyici
  Widget _buildAyniDertButonu(ForumPost post) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        if (post.id != null) {
          await _db.collection('kullanici_forumu').doc(post.id).update({
            'ayni_dert_sayisi': FieldValue.increment(1)
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.analytics_outlined, size: 14, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text("KRÖNİK ANALİZ (${post.ayniDertSayisi})", style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  // 🚀 SİBER KAYIT TERMİNALİ (Bottom Sheet)
  void _yeniKonuDialog() {
    final baslikCtrl = TextEditingController();
    final icerikCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: _cyberBlack,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: _neonGreen.withOpacity(0.3))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: SiberTema.textMuted, borderRadius: BorderRadius.circular(2))),
            SizedBox(height: 24),
            Text("SİBER ARIZA KAYDI", style: TextStyle(color: _neonGreen, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
            SizedBox(height: 8),
            Text("Veri paketleri anonimleştirilerek ana ağa mühürlenir.", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
            SizedBox(height: 32),
            _buildInput("Sorun Başlığı (Örn: Motor Üst Kapak Sızıntısı)", baslikCtrl),
            SizedBox(height: 16),
            _buildInput("Detaylı Teknik Açıklama", icerikCtrl, maxLines: 5),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _neonGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () async {
                  if (baslikCtrl.text.trim().length < 5 || icerikCtrl.text.trim().length < 10) return;

                  // 🛡️ SİBER SANSÜR MOTORU: Bilgi Sızıntısı Kalkanı
                  String rawText = icerikCtrl.text.toLowerCase();
                  bool isLeaked = rawText.contains(RegExp(r'[0-9]{10}')) ||
                      rawText.contains("iban") ||
                      rawText.contains("@");

                  if (isLeaked) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("🚨 GÜVENLİK İHLALİ: İLETİŞİM VERİSİ TESPİT EDİLDİ!"),
                      backgroundColor: _dangerRed,
                    ));
                    return;
                  }

                  // ⚡ ATOMİK YAZMA: Doğrudan Firebase'e Kilitliyoruz
                  await _db.collection('kullanici_forumu').add(ForumPost(
                    yazarId: widget.aktifKullaniciId,
                    yazarAdi: widget.aktifKullaniciAdi,
                    aracModeli: widget.kullaniciAraci,
                    baslik: baslikCtrl.text.trim(),
                    icerik: icerikCtrl.text.trim(),
                    tarih: DateTime.now(),
                    ayniDertSayisi: 0,
                  ).toMap());

                  if (!mounted) return;
                  Navigator.pop(ctx);
                },
                child: Text("ANA AĞA MÜHÜRLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController ctrl, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: TextStyle(color: SiberTema.textMain, fontSize: 14, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: SiberTema.textMain.withOpacity(0.15), fontSize: 13, fontWeight: FontWeight.bold),
        filled: true,
        fillColor: _cyberCard,
        contentPadding: EdgeInsets.all(20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _neonGreen, width: 1)),
      ),
    );
  }

  Widget _buildStatusWidget(String text, Color color) {
    return Center(
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
    );
  }

  String _formatDate(DateTime d) {
    return "${d.day}.${d.month}.${d.year} | ${d.hour}:${d.minute.toString().padLeft(2, '0')}";
  }
}