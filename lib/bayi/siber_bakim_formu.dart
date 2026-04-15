// lib/bayi/siber_bakim_formu.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class SiberBakimFormu extends StatefulWidget {
  final String saseNo;
  final String plaka;

  const SiberBakimFormu({super.key, required this.saseNo, required this.plaka});

  @override
  State<SiberBakimFormu> createState() => _SiberBakimFormuState();
}

class _SiberBakimFormuState extends State<SiberBakimFormu> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _bayiId = FirebaseAuth.instance.currentUser?.uid ?? "BILINMEYEN_BAYI";

  String _secilenBakimTipi = "10.000 KM BAKIMI";
  final List<Map<String, dynamic>> _eklenenParcalar = [];
  double _iscilikUcreti = 0;

  // 🧠 BAKIM PROTOKOLLERİ
  final Map<String, List<String>> _bakimProtokolleri = {
    "10.000 KM BAKIMI": ["Motor Yağı", "Yağ Filtresi", "Hava Filtresi", "Genel Kontrol"],
    "50.000 KM BAKIMI": ["Motor Yağı", "Yağ Filtresi", "Hava Filtresi", "Polen Filtresi", "Fren Hidroliği", "Bujiler", "Yakıt Filtresi"],
    "GENEL ARIZA / ONARIM": [],
  };

  @override
  Widget build(BuildContext context) {
    double toplamParca = _eklenenParcalar.fold(0, (sum, item) => sum + item['fiyat']);
    double genelToplam = toplamParca + _iscilikUcreti;

    // ⚖️ KARARGAH FİNANS KURALI (%12 Kesinti Uygulanmış Vitrin Hesaplaması)
    double vitrinFiyati = genelToplam / 0.88;
    double gaziPayi = vitrinFiyati * 0.12;

    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("${widget.plaka} - SERVİS KAYDI", style: const TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 13)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildBakimTipiSecici(),
                  const SizedBox(height: 24),
                  _buildParcaEklemeBolumu(),
                  const SizedBox(height: 24),
                  _buildIscilikInput(),
                ],
              ),
            ),
            _buildFinansalAltPanel(genelToplam, vitrinFiyati, gaziPayi),
          ],
        ),
      ),
    );
  }

  Widget _buildBakimTipiSecici() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: SiberTema.siberCamZirh(renk: SiberTema.matGrey),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("BAKIM PROTOKOLÜ SEÇİN", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            dropdownColor: SiberTema.matGrey,
            value: _secilenBakimTipi,
            style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10))),
            items: _bakimProtokolleri.keys.map((String key) {
              return DropdownMenuItem(value: key, child: Text(key));
            }).toList(),
            onChanged: (val) => setState(() => _secilenBakimTipi = val!),
          ),
        ],
      ),
    );
  }

  Widget _buildParcaEklemeBolumu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("KULLANILAN PARÇALAR", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._eklenenParcalar.map((p) => ListTile(
          title: Text(p['ad'], style: const TextStyle(color: Colors.white, fontSize: 13)),
          trailing: Text("₺${p['fiyat']}", style: const TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold)),
        )),
        TextButton.icon(
          onPressed: () => _parcaEkleDialog(),
          icon: const Icon(Icons.add_circle_outline, size: 16, color: SiberTema.kuantumCyan),
          label: const Text("YEDEK PARÇA EKLE", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 11)),
        ),
      ],
    );
  }

  Widget _buildIscilikInput() {
    return TextField(
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        labelText: "İŞÇİLİK ÜCRETİ (₺)",
        labelStyle: TextStyle(color: Colors.white38, fontSize: 12),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: SiberTema.kuantumCyan)),
      ),
      onChanged: (val) => setState(() => _iscilikUcreti = double.tryParse(val) ?? 0),
    );
  }

  Widget _buildFinansalAltPanel(double net, double vitrin, double pay) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: SiberTema.matGrey, border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("KARARGAH PAYI (%12):", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 10, fontWeight: FontWeight.bold)),
              Text("₺${pay.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kanKirmizi, fontSize: 12, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: SiberTema.kuantumButonStili(),
              onPressed: () => _servisKaydiMuhurle(vitrin, pay),
              child: Text("İŞLEMİ MÜHÜRLE (₺${vitrin.toStringAsFixed(2)})", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  // 🚀 ATOMİK SERVİS KAYDI (WRITEBATCH)
  Future<void> _servisKaydiMuhurle(double vitrin, double pay) async {
    WriteBatch batch = _db.batch();
    DocumentReference servisRef = _db.collection('servis_kayitlari').doc();

    batch.set(servisRef, {
      'sase_no': widget.saseNo,
      'bayi_id': _bayiId,
      'bakim_tipi': _secilenBakimTipi,
      'parcalar': _eklenenParcalar,
      'iscilik': _iscilikUcreti,
      'toplam_tutar': vitrin,
      'karargah_kesintisi': pay,
      'tarih': FieldValue.serverTimestamp(),
      'durum': 'TAMAMLANDI',
    });

    // Kara Kutu Logu
    DocumentReference logRef = _db.collection('sistem_loglari').doc();
    batch.set(logRef, {
      'islem_turu': 'SERVIS_MUHURU',
      'islem_detayi': 'SİBER BAKIM: ${widget.plaka} için $_secilenBakimTipi mühürlendi. Tutar: ₺$vitrin',
      'tarih': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    if (mounted) Navigator.pop(context);
  }

  void _parcaEkleDialog() {
    // Parça ekleme modalı burada açılacak...
  }
}