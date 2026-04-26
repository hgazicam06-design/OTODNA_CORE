// lib/screens/bayi/usta_akustik_radar_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../../services/siber_kalfa_servisi.dart';

class UstaAkustikRadarScreen extends StatefulWidget {
  final String ustaId;
  const UstaAkustikRadarScreen({super.key, required this.ustaId});

  @override
  State<UstaAkustikRadarScreen> createState() => _UstaAkustikRadarScreenState();
}

class _UstaAkustikRadarScreenState extends State<UstaAkustikRadarScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SiberKalfaServisi _kalfa = SiberKalfaServisi();

  String? _calinanKayitId;
  bool _isPlay = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _sesiCalDurdur(String url, String id) async {
    if (_calinanKayitId == id && _isPlay) {
      await _audioPlayer.pause();
      setState(() => _isPlay = false);
    } else {
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        _calinanKayitId = id;
        _isPlay = true;
      });
      // Ses bitince butonu sıfırla
      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() => _isPlay = false);
      });
    }
  }

  // ── 🚀 USTADAN MÜŞTERİYE TEŞHİS FIRLATMA (ATOMİK) ──
  Future<void> _teshisGonder(String analizId, String musteriId) async {
    TextEditingController teshisCtrl = TextEditingController();
    TextEditingController fiyatCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SiberTema.matGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: SiberTema.kuantumCyan)),
        title: const Text("SİBER TEŞHİS VE TEKLİF", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: teshisCtrl, style: const TextStyle(color: Colors.white), maxLines: 3, decoration: const InputDecoration(hintText: "Usta Yorumu...", hintStyle: TextStyle(color: Colors.white38))),
            const SizedBox(height: 10),
            TextField(controller: fiyatCtrl, style: const TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold), keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Tahmini Maliyet (₺)", hintStyle: TextStyle(color: Colors.white38))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İPTAL", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: SiberTema.kuantumButonStili(),
            onPressed: () async {
              Navigator.pop(context);
              WriteBatch batch = _db.batch();

              // 1. Analizi Güncelle
              DocumentReference analizRef = _db.collection('akustik_analizler').doc(analizId);
              batch.update(analizRef, {
                'durum': 'USTA_YANITLADI',
                'usta_teshisi': teshisCtrl.text.trim(),
                'tahmini_fiyat': double.tryParse(fiyatCtrl.text) ?? 0.0,
                'yanitlayan_usta_id': widget.ustaId,
                'yanit_tarihi': FieldValue.serverTimestamp(),
              });

              // 2. Müşteriye Bildirim Fırlat
              DocumentReference bildirimRef = _db.collection('bildirimler').doc();
              batch.set(bildirimRef, {
                'hedef_kullanici': musteriId,
                'baslik': 'SİBER TEŞHİS GELDİ!',
                'mesaj': 'Ustanız motor sesini dinledi ve teşhisini iletti.',
                'tarih': FieldValue.serverTimestamp(),
              });

              // 3. İstihbarat Kara Kutusuna Mühürle
              DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
              batch.set(logRef, {
                'islem_turu': 'AKUSTIK_TESHIS_GONDERIMI',
                'islem_detayi': 'SİBER KALFA: Usta (${widget.ustaId}), müşteri ($musteriId) için motor sesini dinleyip teşhisini iletti. Tahmini Fiyat: ${fiyatCtrl.text} ₺',
                'usta_id': widget.ustaId,
                'musteri_id': musteriId,
                'analiz_id': analizId,
                'tarih': FieldValue.serverTimestamp(),
              });

              await batch.commit();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Teşhis Karargaha mühürlendi!"), backgroundColor: SiberTema.kuantumCyan));
            },
            child: const Text("MÜŞTERİYE FIRLAT", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("AKUSTİK RADAR VE SİBER KALFA", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5)),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: StreamBuilder<QuerySnapshot>(
          // Sadece bekleyen sesleri dinle
          stream: _db.collection('akustik_analizler').where('durum', isEqualTo: 'USTA_DINLEMESI_BEKLIYOR').orderBy('yuklenme_tarihi', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("RADAR TEMİZ. Bekleyen ses analizi yok.", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)));

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var veri = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                String analizId = snapshot.data!.docs[index].id;
                bool aiTamamlandi = veri['ai_analiz_tamamlandi'] ?? false;

                // Siber Kalfa henüz analiz etmediyse otonom tetikle
                if (!aiTamamlandi) {
                  _kalfa.sesiAnalizEt(analizId, veri['ses_url']);
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: SiberTema.matGrey.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. MÜŞTERİ ŞİKAYETİ VE SES ÇALAR
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _sesiCalDurdur(veri['ses_url'], analizId),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: (_calinanKayitId == analizId && _isPlay) ? SiberTema.kanKirmizi : SiberTema.kuantumCyan.withOpacity(0.1), shape: BoxShape.circle),
                              child: Icon((_calinanKayitId == analizId && _isPlay) ? Icons.pause : Icons.play_arrow, color: (_calinanKayitId == analizId && _isPlay) ? Colors.white : SiberTema.kuantumCyan, size: 32),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("MÜŞTERİ NOTU", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                const SizedBox(height: 4),
                                Text(veri['ariza_notu'] ?? "Not girilmemiş.", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 10),

                      // 2. SİBER KALFA (YAPAY ZEKA) RAPORU
                      if (!aiTamamlandi)
                        const Row(children: [CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 2), SizedBox(width: 12), Text("Siber Kalfa sesi analiz ediyor...", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 12))])
                      else ...[
                        const Row(
                          children: [
                            Icon(Icons.psychology, color: Colors.amberAccent, size: 20),
                            SizedBox(width: 8),
                            Text("SİBER KALFA (AI) RAPORU:", style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(veri['kalfa_notu'] ?? "", style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 10),
                        // Eşleşme Oranları Çubuğu
                        ...List.generate((veri['ai_tahminleri'] as List).length, (i) {
                          var tahmin = veri['ai_tahminleri'][i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(flex: 3, child: Text(tahmin['ariza'], style: const TextStyle(color: Colors.white, fontSize: 11))),
                                Expanded(flex: 2, child: LinearProgressIndicator(value: tahmin['eslesme_orani'] / 100, backgroundColor: Colors.white12, color: tahmin['eslesme_orani'] > 70 ? SiberTema.kanKirmizi : SiberTema.kuantumCyan)),
                                const SizedBox(width: 8),
                                Text("%${tahmin['eslesme_orani']}", style: TextStyle(color: tahmin['eslesme_orani'] > 70 ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, fontWeight: FontWeight.bold, fontSize: 11)),
                              ],
                            ),
                          );
                        }),
                      ],

                      const SizedBox(height: 20),

                      // 3. USTA MÜDAHALE BUTONU
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kuantumCyan, foregroundColor: SiberTema.oledBlack, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: () => _teshisGonder(analizId, veri['kullanici_id']),
                          icon: const Icon(Icons.send_rounded, size: 20),
                          label: const Text("TEŞHİS KOY VE FİYAT VER", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}