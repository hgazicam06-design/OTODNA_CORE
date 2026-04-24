// lib/bayi/bayi_veri_giris_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI VE TEMALARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class BayiVeriGirisScreen extends StatefulWidget {
  const BayiVeriGirisScreen({super.key});

  @override
  State<BayiVeriGirisScreen> createState() => _BayiVeriGirisScreenState();
}

class _BayiVeriGirisScreenState extends State<BayiVeriGirisScreen> {
  final TextEditingController _saseController = TextEditingController(); // PLAKA YERİNE ŞASE!
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  bool _isSearching = false;
  bool _isSaving = false;
  bool _aracSorgulandi = false;

  Map<String, dynamic>? _aracData; // Firebase'den çekilen gerçek araç verisi

  // KONTROL EDİLECEK PARÇALAR VE DURUMLARI (0: Bekliyor, 1: Onaylı ✅, 2: Kusurlu/Riskli ❌)
  final Map<String, int> _kontrolListesi = {
    "Şase ve Direkler": 0,
    "Fren ve Balata Sistemi": 0,
    "Radyatör ve Soğutma": 0,
    "Motor Bloğu ve Yağ Kaçağı": 0,
    "Rot-Balans ve Süspansiyon": 0,
  };

  @override
  void dispose() {
    _saseController.dispose();
    super.dispose();
  }

