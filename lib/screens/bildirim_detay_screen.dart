import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class BildirimDetayScreen extends ConsumerStatefulWidget {
  final String bildirimId; // 🔥 Radardan gelen bildirim kimliği

  BildirimDetayScreen({super.key, required this.bildirimId});

  @override
  ConsumerState<BildirimDetayScreen> createState() => _BildirimDetayScreenState();
}

class _BildirimDetayScreenState extends ConsumerState<BildirimDetayScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isProcessing = false;

  // 💰 SİBER YANIT MOTORU (FİREBASE ENTEGRASYONU)
  Future<void> _yanitProtokolu(String mesaj) async {
    setState(() => _isProcessing = true);
    try {
      // Bildirimi mühürle ve durumu "Müdahale Edildi" olarak güncelle
      await _db.collection('bildirimler').doc(widget.bildirimId).update({
        'yanit': mesaj,
        'durum': 'Müdahale Edildi',
        'islem_tarihi': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: SiberTema.kuantumCyan,
          content: Text('"$mesaj" protokolü ağa mühürlendi. 🦅',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ),
      );
    } catch (e) {
      debugPrint("SİBER HATA: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // 🛡️ SİBER SAVUNMA: ATOMİK ENGELLEME (WRITEBATCH)
  Future<void> _kullaniciyiEngelle(String ipAdresi) async {
    setState(() => _isProcessing = true);
    try {
      WriteBatch batch = _db.batch();

      // 1. IP Adresini Karalisteye Sabit ID ile Mühürle (Mükerrer Kaydı Önler)
      DocumentReference blacklistRef = _db.collection('karaliste').doc(ipAdresi.replaceAll('.', '_'));
      batch.set(blacklistRef, {
        'ip': ipAdresi,
        'neden': 'Siber Taciz / Hatalı İhbar',
        'tarih': FieldValue.serverTimestamp(),
        'tip': 'DEVICE_BAN',
        'derece': 'KRİTİK'
      });

      // 2. Bildirim Durumunu Güncelle
      DocumentReference bildirimRef = _db.collection('bildirimler').doc(widget.bildirimId);
      batch.update(bildirimRef, {'durum': 'ENGELLENDİ'});

      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('SİBER İHLAL: Cihaz ağdan kalıcı olarak dışlandı.', style: TextStyle(fontWeight: FontWeight.bold))
        ),
      );
    } catch (e) {
      debugPrint("SAVUNMA HATASI: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20),
              onPressed: () => Navigator.pop(context)
          ),
          title: Text('ACİL DURUM TERMİNALİ',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3)
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: _db.collection('bildirimler').doc(widget.bildirimId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));

            var data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data == null) return Center(child: Text("SİNYAL KAYBI: VERİ OKUNAMADI", style: TextStyle(color: SiberTema.textMuted)));

            bool isBlocked = data['durum'] == 'ENGELLENDİ';
            bool isIntervened = data['durum'] == 'Müdahale Edildi';

            return SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildZamanSayaci(data['tarih']),
                  SizedBox(height: 20),
                  _buildAlertCard(data),
                  SizedBox(height: 20),
                  _buildLogPanel(data),
                  SizedBox(height: 32),
                  if (!isBlocked && !isIntervened) _buildAksiyonPanel(data),
                  if (isIntervened) _buildMudahaleOzeti(data),
                  if (isBlocked) _buildEngellemeMesaji(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildZamanSayaci(dynamic timestamp) {
    if (timestamp == null) return SizedBox();
    DateTime olusma = (timestamp as Timestamp).toDate();
    Duration fark = DateTime.now().difference(olusma);
    int kalanDakika = 30 - fark.inMinutes;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: kalanDakika > 0 ? Colors.orangeAccent.withOpacity(0.1) : Colors.redAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kalanDakika > 0 ? Colors.orangeAccent.withOpacity(0.3) : Colors.redAccent)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: kalanDakika > 0 ? Colors.orangeAccent : Colors.redAccent, size: 16),
          SizedBox(width: 8),
          Text(
            kalanDakika > 0 ? "ADMİN MÜDAHALESİNE: $kalanDakika DK" : "ADMİN MÜDAHALE SÜRESİ DOLDU!",
            style: TextStyle(color: kalanDakika > 0 ? Colors.orangeAccent : Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> data) {
    return SiberTema.siberCamKalkan(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 32),
              SizedBox(width: 16),
              Expanded(
                  child: Text(data['baslik']?.toString().toUpperCase() ?? 'BİLİNMEYEN SİNYAL',
                      style: TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)
                  )
              ),
            ],
          ),
          Divider(color: SiberTema.textMuted, height: 32),
          Text(data['mesaj'] ?? 'Mesaj içeriği okunamadı.',
              style: TextStyle(color: SiberTema.textMuted, fontSize: 13, height: 1.6, fontWeight: FontWeight.w500)
          ),
        ],
      ),
    );
  }

  Widget _buildLogPanel(Map<String, dynamic> data) {
    return SiberTema.siberCamKalkan(
      child: Column(
        children: [
          _logSatiri('IP ADRESİ', data['gonderen_ip'] ?? 'Gizli Sinyal', Icons.radar),
          _logSatiri('KONUM', data['konum_etiketi'] ?? 'Tespit Edilemedi', Icons.location_on),
          _logSatiri('SİNYAL SAATİ', _formatTimestamp(data['tarih']), Icons.access_time),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic ts) {
    if (ts == null) return "--:--";
    DateTime date = (ts as Timestamp).toDate();
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  Widget _logSatiri(String t, String v, IconData i) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Icon(i, color: SiberTema.kuantumCyan, size: 14),
        SizedBox(width: 12),
        Text(t, style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
        Spacer(),
        Text(v, style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildAksiyonPanel(Map<String, dynamic> data) {
    return Column(
      children: [
        _buildAksiyonButon('5 DAKİKAYA GELİYORUM', () => _yanitProtokolu('5 Dakikaya oradayım.'), SiberTema.kuantumCyan),
        SizedBox(height: 12),
        _buildAksiyonButon('ARACIN BAŞINDA BEKLEYİN', () => _yanitProtokolu('Hemen geliyorum, ayrılmayın.'), Colors.white),
        SizedBox(height: 32),
        TextButton.icon(
          onPressed: _isProcessing ? null : () => _kullaniciyiEngelle(data['gonderen_ip'] ?? '0.0.0.0'),
          icon: Icon(Icons.block, color: Colors.redAccent, size: 18),
          label: Text('RAHATSIZ EDİCİ BİLDİRİM (AĞDAN DIŞLA)',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)
          ),
        )
      ],
    );
  }

  Widget _buildAksiyonButon(String metin, VoidCallback onTap, Color accent) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: accent == SiberTema.kuantumCyan ? SiberTema.kuantumCyan : Colors.transparent,
            side: accent == Colors.white ? BorderSide(color: SiberTema.textMuted) : null,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: accent == SiberTema.kuantumCyan ? 10 : 0,
            shadowColor: accent.withOpacity(0.3)
        ),
        onPressed: _isProcessing ? null : onTap,
        child: Text(metin, style: TextStyle(color: accent == SiberTema.kuantumCyan ? Colors.black : Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12)),
      ),
    );
  }

  Widget _buildMudahaleOzeti(Map<String, dynamic> data) {
    return SiberTema.siberCamKalkan(
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, color: SiberTema.kuantumCyan, size: 40),
          SizedBox(height: 12),
          Text("MÜDAHALE EDİLDİ", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2)),
          SizedBox(height: 8),
          Text("GÖNDERİLEN YANIT: ${data['yanit']}",
              textAlign: TextAlign.center,
              style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }

  Widget _buildEngellemeMesaji() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3))
      ),
      child: Column(
        children: [
          Icon(Icons.gpp_bad, color: Colors.redAccent, size: 40),
          SizedBox(height: 16),
          Text('SİBER SAVUNMA AKTİF', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 2)),
          SizedBox(height: 8),
          Text('BU SİNYAL KAYNAĞI AĞDAN KALICI OLARAK DIŞLANDI.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }
}