import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 SİBER ZIRHLAR VE MERKEZİ TEMA
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

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

  // 🛠️ MUAYENE EDİLECEK KRİTİK NOKTALAR
  final List<String> _kontrolListesi = [
    'Şase ve Ana Gövde',
    'Fren Sistemi ve Balatalar',
    'Radyatör ve Soğutma',
    'Motor Bloğu ve Yağ Kaçağı',
    'Rot ve Balans Ayarları'
  ];

  // 📊 SİBER MATRİS (Durum: 0=Bekliyor, 1=Onaylı, -1=Riskli)
  final Map<String, Map<String, dynamic>> _muayeneMatrisi = {};

  @override
  void initState() {
    super.initState();
    for (var parca in _kontrolListesi) {
      _muayeneMatrisi[parca] = {'durum': 0, 'kanit_url': null};
    }
  }

  // --- 📸 SİBER KANIT YÜKLEME (YEŞİL TIK ZORUNLULUĞU) ---
  Future<void> _kanitYukleVeOnayla(String parcaAdi, bool isRiskli) async {
    final XFile? secilenDosya = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50, // Hız için optimize edildi
    );

    if (secilenDosya == null) {
      _siberUyariVer("SİBER İHLAL: Kanıt yüklemek zorunludur!", isError: true);
      return;
    }

    _siberUyariVer("Kanıt Kuantum Ağına İşleniyor...", isError: false);

    try {
      File file = File(secilenDosya.path);
      String fileName = "muayene_${widget.aracId}_${DateTime.now().millisecondsSinceEpoch}.jpg";
      String storagePath = 'muayene_kanitlari/${widget.aracId}/$fileName';

      TaskSnapshot snapshot = await _storage.ref().child(storagePath).putFile(file);
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _muayeneMatrisi[parcaAdi]!['kanit_url'] = downloadUrl;
        _muayeneMatrisi[parcaAdi]!['durum'] = isRiskli ? -1 : 1;
      });

      _siberUyariVer(isRiskli ? "KIRMIZI X MÜHÜRLENDİ!" : "YEŞİL TIK MÜHÜRLENDİ!", isError: isRiskli);
    } catch (e) {
      _siberUyariVer("AĞ HATASI: Veri mühürlenemedi.", isError: true);
    }
  }

  // --- 🔴 ATOMİK RAPORLAMA (WRITEBATCH) ---
  Future<void> _raporuKarargahaGonder() async {
    bool eksikVarMi = _muayeneMatrisi.values.any((element) => element['durum'] == 0);
    if (eksikVarMi) {
      _siberUyariVer("SİBER İHLAL: Tüm kontroller tamamlanmalıdır!", isError: true);
      return;
    }

    setState(() => _isMuhurleniyor = true);

    try {
      WriteBatch batch = _db.batch();
      String ustaId = FirebaseAuth.instance.currentUser?.uid ?? 'BILINMEYEN_USTA';
      bool kritikRiskVarMi = _muayeneMatrisi.values.any((e) => e['durum'] == -1);

      // 1. Rapor Kaydı
      DocumentReference raporRef = _db.collection('muayene_raporlari').doc();
      batch.set(raporRef, {
        'arac_id': widget.aracId,
        'plaka': widget.plaka,
        'usta_id': ustaId,
        'tarih': FieldValue.serverTimestamp(),
        'detaylar': _muayeneMatrisi,
        'sonuc': kritikRiskVarMi ? 'TRAFİĞE ÇIKIŞI RİSKLİ' : 'OTODNA ONAYLIDIR',
      });

      // 2. DNA ve Risk Güncelleme (10 Puan Artış veya 30 Puan Düşüş)
      DocumentReference aracRef = _db.collection('araclar').doc(widget.aracId);
      batch.update(aracRef, {
        'dna_skoru': FieldValue.increment(kritikRiskVarMi ? -30 : 10),
        'trafik_riski': kritikRiskVarMi,
        'son_muayene_tarihi': FieldValue.serverTimestamp(),
      });

      // 3. Murat Plaza Ekonomik Tetikleyici (%12 Karargah / %30 Murat Plaza)
      if (kritikRiskVarMi) {
        DocumentReference finansRef = _db.collection('bayi_ekosistemi_firsatlari').doc();
        batch.set(finansRef, {
          'arac_id': widget.aracId,
          'plaka': widget.plaka,
          'durum': 'Yedek Parça Önerisi Bekliyor',
          'bayi_referansi': 'Murat Plaza',
          'karargah_komisyon_orani': 0.12,
          'bayi_marji': 0.30,
          'tarih': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (!mounted) return;
      Navigator.pop(context);
      _siberUyariVer(kritikRiskVarMi ? "RİSKLİ ARAÇ SİSTEME İŞLENDİ!" : "DİJİTAL REFERANS MÜHÜRLENDİ!", isError: kritikRiskVarMi);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isMuhurleniyor = false);
      _siberUyariVer("SİBER HATA: İşlem başarısız.", isError: true);
    }
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
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
          centerTitle: true,
          title: Text("DİJİTAL MUAYENE TERMİNALİ", style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Text(widget.plaka, style: const TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 14))),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _kontrolListesi.length,
                itemBuilder: (context, index) {
                  String parca = _kontrolListesi[index];
                  int durum = _muayeneMatrisi[parca]!['durum'];
                  return _buildSiberKart(parca, durum);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  style: SiberTema.kuantumButonStili(),
                  onPressed: _isMuhurleniyor ? null : _raporuKarargahaGonder,
                  child: _isMuhurleniyor
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text("RAPORU MATRIX'E GÖNDER", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSiberKart(String parca, int durum) {
    Color statusColor = durum == 0 ? Colors.white24 : (durum == 1 ? SiberTema.kuantumCyan : SiberTema.kanKirmizi);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(parca.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
          const SizedBox(height: 20),
          Row(
            children: [
              _statusAction(Icons.close, SiberTema.kanKirmizi, durum == -1, () => _kanitYukleVeOnayla(parca, true)),
              const SizedBox(width: 12),
              _statusAction(Icons.check, SiberTema.kuantumCyan, durum == 1, () => _kanitYukleVeOnayla(parca, false)),
            ],
          )
        ],
      ),
    );
  }

  Widget _statusAction(IconData icon, Color color, bool active, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? color : Colors.white10),
          ),
          child: Icon(icon, color: active ? color : Colors.white24, size: 28),
        ),
      ),
    );
  }
}