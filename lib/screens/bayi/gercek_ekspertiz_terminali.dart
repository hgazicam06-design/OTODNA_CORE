import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🚨 KİMLİK MÜHRÜ İÇİN EKLENDİ

// 🚀 KARARGAH ZIRHLARI VE TEMA
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class GercekEkspertizTerminali extends StatefulWidget {
  // Bu ekrana gelirken, hangi araca ekspertiz yapacağımızı bilmemiz lazım
  final String plakaID;

  GercekEkspertizTerminali({super.key, required this.plakaID});

  @override
  State<GercekEkspertizTerminali> createState() => _GercekEkspertizTerminaliState();
}

class _GercekEkspertizTerminaliState extends State<GercekEkspertizTerminali> {
  // TRAMER BİLGİSİ
  final _tramerController = TextEditingController();
  final _ekspertizNotuController = TextEditingController();

  // KAPORTA & BOYA DURUMLARI (Gerçek Veri Haritası)
  // Varsayılan olarak hepsi "Orijinal"
  final Map<String, String> _kaportaDurumu = {
    "Kaput": "Orijinal",
    "Tavan": "Orijinal",
    "Bagaj": "Orijinal",
    "Sol Ön Çamurluk": "Orijinal",
    "Sol Ön Kapı": "Orijinal",
    "Sol Arka Kapı": "Orijinal",
    "Sol Arka Çamurluk": "Orijinal",
    "Sağ Ön Çamurluk": "Orijinal",
    "Sağ Ön Kapı": "Orijinal",
    "Sağ Arka Kapı": "Orijinal",
    "Sağ Arka Çamurluk": "Orijinal",
  };

  final List<String> _durumSecenekleri = ["Orijinal", "Boyalı", "Lokal Boyalı", "Değişen"];
  bool _isSaving = false;

