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

  static const _cyan = Color(0xFF00FFC2);
  static const _dark = Color(0xFF070B14); // Dijital Kale Arka Planı
  static const _cardDark = Color(0xFF121B2B); // Dijital Kale Kart Rengi

  @override
  Widget build(BuildContext context) {
    final notifService = NotificationService();
    final tur = data['tur'] ?? 'diger';
    final mesaj = data['mesaj'] ?? 'Detaylı sinyal verisi bulunamadı.';
    final ip = data['gonderenIp'] ?? 'Bilinmeyen IP';
    final tarih = (data['tarih'] as Timestamp?)?.toDate();

    return Scaffold(
      backgroundColor: _dark,
      appBar: AppBar(
        backgroundColor: _cardDark,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: Colors.white12, width: 1)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _cyan, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Sinyal Detay Raporu',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                  color: _cyan.withOpacity(0.05),
                  border: Border.all(color: _cyan.withOpacity(0.5), width: 2),
                  boxShadow: [BoxShadow(color: _cyan.withOpacity(0.15), blurRadius: 20, spreadRadius: 5)],
                ),
                child: Text(notifService.turIcon(tur), style: const TextStyle(fontSize: 60)),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                notifService.turLabel(tur).toUpperCase(),
                style: const TextStyle(color: _cyan, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
            ),
            const SizedBox(height: 40),

            // ORTA KART: Bildirim İçeriği
            const Text("SİNYAL İÇERİĞİ", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
              ),
              child: Text(
                mesaj,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 32),

            // ALT KART: Güvenlik ve Ağ Verileri (IP, Tarih)
            const Text("SİBER AĞ İZLERİ", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _buildAgaVeriSatiri(Icons.wifi_tethering, "Gönderici IP", ip, Colors.redAccent),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white12)),
                  _buildAgaVeriSatiri(Icons.security, "Hedef Şase", saseNo, Colors.white70),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white12)),
                  _buildAgaVeriSatiri(Icons.access_time, "Zaman Damgası", tarih != null ? _formatDate(tarih) : "Bilinmiyor", Colors.white70),
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
        Icon(icon, color: Colors.white38, size: 18),
        const SizedBox(width: 12),
        Text(baslik, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        const Spacer(),
        Text(deger, style: TextStyle(color: degerRengi, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 1)),
      ],
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} | ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}