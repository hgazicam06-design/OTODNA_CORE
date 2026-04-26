import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';

class BildirimDetayScreen extends StatelessWidget {
  final String saseNo;
  final String bildirimId;
  final Map<String, dynamic> data;

  const BildirimDetayScreen({
    super.key,
    required this.saseNo,
    required this.bildirimId,
    required this.data,
  });

  // 🏢 PLAZA KALİTESİ PALET
  static const _bgColor = Color(0xFFFAFAFC);
  static const _cardColor = Colors.white;
  static const _textColor = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    final primaryTeal = Colors.teal.shade700;
    final notifService = NotificationService();
    final tur = data['tur'] ?? 'diger';
    final mesaj = data['mesaj'] ?? 'Detaylı sinyal verisi bulunamadı.';
    final ip = data['gonderenIp'] ?? 'Bilinmeyen IP';
    final tarih = (data['tarih'] as Timestamp?)?.toDate();

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _cardColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 1)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Sinyal Detay Raporu',
            style: TextStyle(color: _textColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ÜST KART: Sinyal Türü ve İkon
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryTeal.withValues(alpha: 0.05),
                  border: Border.all(color: primaryTeal.withValues(alpha: 0.2), width: 2),
                  boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.05), blurRadius: 20, spreadRadius: 5)],
                ),
                child: Text(notifService.turIcon(tur), style: const TextStyle(fontSize: 60)),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                notifService.turLabel(tur).toUpperCase(),
                style: TextStyle(color: primaryTeal, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir'),
              ),
            ),
            const SizedBox(height: 40),

            // ORTA KART: Bildirim İçeriği
            const Text("SİNYAL İÇERİĞİ", style: TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
              ),
              child: Text(
                mesaj,
                style: const TextStyle(color: _textColor, fontSize: 14, height: 1.5, fontFamily: 'Avenir', fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 32),

            // ALT KART: Güvenlik ve Ağ Verileri (IP, Tarih)
            const Text("SİBER AĞ İZLERİ", style: TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  _buildAgaVeriSatiri(Icons.wifi_tethering, "Gönderici IP", ip, Colors.redAccent),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.black.withValues(alpha: 0.05))),
                  _buildAgaVeriSatiri(Icons.security, "Hedef Şase", saseNo, _textColor),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.black.withValues(alpha: 0.05))),
                  _buildAgaVeriSatiri(Icons.access_time, "Zaman Damgası", tarih != null ? _formatDate(tarih) : "Bilinmiyor", _textColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgaVeriSatiri(IconData icon, String baslik, String deger, Color degerRengi) {
    return Row(
      children: [
        Icon(icon, color: Colors.black38, size: 18),
        const SizedBox(width: 12),
        Text(baslik, style: const TextStyle(color: Colors.black54, fontSize: 13, fontFamily: 'Avenir')),
        const Spacer(),
        Text(deger, style: TextStyle(color: degerRengi, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 1)),
      ],
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} | ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}