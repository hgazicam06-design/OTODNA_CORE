import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class BayiPaneliScreen extends StatefulWidget {
  final String bayiId; // 🔥 SİBER KİLİDİ ÇÖZEN PARAMETRE!

  const BayiPaneliScreen({super.key, required this.bayiId});

  @override
  State<BayiPaneliScreen> createState() => _BayiPaneliScreenState();
}

class _BayiPaneliScreenState extends State<BayiPaneliScreen> with SingleTickerProviderStateMixin {
  late AnimationController _radarCtrl;

  @override
  void initState() {
    super.initState();
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _radarCtrl.dispose();
    super.dispose();
  }

  // --- 🔴 FİREBASE: SİNYAL YÖNETİM MERKEZİ (ATOMİK GÜNCELLEME) ---
  Future<void> _sinyalDurumGuncelle(String docId, String yeniDurum, bool asilsizMi, String? kullaniciId) async {
    try {
      final db = FirebaseFirestore.instance;
      WriteBatch batch = db.batch();

      DocumentReference sosRef = db.collection('sos_sinyalleri').doc(docId);

      // 1. Sinyal Durumunu Güncelle
      batch.update(sosRef, {
        'durum': yeniDurum,
        'asilsiz_ihbar_mi': asilsizMi,
        'mudahale_eden_bayi': widget.bayiId,
        'guncelleme_zamani': FieldValue.serverTimestamp(),
      });

      // 2. Eğer Asılsız İhbar ise Kullanıcıya Ceza Protokolü Uygula (Sarı/Kırmızı Kart)
      if (asilsizMi && kullaniciId != null) {
        DocumentReference userRef = db.collection('kullanicilar').doc(kullaniciId);
        batch.update(userRef, {
          'ceza_puani': FieldValue.increment(1),
          'son_ihlal_tarihi': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (!mounted) return;
      _siberMesajGoster(
          asilsizMi ? 'İHLAL RAPORLANDI: ASILSIZ SİNYAL İŞLENDİ!' : 'MÜDAHALE BAŞLADI: EKİP YÖNLENDİRİLDİ 🦅',
          asilsizMi ? SiberTema.kanKirmizi : SiberTema.kuantumCyan
      );
    } catch (e) {
      if (!mounted) return;
      _siberMesajGoster('AĞ HATASI: $e', SiberTema.kanKirmizi);
    }
  }

  void _siberMesajGoster(String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mesaj, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1)),
          backgroundColor: renk,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )
    );
  }

  Future<void> _haritayiAc(String konumStr) async {
    if (konumStr == 'Konum Alınamadı' || !konumStr.contains(',')) {
      _siberMesajGoster('GEÇERLİ KOORDİNAT BULUNAMADI!', Colors.orangeAccent);
      return;
    }

    final coords = konumStr.split(',');
    final lat = coords[0].trim();
    final lng = coords[1].trim();
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _siberMesajGoster('SİBER HATA: HARİTA TETİKLENEMEDİ!', SiberTema.kanKirmizi);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildRadarHeader(),
            Expanded(child: _buildSignalStream()),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context)
      ),
      title: const Text('B A Y İ   S . O . S   R A D A R I',
          style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: SiberTema.kanKirmizi.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: SiberTema.kanKirmizi.withOpacity(0.3))
              ),
              child: const Icon(Icons.emergency_recording, color: SiberTema.kanKirmizi, size: 16),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildRadarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          RotationTransition(
            turns: _radarCtrl,
            child: const Icon(Icons.radar, color: SiberTema.kuantumCyan, size: 20),
          ),
          const SizedBox(width: 12),
          const Text("CANLI SAHA TAKİBİ",
              style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const Spacer(),
          Text("BAYI_ID: ${widget.bayiId.toUpperCase()}",
              style: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.4), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildSignalStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sos_sinyalleri')
          .where('durum', isEqualTo: 'Bekliyor') // Sadece müdahale bekleyenleri göstererek karmaşayı önlüyoruz
          .orderBy('sinyal_zamani', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _buildStatusMessage("RADAR BAĞLANTI HATASI!", SiberTema.kanKirmizi);
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));

        final data = snapshot.requireData;
        if (data.size == 0) return _buildEmptyRadar();

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
          itemCount: data.size,
          itemBuilder: (context, index) => _buildSignalCard(data.docs[index]),
        );
      },
    );
  }

  Widget _buildSignalCard(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    String plaka = data['plaka'] ?? 'BİLİNMİYOR';
    String kullanici = data['kullanici_ad_soyad'] ?? 'BİLİNMEYEN SÜRÜCÜ';
    String kullaniciId = data['kullanici_id'] ?? '';
    String konum = data['konum_koordinat'] ?? 'Konum Alınamadı';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: SiberTema.siberCamDekoru(borderColor: SiberTema.kanKirmizi.withOpacity(0.3)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: SiberTema.kanKirmizi, size: 24),
                        const SizedBox(width: 12),
                        Text(plaka.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      ],
                    ),
                    _buildPulseIndicator(),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.person_pin, "SÜRÜCÜ", kullanici.toUpperCase()),
                const SizedBox(height: 12),
                _buildMapButton(konum),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildActionButton(
                          "MÜDAHALE ET",
                          SiberTema.kuantumCyan,
                          Icons.local_shipping,
                              () => _sinyalDurumGuncelle(doc.id, 'Müdahale Edildi', false, kullaniciId)
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _buildActionButton(
                          "",
                          SiberTema.kanKirmizi,
                          Icons.block,
                              () => _sinyalDurumGuncelle(doc.id, 'Asılsız İhbar', true, kullaniciId),
                          isOutline: true
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 14),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildMapButton(String konum) {
    return InkWell(
      onTap: () => _haritayiAc(konum),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10)
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.orangeAccent, size: 16),
            const SizedBox(width: 10),
            const Expanded(child: Text("HEDEF NAVİGASYONUNU TETİKLE", style: TextStyle(color: Colors.orangeAccent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1))),
            Icon(Icons.open_in_new, color: Colors.orangeAccent.withOpacity(0.5), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, IconData icon, VoidCallback tap, {bool isOutline = false}) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: tap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutline ? Colors.transparent : color,
          foregroundColor: isOutline ? color : Colors.black,
          elevation: 0,
          side: isOutline ? BorderSide(color: color.withOpacity(0.5), width: 1.5) : BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildPulseIndicator() {
    return Container(
      width: 8, height: 8,
      decoration: const BoxDecoration(color: SiberTema.kanKirmizi, shape: BoxShape.circle),
    );
  }

  Widget _buildEmptyRadar() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.security, color: SiberTema.kuantumCyan.withOpacity(0.1), size: 80),
          const SizedBox(height: 24),
          const Text('SAHADA HER ŞEY SAKİN',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 8),
          const Text('Aktif S.O.S sinyali bulunmuyor.\nRadar taramaya devam ediyor...',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white24, fontSize: 11, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildStatusMessage(String msg, Color color) {
    return Center(child: Text(msg, style: TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 1)));
  }
}