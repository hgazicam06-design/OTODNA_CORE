import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class MuayeneOnayEkrani extends ConsumerStatefulWidget {
  final String plakaID;
  final Map<String, int> islenenKontrolListesi; // 0: Bekliyor, 1: ✅, 2: ❌
  final int yeniDnaSkoru;

  const MuayeneOnayEkrani({
    super.key,
    required this.plakaID,
    required this.islenenKontrolListesi,
    required this.yeniDnaSkoru,
  });

  @override
  ConsumerState<MuayeneOnayEkrani> createState() => _MuayeneOnayEkraniState();
}

class _MuayeneOnayEkraniState extends ConsumerState<MuayeneOnayEkrani> with SingleTickerProviderStateMixin {
  final Color bgColor = SiberTema.oledBlack;
  final Color primaryCyan = SiberTema.kuantumCyan;
  final Color surfaceColor = SiberTema.matGrey;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sesli Asistan Durumları
  bool _isListening = false;
  bool _isSaving = false;
  String _aiMesaj = "Ustam, dinliyorum... 'Mühürle' demen yeterli.";
  late AnimationController _micAnimation;

  // Çevrilmiş Kontrol Listesi (int'ten bool'a görsel gösterim için)
  late Map<String, bool?> _gorselKontrolListesi;

  @override
  void initState() {
    super.initState();
    _micAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Gelen 0, 1, 2 verilerini arayüzün anlayacağı (null, true, false) formatına çevir
    _gorselKontrolListesi = {};
    widget.islenenKontrolListesi.forEach((key, value) {
      if (value == 1) _gorselKontrolListesi[key] = true;
      else if (value == 2) _gorselKontrolListesi[key] = false;
      else _gorselKontrolListesi[key] = null;
    });
  }

