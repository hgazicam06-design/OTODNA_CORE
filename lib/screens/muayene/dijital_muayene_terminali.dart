import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

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
  // 🏢 FİLDİŞİ SEDEF PALET
  final Color bgColor = const Color(0xFFFDFBF7);
  final Color surfaceColor = Colors.white;
  final Color primaryTeal = Colors.teal.shade700;
  final Color textMain = const Color(0xFF1E293B);
  final Color textMuted = const Color(0xFF64748B);
  final Color dangerColor = SiberTema.kanKirmizi;

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
      context.pop();
      _siberUyariVer(kritikRiskVarMi ? "RİSKLİ ARAÇ SİSTEME İŞLENDİ!" : "DİJİTAL REFERANS MÜHÜRLENDİ!", isError: kritikRiskVarMi);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isMuhurleniyor = false);
      _siberUyariVer("SİBER HATA: İşlem başarısız.", isError: true);
    }
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
      backgroundColor: isError ? dangerColor : primaryTeal,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false, // Ivory için false
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: primaryTeal), onPressed: () => context.pop()),
          title: Text("DİJİTAL MUAYENE", style: TextStyle(color: textMain, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Text(widget.plaka, style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, fontSize: 14))),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isMuhurleniyor ? null : _raporuKarargahaGonder,
                  child: _isMuhurleniyor
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("RAPORU MATRIX'E GÖNDER", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSiberKart(String parca, int durum) {
    Color statusColor = durum == 0 ? Colors.black.withOpacity(0.1) : (durum == 1 ? primaryTeal : dangerColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: durum == 0 ? Colors.black.withOpacity(0.05) : statusColor.withOpacity(0.5), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(parca.toUpperCase(), style: TextStyle(color: textMain, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
          const SizedBox(height: 20),
          Row(
            children: [
              _statusAction(Icons.close, dangerColor, durum == -1, () => _kanitYukleVeOnayla(parca, true)),
              const SizedBox(width: 12),
              _statusAction(Icons.check, primaryTeal, durum == 1, () => _kanitYukleVeOnayla(parca, false)),
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
            color: active ? color.withOpacity(0.1) : surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? color : Colors.black.withOpacity(0.05)),
          ),
          child: Icon(icon, color: active ? color : textMuted, size: 28),
        ),
      ),
    );
  }
}