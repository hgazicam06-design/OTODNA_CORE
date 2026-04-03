import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

// SİBER ZIRHLAR
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class DijitalMuayeneTerminali extends StatefulWidget {
  final String aracId;
  final String plaka;

  const DijitalMuayeneTerminali({
    super.key,
    required this.aracId,
    required this.plaka,
  });

  @override
  State<DijitalMuayeneTerminali> createState() => _DijitalMuayeneTerminaliState();
}

class _DijitalMuayeneTerminaliState extends State<DijitalMuayeneTerminali> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  bool _isMuhurleniyor = false;

  // MUAYENE EDİLECEK KRİTİK PARÇALAR
  final List<String> _kontrolListesi = [
    'Şase ve Ana Gövde',
    'Fren Sistemi ve Balatalar',
    'Radyatör ve Soğutma',
    'Motor Bloğu ve Yağ Kaçağı',
    'Rot ve Balans Ayarları'
  ];

  // PARÇA DURUMLARI (Key: Parça Adı, Value: Map {durum: 0=Bekliyor, 1=Onaylı, -1=Riskli, kanit_url: string})
  final Map<String, Map<String, dynamic>> _muayeneMatrisi = {};

  @override
  void initState() {
    super.initState();
    // Matrisi sıfırla
    for (var parca in _kontrolListesi) {
      _muayeneMatrisi[parca] = {'durum': 0, 'kanit_url': null};
    }
  }

  // --- SİBER KANIT YÜKLEME (YEŞİL TIK ZORUNLULUĞU) ---
  Future<void> _kanitYukleVeOnayla(String parcaAdi, bool isRiskli) async {
    final XFile? secilenDosya = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);

    if (secilenDosya == null) {
      _siberUyariVer("SİBER İHLAL: İşlemi onaylamak için görsel kanıt yüklemek ZORUNLUDUR!", isError: true);
      return;
    }

    _siberUyariVer("Kanıt Kuantum Ağına Yükleniyor...", isError: false);

    try {
      File file = File(secilenDosya.path);
      String fileName = "kanit_${DateTime.now().millisecondsSinceEpoch}.jpg";
      String storagePath = 'muayene_kanitlari/${widget.aracId}/$fileName';

      TaskSnapshot snapshot = await _storage.ref().child(storagePath).putFile(file);
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _muayeneMatrisi[parcaAdi]!['kanit_url'] = downloadUrl;
        _muayeneMatrisi[parcaAdi]!['durum'] = isRiskli ? -1 : 1;
      });

      _siberUyariVer(isRiskli ? "KIRMIZI X (RİSK) MÜHÜRLENDİ!" : "YEŞİL TIK (ONAY) MÜHÜRLENDİ!", isError: isRiskli);

    } catch (e) {
      _siberUyariVer("AĞ HATASI: Kanıt yüklenemedi.", isError: true);
    }
  }

  // --- 🔴 FİREBASE: ATOMİK YAZMA (WRITEBATCH) İLE RAPORU MERKEZE İLETME ---
  Future<void> _raporuKarargahaGonder() async {
    // Tüm parçalar kontrol edildi mi?
    bool eksikVarMi = _muayeneMatrisi.values.any((element) => element['durum'] == 0);
    if (eksikVarMi) {
      _siberUyariVer("SİBER İHLAL: Tüm parçaların kontrolü ve kanıt yüklemesi tamamlanmalıdır!", isError: true);
      return;
    }

    setState(() => _isMuhurleniyor = true);

    try {
      WriteBatch batch = _db.batch();
      String ustaId = FirebaseAuth.instance.currentUser?.uid ?? 'BİLİNMEYEN_USTA';

      // 1. Raporu muayene_raporlari koleksiyonuna yaz
      DocumentReference raporRef = _db.collection('muayene_raporlari').doc();

      bool kritikRiskVarMi = _muayeneMatrisi.values.any((e) => e['durum'] == -1);
      int guncelDnaSkoruHesabi = kritikRiskVarMi ? -30 : 10; // Risk varsa skoru çak, yoksa artır

      batch.set(raporRef, {
        'arac_id': widget.aracId,
        'plaka': widget.plaka,
        'usta_id': ustaId,
        'tarih': FieldValue.serverTimestamp(),
        'detaylar': _muayeneMatrisi,
        'sonuc': kritikRiskVarMi ? 'TRAFİĞE ÇIKIŞI RİSKLİ' : 'OTODNA ONAYLIDIR',
      });

      // 2. Aracın ana kütüğünü güncelle (DNA Skoru ve Risk Durumu)
      DocumentReference aracRef = _db.collection('araclar').doc(widget.aracId);
      batch.update(aracRef, {
        'dna_skoru': FieldValue.increment(guncelDnaSkoruHesabi),
        'trafik_riski': kritikRiskVarMi,
        'son_muayene_tarihi': FieldValue.serverTimestamp(),
      });

      // 3. Kırmızı X varsa Ekosistem Kapısını (Murat Plaza & Karargah %12 Payı) Tetikle
      if (kritikRiskVarMi) {
        DocumentReference finansRef = _db.collection('bayi_ekosistemi_firsatlari').doc();
        batch.set(finansRef, {
          'arac_id': widget.aracId,
          'plaka': widget.plaka,
          'durum': 'Yedek Parça Önerisi Bekliyor',
          'bayi_referansi': 'Murat Plaza',
          'karargah_komisyon_orani': 0.12, // %12 Sistem Payı
          'bayi_marji': 0.30, // %30 Murat Plaza Marjı
          'tarih': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit(); // Tüm işlemleri tek seferde atomik olarak mühürle!

      if (!mounted) return;
      setState(() => _isMuhurleniyor = false);
      Navigator.pop(context);
      _siberUyariVer(kritikRiskVarMi ? "ARAÇ RİSKLİ İŞARETLENDİ! Tedarik Zinciri Tetiklendi." : "DİJİTAL REFERANS (✅) BAŞARIYLA VERİLDİ!", isError: kritikRiskVarMi);

    } catch (e) {
      if (!mounted) return;
      setState(() => _isMuhurleniyor = false);
      _siberUyariVer("SİBER AĞ HATASI: Rapor mühürlenemedi.", isError: true);
    }
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, fontFamily: 'Avenir', letterSpacing: 1)),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
    ));
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
          leading: IconButton(icon: const Icon(Icons.close, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: Column(
            children: [
              Text("DİJİTAL REFERANS PROTOKOLÜ", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, fontFamily: 'Avenir')),
              Text(widget.plaka, style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Avenir', letterSpacing: 2)),
            ],
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: SiberTema.kanKirmizi.withOpacity(0.1),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: SiberTema.kanKirmizi),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text("UYARI: Yeşil Tık (✅) veya Kırmızı X (❌) verebilmek için anlık görsel kanıt yüklemek zorunludur. Sahte muayeneye geçit yok!",
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10, fontFamily: 'Avenir', fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: _kontrolListesi.length,
                  itemBuilder: (context, index) {
                    String parca = _kontrolListesi[index];
                    int durum = _muayeneMatrisi[parca]!['durum'];
                    String? kanitUrl = _muayeneMatrisi[parca]!['kanit_url'];

                    return _buildSiberKontrolKarti(parca, durum, kanitUrl);
                  },
                ),
              ),

              // RAPORU MÜHÜRLE BUTONU
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: SiberTema.kuantumButonStili(),
                    onPressed: _isMuhurleniyor ? null : _raporuKarargahaGonder,
                    child: _isMuhurleniyor
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 2))
                        : const Text("DİJİTAL İMZAYI AT VE MÜHÜRLE", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1.5)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiberKontrolKarti(String parca, int durum, String? kanitUrl) {
    Color cerceveRengi = durum == 0 ? Colors.white.withOpacity(0.1) : (durum == 1 ? SiberTema.kuantumCyan : SiberTema.kanKirmizi);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cerceveRengi, width: durum == 0 ? 1 : 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(parca, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Avenir', letterSpacing: 1))),
                    if (kanitUrl != null)
                      const Icon(Icons.camera_alt, color: SiberTema.kuantumCyan, size: 16),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // KIRMIZI X BUTONU
                    Expanded(
                      child: InkWell(
                        onTap: () => _kanitYukleVeOnayla(parca, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: durum == -1 ? SiberTema.kanKirmizi.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: durum == -1 ? SiberTema.kanKirmizi : Colors.white.withOpacity(0.1)),
                          ),
                          child: const Center(child: Icon(Icons.close, color: SiberTema.kanKirmizi, size: 28)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // YEŞİL TIK BUTONU (Sistemde Turkuaz parlıyor)
                    Expanded(
                      child: InkWell(
                        onTap: () => _kanitYukleVeOnayla(parca, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: durum == 1 ? SiberTema.kuantumCyan.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: durum == 1 ? SiberTema.kuantumCyan : Colors.white.withOpacity(0.1)),
                          ),
                          child: const Center(child: Icon(Icons.check, color: SiberTema.kuantumCyan, size: 28)),
                        ),
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
}