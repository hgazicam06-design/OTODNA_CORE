import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI VE MOTORLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../services/takip_radari.dart';

class BayiEkosistemiScreen extends StatefulWidget {
  const BayiEkosistemiScreen({super.key});

  @override
  State<BayiEkosistemiScreen> createState() => _BayiEkosistemiScreenState();
}

class _BayiEkosistemiScreenState extends State<BayiEkosistemiScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TakipRadari _takipRadari = TakipRadari();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _aracIdController = TextEditingController();

  bool _isProcessing = false;

  // Kontrol Edilecek Kritik Parçalar
  final List<String> _kritikParcalar = [
    "Fren Sistemi & Balatalar",
    "Şase & Direk Kontrolü",
    "Motor Bloğu & Yağ Kaçağı",
    "Otomatik Şanzıman Geçişleri",
    "Radyatör & Soğutma",
  ];

  // Parçaların anlık durumlarını tutar (null: Bekliyor, true: Sağlam, false: Riskli)
  final Map<String, bool?> _parcaDurumlari = {};
  final Map<String, String> _parcaKanitlari = {};

  @override
  void initState() {
    super.initState();
    for (var parca in _kritikParcalar) {
      _parcaDurumlari[parca] = null;
    }
  }

  @override
  void dispose() {
    _aracIdController.dispose();
    super.dispose();
  }

  // --- 🛰️ SİBER MÜHÜRLEME MOTORU (WRITEBATCH) ---
  Future<void> _parcaIsleminiMuhurle(String parcaAdi, bool saglamMi, {String? fotoPath}) async {
    final String aracId = _aracIdController.text.trim().toUpperCase();
    if (aracId.isEmpty) {
      _siberUyariVer("SİBER İHLAL: Önce hedef araç kimliğini girin!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final String? ustaUid = FirebaseAuth.instance.currentUser?.uid;
      final WriteBatch batch = _db.batch();

      // 1. İşlem Kaydı Oluştur (Ekspertiz Tarihçesi)
      DocumentReference raporRef = _db.collection('dna_raporlari').doc();
      batch.set(raporRef, {
        'arac_id': aracId,
        'parca_adi': parcaAdi,
        'durum': saglamMi ? 'SAGLAM' : 'RISKLI',
        'usta_id': ustaUid,
        'kanit_url': fotoPath ?? '',
        'tarih': FieldValue.serverTimestamp(),
        'lokasyon': 'Merkez Karargah', // Statik veya konum servisinden gelebilir
      });

      // 2. Takip Radarı Üzerinden Skor ve Muayene Güncellemesi
      // Bu metodlar kendi batch'lerini yönettiği için await ile çağrılır
      // veya servis içine batch desteği eklenir. Mevcut yapıyı koruyarak mühürlüyoruz:
      await _takipRadari.dnaSkoruHesapla(aracId, !saglamMi);

      if (saglamMi) {
        await _takipRadari.araMuayeneKur(aracId, aracId, parcaAdi, 12);
      }

      // 3. Sistem Loglarına İşle (Denetim İzi)
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem': 'DİJİTAL_REFERANS',
        'detay': '$aracId plakalı aracın $parcaAdi kontrolü yapıldı.',
        'sonuc': saglamMi ? 'BAŞARILI' : 'KRİTİK HATA',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      setState(() {
        _parcaDurumlari[parcaAdi] = saglamMi;
        if (fotoPath != null) _parcaKanitlari[parcaAdi] = fotoPath;
      });

      _siberUyariVer("$parcaAdi: PROTOKOL TAMAMLANDI.", isError: !saglamMi);
    } catch (e) {
      _siberUyariVer("SİBER HATA: Kuantum ağına mühürleme yapılamadı!", isError: true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // --- ✅ FOTOĞRAFLI YEŞİL TIK ---
  Future<void> _yesilTikAt(String parcaAdi) async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (foto == null) {
      _siberUyariVer("SİBER RED: Kanıt olmadan mühürleme yapılamaz!", isError: true);
      return;
    }
    await _parcaIsleminiMuhurle(parcaAdi, true, fotoPath: foto.path);
  }

  // --- ❌ KIRMIZI X ---
  Future<void> _kirmiziCarpiAt(String parcaAdi) async {
    await _parcaIsleminiMuhurle(parcaAdi, false);
  }

  void _siberUyariVer(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 12)),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          leading: IconButton(icon: const Icon(Icons.shield, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: const Text("DİJİTAL REFERANS MERKEZİ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2)),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // ── 1. ARAÇ KİMLİK GİRİŞİ ──
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SiberTema.siberCamKalkan(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _aracIdController,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 3),
                      decoration: const InputDecoration(
                        hintText: "PLAKA VEYA ŞASE GİRİN",
                        hintStyle: TextStyle(color: Colors.white24, fontSize: 12),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.radar, color: SiberTema.kuantumCyan, size: 20),
                      ),
                    ),
                  ),
                ),

                // ── 2. KONTROL LİSTESİ ──
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _kritikParcalar.length,
                    itemBuilder: (context, index) {
                      String parca = _kritikParcalar[index];
                      bool? durum = _parcaDurumlari[parca];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: SiberTema.matGrey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: durum == null ? Colors.white12 : (durum ? SiberTema.kuantumCyan : SiberTema.kanKirmizi),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(parca, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                                if (durum != null) Icon(durum ? Icons.verified : Icons.gpp_bad, color: durum ? SiberTema.kuantumCyan : SiberTema.kanKirmizi),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                _islemButonu(
                                  onTap: () => _kirmiziCarpiAt(parca),
                                  icon: Icons.close,
                                  renk: SiberTema.kanKirmizi,
                                  aktif: durum == false,
                                ),
                                const SizedBox(width: 12),
                                _islemButonu(
                                  onTap: () => _yesilTikAt(parca),
                                  icon: Icons.camera_enhance,
                                  renk: SiberTema.kuantumCyan,
                                  aktif: durum == true,
                                  ekstraIcon: Icons.check,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            if (_isProcessing)
              Container(
                color: Colors.black87,
                child: const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _islemButonu({required VoidCallback onTap, required IconData icon, required Color renk, bool aktif = false, IconData? ekstraIcon}) {
    return Expanded(
      child: GestureDetector(
        onTap: _isProcessing ? null : onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: aktif ? renk.withOpacity(0.2) : Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: aktif ? renk : renk.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: renk, size: 20),
              if (ekstraIcon != null) ...[
                const SizedBox(width: 8),
                Icon(ekstraIcon, color: renk, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}