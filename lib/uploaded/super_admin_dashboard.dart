import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'dart:developer' as developer;

/// 🦅 OTODNA YÜKSEK KONSEY TERMİNALİ (Super Admin)
/// Finansal Onaylar, Hakem Kararları ve Blacklist Yönetimi.
class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🎨 Siber Tasarım (Komutan Teması)
  static const Color _neonCyan = Color(0xFF00FFC2);
  static const Color _deepBlack = Color(0xFF0A0A0B);
  static const Color _alertRed = Color(0xFFFF4D4D);
  static const Color _goldColor = Color(0xFFFFD700);

  void _siberUyari(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      backgroundColor: isError ? _alertRed : _neonCyan,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.security, color: _neonCyan),
            SizedBox(width: 12),
            Text("YÜKSEK KONSEY TERMİNALİ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSistemOzeti(), // 🚀 MAKET YIKILDI: CANLI RADAR GELDİ
            const SizedBox(height: 30),
            _buildSectionTitle("FİNANSAL ONAY BEKLEYENLER", Icons.account_balance),
            _buildParaTalepleriListesi(),
            const SizedBox(height: 30),
            _buildSectionTitle("İHTİLAFLI DOSYALAR (HAKEM YARGISI)", Icons.gavel),
            _buildIhtilafListesi(),
          ],
        ),
      ),
    );
  }

  // 📊 SİSTEM GENEL DURUMU (Canlı Firebase Radarı)
  Widget _buildSistemOzeti() {
    return Row(
      children: [
        // CANLI AKTİF BAYİ RADARI
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db.collection('bayiler').where('yetki_durumu', isEqualTo: 'ONAYLANDI').snapshots(),
            builder: (context, snapshot) {
              String count = snapshot.hasData ? snapshot.data!.docs.length.toString() : "...";
              return _buildSummaryCard("AKTİF BAYİ AĞI", count, _neonCyan);
            },
          ),
        ),
        const SizedBox(width: 15),
        // CANLI SOS SİNYAL RADARI
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db.collection('sos_alarmlari').where('durum', isEqualTo: 'AKTİF').snapshots(),
            builder: (context, snapshot) {
              String count = snapshot.hasData ? snapshot.data!.docs.length.toString() : "...";
              bool isKritik = count != "0" && count != "...";
              return _buildSummaryCard("S.O.S SİNYALLERİ", "KRİTİK DURUM: $count", isKritik ? _alertRed : Colors.white54);
            },
          ),
        ),
      ],
    );
  }

  // 💎 SİBER CAM EFEKTLİ BİLGİ KARTI
  Widget _buildSummaryCard(String title, String value, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: color.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // 💸 PARA ÇEKME TALEPLERİ (Atomik Onay)
  Widget _buildParaTalepleriListesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('para_cekme_talepleri').where('durum', isEqualTo: 'Bekliyor').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator(color: _neonCyan);
        var docs = snapshot.data!.docs;

        if (docs.isEmpty) return _buildEmptyStatus("ONAY BEKLEYEN FİNANSAL TALEP YOK.");

        return Column(
          children: docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['bayi_adi'] ?? "GİZLİ BAYİ", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text("IBAN: ${data['iban']}", style: const TextStyle(color: _neonCyan, fontSize: 11, letterSpacing: 1.2)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _paraTalebiniOnayla(doc.id, data['bayi_adi'] ?? 'Bayi', data['tutar'].toString()),
                    style: ElevatedButton.styleFrom(backgroundColor: _neonCyan, foregroundColor: Colors.black, elevation: 8, shadowColor: _neonCyan.withOpacity(0.5)),
                    child: Text("₺${data['tutar']} ONAYLA", style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ⚖️ HAKEM MODU (İhtilaf Çözücü)
  Widget _buildIhtilafListesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('ihtilaflar').where('durum', isEqualTo: 'Acık').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        var docs = snapshot.data!.docs;

        if (docs.isEmpty) return _buildEmptyStatus("SAHADA İHTİLAFLI DOSYA YOK.");

        return Column(
          children: docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: _alertRed.withOpacity(0.4), width: 1.5),
                borderRadius: BorderRadius.circular(12),
                color: _alertRed.withOpacity(0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_rounded, color: _alertRed, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text("İHLAL: ${data['baslik']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: Colors.white12),
                  ),
                  Text("Raporlayan: ${data['raporlayan_firma']}", style: const TextStyle(color: _neonCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Şikayet Edilen: ${data['hatali_firma']}", style: const TextStyle(color: _alertRed, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _hakemKarariVer(doc.id, data['hatali_firma_id'], true),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: _neonCyan), padding: const EdgeInsets.symmetric(vertical: 12)),
                          child: const Text("RAPORLAYAN HAKLI", style: TextStyle(color: _neonCyan, fontSize: 10, fontWeight: FontWeight.w900)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _hakemKarariVer(doc.id, data['raporlayan_id'], false),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: _alertRed), padding: const EdgeInsets.symmetric(vertical: 12)),
                          child: const Text("ŞİKAYET EDİLEN HAKLI", style: TextStyle(color: _alertRed, fontSize: 10, fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ── 🛠️ SİBER ATOMİK FONKSİYONLAR (WRITEBATCH EKLENDİ) ───────────────────

  Future<void> _paraTalebiniOnayla(String talepId, String bayiAdi, String tutar) async {
    try {
      developer.log("SİBER FİNANS: $bayiAdi için ₺$tutar ödeme emri Kuantum Kasasında işleniyor...");
      WriteBatch batch = _db.batch();

      // 1. Talebi Kapat
      batch.update(_db.collection('para_cekme_talepleri').doc(talepId), {
        'durum': 'Ödendi',
        'onay_tarihi': FieldValue.serverTimestamp(),
      });

      // 2. Kara Kutuya Mühürle
      batch.set(_db.collection('sistem_loglari').doc(), {
        'islem_turu': 'YUKSEK_KONSEY_ODEME_ONAYI',
        'islem_detayi': 'SİBER FİNANS: Yüksek Konsey, $bayiAdi firmasının ₺$tutar ödeme talebini onayladı.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      _siberUyari("ÖDEME EMRİ VERİLDİ. KARARGAH KASASI GÜNCELLENDİ.");
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Ödeme emri verilemedi!", error: e);
      _siberUyari("SİBER HATA: İşlem tamamlanamadı!", isError: true);
    }
  }

  Future<void> _hakemKarariVer(String docId, String haksizFirmaId, bool raporlayanHakli) async {
    try {
      developer.log("SİBER YARGI: İhtilaf dosyası ($docId) için Yüksek Konsey Kararı mühürleniyor...");
      WriteBatch batch = _db.batch();

      // 1. İhtilaf Dosyasını Kapat
      batch.update(_db.collection('ihtilaflar').doc(docId), {
        'durum': 'Kapalı',
        'karar': raporlayanHakli ? 'Raporlayan Haklı' : 'Şikayet Edilen Haklı',
        'karar_tarihi': FieldValue.serverTimestamp(),
      });

      // 2. Haksız Firmaya Ceza Kes (Atomik Düşüş)
      batch.update(_db.collection('kullanicilar').doc(haksizFirmaId), {
        'puan': FieldValue.increment(-0.5) // Karargah Cezası
      });

      // 3. Yargıyı Kara Kutuya Mühürle
      batch.set(_db.collection('sistem_loglari').doc(), {
        'islem_turu': 'YUKSEK_KONSEY_HAKEM_KARARI',
        'islem_detayi': 'SİBER YARGI: İhtilaf dosyası kapatıldı. Haksız firmaya ceza puanı uygulandı.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      _siberUyari("HAKEM KARARI MÜHÜRLENDİ. İLGİLİ FİRMAYA CEZA KESİLDİ.");
    } catch (e) {
      developer.log("AĞ ÇÖKTÜ: Hakem kararı uygulanamadı!", error: e);
      _siberUyari("SİBER HATA: Adalet motoru arızalandı!", isError: true);
    }
  }

  // ── 🔧 YARDIMCI WIDGETLAR ───────────────────────────────────────────────
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: _neonCyan, size: 20),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
        ],
      ),
    );
  }

  Widget _buildEmptyStatus(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10, style: BorderStyle.solid)
      ),
      child: Column(
        children: [
          const Icon(Icons.verified_user_outlined, color: Colors.white24, size: 30),
          const SizedBox(height: 10),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ],
      ),
    );
  }
}