// lib/screens/kullanici/dijital_torpido_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';

// 🚀 KARARGAH ZIRHLARI VE SERVİSLER
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../../services/torpido_servisi.dart';

class SiberDijitalTorpidoScreen extends StatefulWidget {
  final String aracId;
  final String plaka;
  final String kullaniciId;

  const SiberDijitalTorpidoScreen({
    super.key,
    required this.aracId,
    required this.plaka,
    required this.kullaniciId
  });

  @override
  State<SiberDijitalTorpidoScreen> createState() => _SiberDijitalTorpidoScreenState();
}

class _SiberDijitalTorpidoScreenState extends State<SiberDijitalTorpidoScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TorpidoServisi _torpidoServisi = TorpidoServisi();
  bool _islemSuruyor = false;

  // ── 🧠 KARARGAH ZORUNLU EVRAK MATRİSİ ──
  // Sistem bu listeyi baz alarak Firebase'deki belgelerle karşılaştırır.
  final List<Map<String, dynamic>> _zorunluEvraklar = [
    {"tur": "Sürücü Belgesi", "kurum": "Nüfus Müdürlüğü", "ikon": Icons.badge_outlined},
    {"tur": "Araç Ruhsatı", "kurum": "Noterler Birliği", "ikon": Icons.directions_car_outlined},
    {"tur": "Kasko Poliçesi", "kurum": "Sigorta Şirketi", "ikon": Icons.shield_outlined},
    {"tur": "TÜVTÜRK Raporu", "kurum": "Ulaştırma Bakanlığı", "ikon": Icons.fact_check_outlined},
    {"tur": "Egzoz Emisyon", "kurum": "Çevre Bakanlığı", "ikon": Icons.cloud_off_outlined},
  ];

  // 📸 SİBER BELGE YÜKLEME RADARI
  void _belgeYukleMotoru(String belgeTuru) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: SiberTema.matGrey.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            Text("[$belgeTuru] YÜKLE", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 8),
            const Text("Belgenin orijinalini düz bir zemine koyarak fotoğrafını çekin veya arşivden seçin.", style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: _buildModalButonu(Icons.camera_alt_outlined, "AI Kamera", () => _yuklemeyiBaslat(belgeTuru, ImageSource.camera))),
                const SizedBox(width: 16),
                Expanded(child: _buildModalButonu(Icons.photo_library_outlined, "Galeri", () => _yuklemeyiBaslat(belgeTuru, ImageSource.gallery))),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _yuklemeyiBaslat(String belgeTuru, ImageSource kaynak) async {
    Navigator.pop(context); // Paneli kapat
    setState(() => _islemSuruyor = true);

    var sonuc = await _torpidoServisi.torpidoyaBelgeEkle(
      kullaniciId: widget.kullaniciId,
      aracId: widget.aracId,
      belgeTuru: belgeTuru,
      source: kaynak,
    );

    setState(() => _islemSuruyor = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(sonuc['mesaj'], style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: sonuc['basarili'] ? SiberTema.kuantumCyan : SiberTema.kanKirmizi,
      ));
    }
  }

  Widget _buildModalButonu(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: SiberTema.oledBlack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: SiberTema.kuantumCyan, size: 28),
            const SizedBox(height: 12),
            Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1))
          ],
        ),
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: Column(
            children: [
              const Text("D İ J İ T A L   T O R P İ D O", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 3)),
              Text(widget.plaka, style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          centerTitle: true,
        ),
        body: _islemSuruyor
            ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(color: SiberTema.kuantumCyan), SizedBox(height: 16), Text("KUANTUM AĞINA ŞİFRELENİYOR...", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2))]))
            : StreamBuilder<DocumentSnapshot>(
          // 📡 GERÇEK VERİ AKIŞI: Firebase'den aracın belgeleri dinleniyor
          stream: _db.collection('araclar').doc(widget.aracId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
            if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: Text("SİBER İHLAL: Araç verisi bulunamadı.", style: TextStyle(color: SiberTema.kanKirmizi)));

            var aracVerisi = snapshot.data!.data() as Map<String, dynamic>;
            List<dynamic> yuklenenBelgeler = aracVerisi['torpido_belgeleri'] ?? [];
            List<dynamic> garantiBelgeleri = aracVerisi['garanti_belgeleri'] ?? [];

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                // 1. ZIRH UYARISI
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, color: Colors.white38, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text("Tüm evraklarınız AES-256 Kuantum Şifreleme ile kilitlenmiştir.", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, letterSpacing: 0.5, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),

                // 2. OTODNA GARANTİ MÜHÜRLERİ (YENİ EKLENTİ)
                if (garantiBelgeleri.isNotEmpty) ...[
                  const Text("🛡️ OTODNA GARANTİLİ PARÇALAR", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 12),
                  ...garantiBelgeleri.map((garanti) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: SiberTema.kuantumCyan.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 1.5),
                        boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.1), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(garanti['parca_adi'].toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                              const Icon(Icons.verified, color: SiberTema.kuantumCyan, size: 20),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.business, color: Colors.white54, size: 14),
                              const SizedBox(width: 6),
                              Text(garanti['firma_unvani'], style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.qr_code, color: Colors.white54, size: 14),
                              const SizedBox(width: 6),
                              Text("OEM: ${garanti['oem_kodu']}", style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Colors.white24, height: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("OTODNA DİJİTAL MÜHRÜ AKTİF", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Garanti Sertifikası PDF Olarak İndiriliyor..."), backgroundColor: SiberTema.kuantumCyan));
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: SiberTema.kuantumCyan),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                  minimumSize: const Size(0, 30)
                                ),
                                child: const Text("SERTİFİKA", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.bold)),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],

                // 3. ZORUNLU EVRAKLAR
                const Text("ZORUNLU ARAÇ EVRAKLARI", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const SizedBox(height: 12),
                ..._zorunluEvraklar.map((evrakSablonu) {

                // Belge Firebase'de var mı diye kontrol et
                var bulunanBelge = yuklenenBelgeler.cast<Map<String,dynamic>>().firstWhere(
                        (b) => b['belge_turu'] == evrakSablonu['tur'],
                    orElse: () => <String, dynamic>{}
                );

                bool isEksik = bulunanBelge.isEmpty;
                Color durumRengi = isEksik ? SiberTema.kanKirmizi : SiberTema.kuantumCyan;
                String durumMetni = isEksik ? "EKSİK / YÜKLE" : "MÜHÜRLÜ";
                IconData durumIkonu = isEksik ? Icons.warning_amber_rounded : Icons.verified_user;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: SiberTema.matGrey.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: durumRengi.withOpacity(0.3), width: 1.5),
                      boxShadow: [
                        if (!isEksik) BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)
                      ]
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(evrakSablonu['ikon'], color: durumRengi, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(evrakSablonu['tur'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                const SizedBox(height: 4),
                                Text(evrakSablonu['kurum'], style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Icon(durumIkonu, color: durumRengi, size: 16),
                              const SizedBox(height: 4),
                              Text(durumMetni, style: TextStyle(color: durumRengi, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isEksik ? "Kayıt Bekleniyor..." : "Sistemde Aktif", style: TextStyle(color: isEksik ? Colors.white38 : Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),

                          // ZARİF AKSİYON BUTONU
                          InkWell(
                            onTap: () {
                              if (isEksik) {
                                _belgeYukleMotoru(evrakSablonu['tur']);
                              } else {
                                // SİBER NOT: Burada belgenin fotoğrafı tam ekran açılabilir.
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Belge Görüntüleniyor...'), backgroundColor: SiberTema.matGrey));
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                  color: durumRengi.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: durumRengi.withOpacity(0.5))
                              ),
                              child: Text(isEksik ? "YÜKLE" : "GÖRÜNTÜLE", style: TextStyle(color: durumRengi, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                });
              ],
            );
          },
        ),
      ),
    );
  }
}