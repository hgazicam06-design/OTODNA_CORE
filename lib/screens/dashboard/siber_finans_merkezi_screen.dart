import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class SiberFinansMerkeziScreen extends StatefulWidget {
  const SiberFinansMerkeziScreen({super.key});

  @override
  State<SiberFinansMerkeziScreen> createState() => _SiberFinansMerkeziScreenState();
}

class _SiberFinansMerkeziScreenState extends State<SiberFinansMerkeziScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _formatCurrency(double amount) {
    String formatted = amount.toStringAsFixed(2);
    formatted = formatted.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return "$formatted ₺";
  }

  void _siberUyari(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("SİBER FİNANS & LOJİSTİK MERKEZİ", style: TextStyle(color: SiberTema.sariAltin, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 13)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: SiberTema.sariAltin),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. LOJİSTİK RADARI
              _buildBolumBasligi("LOJİSTİK VE DEPO RADARI", Icons.local_shipping),
              _buildLojistikPaneli(),
              
              const SizedBox(height: 32),
              
              // 2. MUHASEBE VE KAZANÇ TABLOSU
              _buildBolumBasligi("KUANTUM KAZANÇ TABLOSU (%12 GAZİ PAYI)", Icons.account_balance_wallet),
              _buildKazancPaneli(),
              
              const SizedBox(height: 32),

              // 3. E-FATURA & İADE YÖNETİMİ HIZLI ERİŞİM
              _buildBolumBasligi("E-FATURA & İADE OTOMASYONU", Icons.receipt_long),
              _buildOtomasyonPaneli(),

              const SizedBox(height: 32),

              // 4. CANLI İŞLEM AKIŞI (HAVUZ TAKİP)
              _buildBolumBasligi("CANLI İŞLEM AKIŞI (KARARGAH HAVUZU)", Icons.swap_vert),
              _buildCanliIslemListesi(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBolumBasligi(String baslik, IconData ikon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(ikon, color: SiberTema.kuantumCyan, size: 20),
          const SizedBox(width: 8),
          Text(baslik, style: const TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
        ],
      ),
    );
  }

  // ── 1. LOJİSTİK PANELİ ──
  Widget _buildLojistikPaneli() {
    // Şimdilik lojistik verileri sabit, ileride siparişler tablosundan çekilebilir
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard("KARGODA\nBEKLEYEN", "12", Colors.amber, Icons.inbox),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard("15 GÜNLÜK\nKRİTİK RİSK", "3", SiberTema.kanKirmizi, Icons.warning_amber_rounded, titresim: true),
        ),
      ],
    );
  }

  // ── 2. KAZANÇ PANELİ ──
  Widget _buildKazancPaneli() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('finansal_islemler').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: SiberTema.sariAltin));

        double gunlukKazan = 0;
        double haftalikKazan = 0;
        double aylikKazan = 0;
        double yillikKazan = 0;

        DateTime now = DateTime.now();

        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>;
          double gaziPayi = (data['gazi_payi_12'] ?? 0).toDouble();
          Timestamp? tStamp = data['tarih'];
          
          if (tStamp != null) {
            DateTime t = tStamp.toDate();
            // Yıllık
            if (t.year == now.year) yillikKazan += gaziPayi;
            // Aylık
            if (t.year == now.year && t.month == now.month) aylikKazan += gaziPayi;
            // Haftalık (Son 7 gün)
            if (now.difference(t).inDays <= 7) haftalikKazan += gaziPayi;
            // Günlük
            if (t.year == now.year && t.month == now.month && t.day == now.day) gunlukKazan += gaziPayi;
          }
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: SiberTema.textMuted),
              ),
              child: Column(
                children: [
                  _buildKazancSatiri("GÜNLÜK KAZANÇ", gunlukKazan, SiberTema.sariAltin),
                  const Divider(color: SiberTema.textMuted, height: 1),
                  _buildKazancSatiri("HAFTALIK KAZANÇ", haftalikKazan, SiberTema.kuantumCyan),
                  const Divider(color: SiberTema.textMuted, height: 1),
                  _buildKazancSatiri("AYLIK KAZANÇ", aylikKazan, Colors.white),
                  const Divider(color: SiberTema.textMuted, height: 1),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: SiberTema.sariAltin.withOpacity(0.1)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("YILLIK TOPLAM KAZANÇ", style: TextStyle(color: SiberTema.sariAltin, fontSize: 12, fontWeight: FontWeight.w900)),
                        Text(_formatCurrency(yillikKazan), style: const TextStyle(color: SiberTema.sariAltin, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildKazancSatiri(String baslik, double tutar, Color renk) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
          Text(_formatCurrency(tutar), style: TextStyle(color: renk, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        ],
      ),
    );
  }

  // ── 3. OTOMASYON PANELİ ──
  Widget _buildOtomasyonPaneli() {
    return Column(
      children: [
        _buildOtomasyonButonu("SON KESİLEN E-FATURALAR", Icons.receipt, SiberTema.kuantumCyan, () {
          _siberUyari("E-Faturalar listeleniyor...");
        }),
        const SizedBox(height: 12),
        _buildOtomasyonButonu("İADE / GİDER PUSULASI BEKLEYENLER", Icons.assignment_return, Colors.amber, () {
          _siberUyari("İade süreçleri kontrol ediliyor...");
        }),
        const SizedBox(height: 12),
        _buildOtomasyonButonu("İPTAL EDİLEN KAZANÇLAR (MAHSUP)", Icons.money_off, SiberTema.kanKirmizi, () {
          _siberUyari("Mahsup işlemleri yükleniyor...", isError: true);
        }),
      ],
    );
  }

  Widget _buildOtomasyonButonu(String baslik, IconData ikon, Color renk, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white45,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: renk.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(ikon, color: renk, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(baslik, style: TextStyle(color: SiberTema.textMain, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1))),
            const Icon(Icons.arrow_forward_ios, color: SiberTema.textMuted, size: 14),
          ],
        ),
      ),
    );
  }

  // ── 4. CANLI İŞLEM LİSTESİ (ESKİ HAVUZ TAKİP) ──
  Widget _buildCanliIslemListesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('finansal_islemler').orderBy('tarih', descending: true).limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text("Henüz finansal işlem bulunmuyor...", style: TextStyle(color: SiberTema.textMuted)));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            bool islemTamam = data['islem_tipi'] == 'SATIŞ' || data['return_status'] == 'AI_ONAYLI_KARGO_BEKLENIYOR';
            bool islemIptal = data['is_frozen'] == true || data['return_status'] == 'IADE_REDDEDILDI_SAHTECILIK';

            Color islemRengi = islemIptal ? SiberTema.kanKirmizi : (islemTamam ? SiberTema.kuantumCyan : Colors.amber);
            IconData islemIkonu = islemIptal ? Icons.cancel : (islemTamam ? Icons.check_circle : Icons.timer);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: islemRengi.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: islemRengi.withOpacity(0.1),
                    child: Icon(islemIkonu, color: islemRengi, size: 18),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['bayi_adi'] ?? "Bilinmeyen Bayi", style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(data['islem_tipi'] ?? "GENEL İŞLEM", style: const TextStyle(color: SiberTema.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_formatCurrency((data['brut_tutar'] ?? 0).toDouble()), style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontSize: 14)),
                      Text(islemIptal ? "İPTAL EDİLDİ" : "+${_formatCurrency((data['gazi_payi_12'] ?? 0).toDouble())}", style: TextStyle(color: islemRengi, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoCard(String baslik, String deger, Color renk, IconData ikon, {bool titresim = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: renk.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: renk.withOpacity(0.5), width: titresim ? 2 : 1),
        boxShadow: titresim ? [BoxShadow(color: renk.withOpacity(0.2), blurRadius: 20)] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: renk, size: 28),
          const SizedBox(height: 16),
          Text(deger, style: const TextStyle(color: SiberTema.textMain, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
          const SizedBox(height: 4),
          Text(baslik, style: TextStyle(color: renk, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }
}
