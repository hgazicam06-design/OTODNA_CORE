import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA BAĞLANTISI
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class KargoQrKilitScreen extends StatefulWidget {
  const KargoQrKilitScreen({super.key});

  @override
  State<KargoQrKilitScreen> createState() => _KargoQrKilitScreenState();
}

class _KargoQrKilitScreenState extends State<KargoQrKilitScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _qrPulseController;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _qrPulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _qrPulseController.dispose();
    super.dispose();
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
    ));
  }

  // =========================================================================
  // 🖨️ KUANTUM QR ÜRETME VE FİREBASE'E MÜHÜRLEME MOTORU
  // =========================================================================
  void _qrUretVeYazdir(String siparisId, String urunAdi) {
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), border: Border(top: BorderSide(color: SiberTema.kuantumCyan, width: 2))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Kilitli Kargo QR Kodu Üretildi!", style: TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Sipariş: $urunAdi\nSipariş No: $siparisId", textAlign: TextAlign.center, style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 24),

                  // SİBER QR KOD SİMÜLASYONU
                  AnimatedBuilder(
                      animation: _qrPulseController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.5 * _qrPulseController.value), blurRadius: 30, spreadRadius: 5)]),
                          child: const Icon(Icons.qr_code_2, color: Colors.white, size: 150),
                        );
                      }
                  ),

                  const SizedBox(height: 24),
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orangeAccent)), child: const Row(children: [Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent), SizedBox(width: 12), Expanded(child: Text("Bu QR Kodu paketin üzerine yapıştırın. Alıcı kargoyu teslim alırken kendi uygulamasından bu QR'ı okutmak zorundadır.", style: TextStyle(color: Colors.orangeAccent, fontSize: 11)))])),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                          child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: SiberTema.textMuted), padding: const EdgeInsets.symmetric(vertical: 16)),
                              onPressed: isProcessing ? null : () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.white),
                              label: const Text("Kapat", style: TextStyle(color: SiberTema.textMain))
                          )
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kuantumCyan, padding: const EdgeInsets.symmetric(vertical: 16)),
                              onPressed: isProcessing ? null : () async {
                                setModalState(() => isProcessing = true);
                                try {
                                  // 🚀 FİREBASE GÜNCELLEMESİ: ATOMİK MÜHÜRLEME DEVREDE
                                  WriteBatch batch = _db.batch();
                                  
                                  DocumentReference siparisRef = _db.collection('siparisler').doc(siparisId);
                                  batch.update(siparisRef, {
                                    'durum': 'Kargoda',
                                    'kargoya_verilis_tarihi': FieldValue.serverTimestamp(),
                                  });

                                  DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
                                  batch.set(logRef, {
                                    'islem_turu': 'KARGO_QR_URETILDI',
                                    'islem_detayi': 'SİBER KARGO: $urunAdi ($siparisId) için kargo QR kodu üretildi.',
                                    'siparis_id': siparisId,
                                    'urun_adi': urunAdi,
                                    'satici_id': _currentUser!.uid,
                                    'tarih': FieldValue.serverTimestamp(),
                                  });

                                  await batch.commit();

                                  if (mounted) {
                                    Navigator.pop(context);
                                    _showSnackBar('Yazıcıya Gönderildi ve Kargo Ağa İşlendi! 🖨️📦');
                                  }
                                } catch (e) {
                                  setModalState(() => isProcessing = false);
                                  _showSnackBar('Siber Hata: $e', isError: true);
                                }
                              },
                              icon: isProcessing ? const SizedBox() : const Icon(Icons.print, color: Color(0xFF0F172A)),
                              label: isProcessing
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text("Yazdır & Gönder", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold))
                          )
                      ),
                    ],
                  )
                ],
              ),
            );
          }
      ),
    );
  }

  // GÜVENLİ HAVUZ ZAMAN HESAPLAYICI (15 GÜN KURALI)
  String _kalanZamaniHesapla(Timestamp? islemTarihi) {
    if (islemTarihi == null) return "Hesaplanıyor...";

    DateTime islemZamani = islemTarihi.toDate();
    DateTime bitisZamani = islemZamani.add(const Duration(days: 15));
    Duration fark = bitisZamani.difference(DateTime.now());

    if (fark.isNegative) {
      return "0 Gün 0 Saat (Süre Doldu)";
    }
    return "${fark.inDays} Gün ${fark.inHours % 24} Saat";
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = SiberTema.oledBlack;
    const primaryCyan = SiberTema.kuantumCyan;
    const cardColor = SiberTema.matGrey;

    if (_currentUser == null) {
      return const Scaffold(backgroundColor: bgColor, body: Center(child: Text("Siber Kimlik Bulunamadı!", style: TextStyle(color: SiberTema.kanKirmizi))));
    }

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
        title: const Text('Kargo & Güvenli Havuz', style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold)),
        centerTitle: true, iconTheme: const IconThemeData(color: primaryCyan),
        bottom: TabBar(
          controller: _tabController, indicatorColor: primaryCyan, labelColor: primaryCyan, unselectedLabelColor: Colors.white54,
          tabs: const [Tab(text: "Bekleyen Kargolar"), Tab(text: "15 Günlük Havuz")],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Ustanın Tereddütsüz Tüm Siparişlerini Çek (Dart tarafında filtreleyerek Index hatasını önleriz)
          stream: _db.collection('siparisler').where('satici_id', isEqualTo: _currentUser!.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: primaryCyan));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("OtoDNA Ağında size ait bir sipariş bulunmuyor.", style: TextStyle(color: SiberTema.textMuted)));
            }

            // Verileri ayır: Bekleyenler (Sekme 1) ve Havuzdakiler/Kargodakiler (Sekme 2)
            var tumSiparisler = snapshot.data!.docs;
            var bekleyenler = tumSiparisler.where((doc) => doc['durum'] == 'Bekliyor').toList();
            var havuzdakiler = tumSiparisler.where((doc) => doc['durum'] != 'Bekliyor').toList();

            return TabBarView(
              controller: _tabController,
              children: [
                // =================================================================
                // 1. SEKME: BEKLEYEN SİPARİŞLER (QR ÜRETİLECEK OLANLAR)
                // =================================================================
                bekleyenler.isEmpty
                    ? const Center(child: Text("Bekleyen kargonuz bulunmuyor. ✅", style: TextStyle(color: primaryCyan)))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16), physics: const BouncingScrollPhysics(), itemCount: bekleyenler.length,
                  itemBuilder: (context, index) {
                    var doc = bekleyenler[index];
                    var siparis = doc.data() as Map<String, dynamic>;
                    String formatliTarih = siparis['tarih'] != null ? DateFormat('dd MMM yyyy - HH:mm', 'tr_TR').format((siparis['tarih'] as Timestamp).toDate()) : "Tarih Yok";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.textMuted)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(doc.id.substring(0, 10).toUpperCase(), style: const TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold)), Text(formatliTarih, style: const TextStyle(color: SiberTema.textMuted, fontSize: 11))]),
                          const SizedBox(height: 12),
                          Text(siparis['urun_adi'] ?? 'Bilinmeyen Ürün', style: const TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(children: [const Icon(Icons.person, color: primaryCyan, size: 14), const SizedBox(width: 4), Text("Alıcı: ${siparis['alici_adi'] ?? '-'}", style: const TextStyle(color: primaryCyan, fontSize: 13))]),
                          const SizedBox(height: 12),
                          const Divider(color: SiberTema.textMuted),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("₺${siparis['fiyat'] ?? 0}", style: const TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.bold)),
                              ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                  onPressed: () => _qrUretVeYazdir(doc.id, siparis['urun_adi'] ?? 'Ürün'),
                                  icon: const Icon(Icons.qr_code, color: bgColor, size: 16),
                                  label: const Text("Kargo QR Üret", style: TextStyle(color: bgColor, fontWeight: FontWeight.bold))
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),

                // =================================================================
                // 2. SEKME: 15 GÜNLÜK GÜVENLİ HAVUZ SAYAÇLARI
                // =================================================================
                havuzdakiler.isEmpty
                    ? const Center(child: Text("Havuzda bekleyen bakiye/sipariş yok.", style: TextStyle(color: SiberTema.textMuted)))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16), physics: const BouncingScrollPhysics(), itemCount: havuzdakiler.length,
                  itemBuilder: (context, index) {
                    var doc = havuzdakiler[index];
                    var siparis = doc.data() as Map<String, dynamic>;

                    String durum = siparis['durum'] ?? 'Bilinmiyor';
                    String kalanZaman = _kalanZamaniHesapla(siparis['kargoya_verilis_tarihi'] ?? siparis['tarih']);

                    // Kuantum Durum Renklendirici
                    Color durumRengi = Colors.orangeAccent;
                    if (durum == 'Kargoda') durumRengi = Colors.blueAccent;
                    if (durum == 'Teslim Edildi') durumRengi = Colors.purpleAccent;
                    if (durum == 'Tamamlandı' || kalanZaman.contains("Süre Doldu")) durumRengi = primaryCyan;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: durumRengi.withOpacity(0.5), width: 1.5)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(doc.id.substring(0, 10).toUpperCase(), style: const TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold)), const Icon(Icons.security, color: primaryCyan, size: 16)]),
                          const SizedBox(height: 12),
                          Text(siparis['urun_adi'] ?? 'Bilinmeyen Ürün', style: const TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: durumRengi.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(durum, style: TextStyle(color: durumRengi, fontSize: 11, fontWeight: FontWeight.bold))),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Kalan Havuz Süresi", style: TextStyle(color: SiberTema.textMuted, fontSize: 10)), const SizedBox(height: 4), Text(kalanZaman, style: TextStyle(color: durumRengi, fontSize: 14, fontWeight: FontWeight.bold))]),
                              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text("Aktarılacak Tutar", style: TextStyle(color: SiberTema.textMuted, fontSize: 10)), const SizedBox(height: 4), Text("₺${siparis['fiyat'] ?? 0}", style: const TextStyle(color: SiberTema.textMain, fontSize: 18, fontWeight: FontWeight.bold))]),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          }
      ),
      ),
    );
  }
}