  // 🚀 FİREBASE CANLI ARAÇ SORGULAMA MOTORU (ŞASE İLE)
  Future<void> _sorgula() async {
    FocusScope.of(context).unfocus();
    String saseGirdisi = _saseController.text.trim().replaceAll(" ", "").toUpperCase();

    if (saseGirdisi.isEmpty) {
      _showSnackBar("Lütfen bir Şase Numarası (VIN) veya QR Kodu girin!", isError: true);
      return;
    }

    setState(() {
      _isSearching = true;
      _aracSorgulandi = false;
      _aracData = null;
      // Yeni araç arandığında eski kontrol listesini sıfırla
      _kontrolListesi.updateAll((key, value) => 0);
    });

    try {
      // ⚠️ DOĞRU TABLO: vehicles (Kuantum Standart Tablosu)
      DocumentSnapshot doc = await _db.collection('vehicles').doc(saseGirdisi).get();

      if (doc.exists) {
        setState(() {
          _aracData = doc.data() as Map<String, dynamic>;
          _aracSorgulandi = true;
        });
        _showSnackBar("Hedef Araç Kuantum Ağında Bulundu! 🦅");
      } else {
        _showSnackBar("Bu şaseye ait araç OtoDNA Karargahında bulunamadı!", isError: true);
      }
    } catch (e) {
      _showSnackBar("Siber Radar Hatası: Matrix bağlantınızı kontrol edin.", isError: true);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
    ));
  }

  // YEŞİL TIK (ONAY) İŞLEMİ
  void _onayVer(String parca) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: SiberTema.matGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: SiberTema.kuantumCyan, width: 2)),
        title: const Row(children: [Icon(Icons.camera_alt, color: SiberTema.kuantumCyan), SizedBox(width: 12), Text("Kanıt Yüklemesi", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))]),
        content: Text("Dijital Referans Protokolü gereği, '$parca' için Yeşil Tık (✅) atabilmeniz için anlık fotoğraf veya video yüklemeniz önerilir.", style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal", style: TextStyle(color: Colors.white54))),
          ElevatedButton.icon(
            style: SiberTema.kuantumButonStili(),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _kontrolListesi[parca] = 1);
              _showSnackBar("$parca onaylandı ve dijital imzanız atıldı! ✅");
            },
            icon: const Icon(Icons.check_circle, color: SiberTema.oledBlack, size: 16),
            label: const Text("Onayla & Geç", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // KIRMIZI ÇARPI (KUSUR/RİSK) İŞLEMİ
  void _retVer(String parca) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: SiberTema.matGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: SiberTema.kanKirmizi, width: 2)),
        title: const Row(children: [Icon(Icons.warning, color: SiberTema.kanKirmizi), SizedBox(width: 12), Text("Kritik Risk Bildirimi!", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 16, fontWeight: FontWeight.bold))]),
        content: Text("DİKKAT! '$parca' alanına Kırmızı X (❌) atıyorsunuz. Bu işlem aracın DNA Skorunu kalıcı olarak düşürecek ve Kuantum Merkezine raporlanacaktır. Onaylıyor musunuz?", style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal", style: TextStyle(color: Colors.white54))),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kanKirmizi),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _kontrolListesi[parca] = 2);
              _showSnackBar("$parca riskli işaretlendi! Aracın değeri düşürülecek. ❌", isError: true);
            },
            icon: const Icon(Icons.gpp_bad, color: Colors.white, size: 16),
            label: const Text("Riski Raporla", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // 🚀 FİREBASE ATOMİK KAYIT (WRITE BATCH) & DNA SKORU DÜŞÜRME MOTORU
  Future<void> _protokoluTamamla() async {
    bool hepsiDolu = _kontrolListesi.values.every((durum) => durum != 0);
    if (!hepsiDolu) {
      _showSnackBar("Tüm parçaların kontrol edilmesi zorunludur!", isError: true);
      return;
    }

    if (_aracData == null || _currentUser == null) return;

    setState(() => _isSaving = true);

    try {
      String saseID = _saseController.text.trim().toUpperCase();
      int mevcutDnaSkoru = _aracData!['dna_skoru'] ?? 100;
      int cezaPuani = 0;

      // 🧠 KUANTUM HESAPLAMA: Kırmızı X sayısına göre puan düşür!
      _kontrolListesi.forEach((parca, durum) {
        if (durum == 2) {
          cezaPuani += 10; // Her kusur 10 puan düşürür
        }
      });

      int yeniDnaSkoru = mevcutDnaSkoru - cezaPuani;
      if (yeniDnaSkoru < 0) yeniDnaSkoru = 0; // Skor eksiye düşemez
      String yeniDurum = cezaPuani > 0 ? "🔴 RİSKLİ/KUSURLU" : "🟢 OTODNA ONAYLIDIR";

      // ATOMİK İŞLEM BAŞLIYOR (WriteBatch)
      WriteBatch batch = _db.batch();

      // 1. İşlem: Aracın DNA Skorunu Güncelle (`vehicles`)
      DocumentReference aracRef = _db.collection('vehicles').doc(saseID);
      batch.update(aracRef, {
        'dna_skoru': yeniDnaSkoru,
        'muayene_durumu': yeniDurum,
        'son_muayene_zaman_damgasi': FieldValue.serverTimestamp(),
      });

      // 2. İşlem: Ekspertiz Raporunu Kuantum Ağına Mühürle (`service_records`)
      String islemId = "EXP-${DateTime.now().millisecondsSinceEpoch}";
      DocumentReference raporRef = _db.collection('service_records').doc(islemId);
      batch.set(raporRef, {
        'sase_no': saseID,
        'bayi_id': _currentUser!.uid,
        'islem_adi': "Siber Ekspertiz & Genel Kontrol",
        'durum': "TAMAMLANDI",
        'kontrol_listesi': _kontrolListesi, // Hangi parçaya ne verildiği listesi
        'onceki_dna_skoru': mevcutDnaSkoru,
        'yeni_dna_skoru': yeniDnaSkoru,
        'olusturulma_zaman_damgasi': FieldValue.serverTimestamp(),
      });

      // 3. İşlem: Siber İstihbarat Radarına Mühürle!
      DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'BAYI_EKSPERTIZ_GIRIS',
        'seviye': cezaPuani > 0 ? 'KRİTİK' : 'BİLGİ',
        'islem_detayi': cezaPuani > 0 
            ? 'RİSKLİ ARAÇ! $saseID şaseli araç ekspertizde kusurlu bulundu. (DNA Skoru $mevcutDnaSkoru -> $yeniDnaSkoru)'
            : 'KUSURSUZ RAPOR: $saseID şaseli araç ekspertizden başarıyla geçti.',
        'vaka_id': saseID,
        'kullanici_id': _currentUser!.uid,
        'tarih': FieldValue.serverTimestamp(),
      });

      // ZIRHLARI ATEŞLE!
      await batch.commit();

      if (mounted) {
        _showSnackBar(cezaPuani > 0
            ? "Rapor İletildi! Araç Kusurlu Bulundu (DNA -$cezaPuani). 🛡️"
            : "Kusursuz Rapor! Dijital İmzanız Ağa İşlendi. ✅");

        Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));
      }

    } catch (e) {
      _showSnackBar("Mühürleme Hatası: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🛡️ TAAHÜT ETTİĞİMİZ SİBER ZIRH EKLENDİ
    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Zırh zaten siyah
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: const Text("Usta Veri Terminali", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, letterSpacing: 2)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SORGULAMA EKRANI
              const Text("Araç Tanımlama", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _saseController,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                      decoration: InputDecoration(
                        hintText: "ŞASE VEYA QR (VIN)",
                        hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 0),
                        filled: true, fillColor: SiberTema.matGrey,
                        prefixIcon: const Icon(Icons.qr_code_scanner, color: SiberTema.kuantumCyan),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: SiberTema.kuantumCyan, width: 2)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _isSearching ? null : _sorgula,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: SiberTema.kuantumCyan, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.3), blurRadius: 10, spreadRadius: 1)]),
                      child: _isSearching
                          ? const SizedBox(height: 28, width: 28, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 3))
                          : const Icon(Icons.radar, color: SiberTema.oledBlack, size: 28),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),

              // 2. ARAÇ BULUNDUYSA KONTROL LİSTESİNİ GÖSTER
              if (_aracSorgulandi && _aracData != null) ...[
                // CANLI ARAÇ BİLGİ KARTI
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5))),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car, color: SiberTema.kuantumCyan, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_aracData!['plaka'] ?? 'GİZLİ PLAKA', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                            const SizedBox(height: 4),
                            Text(_aracData!['marka_model'] ?? "Bilinmeyen Kasa", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text("Güncel DNA: ${_aracData!['dna_skoru'] ?? 100} / 100", style: const TextStyle(color: SiberTema.altinSari, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)), child: const Text("OtoDNA\nEkspertiz", textAlign: TextAlign.center, style: TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // DİJİTAL REFERANS PROTOKOLÜ (LİSTE)
                const Text("Dijital Referans Protokolü", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Aşağıdaki donanımları kontrol edin. 'Kırmızı X' aracın DNA Skorunu düşürür.", style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 16),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _kontrolListesi.keys.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    String parca = _kontrolListesi.keys.elementAt(index);
                    int durum = _kontrolListesi[parca]!;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: durum == 0 ? SiberTema.matGrey : durum == 1 ? Colors.green.withOpacity(0.1) : SiberTema.kanKirmizi.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: durum == 0 ? Colors.white12 : durum == 1 ? Colors.green : SiberTema.kanKirmizi),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(parca, style: TextStyle(color: durum == 0 ? Colors.white : durum == 1 ? Colors.green : SiberTema.kanKirmizi, fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                          // KIRMIZI X BUTONU
                          GestureDetector(
                            onTap: () => _retVer(parca),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: durum == 2 ? SiberTema.kanKirmizi : SiberTema.oledBlack, shape: BoxShape.circle, border: Border.all(color: SiberTema.kanKirmizi)),
                              child: Icon(Icons.close, color: durum == 2 ? Colors.white : SiberTema.kanKirmizi, size: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // YEŞİL TIK BUTONU
                          GestureDetector(
                            onTap: () => _onayVer(parca),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: durum == 1 ? Colors.green : SiberTema.oledBlack, shape: BoxShape.circle, border: Border.all(color: Colors.green)),
                              child: Icon(Icons.check, color: durum == 1 ? Colors.white : Colors.green, size: 20),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // DİJİTAL İMZA VE KAYDET BUTONU
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    style: SiberTema.kuantumButonStili(),
                    onPressed: _isSaving ? null : _protokoluTamamla,
                    icon: _isSaving ? const SizedBox() : const Icon(Icons.fingerprint, color: SiberTema.oledBlack, size: 24),
                    label: _isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 2))
                        : const Text("Dijital İmzam ile Ağa Kaydet", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5)),
                  ),
                ),
                const SizedBox(height: 40),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
// ── DOSYA SONU MÜHRÜ ──