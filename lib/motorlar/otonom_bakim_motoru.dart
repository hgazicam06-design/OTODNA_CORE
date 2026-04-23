import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE MODELLER
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../models/service_model.dart';

/// 🛡️ KUANTUM TAHMİN VE BAKIM MOTORU
/// Aracın KM artış hızını hesaplar, Triger tipini ayırır,
/// geçmiş servis kayıtlarını tarayıp Kestirimci Bakım tahmini yapar.
class OtonomBakimMotoru extends StatefulWidget {
  final String saseNo;

  const OtonomBakimMotoru({super.key, required this.saseNo});

  @override
  State<OtonomBakimMotoru> createState() => _OtonomBakimMotoruState();
}

class _OtonomBakimMotoruState extends State<OtonomBakimMotoru> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fabrika Verileri (Araç modelinden çekildiğini varsayıyoruz)
  int _guncelKm = 0;
  int _aylikOrtalamaKm = 1500;
  String _motorTipi = "KAYIŞ"; // VEYA "ZİNCİR"

  // Radarın Bulduğu Son Bakım KM'leri
  int _son10kBakimKm = 0;
  int _son50kBakimKm = 0;
  int _sonTrigerDegisimKm = 0;

  bool _isAnalizEdiliyor = true;

  @override
  void initState() {
    super.initState();
    _araciKuantumAgiylaTara();
  }

  Future<void> _araciKuantumAgiylaTara() async {
    try {
      // 1. ADIM: Araç Genel Bilgilerini Çek (Güncel KM, Aylık Kullanım)
      // (Test için varsayılan araç verisi oluşturuyoruz, normalde 'araclar' koleksiyonundan gelir)
      DocumentSnapshot aracDoc = await _db.collection('araclar').doc(widget.saseNo).get();
      if (aracDoc.exists) {
        var data = aracDoc.data() as Map<String, dynamic>;
        _guncelKm = (data['guncel_km'] ?? 85000).toInt();
        _aylikOrtalamaKm = (data['aylik_ortalama_km'] ?? 1500).toInt();
        _motorTipi = data['motor_tipi'] ?? "KAYIŞ";
      } else {
        // Mock fallback if vehicle not yet fully registered
        _guncelKm = 85000;
        _aylikOrtalamaKm = 1500;
        _motorTipi = "KAYIŞ";
      }

      // 2. ADIM: Tüm Geçmiş Servis Kayıtlarını Çek
      QuerySnapshot servisQuery = await _db
          .collection('bakim_kayitlari')
          .where('sase_no', isEqualTo: widget.saseNo)
          .orderBy('kilometre', descending: true)
          .get();

      if (servisQuery.docs.isNotEmpty) {
        // KM'yi en son servis kaydına göre eşitleyelim (Eğer kullanıcının bildirdiği KM daha düşükse)
        int sonServisKm = (servisQuery.docs.first.data() as Map<String, dynamic>)['kilometre'] ?? 0;
        if (sonServisKm > _guncelKm) _guncelKm = sonServisKm;

        for (var doc in servisQuery.docs) {
          ServiceRecord record = ServiceRecord.fromFirestore(doc);
          List<String> islemler = record.yapilanIslemler.map((e) => e.toUpperCase()).toList();

          // En son ne zaman periyodik bakım (Yağ değişimi) yapıldı?
          if (_son10kBakimKm == 0 && (islemler.contains("PERİYODİK BAKIM") || islemler.contains("MOTOR YAĞI"))) {
            _son10kBakimKm = record.kilometre;
          }
          // En son ne zaman Ağır Bakım (Şanzıman yağı, baskı balata vs) yapıldı?
          if (_son50kBakimKm == 0 && (islemler.contains("AĞIR BAKIM") || islemler.contains("ŞANZIMAN YAĞI"))) {
            _son50kBakimKm = record.kilometre;
          }
          // En son ne zaman Triger seti değişti?
          if (_sonTrigerDegisimKm == 0 && islemler.any((item) => item.contains("TRİGER"))) {
            _sonTrigerDegisimKm = record.kilometre;
          }
        }
      }

      // Bulunamayan veriler için varsayılan güvenlik katsayıları
      if (_son10kBakimKm == 0) _son10kBakimKm = _guncelKm - 9500; // Bakıma yaklaştığını farz et
      if (_son50kBakimKm == 0) _son50kBakimKm = _guncelKm - 48000;
      if (_sonTrigerDegisimKm == 0) _sonTrigerDegisimKm = _guncelKm - (_motorTipi == "KAYIŞ" ? 78000 : 145000);

    } catch (e) {
      developer.log("Radar Hatası: $e");
    } finally {
      if (mounted) {
        setState(() => _isAnalizEdiliyor = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAnalizEdiliyor) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.radar, color: SiberTema.kuantumCyan, size: 50),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: SiberTema.kuantumCyan),
              const SizedBox(height: 20),
              Text("DNA SİCİLİ TARANIYOR...", style: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.8), letterSpacing: 2, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    // 🧠 YAPAY ZEKA HESAPLAMALARI
    int siradaki10k = _son10kBakimKm + 10000;
    int kalanKm10k = siradaki10k - _guncelKm;
    if (kalanKm10k < 0) kalanKm10k = 0;
    int tahminiGun10k = (kalanKm10k / (_aylikOrtalamaKm / 30)).round();

    int siradaki50k = _son50kBakimKm + 50000;
    int kalanKm50k = siradaki50k - _guncelKm;
    if (kalanKm50k < 0) kalanKm50k = 0;

    // Triger Kuralı (Kayış 60k-80k / Zincir 120k-150k)
    int trigerOmru = _motorTipi == "KAYIŞ" ? 80000 : 150000;
    int siradakiTrigerKm = _sonTrigerDegisimKm + trigerOmru;
    int kalanTrigerKm = siradakiTrigerKm - _guncelKm;
    if (kalanTrigerKm < 0) kalanTrigerKm = 0;

    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("KUANTUM BAKIM RADARI", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 13)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          children: [
            // ── 🏎️ ARAÇ DNA ÖZETİ ──
            _buildAracDnaPaneli(),
            const SizedBox(height: 24),

            // ── ⏱️ OTONOM TAHMİN MATRİSİ ──
            const Text("YAPAY ZEKA TAHMİN MATRİSİ", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 12),
            _buildTahminKarti(
              "PERİYODİK BAKIM (YAĞ & FİLTRE)", 
              kalanKm10k == 0 ? "ACİL BAKIM GEREKLİ!" : "Tahmini Süre: $tahminiGun10k Gün Sonra", 
              kalanKm10k, 
              10000, 
              kalanKm10k == 0 ? SiberTema.kanKirmizi : SiberTema.kuantumCyan
            ),
            const SizedBox(height: 12),
            _buildTahminKarti(
              "AĞIR BAKIM (ŞANZIMAN vb.)", 
              kalanKm50k < 5000 ? "Ağır Bakıma Çok Yaklaştınız" : "Sistem Normal İlerliyor", 
              kalanKm50k, 
              50000, 
              kalanKm50k < 5000 ? Colors.amberAccent : Colors.white54
            ),
            const SizedBox(height: 12),
            _buildTahminKarti(
              "TRİGER KONTROLÜ (${_motorTipi})", 
              _motorTipi == "KAYIŞ" && kalanTrigerKm < 5000 ? "Kopma Riski Yaklaşıyor! Şakası Yok!" : "Zincir/Kayış Ömrü Güvende", 
              kalanTrigerKm, 
              trigerOmru, 
              kalanTrigerKm < 5000 ? SiberTema.kanKirmizi : SiberTema.altinSari
            ),

            const SizedBox(height: 32),

            // ── 💰 OTODNA REKLAM VE TEDARİK AĞI (Para Kazanma Noktamız) ──
            if (kalanKm10k <= 2000) // Bakıma 2000 KM kala reklamı bas!
              _buildSponsorluUrunKarti("Castrol EDGE 5W-30 Tam Sentetik Motor Yağı", "1.250", "Periyodik bakım yaklaşıyor."),
            
            if (kalanTrigerKm <= 10000) // Trigere az kaldıysa pahalı sepet!
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildSponsorluUrunKarti("Orijinal Triger Seti + Devirdaim Pompası", "8.500", "Motoru kurtarmanın tam zamanı."),
              )
          ],
        ),
      ),
    );
  }

  // ── 🔧 ARAÇ DNA BİLGİ KAPSÜLÜ ──
  Widget _buildAracDnaPaneli() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SiberTema.matGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("GÜNCEL KİLOMETRE", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
              Text("$_guncelKm KM", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("AYLIK ORTALAMA KULLANIM", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
              Text("$_aylikOrtalamaKm KM / AY", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 14, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  // ── ⏱️ TAHMİN KARTI ──
  Widget _buildTahminKarti(String baslik, String altBaslik, int kalanKm, int toplamKm, Color renk) {
    double yuzde = 1.0 - (kalanKm / toplamKm);
    if (yuzde > 1.0) yuzde = 1.0;
    if (yuzde < 0) yuzde = 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(baslik, style: TextStyle(color: renk, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1))),
              Text("$kalanKm KM KALDI", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 6),
          Text(altBaslik, style: TextStyle(color: renk == SiberTema.kanKirmizi ? SiberTema.kanKirmizi : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: yuzde, backgroundColor: Colors.white10, color: renk, minHeight: 6, borderRadius: BorderRadius.circular(3)),
        ],
      ),
    );
  }

  // ── 💰 OTODNA TEDARİK & REKLAM (GERÇEK GELİR MODELİ) ──
  Widget _buildSponsorluUrunKarti(String urunAdi, String fiyat, String aciklama) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SiberTema.kuantumCyan.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 1.5),
        boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_cart, color: SiberTema.kuantumCyan, size: 18),
              const SizedBox(width: 8),
              Text("SİBER TEDARİK ÖNERİSİ", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 12),
          Text(urunAdi, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("$aciklama Fabrika standartlarına %100 uygun.", style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SiberTema.kuantumCyan,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                developer.log("SİBER SATIŞ: $urunAdi satışı tetiklendi. OtoDNA komisyonu kazandı.");
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$urunAdi SEPETE EKLENDİ! 🛒", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: SiberTema.kuantumCyan));
              },
              child: Text("SİSTEMDEN SİPARİŞ VER (₺$fiyat)", style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            ),
          )
        ],
      ),
    );
  }
}