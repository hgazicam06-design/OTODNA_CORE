import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI (Mutlak Rota)
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class MegaRevizyonScreen extends StatefulWidget {
  final String plaka;
  const MegaRevizyonScreen({super.key, required this.plaka});

  @override
  State<MegaRevizyonScreen> createState() => _MegaRevizyonScreenState();
}

class _MegaRevizyonScreenState extends State<MegaRevizyonScreen> {
  // 🔥 ANOMALİ GİDERİLDİ: Veritabanı motorları Kuantum Ağına tam bağlandı
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  String _seciliAracTipi = 'Otomobil';
  bool _isProcessing = false;

  // ── Kuantum Revizyon Paketleri ──
  final Map<String, List<String>> _paketler = {
    'Otomobil': ['Piston Takımı', 'Segman Seti', 'Ana Yatak', 'Kol Yatak', 'Triger Seti', 'Salıncak', 'Amortisör', 'Fren Disk/Balata'],
    'Kamyon / Tır': ['Islak Gömlek', 'Kompresör Revizyonu', 'Makas Burçları', 'Hava Körükleri', 'PTO (Yavru Şanzıman)', 'Kurutucu Filtre'],
    'İş Makinesi': ['Ana Pompa Revizyonu', 'Kumanda Valfi Keçeleri', 'Bom Silindiri', 'Yürüyüş Motoru', 'Palet Pabucu', 'Radyatör Temizliği'],
  };

  // Seçilen parçaları, fiyatlarını ve resimlerini tutan Atomik Hafıza
  final Map<String, Map<String, dynamic>> _secilenParcalar = {};

  // ── SİBER ÖZGÜRLÜK: KAMERA VEYA GALERİ ──
  Future<void> _gorselSec(String parca, ImageSource kaynak) async {
    final XFile? secilenGorsel = await _picker.pickImage(source: kaynak, imageQuality: 70);
    if (secilenGorsel != null) {
      setState(() {
        _secilenParcalar[parca] ??= {'fiyat': 0.0};
        _secilenParcalar[parca]!['gorsel'] = File(secilenGorsel.path);
      });
    }
  }

  void _fiyatGuncelle(String parca, String fiyatText) {
    double fiyat = double.tryParse(fiyatText.replaceAll(',', '.')) ?? 0.0;
    _secilenParcalar[parca] ??= {};
    _secilenParcalar[parca]!['fiyat'] = fiyat;
  }

