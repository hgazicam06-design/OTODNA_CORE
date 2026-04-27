import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class FabrikaAnaKarargah extends StatefulWidget {
  const FabrikaAnaKarargah({super.key});

  @override
  State<FabrikaAnaKarargah> createState() => _FabrikaAnaKarargahState();
}

class _FabrikaAnaKarargahState extends State<FabrikaAnaKarargah> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 0: Tümü, 1: İthal (Prins, Lovato vb.), 2: Yerli (Atiker vb.)
  int _seciliFiltre = 0;

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.altinSari, size: 18), onPressed: () => Navigator.pop(context)),
          title: const Text("GLOBAL TEDARİK MERKEZİ", style: TextStyle(color: SiberTema.altinSari, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
          actions: [IconButton(icon: const Icon(Icons.local_fire_department, color: Colors.orangeAccent), onPressed: () {})],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. REKLAM & FLAŞ KAMPANYALAR (CAROUSEL)
              const SizedBox(height: 16),
              _buildKampanyaCarousel(),
              
              // 2. EN İYİ MARKALAR (VİTRİN)
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text("SİBER VİTRİN: EN İYİ MARKALAR", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 16),
              _buildEnIyiMarkalar(),

              // 3. FİLTRELEME BUTONLARI (İTHAL / YERLİ)
              const SizedBox(height: 32),
              _buildFiltreler(),

              // 4. DİNAMİK ÜLKE & DİSTRİBÜTÖR LİSTESİ (FİREBASE STREAM)
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text("KÜRESEL DİSTRİBÜTÖR AĞI (CANLI VERİ)", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildDinamikAglariGetir(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // 🚀 REKLAM VE FLAŞ KAMPANYALAR
  Widget _buildKampanyaCarousel() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _buildKampanyaKarti("PRINS VSI-3 DI", "İthal LPG Sistemlerinde Devrim! %15 Distribütör İndirimi", SiberTema.kuantumCyan, Icons.electric_bolt),
          _buildKampanyaKarti("ATİKER GRAND", "Yerli Üretim, Maksimum Performans. Stoklar Güncellendi.", SiberTema.sariAltin, Icons.local_fire_department),
          _buildKampanyaKarti("LOVATO OBD II", "İtalyan Efsanesi Geri Döndü! Toplu alımlarda kargo bizden.", Colors.orangeAccent, Icons.workspace_premium),
        ],
      ),
    );
  }

  Widget _buildKampanyaKarti(String baslik, String altMetin, Color renk, IconData ikon) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: renk.withOpacity(0.5), width: 1.5),
        boxShadow: [BoxShadow(color: renk.withOpacity(0.15), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: renk.withOpacity(0.1), shape: BoxShape.circle), child: Icon(ikon, color: renk, size: 20)),
              const SizedBox(width: 12),
              const Text("FLAŞ KAMPANYA", style: TextStyle(color: SiberTema.textMuted, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
          const Spacer(),
          Text(baslik, style: TextStyle(color: renk, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(altMetin, style: const TextStyle(color: SiberTema.textMuted, fontSize: 11, height: 1.4)),
        ],
      ),
    );
  }

  // 🌟 EN İYİ MARKALAR (YATAY VİTRİN)
  Widget _buildEnIyiMarkalar() {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _buildMarkaRozeti("PRINS", "Hollanda", true),
          _buildMarkaRozeti("ATİKER", "Türkiye", false),
          _buildMarkaRozeti("LOVATO", "İtalya", true),
          _buildMarkaRozeti("BRC", "İtalya", true),
          _buildMarkaRozeti("CANGAS", "Türkiye", false),
        ],
      ),
    );
  }

  Widget _buildMarkaRozeti(String marka, String ulke, bool ithalMi) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiberTema.textMuted),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(marka, style: const TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(ithalMi ? Icons.flight_land : Icons.home, color: ithalMi ? SiberTema.kuantumCyan : SiberTema.altinSari, size: 10),
              const SizedBox(width: 4),
              Text(ulke, style: TextStyle(color: SiberTema.textMain.withOpacity(0.5), fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }

  // 🎛️ FİLTRELEME BUTONLARI
  Widget _buildFiltreler() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildFiltreButonu(0, "TÜM AĞ"),
          const SizedBox(width: 12),
          _buildFiltreButonu(1, "İTHAL LİSTESİ"),
          const SizedBox(width: 12),
          _buildFiltreButonu(2, "YERLİ AĞ"),
        ],
      ),
    );
  }

  Widget _buildFiltreButonu(int index, String baslik) {
    bool isSelected = _seciliFiltre == index;
    Color r = isSelected ? SiberTema.altinSari : Colors.white10;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _seciliFiltre = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? SiberTema.altinSari.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: r),
          ),
          child: Center(
            child: Text(baslik, style: TextStyle(color: isSelected ? SiberTema.altinSari : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ),
        ),
      ),
    );
  }

  // 🌐 DİNAMİK FİREBASE STREAM YÜKLEMESİ
  Widget _buildDinamikAglariGetir() {
    // kural: Firebase'deki 'kullanicilar' tablosunda hiyerarşi rolu distribütör olanlar
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('kullanicilar').where('hiyerarsi_rolu', isEqualTo: 'ULKE_DISTRIBUTORU').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: SiberTema.altinSari)));
        }

        List<DocumentSnapshot> docs = snapshot.data?.docs ?? [];

        // EĞER FIREBASE BOŞSA (Test amaçlı henüz kayıt yoksa) SİBER FALLBACK GÖSTER
        if (docs.isEmpty) {
          return _buildSiberFallbackListe();
        }

        // FİLTRELEME MANTIĞI
        var filtrelenmisDocs = docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          bool ithalMi = data['ithal_mi'] ?? false;
          if (_seciliFiltre == 1) return ithalMi == true; // Sadece İthal
          if (_seciliFiltre == 2) return ithalMi == false; // Sadece Yerli
          return true; // Tümü
        }).toList();

        if (filtrelenmisDocs.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Bu filtreye uygun distribütör bulunamadı.", style: TextStyle(color: SiberTema.textMuted))));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtrelenmisDocs.length,
          itemBuilder: (context, index) {
            var data = filtrelenmisDocs[index].data() as Map<String, dynamic>;
            return _buildUlkeRadari(data['firma_adi'] ?? "Bilinmeyen Distribütör", data['toplam_montaj'] ?? 0, "AKTİF", SiberTema.kuantumCyan, data['ithal_mi'] ?? false);
          },
        );
      },
    );
  }

  // EĞER VERİTABANI BOŞSA GÖRÜNECEK TEST LİSTESİ (Kuantum Ekosistemi boş kalmasın diye)
  Widget _buildSiberFallbackListe() {
    List<Map<String, dynamic>> sahteListe = [
      {"firma": "Türkiye Prins (İthal)", "montaj": 14200, "ithal": true},
      {"firma": "Almanya Lovato (İthal)", "montaj": 3200, "ithal": true},
      {"firma": "Türkiye Atiker (Yerli)", "montaj": 45800, "ithal": false},
      {"firma": "İtalya BRC (Yerli)", "montaj": 8900, "ithal": false}, // İtalya menşeli
    ];

    var filtrelenmis = sahteListe.where((item) {
      if (_seciliFiltre == 1) return item['ithal'] == true;
      if (_seciliFiltre == 2) return item['ithal'] == false;
      return true;
    }).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtrelenmis.length,
      itemBuilder: (context, index) {
        var item = filtrelenmis[index];
        Color r = item['ithal'] ? SiberTema.kuantumCyan : SiberTema.sariAltin;
        return _buildUlkeRadari(item['firma'], item['montaj'], "AĞA BAĞLI", r, item['ithal']);
      },
    );
  }

  Widget _buildUlkeRadari(String ulkeAdi, int montaj, String durum, Color durumRengi, bool ithalMi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(16), border: Border.all(color: durumRengi.withOpacity(0.3))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: durumRengi.withOpacity(0.1), shape: BoxShape.circle), child: Icon(ithalMi ? Icons.flight_land : Icons.home_work, color: durumRengi, size: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ulkeAdi, style: const TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text("Mühürlü İşlem: $montaj", style: const TextStyle(color: SiberTema.textMuted, fontSize: 11)),
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: SiberTema.textMuted, borderRadius: BorderRadius.circular(4)), child: Text(ithalMi ? "İTHAL" : "YERLİ", style: TextStyle(color: SiberTema.textMain.withOpacity(0.7), fontSize: 8, fontWeight: FontWeight.bold))),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(durum, style: TextStyle(color: durumRengi, fontSize: 10, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.arrow_forward_ios, color: SiberTema.textMuted, size: 14), onPressed: () {}),
            ],
          )
        ],
      ),
    );
  }
}
