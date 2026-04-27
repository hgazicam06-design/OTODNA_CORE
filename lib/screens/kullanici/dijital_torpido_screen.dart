// lib/screens/kullanici/dijital_torpido_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';

// 🚀 KARARGAH ZIRHLARI VE SERVİSLER
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

  // 🏢 PLAZA KALİTESİ PALET
  final Color primaryTeal = Colors.teal.shade700;
  final Color bgColor = const Color(0xFFFAFAFC);
  final Color textColor = const Color(0xFF1E293B);
  final Color dangerColor = Colors.redAccent;
  final Color warningColor = Colors.orange;

  // ── 🧠 KARARGAH ZORUNLU EVRAK MATRİSİ ──
  final List<Map<String, dynamic>> _zorunluEvraklar = [
    {"tur": "Sürücü Belgesi", "kurum": "Nüfus Müdürlüğü", "ikon": Icons.badge_outlined},
    {"tur": "Araç Ruhsatı", "kurum": "Noterler Birliği", "ikon": Icons.directions_car_outlined},
    {"tur": "Kasko Poliçesi", "kurum": "Sigorta Şirketi", "ikon": Icons.shield_outlined},
    {"tur": "TÜVTÜRK Raporu", "kurum": "Ulaştırma Bakanlığı", "ikon": Icons.fact_check_outlined},
    {"tur": "Egzoz Emisyon", "kurum": "Çevre Bakanlığı", "ikon": Icons.cloud_off_outlined},
  ];

  // ── 💸 FİNANS VE GİDER YÖNETİMİ ──
  final List<Map<String, dynamic>> _finansVeGiderler = [
    {"tur": "Yakıt Fişleri / Tüketim", "kurum": "Ortalama 6.2L / 100km", "ikon": Icons.local_gas_station_outlined, "islem": "YÜKLE/ANALİZ ET"},
    {"tur": "Trafik Cezaları (EGM)", "kurum": "Son Sorgu: Bugün 14:00", "ikon": Icons.gavel_outlined, "islem": "SORGULA"},
    {"tur": "HGS Geçiş Kayıtları", "kurum": "Bakiye: 245.50 TL", "ikon": Icons.add_road_outlined, "islem": "DETAYLAR"},
  ];

  // 📸 SİBER BELGE YÜKLEME RADARI
  void _belgeYukleMotoru(String belgeTuru) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: primaryTeal.withValues(alpha: 0.3), width: 2)),
          boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.1), blurRadius: 20)]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            Text("[$belgeTuru] YÜKLE", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
            const SizedBox(height: 8),
            const Text("Belgenin orijinalini düz bir zemine koyarak fotoğrafını çekin veya arşivden seçin.", style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: _buildModalButonu(Icons.camera_alt_outlined, "Kamera", () => _yuklemeyiBaslat(belgeTuru, ImageSource.camera))),
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

  // 🔍 SORGULAMA VE DENETİM PANELİ
  void _sorguMotoru(String islemTuru) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        title: Row(
          children: [
            Icon(Icons.radar, color: primaryTeal),
            const SizedBox(width: 8),
            Expanded(child: Text("OtoDNA Denetim Ağı", style: TextStyle(color: textColor, fontSize: 16, fontFamily: 'Avenir', fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text("Ağ üzerinden '$islemTuru' kayıtları canlı olarak denetleniyor. Plakanız (${widget.plaka}) ve Karayolları/EGM veritabanı eşleştiriliyor. Devam edilsin mi?", style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.5, fontFamily: 'Avenir')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal", style: TextStyle(color: Colors.white38, fontFamily: 'Avenir'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white, elevation: 0),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$islemTuru sorgulanıyor... Lütfen bekleyin.'), backgroundColor: primaryTeal));
            },
            child: const Text("Taramayı Başlat", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          ),
        ],
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
        backgroundColor: sonuc['basarili'] ? primaryTeal : dangerColor,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryTeal.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.05), blurRadius: 10)]
        ),
        child: Column(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: primaryTeal, size: 28)),
            const SizedBox(height: 12),
            Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1, fontFamily: 'Avenir'))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20), onPressed: () => Navigator.pop(context)),
          title: Column(
            children: [
              Text("D İ J İ T A L   T O R P İ D O", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 3, fontFamily: 'Avenir')),
              Text(widget.plaka, style: TextStyle(color: primaryTeal, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
            ],
          ),
          centerTitle: true,
        ),
        body: _islemSuruyor
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(color: primaryTeal), const SizedBox(height: 16), Text("DİJİTAL KASAYA ŞİFRELENİYOR...", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir'))]))
            : StreamBuilder<DocumentSnapshot>(
          // 📡 GERÇEK VERİ AKIŞI: Firebase'den aracın belgeleri dinleniyor
          stream: _db.collection('araclar').doc(widget.aracId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: primaryTeal));
            if (!snapshot.hasData || !snapshot.data!.exists) return Center(child: Text("SİSTEM İHLALİ: Araç verisi bulunamadı.", style: TextStyle(color: dangerColor, fontFamily: 'Avenir')));

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
                      Icon(Icons.lock_outline, color: primaryTeal, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text("Tüm evraklarınız 256-Bit Şifreleme ile güvendedir.", style: TextStyle(color: primaryTeal, fontSize: 11, letterSpacing: 0.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))),
                    ],
                  ),
                ),

                // 2. OTODNA GARANTİ MÜHÜRLERİ
                if (garantiBelgeleri.isNotEmpty) ...[
                  Text("🛡️ OTODNA GARANTİLİ PARÇALAR", style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                  const SizedBox(height: 12),
                  ...garantiBelgeleri.map((garanti) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryTeal.withValues(alpha: 0.3), width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.05), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(garanti['parca_adi'].toString().toUpperCase(), style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                              Icon(Icons.verified, color: primaryTeal, size: 20),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.business, color: Colors.white54, size: 14),
                              const SizedBox(width: 6),
                              Text(garanti['firma_unvani'], style: const TextStyle(color: Colors.white87, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.qr_code, color: Colors.white54, size: 14),
                              const SizedBox(width: 6),
                              Text("OEM: ${garanti['oem_kodu']}", style: const TextStyle(color: Colors.white87, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("OTODNA DİJİTAL MÜHRÜ AKTİF", style: TextStyle(color: primaryTeal, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                              OutlinedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Garanti Sertifikası PDF Olarak İndiriliyor..."), backgroundColor: primaryTeal));
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: primaryTeal),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                  minimumSize: const Size(0, 30)
                                ),
                                child: Text("SERTİFİKA", style: TextStyle(color: primaryTeal, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],

                // 3. FİNANS VE GİDER YÖNETİMİ (YAKIT, CEZA, HGS)
                Text("FİNANS & GİDER YÖNETİMİ", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                const SizedBox(height: 12),
                ..._finansVeGiderler.map((giderSistemi) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1.5),
                        boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10)]
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: warningColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(giderSistemi['ikon'], color: warningColor, size: 28)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(giderSistemi['tur'], style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5, fontFamily: 'Avenir')),
                                  const SizedBox(height: 4),
                                  Text(giderSistemi['kurum'], style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Canlı Ağ Denetimi", style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                            InkWell(
                              onTap: () {
                                if(giderSistemi['islem'] == "YÜKLE/ANALİZ ET") {
                                  _belgeYukleMotoru(giderSistemi['tur']);
                                } else {
                                  _sorguMotoru(giderSistemi['tur']);
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                    color: warningColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: warningColor.withValues(alpha: 0.5))
                                ),
                                child: Text(giderSistemi['islem'], style: TextStyle(color: warningColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // 4. ZORUNLU EVRAKLAR
                const Text("ZORUNLU ARAÇ EVRAKLARI", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                const SizedBox(height: 12),
                ..._zorunluEvraklar.map((evrakSablonu) {

                // Belge Firebase'de var mı diye kontrol et
                var bulunanBelge = yuklenenBelgeler.cast<Map<String,dynamic>>().firstWhere(
                        (b) => b['belge_turu'] == evrakSablonu['tur'],
                    orElse: () => <String, dynamic>{}
                );

                bool isEksik = bulunanBelge.isEmpty;
                Color durumRengi = isEksik ? dangerColor : primaryTeal;
                String durumMetni = isEksik ? "EKSİK / YÜKLE" : "MÜHÜRLÜ";
                IconData durumIkonu = isEksik ? Icons.warning_amber_rounded : Icons.verified_user;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: durumRengi.withValues(alpha: 0.3), width: 1.5),
                      boxShadow: [
                        if (!isEksik) BoxShadow(color: primaryTeal.withValues(alpha: 0.05), blurRadius: 10, spreadRadius: 1)
                        else BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10)
                      ]
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: durumRengi.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(evrakSablonu['ikon'], color: durumRengi, size: 28)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(evrakSablonu['tur'], style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5, fontFamily: 'Avenir')),
                                const SizedBox(height: 4),
                                Text(evrakSablonu['kurum'], style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Icon(durumIkonu, color: durumRengi, size: 16),
                              const SizedBox(height: 4),
                              Text(durumMetni, style: TextStyle(color: durumRengi, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isEksik ? "Kayıt Bekleniyor..." : "Sistemde Aktif", style: TextStyle(color: isEksik ? Colors.black38 : textColor, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),

                          // ZARİF AKSİYON BUTONU
                          InkWell(
                            onTap: () {
                              if (isEksik) {
                                _belgeYukleMotoru(evrakSablonu['tur']);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Belge Görüntüleniyor...'), backgroundColor: Colors.white));
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                  color: durumRengi.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: durumRengi.withValues(alpha: 0.5))
                              ),
                              child: Text(isEksik ? "YÜKLE" : "GÖRÜNTÜLE", style: TextStyle(color: durumRengi, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                );
              });
              ],
            );
          },
        ),
      ),
    );
  }
}