  @override
  void dispose() {
    _micAnimation.dispose();
    super.dispose();
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
    ));
  }

  // --- YAPAY ZEKA SESLİ ASİSTAN SİMÜLASYONU ---
  void _aiDinlemeyiBaslat() {
    setState(() {
      _isListening = true;
      _aiMesaj = "Seni dinliyorum ustam...";
    });

    // TODO: TTS (Text-To-Speech) ve STT paketleri eklendiğinde gerçek motor devreye girecek
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _aiSesiOynat("Ustam, kontrol verilerini aldım. Aracın yeni DNA skoru ${widget.yeniDnaSkoru} olacak. Mühürlüyor muyuz?");
    });
  }

  void _aiSesiOynat(String metin) {
    setState(() {
      _aiMesaj = metin;
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _aiMesaj = "Rapor mühürleniyor ustam, eline sağlık!";
      });
      _dijitalImzaIleKaydet();
    });
  }

  // 🔥 FİREBASE ATOMİK KAYIT MOTORU (DİJİTAL MÜHÜR) 🔥
  Future<void> _dijitalImzaIleKaydet() async {
    setState(() => _isSaving = true);

    try {
      String ustaId = FirebaseAuth.instance.currentUser?.uid ?? "Bilinmeyen Usta";

      WriteBatch batch = _db.batch();

      // 1. İşlem: Aracın DNA Skorunu ve Son Bakımını Güncelle
      DocumentReference aracRef = _db.collection('vehicles').doc(widget.plakaID);
      batch.update(aracRef, {
        'dna_skoru': widget.yeniDnaSkoru,
        'son_ekspertiz_tarihi': FieldValue.serverTimestamp(),
        'son_islem_yapan_bayi': ustaId,
      });

      // 2. İşlem: Resmi Ekspertiz/Muayene Raporunu Kuantum Ağına Mühürle
      DocumentReference raporRef = _db.collection('service_records').doc();
      batch.set(raporRef, {
        'plaka': widget.plakaID,
        'usta_id': ustaId,
        'kontrol_listesi': widget.islenenKontrolListesi, // 0, 1, 2 formatında saf veri
        'yeni_dna_skoru': widget.yeniDnaSkoru,
        'tarih': FieldValue.serverTimestamp(),
      });

      // 3. İşlem: Siber İstihbarat Logu
      DocumentReference logRef = _db.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'MUAYENE_ONAY_MUHURU',
        'seviye': 'BİLGİ',
        'islem_detayi': 'SİBER MUAYENE: ${widget.plakaID} plakalı araç için yeni DNA skoru (${widget.yeniDnaSkoru}) mühürlendi.',
        'vaka_id': widget.plakaID,
        'kullanici_id': ustaId,
        'tarih': FieldValue.serverTimestamp(),
      });

      // Füzeleri Ateşle
      await batch.commit();

      if (mounted) {
        _showSnackBar("Dijital Mühür Vuruldu! Araç Ağa İşlendi. ✅");
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            // İki ekran geriye (Ana Karargaha) dön
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        });
      }

    } catch (e) {
      _showSnackBar("Mühürleme Hatası: $e", isError: true);
      setState(() => _isSaving = false);
    }
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
        title: Column(
          children: [
            Text(
              'OTO REFERANS ONAYI',
              style: TextStyle(color: primaryCyan, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5),
            ),
            Text('Araç: ${widget.plakaID}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Kontrol Listesi Özeti (Salt Okunur - Değişiklik terminalde yapıldı)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _gorselKontrolListesi.length,
                itemBuilder: (context, index) {
                  String key = _gorselKontrolListesi.keys.elementAt(index);
                  bool? durum = _gorselKontrolListesi[key];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: durum == true ? Colors.greenAccent.withOpacity(0.5)
                            : durum == false ? Colors.redAccent.withOpacity(0.5)
                            : Colors.white12,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            key,
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                        // Onay Ekranı olduğu için butonlar pasif, sadece durum gösterilir
                        Icon(
                            durum == true ? Icons.check_circle : (durum == false ? Icons.cancel : Icons.hourglass_empty),
                            color: durum == true ? Colors.greenAccent : (durum == false ? Colors.redAccent : Colors.white24),
                            size: 30
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // AI ASİSTAN KONSOLU (Sanayinin Dijital Çırağı)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                border: const Border(top: BorderSide(color: Colors.white12)),
                boxShadow: [
                  BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
                ],
              ),
              child: Column(
                children: [
                  // AI Geri Bildirim Metni
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _aiMesaj,
                      key: ValueKey(_aiMesaj),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _isListening ? primaryCyan : Colors.white70, fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sesli Komut Mikrofonu veya Kaydediliyor İkonu
                  GestureDetector(
                    onTap: (_isListening || _isSaving) ? null : _aiDinlemeyiBaslat,
                    child: AnimatedBuilder(
                      animation: _micAnimation,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (_isListening || _isSaving) ? primaryCyan.withOpacity(0.2) : surfaceColor,
                            border: Border.all(
                              color: (_isListening || _isSaving) ? primaryCyan.withOpacity(0.5 + (_micAnimation.value * 0.5)) : Colors.white12,
                              width: (_isListening || _isSaving) ? 3 : 1,
                            ),
                            boxShadow: (_isListening || _isSaving) ? [
                              BoxShadow(color: primaryCyan.withOpacity(0.3), blurRadius: 20 * _micAnimation.value, spreadRadius: 5 * _micAnimation.value)
                            ] : [],
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(color: primaryCyan)
                              : Icon(
                            _isListening ? Icons.graphic_eq : Icons.mic,
                            color: _isListening ? primaryCyan : Colors.white54,
                            size: 36,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isSaving ? 'KUANTUM AĞINA İŞLENİYOR...' : (_isListening ? 'SESLİ KOMUT BEKLENİYOR...' : 'ASİSTANA SESLEN (VEYA DOKUN)'),
                    style: TextStyle(color: (_isListening || _isSaving) ? primaryCyan : Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}