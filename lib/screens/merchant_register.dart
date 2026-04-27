import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🦅 OTO DNA ESNAF KAYIT TERMİNALİ - SİBER ONAM MOTORU
/// [2026-03-28] GÜNCELLEME: %100 GERÇEK FIREBASE ENTEGRASYONU
class MerchantRegister extends StatefulWidget {
  const MerchantRegister({super.key});

  @override
  State<MerchantRegister> createState() => _MerchantRegisterState();
}

class _MerchantRegisterState extends State<MerchantRegister> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isUploadingVergi = false;
  bool _isUploadingRuhsat = false;
  String? _vergiUrl;
  String? _ruhsatUrl;
  bool _isFinalizing = false;

  // 🚀 FİREBASE: GERÇEK EVRAK YÜKLEME VE DEPOLAMA MOTORU
  Future<void> _evrakYukle(String belgeTuru) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String userId = _auth.currentUser?.uid ?? "misafir_bayi";
        String fileName = "${belgeTuru.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}";
        String storagePath = 'bayi_basvurulari/$userId/$fileName';

        setState(() {
          if (belgeTuru == 'VERGİ') _isUploadingVergi = true;
          else _isUploadingRuhsat = true;
        });

        // Kuantum Hattına Yükle
        TaskSnapshot snapshot = await _storage.ref(storagePath).putFile(file);
        String downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          if (belgeTuru == 'VERGİ') {
            _vergiUrl = downloadUrl;
            _isUploadingVergi = false;
          } else {
            _ruhsatUrl = downloadUrl;
            _isUploadingRuhsat = false;
          }
        });

        _siberUyari("$belgeTuru LEVHASI SİSTEME MÜHÜRLENDİ!", isError: false);
      }
    } catch (e) {
      _siberUyari("YÜKLEME İHLALİ: $e", isError: true);
      setState(() {
        _isUploadingVergi = false;
        _isUploadingRuhsat = false;
      });
    }
  }

  // 🔥 BAŞVURUYU ANKARA KARARGAHINA MÜHÜRLE
  Future<void> _basvuruyuTamamla() async {
    if (_vergiUrl == null || _ruhsatUrl == null) return;

    setState(() => _isFinalizing = true);

    try {
      String userId = _auth.currentUser?.uid ?? "";

      // %100 Gerçek Kayıt: WriteBatch ile atomik mühürleme
      WriteBatch batch = _db.batch();

      DocumentReference basvuruRef = _db.collection('bayi_basvurulari').doc(userId);
      batch.set(basvuruRef, {
        'bayi_id': userId,
        'vergi_levhasi_url': _vergiUrl,
        'isletme_ruhsati_url': _ruhsatUrl,
        'basvuru_tarihi': FieldValue.serverTimestamp(),
        'onay_durumu': 'beklemede',
        'merkez_notu': 'Ankara Karargah onayı bekleniyor.',
      });

      // Kullanıcı statüsünü "aday_bayi" olarak güncelle
      DocumentReference userRef = _db.collection('kullanicilar').doc(userId);
      batch.update(userRef, {'rol': 'aday_bayi'});

      await batch.commit();

      _siberUyari("BAŞVURU ANKARA MERKEZE İLETİLDİ! 🚀", isError: false);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _siberUyari("MÜHÜRLEME HATASI: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isFinalizing = false);
    }
  }

  void _siberUyari(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text("ESNAF KAYİT TERMİNALİ", style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
          centerTitle: true,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🛡️ SİBER BİLGİLENDİRME (Siber Cam Efekti)
                  _buildBilgiPaneli(),
                  const SizedBox(height: 48),

                  // 📄 VERGİ LEVHASI
                  _buildYuklemeKarti(
                    title: "VERGİ LEVHASI (PDF/JPG)",
                    icon: Icons.account_balance_outlined,
                    isUploading: _isUploadingVergi,
                    isUploaded: _vergiUrl != null,
                    onTap: () => _evrakYukle('VERGİ'),
                  ),
                  const SizedBox(height: 24),

                  // 📄 İŞLETME RUHSATI
                  _buildYuklemeKarti(
                    title: "İŞLETME RUHSATI (PDF/JPG)",
                    icon: Icons.store_mall_directory_outlined,
                    isUploading: _isUploadingRuhsat,
                    isUploaded: _ruhsatUrl != null,
                    onTap: () => _evrakYukle('RUHSAT'),
                  ),
                  const SizedBox(height: 48),

                  // 🚀 ATEŞLEME BUTONU
                  _buildFinalizeButon(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBilgiPaneli() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SiberTema.kuantumCyan.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.domain_verification, color: SiberTema.kuantumCyan, size: 48),
          const SizedBox(height: 16),
          const Text("ANKARA MERKEZ ONAYI", style: TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text(
            "Evraklarınız şifrelenerek Ankara Karargahına iletilir. İnceleme süreci 24 saat içinde tamamlanacaktır.",
            textAlign: TextAlign.center,
            style: TextStyle(color: SiberTema.textMain.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.bold, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildYuklemeKarti({required String title, required IconData icon, required bool isUploading, required bool isUploaded, required VoidCallback onTap}) {
    Color kartRengi = isUploaded ? SiberTema.kuantumCyan : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: SiberTema.matGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isUploaded ? SiberTema.kuantumCyan.withOpacity(0.5) : Colors.white10, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: (isUploading || isUploaded) ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(isUploaded ? Icons.verified : icon, color: kartRengi, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: kartRengi, fontSize: 12, fontWeight: FontWeight.w900)),
                      Text(isUploaded ? "MÜHÜRLENDİ" : "DOKÜMAN SEÇ", style: const TextStyle(color: SiberTema.textMuted, fontSize: 10)),
                    ],
                  ),
                ),
                if (isUploading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 2)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinalizeButon() {
    bool ready = _vergiUrl != null && _ruhsatUrl != null;
    return SizedBox(
      height: 64,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: SiberTema.kuantumCyan,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          disabledBackgroundColor: SiberTema.kuantumCyan.withOpacity(0.1),
        ),
        onPressed: (ready && !_isFinalizing) ? _basvuruyuTamamla : null,
        icon: _isFinalizing ? const SizedBox.shrink() : const Icon(Icons.rocket_launch),
        label: _isFinalizing
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(ready ? "BAŞVURUYU TAMAMLA" : "EVRAKLAR BEKLENİYOR", style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}