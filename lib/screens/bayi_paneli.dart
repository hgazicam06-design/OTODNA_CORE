import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class BayiPaneliScreen extends StatefulWidget {
  final String bayiId; // 🔥 İŞTE SİBER KİLİDİ ÇÖZEN PARAMETRE!

  const BayiPaneliScreen({super.key, required this.bayiId});

  @override
  State<BayiPaneliScreen> createState() => _BayiPaneliScreenState();
}

class _BayiPaneliScreenState extends State<BayiPaneliScreen> with SingleTickerProviderStateMixin {
  final Color bgColor = const Color(0xFF000000);
  final Color surfaceColor = const Color(0xFF111111);
  final Color primaryCyan = const Color(0xFF00FFC2);
  final Color dangerColor = Colors.redAccent;

  late AnimationController _radarCtrl;

  @override
  void initState() {
    super.initState();
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _radarCtrl.dispose();
    super.dispose();
  }

  Future<void> _sinyalDurumGuncelle(String docId, String yeniDurum, bool asilsizMi) async {
    try {
      await FirebaseFirestore.instance.collection('sos_sinyalleri').doc(docId).update({
        'durum': yeniDurum,
        'asilsiz_ihbar_mi': asilsizMi,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(asilsizMi ? 'İHLAL RAPORLANDI: ASILSIZ SİNYAL!' : 'MÜDAHALE BAŞLADI: EKİP YÖNLENDİRİLDİ 🦅', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: asilsizMi ? dangerColor : primaryCyan,
          )
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AĞ HATASI: $e', style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: dangerColor),
      );
    }
  }

  Future<void> _haritayiAc(String konumStr) async {
    if (konumStr == 'Konum Alınamadı' || !konumStr.contains(',')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir koordinat bulunamadı!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    try {
      final url = Uri.parse('http://maps.google.com/maps?q=$konumStr');
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Harita açılamadı');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Siber Hata: Harita tetiklenemedi!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('B A Y İ   S . O . S   R A D A R I', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: dangerColor.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: dangerColor.withOpacity(0.5))),
            child: Icon(Icons.emergency_recording, color: dangerColor, size: 16),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.radar, color: primaryCyan, size: 20),
                const SizedBox(width: 12),
                const Text("CANLI SAHA TAKİBİ", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const Spacer(),
                // Bayi kimliğini ekranda ufakça gösteriyoruz ki Kuantum hissi versin
                Text("ID: ${widget.bayiId.substring(0, 6)}...", style: TextStyle(color: primaryCyan.withOpacity(0.5), fontSize: 8, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('sos_sinyalleri')
                  .orderBy('sinyal_zamani', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('RADAR BAĞLANTI HATASI!', style: TextStyle(color: dangerColor, fontWeight: FontWeight.bold)));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: primaryCyan));
                }

                final data = snapshot.requireData;

                if (data.size == 0) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _radarCtrl,
                          builder: (_, __) => Transform.scale(
                            scale: 0.95 + 0.05 * _radarCtrl.value,
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryCyan.withOpacity(0.05),
                                border: Border.all(color: primaryCyan.withOpacity(0.2 + 0.2 * _radarCtrl.value)),
                              ),
                              child: const Icon(Icons.shield_outlined, color: Color(0xFF00FFC2), size: 64),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text('SAHADA HER ŞEY SAKİN', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        const SizedBox(height: 12),
                        const Text('Aktif S.O.S sinyali bulunmuyor.\nRadar taramaya devam ediyor...', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.5)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: data.size,
                  itemBuilder: (context, index) {
                    var sinyal = data.docs[index];
                    var docId = sinyal.id;
                    Map<String, dynamic> sinyalData = sinyal.data() as Map<String, dynamic>;

                    var plaka = sinyalData['plaka'] ?? 'BİLİNMİYOR';
                    var kullanici = sinyalData['kullanici'] ?? 'BİLİNMEYEN SÜRÜCÜ';
                    var durum = sinyalData['durum'] ?? 'Bekliyor';
                    var konum = sinyalData['konum'] ?? 'Konum Alınamadı';

                    bool isBekliyor = durum == 'Bekliyor';
                    Color durumRengi = isBekliyor ? dangerColor : primaryCyan;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isBekliyor ? dangerColor.withOpacity(0.05) : surfaceColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isBekliyor ? dangerColor.withOpacity(0.5) : Colors.white.withOpacity(0.05), width: isBekliyor ? 2 : 1),
                        boxShadow: isBekliyor ? [BoxShadow(color: dangerColor.withOpacity(0.1), blurRadius: 20)] : [],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(isBekliyor ? Icons.warning_amber_rounded : Icons.check_circle_outline, color: durumRengi, size: 28),
                                  const SizedBox(width: 12),
                                  Text(plaka.toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: durumRengi.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: durumRengi.withOpacity(0.5)),
                                ),
                                child: Text(durum.toUpperCase(), style: TextStyle(color: durumRengi, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1)),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(color: Colors.white12),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.person_outline, color: Colors.white38, size: 16),
                              const SizedBox(width: 8),
                              Text(kullanici.toString().toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),

                          GestureDetector(
                            onTap: () => _haritayiAc(konum),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.orangeAccent, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      konum == 'Konum Alınamadı' ? konum : "Konuma Gitmek İçin Tıklayın (Navigasyon)",
                                      style: const TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Icon(Icons.navigation, color: Colors.orangeAccent, size: 16),
                                ],
                              ),
                            ),
                          ),

                          if (isBekliyor) ...[
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryCyan,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    icon: const Icon(Icons.electric_bolt, size: 18),
                                    label: const Text('MÜDAHALE ET', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                                    onPressed: () => _sinyalDurumGuncelle(docId, 'Müdahale Edildi', false),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: dangerColor,
                                      side: BorderSide(color: dangerColor.withOpacity(0.5)),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Icon(Icons.block, size: 20),
                                    onPressed: () => _sinyalDurumGuncelle(docId, 'Asılsız İhbar', true),
                                  ),
                                ),
                              ],
                            )
                          ]
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}