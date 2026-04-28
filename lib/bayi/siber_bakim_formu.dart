import 'package:otodna/core/siber_tema.dart';
// lib/bayi/siber_bakim_formu.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

// ⚙️ EKOSİSTEM MOTORU
import '../commerce/eco_system_gate.dart';

class SiberBakimFormu extends StatefulWidget {
  final String saseNo;
  final String plaka;

  SiberBakimFormu({super.key, required this.saseNo, required this.plaka});

  @override
  State<SiberBakimFormu> createState() => _SiberBakimFormuState();
}

class _SiberBakimFormuState extends State<SiberBakimFormu> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _bayiId = FirebaseAuth.instance.currentUser?.uid ?? "BILINMEYEN_BAYI";

  String _secilenBakimTipi = "10.000 KM BAKIMI";
  final List<Map<String, dynamic>> _eklenenParcalar = [];
  double _iscilikUcreti = 0.0;
  bool _isProcessing = false;

  // 🧠 BAKIM PROTOKOLLERİ
  final Map<String, List<String>> _bakimProtokolleri = {
    "10.000 KM BAKIMI": ["Motor Yağı", "Yağ Filtresi", "Hava Filtresi", "Genel Kontrol"],
    "50.000 KM BAKIMI": ["Motor Yağı", "Yağ Filtresi", "Hava Filtresi", "Polen Filtresi", "Fren Hidroliği", "Bujiler", "Yakıt Filtresi"],
    "GENEL ARIZA / ONARIM": [],
  };

  @override
  Widget build(BuildContext context) {
    double toplamParcaNet = _eklenenParcalar.fold(0.0, (sum, item) => sum + (item['fiyat'] as double));

    // ⚖️ KARARGAH FİNANS KURALI (SADECE PARÇADAN %12 KESİNTİ, İŞÇİLİK %100 BAYİNİN)
    double vitrinParcaFiyati = toplamParcaNet > 0 ? (toplamParcaNet / 0.88) : 0.0;
    double gaziPayi = vitrinParcaFiyati * 0.12;
    double genelToplamVitrin = vitrinParcaFiyati + _iscilikUcreti;

    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("${widget.plaka} - SERVİS KAYDI", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Avenir', letterSpacing: 1.5)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(20),
                children: [
                  _buildBakimTipiSecici(),
                  SizedBox(height: 24),
                  _buildParcaEklemeBolumu(),
                  SizedBox(height: 24),
                  _buildIscilikInput(),
                ],
              ),
            ),
            _buildFinansalAltPanel(genelToplamVitrin, gaziPayi, vitrinParcaFiyati),
          ],
        ),
      ),
    );
  }

  Widget _buildBakimTipiSecici() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: SiberTema.siberCamZirh(renk: SiberTema.matGrey),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("BAKIM PROTOKOLÜ SEÇİN", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir', letterSpacing: 1)),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            dropdownColor: SiberTema.matGrey,
            value: _secilenBakimTipi,
            icon: Icon(Icons.keyboard_arrow_down, color: SiberTema.kuantumCyan),
            style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: SiberTema.kuantumCyan)),
            ),
            items: _bakimProtokolleri.keys.map((String key) {
              return DropdownMenuItem(value: key, child: Text(key, style: TextStyle(fontFamily: 'Avenir')));
            }).toList(),
            onChanged: (val) {
              setState(() {
                _secilenBakimTipi = val!;
                _eklenenParcalar.clear(); // Tip değişince sepeti temizle
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildParcaEklemeBolumu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("KULLANILAN PARÇALAR (Maliyet Fiyatı)", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir', letterSpacing: 1)),
        SizedBox(height: 12),
        ..._eklenenParcalar.map((p) => Container(
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(p['ad'], style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Avenir', fontWeight: FontWeight.bold)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("₺${(p['fiyat'] as double).toStringAsFixed(2)}", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontFamily: 'monospace', fontSize: 14)),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.remove_circle_outline, color: SiberTema.kritikRed, size: 20),
                  onPressed: () => setState(() => _eklenenParcalar.remove(p)),
                )
              ],
            ),
          ),
        )),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _parcaEkleDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: SiberTema.kuantumCyan,
                  side: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                icon: Icon(Icons.add_circle_outline, size: 18),
                label: Text("PARÇA EKLE", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, fontFamily: 'Avenir', letterSpacing: 1)),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _parcaTeklifiDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SiberTema.altinSari.withOpacity(0.2),
                  foregroundColor: SiberTema.altinSari,
                  side: BorderSide(color: SiberTema.altinSari.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                icon: Icon(Icons.send_outlined, size: 18),
                label: Text("TEKLİF GÖNDER", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, fontFamily: 'Avenir', letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIscilikInput() {
    return Container(
      decoration: BoxDecoration(
        color: SiberTema.oledBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        keyboardType: TextInputType.number,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'monospace'),
        decoration: InputDecoration(
          labelText: "SAF İŞÇİLİK ÜCRETİ (₺) - %100 SİZİN",
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontFamily: 'Avenir', fontWeight: FontWeight.bold, letterSpacing: 1),
          prefixIcon: Icon(Icons.build_circle_outlined, color: Colors.white54),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(20),
        ),
        onChanged: (val) => setState(() => _iscilikUcreti = double.tryParse(val.replaceAll(',', '.')) ?? 0.0),
      ),
    );
  }

  Widget _buildFinansalAltPanel(double vitrinToplam, double pay, double vitrinParca) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SiberTema.matGrey,
        border: Border(top: BorderSide(color: Colors.white12)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 20, offset: Offset(0, -5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("KARARGAH PAYI (%12 PARÇADAN):", style: TextStyle(color: SiberTema.kritikRed, fontSize: 10, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 1)),
              Text("₺${pay.toStringAsFixed(2)}", style: TextStyle(color: SiberTema.kritikRed, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              style: SiberTema.kuantumButonStili(),
              onPressed: _isProcessing ? null : () => _servisKaydiMuhurle(vitrinToplam, pay, vitrinParca),
              icon: _isProcessing
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : Icon(Icons.fingerprint, color: Colors.black, size: 24),
              label: Text(
                  _isProcessing ? "MÜHÜRLENİYOR..." : "İŞLEMİ MÜHÜRLE (₺${vitrinToplam.toStringAsFixed(2)})",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, fontFamily: 'Avenir', letterSpacing: 1.5)
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🚀 ATOMİK SERVİS KAYDI (WRITEBATCH)
  Future<void> _servisKaydiMuhurle(double vitrinToplam, double pay, double vitrinParca) async {
    if (_isProcessing) return; // 🔒 DOUBLE SPEND KORUMASI (Siber Kilit)
    
    if (_eklenenParcalar.isEmpty && _iscilikUcreti <= 0) {
      _siberUyariGoster("SİBER İHLAL: Parça veya İşçilik girmeden mühür vurulamaz!", true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      WriteBatch batch = _db.batch();
      DocumentReference servisRef = _db.collection('servis_kayitlari').doc();

      batch.set(servisRef, {
        'sase_no': widget.saseNo,
        'plaka': widget.plaka,
        'bayi_id': _bayiId,
        'bakim_tipi': _secilenBakimTipi,
        'parcalar': _eklenenParcalar,
        'iscilik_tutari': _iscilikUcreti,
        'parca_satis_tutari': vitrinParca,
        'toplam_tutar': vitrinToplam,
        'karargah_kesintisi': pay,
        'tarih': FieldValue.serverTimestamp(),
        'durum': 'TAMAMLANDI',
      });

      // Kara Kutu Logu
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'SERVIS_MUHURU',
        'islem_detayi': 'SİBER BAKIM: ${widget.plaka} için $_secilenBakimTipi mühürlendi. Toplam: ₺${vitrinToplam.toStringAsFixed(2)}, Karargah Payı: ₺${pay.toStringAsFixed(2)}',
        'bayi_id': _bayiId,
        'tarih': FieldValue.serverTimestamp(),
      });

      // Araç DNA Skorunu Güncelle
      DocumentReference aracRef = _db.collection('araclar').doc(widget.saseNo.toUpperCase());
      batch.set(aracRef, {
        'dna_skoru': FieldValue.increment(2), // Düzenli bakım DNA skorunu artırır
        'son_bakim_tarihi': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // 🔥 SET MERGE ZIRHI (Diğer veriler ezilmez)

      // Gelir Havuzuna At
      DocumentReference finansRef = _db.collection('otodna_gelir_havuzu').doc(); // finans_havuzu yerine standart otodna_gelir_havuzu
      batch.set(finansRef, {
        'bayi_id': _bayiId,
        'plaka': widget.plaka,
        'iscilik_tutari': _iscilikUcreti,
        'parca_satis_tutari': vitrinParca,
        'karargah_kesintisi': pay,
        'durum': 'TAMAMLANDI',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      developer.log("✅ ONAY: Servis işlemi Karargaha atomik olarak mühürlendi.");

      if (!mounted) return;
      _siberUyariGoster("SİBER MÜHÜR BASILDI!", false);
      Navigator.pop(context);

    } catch (e) {
      developer.log("🚨 AĞ ÇÖKTÜ: $e");
      if (!mounted) return;
      _siberUyariGoster("SİSTEM HATASI: İşlem mühürlenemedi!", true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _siberUyariGoster(String mesaj, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir', fontSize: 12)),
        backgroundColor: isError ? SiberTema.kritikRed : SiberTema.kuantumCyan.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 🔥 MAKET YOK! GERÇEK ÇALIŞAN PARÇA EKLEME DİYALOĞU
  void _parcaEkleDialog() {
    final TextEditingController adCtrl = TextEditingController();
    final TextEditingController fiyatCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: SiberTema.siberCamZirh(renk: SiberTema.matGrey),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings_input_component, color: SiberTema.kuantumCyan, size: 40),
                SizedBox(height: 16),
                Text("YENİ PARÇA EKLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, fontFamily: 'Avenir', letterSpacing: 1.5)),
                SizedBox(height: 24),

                // Parça Adı
                TextField(
                  controller: adCtrl,
                  style: TextStyle(color: Colors.white, fontFamily: 'Avenir'),
                  decoration: InputDecoration(
                    labelText: "Parça Adı",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontFamily: 'Avenir'),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SiberTema.kuantumCyan)),
                    filled: true,
                    fillColor: Colors.black,
                  ),
                ),
                SizedBox(height: 16),

                // Maliyet
                TextField(
                  controller: fiyatCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    labelText: "Maliyet Fiyatı (₺)",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontFamily: 'Avenir'),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SiberTema.kuantumCyan)),
                    filled: true,
                    fillColor: Colors.black,
                  ),
                ),
                SizedBox(height: 32),

                // Butonlar
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("İPTAL", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: SiberTema.kuantumButonStili(),
                        onPressed: () {
                          if (adCtrl.text.trim().isNotEmpty && fiyatCtrl.text.trim().isNotEmpty) {
                            double f = double.tryParse(fiyatCtrl.text.replaceAll(',', '.')) ?? 0.0;
                            setState(() {
                              _eklenenParcalar.add({
                                'ad': adCtrl.text.trim().toUpperCase(),
                                'fiyat': f,
                              });
                            });
                            Navigator.pop(context);
                          }
                        },
                        child: Text("EKLE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // 🛡️ EKOSİSTEM: PARÇA TEKLİFİ GÖNDERME DİYALOĞU
  void _parcaTeklifiDialog() {
    final TextEditingController adCtrl = TextEditingController();
    final TextEditingController fiyatCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: SiberTema.siberCamZirh(renk: SiberTema.matGrey),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.handshake_outlined, color: SiberTema.altinSari, size: 40),
                SizedBox(height: 16),
                Text("ARAÇ SAHİBİNE TEKLİF SUN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Avenir', letterSpacing: 1)),
                SizedBox(height: 8),
                Text("Parça fiyatına %12 Karargah Payı yansıtılarak araç sahibine iletilecektir.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 11)),
                SizedBox(height: 24),

                TextField(
                  controller: adCtrl,
                  style: TextStyle(color: Colors.white, fontFamily: 'Avenir'),
                  decoration: InputDecoration(
                    labelText: "Önerilen Parça",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontFamily: 'Avenir'),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SiberTema.altinSari)),
                    filled: true,
                    fillColor: Colors.black,
                  ),
                ),
                SizedBox(height: 16),

                TextField(
                  controller: fiyatCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: SiberTema.altinSari, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    labelText: "Satış Fiyatı (₺)",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontFamily: 'Avenir'),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SiberTema.altinSari)),
                    filled: true,
                    fillColor: Colors.black,
                  ),
                ),
                SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("İPTAL", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SiberTema.altinSari,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          if (adCtrl.text.trim().isNotEmpty && fiyatCtrl.text.trim().isNotEmpty) {
                            double f = double.tryParse(fiyatCtrl.text.replaceAll(',', '.')) ?? 0.0;
                            Navigator.pop(context); // Dialog kapat
                            
                            // Ekosistem Motorunu Tetikle
                            await OtoDnaEcoSystem().parcaOner(
                              plakaID: widget.saseNo, // Şase üzerinden bağlanıyor
                              sorunluParca: adCtrl.text.trim().toUpperCase(),
                              parcaSatisFiyati: f,
                              saticiBayiAdi: _bayiId, // Normalde Auth displayName çekilir
                            );
                            
                            if (mounted) _siberUyariGoster("SİBER TİCARET: Teklif Mühürlendi!", false);
                          }
                        },
                        child: Text("GÖNDER", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}