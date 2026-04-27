import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 SİBER KÖPRÜLER
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class YedekParcaIlanVerScreen extends StatefulWidget {
  const YedekParcaIlanVerScreen({super.key});

  @override
  State<YedekParcaIlanVerScreen> createState() => _YedekParcaIlanVerScreenState();
}

class _YedekParcaIlanVerScreenState extends State<YedekParcaIlanVerScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _baslikCtrl = TextEditingController();
  final TextEditingController _fiyatCtrl = TextEditingController();
  final TextEditingController _aciklamaCtrl = TextEditingController();

  String _seciliKategori = "Yedek Parça";
  final List<String> _kategoriler = ["Yedek Parça", "Aksesuar", "Ekspertiz & Hizmet"];

  double _girilenFiyat = 0.0;
  bool _isLoading = false;

  @override
  void dispose() {
    _baslikCtrl.dispose();
    _fiyatCtrl.dispose();
    _aciklamaCtrl.dispose();
    super.dispose();
  }

  // 🧠 FİREBASE: İLANI KUANTUM AĞINA MÜHÜRLE
  Future<void> _ilaniMuhurle() async {
    String baslik = _baslikCtrl.text.trim();
    String aciklama = _aciklamaCtrl.text.trim();

    if (baslik.isEmpty || _girilenFiyat <= 0 || aciklama.isEmpty) {
      _siberUyari("İhlal: Başlık, Fiyat ve Açıklama alanları boş bırakılamaz!", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      String aktifKullaniciId = _auth.currentUser?.uid ?? "BILINMEYEN_ID";

      // Kullanıcı/Bayi bilgilerini çek
      DocumentSnapshot userDoc = await _db.collection('kullanicilar').doc(aktifKullaniciId).get();
      String saticiIsmi = "Gizli Satıcı";
      String saticiTipi = "bireysel";

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        saticiTipi = data['rol'] ?? "bireysel";
        saticiIsmi = saticiTipi == "bayi" ? (data['ad'] ?? data['firma_adi'] ?? "Yetkili Bayi") : (data['ad_soyad'] ?? "Bireysel Sürücü");
      }

      // 🔥 SİBER MATEMATİK: %12 Karargah Payı Kesintisi!
      double gaziPayi = _girilenFiyat * 0.12;
      double saticiNet = _girilenFiyat - gaziPayi;

      WriteBatch batch = _db.batch(); // 🛡️ Kuantum Mührü

      // 1. İlanı Market Havuzuna Ekle
      DocumentReference ilanRef = _db.collection('ilanlar').doc();
      batch.set(ilanRef, {
        'ilan_id': ilanRef.id,
        'satici_id': aktifKullaniciId,
        'satici_isim': saticiIsmi,
        'satici_tipi': saticiTipi,
        'kategori': _seciliKategori,
        'baslik': baslik,
        'aciklama': aciklama,
        'brut_fiyat': _girilenFiyat,
        'karargah_payi': gaziPayi, // Sistemin alacağı komisyon (%12)
        'satici_hakedis': saticiNet, // Satılınca satıcıya geçecek tutar
        'durum': 'Aktif',
        'tarih': FieldValue.serverTimestamp(),
      });

      // 2. Karargah Loglarına Raporla
      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'basarili',
        'islem_detayi': 'YENİ PARÇA İLANI: $saticiIsmi, ₺$_girilenFiyat değerinde "$baslik" ilanını ağa yükledi.',
        'bayi_isim': saticiIsmi,
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      if (!mounted) return;
      _siberUyari("SİBER ONAY: Parça İlanınız Kuantum Marketine başarıyla mühürlendi!", isError: false);

      // Mühürlendikten Sonra Markete Geri Dön
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });

    } catch (e) {
      if (!mounted) return;
      _siberUyari("SİSTEM HATASI: İlan mühürlenemedi! $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _siberUyari(String mesaj, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Dinamik Finansal Hesaplamalar
    double gaziPayi = _girilenFiyat * 0.12;
    double netKazanc = _girilenFiyat - gaziPayi;

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: SiberTema.oledBlack,
          elevation: 1,
          shadowColor: SiberTema.kuantumCyan.withOpacity(0.3),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: SiberTema.kuantumCyan, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text("PARÇA İLANI OLUŞTUR", style: TextStyle(color: SiberTema.textMain, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.05),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKategoriSecici(),
                const SizedBox(height: 24),

                _buildGirdiAlani("PARÇA / HİZMET ADI", "Örn: Orijinal BMW F30 Ön Tampon", _baslikCtrl, Icons.title),
                const SizedBox(height: 20),

                _buildFiyatAlani(),
                const SizedBox(height: 20),

                // 💰 CANLI FİNANS PANELİ (KARARGAH PAYI EKRANI)
                _buildCanliFinansRadari(gaziPayi, netKazanc),
                const SizedBox(height: 24),

                _buildGirdiAlani("AÇIKLAMA", "Durumu, garanti bilgisi, uyumlu araçlar vb.", _aciklamaCtrl, Icons.description, maxLines: 4),
                const SizedBox(height: 32),

                // 🚀 FIRLATMA BUTONU
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: SiberTema.kuantumButonStili(),
                    onPressed: _isLoading ? null : _ilaniMuhurle,
                    icon: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 2))
                        : const Icon(Icons.satellite_alt, color: SiberTema.oledBlack, size: 24),
                    label: Text(
                        _isLoading ? "MÜHÜRLENİYOR..." : "AĞA YÜKLE VE SATIŞA BAŞLA",
                        style: const TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14, fontFamily: 'Avenir')
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 🎨 SİBER GÖRSEL ZIRHLAR ---

  Widget _buildKategoriSecici() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("KATEGORİ SEÇİMİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: SiberTema.matGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SiberTema.textMuted),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _seciliKategori,
              dropdownColor: SiberTema.oledBlack,
              icon: const Icon(Icons.arrow_drop_down, color: SiberTema.kuantumCyan),
              isExpanded: true,
              style: const TextStyle(color: SiberTema.textMain, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
              items: _kategoriler.map((String kategori) {
                return DropdownMenuItem<String>(
                  value: kategori,
                  child: Text(kategori),
                );
              }).toList(),
              onChanged: (String? yeniDeger) {
                if (yeniDeger != null) {
                  setState(() => _seciliKategori = yeniDeger);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGirdiAlani(String baslik, String hint, TextEditingController ctrl, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(baslik, style: const TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: SiberTema.textMain, fontSize: 14, fontFamily: 'Avenir'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: SiberTema.textMain.withOpacity(0.2), fontSize: 13),
            prefixIcon: maxLines == 1 ? Icon(icon, color: SiberTema.kuantumCyan.withOpacity(0.5), size: 20) : null,
            filled: true,
            fillColor: SiberTema.matGrey,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.textMuted)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.kuantumCyan, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildFiyatAlani() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("SATIŞ FİYATI (₺)", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
        const SizedBox(height: 8),
        TextField(
          controller: _fiyatCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 2),
          onChanged: (deger) {
            setState(() {
              _girilenFiyat = double.tryParse(deger.replaceAll(',', '.')) ?? 0.0;
            });
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.currency_lira, color: SiberTema.kuantumCyan, size: 24),
            hintText: "0.00",
            hintStyle: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.2)),
            filled: true,
            fillColor: SiberTema.kuantumCyan.withOpacity(0.05),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.3))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SiberTema.kuantumCyan, width: 2)),
          ),
        ),
      ],
    );
  }

  // 💸 EŞ ZAMANLI KESİNTİ VE HAKEDİŞ EKRANI
  Widget _buildCanliFinansRadari(double gaziPayi, double netKazanc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SiberTema.altinSari.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SiberTema.altinSari.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("OtoDNA Sistem Kesintisi (%12)", style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
              Text("- ₺${gaziPayi.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.kanKirmizi, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: SiberTema.textMuted, height: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("NET HAKEDİŞİNİZ", style: TextStyle(color: SiberTema.altinSari, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
              Text("₺${netKazanc.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.altinSari, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
            ],
          ),
        ],
      ),
    );
  }
}