  // ── FİREBASE WRITEBATCH MOTORU VE ZAMAN/KONUM DAMGASI ──
  Future<void> _agaMuhurle() async {
    if (_secilenParcalar.isEmpty) {
      _siberUyari("SİBER İHLAL: Lütfen en az bir parça seçin!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. Koordinatları Çek (Siber Noter)
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      double toplamMaliyet = 0;
      List<Map<String, dynamic>> muhurlenecekParcalar = [];
      String islemId = _db.collection('islem_kayitlari').doc().id;

      // 2. Görselleri Storage'a Yükle ve Linkleri Al
      for (var parca in _secilenParcalar.entries) {
        double fiyat = parca.value['fiyat'] ?? 0.0;
        toplamMaliyet += fiyat;
        String gorselUrl = '';

        if (parca.value['gorsel'] != null) {
          File dosya = parca.value['gorsel'];
          TaskSnapshot snapshot = await _storage.ref('kanit_gorselleri/$islemId/${parca.key}.jpg').putFile(dosya);
          gorselUrl = await snapshot.ref.getDownloadURL();
        }

        muhurlenecekParcalar.add({
          'parca_adi': parca.key,
          'fiyat': fiyat,
          'gorsel_url': gorselUrl,
          'firma_onayi': true, // Usta kendi girdiği için peşin onaylı
        });
      }

      // 3. Karargah Finans Algoritması (Evrensel Kural: %12 Pay)
      double komutanPayi = toplamMaliyet * 0.12;

      // 🔥 GERÇEK BAYİ KİMLİĞİ
      String gercekBayiId = _auth.currentUser?.uid ?? 'BILINMEYEN_BAYI_ID';

      // 4. Atomik WriteBatch Atışı
      WriteBatch batch = _db.batch();

      DocumentReference islemRef = _db.collection('islem_kayitlari').doc(islemId);
      batch.set(islemRef, {
        'islem_id': islemId,
        'plaka': widget.plaka,
        'arac_tipi': _seciliAracTipi,
        'toplam_maliyet': toplamMaliyet,
        'komutan_payi': komutanPayi, // Karargah kasasına yazıldı 💸
        'parcalar': muhurlenecekParcalar,
        'bayi_id': gercekBayiId,
        'islem_tarihi': FieldValue.serverTimestamp(),
        // Çift Yönlü Onay Konum Damgası
        'firma_onay_konumu': GeoPoint(position.latitude, position.longitude),
        'musteri_onayi': 'bekliyor', // Müşteri ekranına düşecek
      });

      // 5. İşlemi Tetikle ve Mühürle
      await batch.commit();

      if (!mounted) return;
      _siberUyari("SİBER MÜHÜR BASILDI: İşlem Ağa Kaydedildi!", isError: false);
      Navigator.pop(context); // İşlem bitince çık

    } catch (e) {
      _siberUyari("SİSTEM HATASI: $e", isError: true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _siberUyari(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
        backgroundColor: isError ? SiberTema.kanKirmizi : Colors.purpleAccent, // Operasyon Rengi
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color operasyonRengi = Colors.purpleAccent; // Ağır Operasyon Taktiksel Rengi

    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Arka plan Zırhtan geliyor
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: operasyonRengi), onPressed: () => Navigator.pop(context)),
          title: Text("MEGA REVİZYON: ${widget.plaka}", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // ── 7D SİNEMATİK ARAÇ TİPİ SEÇİCİ (KUANTUM SEKMELER) ──
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: SiberTema.oledBlack,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 10, inset: true)], // İç Göçme
              ),
              child: Row(
                children: _paketler.keys.map((tip) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _seciliAracTipi = tip;
                      _secilenParcalar.clear(); // Tip değişince sepeti sıfırla
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: _seciliAracTipi == tip ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1E2026), Color(0xFF0F1014)]) : null,
                        color: _seciliAracTipi == tip ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _seciliAracTipi == tip ? operasyonRengi.withOpacity(0.5) : Colors.transparent, width: 1.5),
                        boxShadow: _seciliAracTipi == tip ? [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 5, offset: const Offset(0, 3))] : [],
                      ),
                      child: Center(
                        child: Text(tip, style: TextStyle(color: _seciliAracTipi == tip ? operasyonRengi : Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, fontFamily: 'Avenir', letterSpacing: 1)),
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),

            // ── 7D SİNEMATİK DİNAMİK PARÇA LİSTESİ ──
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _paketler[_seciliAracTipi]!.length,
                itemBuilder: (context, index) {
                  String parca = _paketler[_seciliAracTipi]![index];
                  bool isSelected = _secilenParcalar.containsKey(parca);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2A2D34), Color(0xFF141518), Color(0xFF0A0A0C)],
                          stops: [0.0, 0.4, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border(
                          top: BorderSide(color: Colors.white.withOpacity(0.15), width: 1.5),
                          left: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
                          right: BorderSide(color: Colors.black.withOpacity(0.8), width: 1),
                          bottom: BorderSide(color: Colors.black.withOpacity(0.8), width: 2),
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.9), blurRadius: 15, offset: const Offset(0, 10)),
                          BoxShadow(color: isSelected ? operasyonRengi.withOpacity(0.15) : Colors.transparent, blurRadius: 25, spreadRadius: -5),
                        ]
                    ),
                    child: ExpansionTile(
                      onExpansionChanged: (expanded) {
                        setState(() {
                          if (expanded) _secilenParcalar[parca] ??= {'fiyat': 0.0};
                          else _secilenParcalar.remove(parca);
                        });
                      },
                      leading: Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: isSelected ? operasyonRengi : Colors.white24, shadows: isSelected ? [const Shadow(color: operasyonRengi, blurRadius: 10)] : []),
                      title: Text(parca, style: TextStyle(color: isSelected ? operasyonRengi : Colors.white.withOpacity(0.9), fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                      childrenPadding: const EdgeInsets.all(16),
                      iconColor: isSelected ? operasyonRengi : Colors.white54,
                      collapsedIconColor: Colors.white54,
                      children: [
                        // FİYAT VE GÖRSEL YÜKLEME ALANI
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white, fontFamily: 'Avenir', fontWeight: FontWeight.bold, fontSize: 16),
                                decoration: InputDecoration(
                                  labelText: "İşçilik Fiyatı (₺)",
                                  labelStyle: TextStyle(color: operasyonRengi.withOpacity(0.5), fontSize: 12, fontFamily: 'Avenir'),
                                  filled: true,
                                  fillColor: SiberTema.oledBlack,
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: operasyonRengi, width: 2)),
                                ),
                                onChanged: (val) => _fiyatGuncelle(parca, val),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // SİBER ÖZGÜRLÜK (KAMERA/GALERİ BUTONLARI)
                            Container(
                              decoration: BoxDecoration(color: SiberTema.oledBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
                              child: IconButton(
                                icon: Icon(Icons.camera_alt, color: _secilenParcalar[parca]?['gorsel'] != null ? operasyonRengi : Colors.white54),
                                onPressed: () => _gorselSec(parca, ImageSource.camera),
                                tooltip: "Canlı Çek",
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(color: SiberTema.oledBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
                              child: IconButton(
                                icon: Icon(Icons.photo_library, color: _secilenParcalar[parca]?['gorsel'] != null ? operasyonRengi : Colors.white54),
                                onPressed: () => _gorselSec(parca, ImageSource.gallery),
                                tooltip: "Galeriden Seç",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── 7D ATOMİK MÜHÜRLEME BUTONU ──
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: operasyonRengi, // YENİ YAPI (MaterialStateProperty hatası giderildi)
                    foregroundColor: SiberTema.oledBlack,
                    elevation: 15,
                    shadowColor: operasyonRengi.withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isProcessing ? null : _agaMuhurle,
                  icon: _isProcessing
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 3))
                      : const Icon(Icons.fingerprint, color: SiberTema.oledBlack, size: 28),
                  label: Text(
                    _isProcessing ? "SİSTEME İŞLENİYOR..." : "SİSTEME MÜHÜRLE (WRITEBATCH)",
                    style: const TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, fontFamily: 'Avenir'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}