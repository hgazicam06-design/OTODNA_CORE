import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class BildirimDetayScreen extends ConsumerStatefulWidget {
  final String bildirimId; // 🔥 Radardan gelen bildirim kimliği

  const BildirimDetayScreen({super.key, required this.bildirimId});

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
      // Bildirimi mühürle ve yanıtı karşı tarafa (vatandaş koleksiyonuna) ilet
      await _db.collection('bildirimler').doc(widget.bildirimId).update({
        'yanit': mesaj,
        'durum': 'Müdahale Edildi',
        'islem_tarihi': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: SiberTema.kuantumCyan,
          content: Text('\"$mesaj\" protokolü ağa mühürlendi. 🦅',
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      );
    } catch (e) {
      debugPrint("SİBER HATA: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // 🛡️ SİBER SAVUNMA: CİHAZ ENGELLEME (KARALİSTE)
  Future<void> _kullaniciyiEngelle(String ipAdresi) async {
    setState(() => _isProcessing = true);
    try {
      // IP ve Cihaz ID'sini siber karalisteye mühürle
      await _db.collection('karaliste').add({
        'ip': ipAdresi,
        'neden': 'Hatalı/Taciz Bildirimi',
        'tarih': FieldValue.serverTimestamp(),
        'tip': 'DEVICE_BAN'
      });

      await _db.collection('bildirimler').doc(widget.bildirimId).update({'durum': 'ENGELLENDİ'});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.redAccent, content: Text('SİBER İHLAL: Cihaz ağdan kalıcı olarak silindi.')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => Navigator.pop(context)),
          title: const Text('ACİL DURUM TERMİNALİ', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, letterSpacing: 2)),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: _db.collection('bildirimler').doc(widget.bildirimId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));

            var data = snapshot.data!.data() as Map<String, dynamic>;
            bool isBlocked = data['durum'] == 'ENGELLENDİ';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildAlertCard(data),
                  const SizedBox(height: 24),
                  _buildLogPanel(data),
                  const SizedBox(height: 24),
                  if (!isBlocked) _buildAksiyonPanel(data),
                  if (isBlocked) _buildEngellemeMesaji(),
                ],
              ),
            );
          },
        ),
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
              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 40),
              const SizedBox(width: 16),
              Expanded(child: Text(data['baslik'] ?? 'BİLİNMEYEN SİNYAL', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))),
            ],
          ),
          const Divider(color: Colors.white10, height: 32),
          Text(data['mesaj'] ?? 'Mesaj içeriği okunamadı.', style: const TextStyle(color: Colors.white70, height: 1.5)),
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
          _logSatiri('SAAT', (data['tarih'] as Timestamp).toDate().toString().substring(11, 16), Icons.access_time),
        ],
      ),
    );
  }

  Widget _logSatiri(String t, String v, IconData i) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(i, color: SiberTema.kuantumCyan, size: 16),
        const SizedBox(width: 12),
        Text(t, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
        const Spacer(),
        Text(v, style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')),
      ]),
    );
  }

  Widget _buildAksiyonPanel(Map<String, dynamic> data) {
    return Column(
      children: [
        _buildAksiyonButon('5 DAKİKAYA GELİYORUM', () => _yanitProtokolu('5 Dakikaya oradayım.')),
        const SizedBox(height: 12),
        _buildAksiyonButon('ARACIN BAŞINDA BEKLEYİN', () => _yanitProtokolu('Hemen geliyorum, ayrılmayın.')),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: () => _kullaniciyiEngelle(data['gonderen_ip'] ?? '0.0.0.0'),
          icon: const Icon(Icons.block, color: Colors.redAccent),
          label: const Text('RAHATSIZ EDİCİ BİLDİRİM (ENGELLE)', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _buildAksiyonButon(String metin, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: SiberTema.kuantumButonStili(),
        onPressed: _isProcessing ? null : onTap,
        child: Text(metin, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _buildEngellemeMesaji() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: const Text('SİBER SAVUNMA AKTİF: BU SİNYAL KAYNAĞI AĞDAN DIŞLANDI.', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
    );
  }
}