import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BayiPaneliScreen extends StatefulWidget {
  BayiPaneliScreen({super.key});

  @override
  State<BayiPaneliScreen> createState() => _BayiPaneliScreenState();
}

class _BayiPaneliScreenState extends State<BayiPaneliScreen> with SingleTickerProviderStateMixin {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = Color(0xFF000000);
  final Color surfaceColor = Color(0xFF111111);
  final Color primaryCyan = Color(0xFF00FFC2);
  final Color dangerColor = Colors.redAccent;

  late AnimationController _radarCtrl;

  @override
  void initState() {
    super.initState();
    // Boş ekran radar efekti
    _radarCtrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _radarCtrl.dispose();
    super.dispose();
  }

  // 🚀 SİNYAL MÜDAHALE MOTORU
  Future<void> _sinyalDurumGuncelle(String docId, String yeniDurum, bool asilsizMi) async {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // 1. Sinyali Güncelle
      DocumentReference sinyalRef = FirebaseFirestore.instance.collection('sos_sinyalleri').doc(docId);
      batch.update(sinyalRef, {
        'durum': yeniDurum,
        'asilsiz_ihbar_mi': asilsizMi,
      });

      // 2. Siber İstihbarata Mühürle
      DocumentReference logRef = FirebaseFirestore.instance.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'kategori': 'GÜVENLİK',
        'seviye': asilsizMi ? 'KRİTİK' : 'BİLGİ',
        'mesaj': asilsizMi 
            ? 'ASILSIZ SİNYAL: Bayi bir S.O.S sinyalini asılsız olarak işaretledi ve reddetti!'
            : 'MÜDAHALE BAŞLADI: Bayi S.O.S acil durum operasyonu için saha ekibi yönlendirdi.',
        'hedef_id': docId,
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(asilsizMi ? 'İHLAL RAPORLANDI: ASILSIZ SİNYAL!' : 'MÜDAHALE BAŞLADI: EKİP YÖNLENDİRİLDİ 🦅', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: asilsizMi ? dangerColor : primaryCyan,
          )
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AĞ HATASI: $e', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: dangerColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('B A Y İ   S . O . S   R A D A R I', style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(color: dangerColor.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: dangerColor.withOpacity(0.5))),
            child: Icon(Icons.emergency_recording, color: dangerColor, size: 16),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.radar, color: primaryCyan, size: 20),
                SizedBox(width: 12),
                Text("CANLI SAHA TAKİBİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
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

                // =================================================================
                // 1. BOŞ EKRAN (SAHA SAKİN)
                // =================================================================
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
                              padding: EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryCyan.withOpacity(0.05),
                                border: Border.all(color: primaryCyan.withOpacity(0.2 + 0.2 * _radarCtrl.value)),
                              ),
                              child: Icon(Icons.shield_outlined, color: Color(0xFF00FFC2), size: 64),
                            ),
                          ),
                        ),
                        SizedBox(height: 32),
                        Text('SAHADA HER ŞEY SAKİN', style: TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        SizedBox(height: 12),
                        Text('Aktif S.O.S sinyali bulunmuyor.\nRadar taramaya devam ediyor...', textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMuted, fontSize: 12, height: 1.5)),
                      ],
                    ),
                  );
                }

                // =================================================================
                // 2. S.O.S SİNYALLERİ LİSTESİ
                // =================================================================
                return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: data.size,
                  itemBuilder: (context, index) {
                    var sinyal = data.docs[index];
                    var docId = sinyal.id;
                    var plaka = sinyal['plaka'] ?? 'BİLİNMİYOR';
                    var kullanici = sinyal['kullanici'] ?? 'BİLİNMEYEN SÜRÜCÜ';
                    var durum = sinyal['durum'] ?? 'Bekliyor';
                    var konum = sinyal['konum'] ?? 'Konum Alınamadı';

                    bool isBekliyor = durum == 'Bekliyor';

                    return Container(
                      margin: EdgeInsets.only(bottom: 24),
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isBekliyor ? dangerColor.withOpacity(0.05) : surfaceColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isBekliyor ? dangerColor.withOpacity(0.5) : Colors.white.withOpacity(0.05), width: isBekliyor ? 2 : 1),
                        boxShadow: isBekliyor ? [BoxShadow(color: dangerColor.withOpacity(0.1), blurRadius: 20)] : [],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sinyal Başlığı ve Durum
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(isBekliyor ? Icons.warning_amber_rounded : Icons.check_circle_outline, color: isBekliyor ? dangerColor : primaryCyan, size: 28),
                                  SizedBox(width: 12),
                                  Text(plaka.toString().toUpperCase(), style: TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isBekliyor ? dangerColor : primaryCyan.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(durum.toUpperCase(), style: TextStyle(color: isBekliyor ? Colors.white : primaryCyan, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1)),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(color: SiberTema.textMuted),
                          ),

                          // Sürücü ve Konum Bilgisi
                          Row(
                            children: [
                              Icon(Icons.person_outline, color: SiberTema.textMuted, size: 16),
                              SizedBox(width: 8),
                              Text(kullanici.toString().toUpperCase(), style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on_outlined, color: Colors.orangeAccent, size: 16),
                              SizedBox(width: 8),
                              Expanded(child: Text(konum.toString().toUpperCase(), style: TextStyle(color: Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold, height: 1.4))),
                            ],
                          ),

                          // Aksiyon Butonları (Sadece bekleyen sinyaller için)
                          if (isBekliyor) ...[
                            SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryCyan,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    icon: Icon(Icons.electric_bolt, size: 18),
                                    label: Text('MÜDAHALE ET', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                                    onPressed: () => _sinyalDurumGuncelle(docId, 'Müdahale Edildi', false),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: dangerColor,
                                      side: BorderSide(color: dangerColor.withOpacity(0.5)),
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Icon(Icons.block, size: 20),
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