  // 🔥 FİREBASE'E GERÇEK EKSPERTİZ ATOMİK GÜNCELLEMESİ (BATCH) YAPAN MOTOR 🔥
  Future<void> _ekspertiziKuantumAgaIsle() async {
    setState(() => _isSaving = true);
    FocusScope.of(context).unfocus();

    try {
      final firestore = FirebaseFirestore.instance;
      String ustaId = FirebaseAuth.instance.currentUser?.uid ?? "Bilinmeyen Usta";

      // 1. Aracın mevcut durumunu Kuantum Radarından çek! (vehicles)
      DocumentReference aracRef = firestore.collection('vehicles').doc(widget.plakaID);
      DocumentSnapshot aracDoc = await aracRef.get();

      if (!aracDoc.exists) {
        throw Exception("Siber Hata: Bu plaka sistemde kayıtlı değil!");
      }

      // 2. Mevcut DNA Skorunu bul (Mekanikten düşmüş olabilir, üstüne yazamayız!)
      var aracVerisi = aracDoc.data() as Map<String, dynamic>;
      int mevcutDna = aracVerisi['dna_skoru'] ?? 100;

      // 3. Kaportadan yediği CEZA PUANINI hesapla
      int cezaPuani = _cezaPuaniHesapla();
      int yeniDnaSkoru = mevcutDna - cezaPuani;
      if (yeniDnaSkoru < 0) yeniDnaSkoru = 0; // Skor sıfırın altına düşemez

      // 4. ATOMİK İŞLEM: Hem aracı güncelle hem de Raporlar Tablosuna Mühür Vur!
      WriteBatch batch = firestore.batch();

      // Aracı Güncelle
      batch.update(aracRef, {
        "kaporta_ekspertiz": _kaportaDurumu,
        "tramer_kaydi": double.tryParse(_tramerController.text.trim()) ?? 0.0,
        "kaporta_usta_notu": _ekspertizNotuController.text.trim(),
        "son_kaporta_ekspertiz_tarihi": FieldValue.serverTimestamp(),
        "kaporta_ekspertizi_yapan_bayi": ustaId, // 🛡️ HESAP VEREBİLİRLİK MÜHRÜ
        "dna_skoru": yeniDnaSkoru,
      });

      // Resmi Ekspertiz Raporunu Kasaya İşle (service_records)
      DocumentReference raporRef = firestore.collection('service_records').doc();
      batch.set(raporRef, {
        "sase_no": widget.plakaID, // Sistemde plakaID şase olarak kullanılıyor olabilir
        "islem_adi": "Kaporta & Boya Ekspertizi",
        "durum": "TAMAMLANDI",
        "kontrol_listesi": _kaportaDurumu,
        "tramer": double.tryParse(_tramerController.text.trim()) ?? 0.0,
        "usta_notu": _ekspertizNotuController.text.trim(),
        "kesilen_ceza_puani": cezaPuani,
        "onceki_dna_skoru": mevcutDna,
        "yeni_dna_skoru": yeniDnaSkoru,
        "bayi_id": ustaId,
        "olusturulma_zaman_damgasi": FieldValue.serverTimestamp(),
      });

      // 5. Siber İstihbarat Radarına Mühürle!
      DocumentReference logRef = firestore.collection('siber_istihbarat_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'EKSPERTİZ',
        'seviye': cezaPuani > 0 ? 'KRİTİK' : 'BİLGİ',
        'islem_detayi': cezaPuani > 0 
            ? 'RİSKLİ ARAÇ! ${widget.plakaID} aracı kaporta ekspertizinde kusurlu bulundu. (Ceza: $cezaPuani)'
            : 'KUSURSUZ RAPOR: ${widget.plakaID} aracı kaporta ekspertizinden hatasız geçti.',
        'vaka_id': widget.plakaID,
        'tarih': FieldValue.serverTimestamp(),
      });

      // FÜZEYİ ATEŞLE
      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OtoDNA: Dijital Ekspertiz Başarıyla Mühürlendi! 🦅", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.bold)), backgroundColor: SiberTema.kuantumCyan));
      Navigator.pop(context); // İşlem bitince ekranı kapat

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ağ Güncelleme Hatası: $e"), backgroundColor: Colors.redAccent));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Sadece kesilecek ceza puanını hesaplayan motor
  int _cezaPuaniHesapla() {
    int ceza = 0;
    _kaportaDurumu.forEach((parca, durum) {
      if (durum == "Boyalı") ceza += 2;
      if (durum == "Lokal Boyalı") ceza += 1;
      if (durum == "Değişen") ceza += 5;
    });
    return ceza;
  }

  // Kaporta parçasının durumunu değiştiren dialog
  void _durumDegistir(String parca) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SiberTema.matGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("$parca Durumu", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              ..._durumSecenekleri.map((durum) => ListTile(
                title: Text(durum, style: TextStyle(color: durum == "Değişen" ? Colors.redAccent : (durum.contains("Boya") ? Colors.orangeAccent : Colors.white))),
                trailing: _kaportaDurumu[parca] == durum ? Icon(Icons.check_circle, color: SiberTema.kuantumCyan) : null,
                onTap: () {
                  setState(() => _kaportaDurumu[parca] = durum);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tramerController.dispose();
    _ekspertizNotuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: Text("${widget.plakaID} Ekspertiz Girişi", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 16)),
          centerTitle: true,
        ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TRAMER VE USTA NOTU
            Text("1. Tramer ve Genel Durum", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildInput("Tramer Hasar Kaydı (₺)", _tramerController, isNumber: true, icon: Icons.money_off),
            _buildInput("Ekspertiz / Usta Notu (Örn: Şasede işlem yok, motor %90)", _ekspertizNotuController, isMultiLine: true, icon: Icons.handyman),

            Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: SiberTema.textMuted)),

            // 2. KAPORTA BOYA SEÇİMİ (DİNAMİK LİSTE)
            Text("2. Dijital Kaporta Analizi", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),

            // GÖRSEL ARAÇ EKSPERTİZİ (SAHİBİNDEN STYLE)
            _buildSahibindenKusbakisiArac(),
            
            SizedBox(height: 16),
            // RENK AÇIKLAMALARI (LEGEND)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.white, "Orijinal"),
                SizedBox(width: 16),
                _buildLegendItem(Colors.amber, "Boyalı"),
                SizedBox(width: 16),
                _buildLegendItem(Colors.redAccent, "Değişen"),
              ],
            ),

            SizedBox(height: 32),

            // FİREBASE'E KAYDET BUTONU
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kuantumCyan, padding: EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: _isSaving ? null : _ekspertiziKuantumAgaIsle,
                icon: _isSaving ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 2)) : Icon(Icons.verified, color: SiberTema.oledBlack),
                label: Text(_isSaving ? "AĞA MÜHÜRLENİYOR..." : "EKSPERTİZİ ONAYLA VE KAYDET", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController controller, {bool isNumber = false, bool isMultiLine = false, required IconData icon}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.textMuted)),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : (isMultiLine ? TextInputType.multiline : TextInputType.text),
        maxLines: isMultiLine ? 3 : 1,
        style: TextStyle(color: SiberTema.textMain),
        decoration: InputDecoration(
            icon: Icon(icon, color: SiberTema.kuantumCyan, size: 20),
            hintText: hint,
            hintStyle: TextStyle(color: SiberTema.textMuted, fontSize: 13),
            border: InputBorder.none
        ),
      ),
    );
  }

  // YARDIMCI GÖRSEL WIDGET: Sahibinden Tarzı Kuşbakışı Araç
  Widget _buildSahibindenKusbakisiArac() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      decoration: BoxDecoration(
        color: SiberTema.matGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiberTema.textMuted),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // SOL KISIM
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCarPart("Sol Ön Çamurluk", width: 85, height: 75),
              _buildCarPart("Sol Ön Kapı", width: 85, height: 75),
              _buildCarPart("Sol Arka Kapı", width: 85, height: 75),
              _buildCarPart("Sol Arka Çamurluk", width: 85, height: 75),
            ],
          ),
          SizedBox(width: 8),
          // ORTA KISIM
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCarPart("Kaput", width: 100, height: 85),
              _buildCarPart("Tavan", width: 100, height: 130), // Tavan daha uzun
              _buildCarPart("Bagaj", width: 100, height: 85),
            ],
          ),
          SizedBox(width: 8),
          // SAĞ KISIM
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCarPart("Sağ Ön Çamurluk", width: 85, height: 75),
              _buildCarPart("Sağ Ön Kapı", width: 85, height: 75),
              _buildCarPart("Sağ Arka Kapı", width: 85, height: 75),
              _buildCarPart("Sağ Arka Çamurluk", width: 85, height: 75),
            ],
          ),
        ],
      ),
    );
  }

  // YARDIMCI GÖRSEL WIDGET: Araç Parçası Butonu
  Widget _buildCarPart(String parca, {double width = 80, double height = 80}) {
    String durum = _kaportaDurumu[parca] ?? "Orijinal";
    Color durumRengi = durum == "Orijinal" ? Colors.white : (durum == "Değişen" ? Colors.redAccent : Colors.amber);

    return GestureDetector(
      onTap: () => _durumDegistir(parca),
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: durumRengi.withOpacity(0.15),
          border: Border.all(color: durumRengi, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            parca.replaceAll(" ", "\n"),
            textAlign: TextAlign.center,
            style: TextStyle(color: durumRengi, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ),
      ),
    );
  }

  // YARDIMCI GÖRSEL WIDGET: Renk Açıklaması
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)])),
        SizedBox(width: 6),
        Text(label, style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}