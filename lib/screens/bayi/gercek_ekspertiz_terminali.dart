import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🚨 KİMLİK MÜHRÜ İÇİN EKLENDİ

class GercekEkspertizTerminali extends StatefulWidget {
  // Bu ekrana gelirken, hangi araca ekspertiz yapacağımızı bilmemiz lazım
  final String plakaID;

  const GercekEkspertizTerminali({super.key, required this.plakaID});

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

      // 1. Aracın mevcut durumunu Kuantum Radarından çek!
      DocumentReference aracRef = firestore.collection('araclar').doc(widget.plakaID);
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

      // Resmi Ekspertiz Raporunu Kasaya İşle
      DocumentReference raporRef = firestore.collection('ekspertiz_raporlari').doc();
      batch.set(raporRef, {
        "plaka": widget.plakaID,
        "rapor_tipi": "Kaporta & Boya",
        "kaporta_durumu": _kaportaDurumu,
        "tramer": double.tryParse(_tramerController.text.trim()) ?? 0.0,
        "usta_notu": _ekspertizNotuController.text.trim(),
        "kesilen_ceza_puani": cezaPuani,
        "yeni_dna_skoru": yeniDnaSkoru,
        "ekspertizi_yapan_bayi": ustaId,
        "tarih": FieldValue.serverTimestamp(),
      });

      // FÜZEYİ ATEŞLE
      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OtoDNA: Dijital Ekspertiz Başarıyla Mühürlendi! 🦅", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF00FFC2)));
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
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("$parca Durumu", style: const TextStyle(color: Color(0xFF00FFC2), fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ..._durumSecenekleri.map((durum) => ListTile(
                title: Text(durum, style: TextStyle(color: durum == "Değişen" ? Colors.redAccent : (durum.contains("Boya") ? Colors.orangeAccent : Colors.white))),
                trailing: _kaportaDurumu[parca] == durum ? const Icon(Icons.check_circle, color: Color(0xFF00FFC2)) : null,
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
    const primaryCyan = Color(0xFF00FFC2);
    const bgColor = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan), onPressed: () => Navigator.pop(context)),
        title: Text("${widget.plakaID} Ekspertiz Girişi", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TRAMER VE USTA NOTU
            const Text("1. Tramer ve Genel Durum", style: TextStyle(color: primaryCyan, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildInput("Tramer Hasar Kaydı (₺)", _tramerController, isNumber: true, icon: Icons.money_off),
            _buildInput("Ekspertiz / Usta Notu (Örn: Şasede işlem yok, motor %90)", _ekspertizNotuController, isMultiLine: true, icon: Icons.handyman),

            const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: Colors.white12)),

            // 2. KAPORTA BOYA SEÇİMİ (DİNAMİK LİSTE)
            const Text("2. Dijital Kaporta Analizi", style: TextStyle(color: primaryCyan, fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            ..._kaportaDurumu.keys.map((parca) {
              String durum = _kaportaDurumu[parca]!;
              Color durumRengi = durum == "Orijinal" ? Colors.green : (durum == "Değişen" ? Colors.redAccent : Colors.orangeAccent);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                child: ListTile(
                  title: Text(parca, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: durumRengi.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: durumRengi.withOpacity(0.5))),
                    child: Text(durum, style: TextStyle(color: durumRengi, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  onTap: () => _durumDegistir(parca),
                ),
              );
            }),

            const SizedBox(height: 32),

            // FİREBASE'E KAYDET BUTONU
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: _isSaving ? null : _ekspertiziKuantumAgaIsle,
                icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: bgColor, strokeWidth: 2)) : const Icon(Icons.verified, color: bgColor),
                label: Text(_isSaving ? "AĞA MÜHÜRLENİYOR..." : "EKSPERTİZİ ONAYLA VE KAYDET", style: const TextStyle(color: bgColor, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController controller, {bool isNumber = false, bool isMultiLine = false, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : (isMultiLine ? TextInputType.multiline : TextInputType.text),
        maxLines: isMultiLine ? 3 : 1,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
            icon: Icon(icon, color: const Color(0xFF00FFC2), size: 20),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            border: InputBorder.none
        ),
      ),
    );
  }
}