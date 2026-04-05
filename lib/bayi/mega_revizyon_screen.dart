import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class MegaRevizyonScreen extends StatefulWidget {
  final String plaka; // İşlem yapılacak aracın plakası
  const MegaRevizyonScreen({super.key, required this.plaka});

  @override
  State<MegaRevizyonScreen> createState() => _MegaRevizyonScreenState();
}

class _MegaRevizyonScreenState extends State<MegaRevizyonScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
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
      List<Map<String, dynamic>> mühürlenecekParcalar = [];
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

    mühürlenecekParcalar.add({
    'parca_adi': parca.key,
    'fiyat': fiyat,
    'gorsel_url': gorselUrl,
    'firma_onayi': true, // Usta kendi girdiği için peşin onaylı
    });
    }

    // 3. Karargah Finans Algoritması (Standart %12)
    double komutanPayi = toplamMaliyet * 0.12;

    // 4. Atomik WriteBatch Atışı
    WriteBatch batch = _db.batch();

    DocumentReference islemRef = _db.collection('islem_kayitlari').doc(islemId);
    batch.set(islemRef, {
    'islem_id': islemId,
    'plaka': widget.plaka,
    'arac_tipi': _seciliAracTipi,
    'toplam_maliyet': toplamMaliyet,
    'komutan_payi': komutanPayi, // Karargah kasasına yazıldı 💸
    'parcalar': mühürlenecekParcalar,
    'bayi_id': 'MevcutBayiID', // TODO: Auth'dan çekilecek
    'islem_tarihi': FieldValue.serverTimestamp(),
    // Çift Yönlü Onay Konum Damgası
    'firma_onay_konumu': GeoPoint(position.latitude, position.longitude),
    'musteri_onayi': 'bekliyor', // Müşteri ekranına düşecek
    });

    // İşlemi Tetikle
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
        content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: Text("MEGA REVİZYON: ${widget.plaka}", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // ── ARAÇ TİPİ SEÇİCİ (KUANTUM SEKMELER) ──
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: SiberTema.matGrey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: _paketler.keys.map((tip) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _seciliAracTipi = tip;
                      _secilenParcalar.clear(); // Tip değişince sepeti sıfırla
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _seciliAracTipi == tip ? SiberTema.kuantumCyan.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _seciliAracTipi == tip ? SiberTema.kuantumCyan : Colors.transparent),
                      ),
                      child: Center(
                        child: Text(tip, style: TextStyle(color: _seciliAracTipi == tip ? SiberTema.kuantumCyan : Colors.white54, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Avenir')),
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ),

            // ── DİNAMİK PARÇA LİSTESİ ──
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
                      gradient: LinearGradient(
                        colors: isSelected
                            ? [SiberTema.kuantumCyan.withOpacity(0.1), SiberTema.oledBlack]
                            : [SiberTema.matGrey.withOpacity(0.3), SiberTema.oledBlack],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? SiberTema.kuantumCyan.withOpacity(0.5) : Colors.white.withOpacity(0.05)),
                    ),
                    child: ExpansionTile(
                      onExpansionChanged: (expanded) {
                        setState(() {
                          if (expanded) _secilenParcalar[parca] ??= {'fiyat': 0.0};
                          else _secilenParcalar.remove(parca);
                        });
                      },
                      leading: Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: isSelected ? SiberTema.kuantumCyan : Colors.white24),
                      title: Text(parca, style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w700, fontFamily: 'Avenir')),
                      childrenPadding: const EdgeInsets.all(16),
                      children: [
                        // FİYAT VE GÖRSEL YÜKLEME ALANI
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white, fontFamily: 'Avenir'),
                                decoration: InputDecoration(
                                  labelText: "Parça / İşçilik Fiyatı (₺)",
                                  labelStyle: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.5), fontSize: 12),
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: SiberTema.kuantumCyan)),
                                ),
                                onChanged: (val) => _fiyatGuncelle(parca, val),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // SİBER ÖZGÜRLÜK (KAMERA/GALERİ BUTONLARI)
                            IconButton(
                              icon: Icon(Icons.camera_alt, color: _secilenParcalar[parca]?['gorsel'] != null ? SiberTema.kuantumCyan : Colors.white54),
                              onPressed: () => _gorselSec(parca, ImageSource.camera),
                              tooltip: "Canlı Çek",
                            ),
                            IconButton(
                              icon: Icon(Icons.photo_library, color: _secilenParcalar[parca]?['gorsel'] != null ? SiberTema.kuantumCyan : Colors.white54),
                              onPressed: () => _gorselSec(parca, ImageSource.gallery),
                              tooltip: "Galeriden Seç",
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── ATOMİK MÜHÜRLEME BUTONU ──
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GestureDetector(
                onTap: _isProcessing ? null : _agaMuhurle,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: _isProcessing ? SiberTema.matGrey : SiberTema.kuantumCyan.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _isProcessing ? [] : [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Center(
                    child: _isProcessing
                        ? const CircularProgressIndicator(color: SiberTema.oledBlack)
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fingerprint, color: SiberTema.oledBlack, size: 28),
                        SizedBox(width: 12),
                        Text("SİSTEME MÜHÜRLE (WRITEBATCH)", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Avenir')),
                      ],
                    ),
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