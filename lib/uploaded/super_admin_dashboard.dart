import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      content: Text(mesaj, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? _alertRed : _neonCyan,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.security, color: _neonCyan),
            SizedBox(width: 12),
            Text("YÜKSEK KONSEY TERMİNALİ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSistemOzeti(),
            const SizedBox(height: 30),
            _buildSectionTitle("PARA ÇEKME TALEPLERİ", Icons.account_balance),
            _buildParaTalepleriListesi(),
            const SizedBox(height: 30),
            _buildSectionTitle("İHTİLAFLI DOSYALAR (HAKEM MODU)", Icons.gavel),
            _buildIhtilafListesi(),
          ],
        ),
      ),
    );
  }

  // 📊 SİSTEM GENEL DURUMU (Canlı Veri)
  Widget _buildSistemOzeti() {
    return Row(
      children: [
        _buildSummaryCard("AKTİF BAYİ", "81 İL / 7 BÖLGE", _neonCyan),
        const SizedBox(width: 15),
        _buildSummaryCard("TOPLAM SOS", "KRİTİK DURUM: 0", _alertRed),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // 💸 PARA ÇEKME TALEPLERİ (Karargah Onayı)
  Widget _buildParaTalepleriListesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('para_cekme_talepleri').where('durum', isEqualTo: 'Bekliyor').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator(color: _neonCyan);
        var docs = snapshot.data!.docs;

        if (docs.isEmpty) return _buildEmptyStatus("Bekleyen ödeme talebi yok.");

        return Column(
          children: docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['bayi_adi'] ?? "Bilinmeyen Bayi", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text("IBAN: ${data['iban']}", style: const TextStyle(color: Colors.white54, fontSize: 10)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _paraTalebiniOnayla(doc.id),
                    style: ElevatedButton.styleFrom(backgroundColor: _neonCyan, foregroundColor: Colors.black),
                    child: Text("₺${data['tutar']} ONAYLA"),
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

        if (docs.isEmpty) return _buildEmptyStatus("İhtilaflı dosya bulunmuyor.");

        return Column(
          children: docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: _alertRed.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
                color: _alertRed.withOpacity(0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("KONU: ${data['baslik']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Raporlayan: ${data['raporlayan_firma']}", style: const TextStyle(color: _neonCyan, fontSize: 11)),
                  Text("İşlem Yapan: ${data['hatali_firma']}", style: const TextStyle(color: _alertRed, fontSize: 11)),
                  const Divider(color: Colors.white12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _hakemKarariVer(doc.id, data['raporlayan_id'], true),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: _neonCyan)),
                          child: const Text("RAPORLAYAN HAKLI", style: TextStyle(color: _neonCyan, fontSize: 10)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _hakemKarariVer(doc.id, data['hatali_firma_id'], false),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: _alertRed)),
                          child: const Text("İŞLEM YAPAN HAKLI", style: TextStyle(color: _alertRed, fontSize: 10)),
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

  // 🛠️ SİBER FONKSİYONLAR
  Future<void> _paraTalebiniOnayla(String talepId) async {
    await _db.collection('para_cekme_talepleri').doc(talepId).update({
      'durum': 'Ödendi',
      'onay_tarihi': FieldValue.serverTimestamp(),
    });
    _siberUyari("ÖDEME EMRİ VERİLDİ. KARARGAH KASASI GÜNCELLENDİ.");
  }

  Future<void> _hakemKarariVer(String docId, String haksizFirmaId, bool raporlayanHakli) async {
    // Haksız olan firmanın puanını düşür ve dosyayı kapat
    await _db.collection('ihtilaflar').doc(docId).update({'durum': 'Kapalı', 'karar': raporlayanHakli ? 'Raporlayan Haklı' : 'İşlem Yapan Haklı'});
    await _db.collection('kullanicilar').doc(haksizFirmaId).update({'puan': FieldValue.increment(-0.5)});
    _siberUyari("HAKEM KARARI MÜHÜRLENDİ. PUAN CEZASI KESİLDİ.");
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: _neonCyan, size: 18),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildEmptyStatus(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(12)),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white24, fontSize: 12)),
    );
  }
}