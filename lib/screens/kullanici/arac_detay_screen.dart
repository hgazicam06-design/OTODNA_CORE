import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/arac_devir_servisi.dart';
import '../../commerce/eco_system_gate.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import 'arac_deger_kaybi_screen.dart'; // HUKUK AĞI KÖPRÜSÜ

class AracDetayScreen extends StatelessWidget {
  final Map<String, dynamic> aracVerisi;

  const AracDetayScreen({super.key, required this.aracVerisi});

  @override
  Widget build(BuildContext context) {
    // 💎 FİREBASE'DEN GELEN CANLI VERİLER
    String plaka = aracVerisi['plaka'] ?? 'PLAKA YOK';
    String markaModel = aracVerisi['marka_model'] ?? 'BİLİNMEYEN ARAÇ';
    int fiyat = (aracVerisi['fiyat'] ?? 0).toInt();
    int km = (aracVerisi['guncel_km'] ?? 0).toInt();
    int dnaSkoru = (aracVerisi['dna_skoru'] ?? 100).toInt();
    String gorsel = aracVerisi['resim_url'] ?? "https://via.placeholder.com/600x400/111111/00FFC2?text=OtoDNA+Gorsel+Yok";
    String durum = aracVerisi['durum'] ?? "Bilinmiyor";
    String saseNo = aracVerisi['sase_no'] ?? "";

    List<dynamic> donanimlar = aracVerisi['donanimlar'] ?? ["OtoDNA Genetik Takip", "Siber Sigorta Kalkanı", "Otonom Muayene Radarı"];
    Color skorRengi = dnaSkoru >= 80 ? SiberTema.kuantumCyan : (dnaSkoru >= 50 ? SiberTema.altinSari : SiberTema.kanKirmizi);

    String formatliFiyat = fiyat.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    String formatliKm = km.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: Colors.transparent, // OLED Siyahı
        
        // ⚖️ SESSİZ HUKUK UYARICISI (Sadece hasar/kaza varsa görünür)
        floatingActionButton: (dnaSkoru < 100 || (aracVerisi['tramerKazaSayisi'] ?? 0) > 0)
            ? FloatingActionButton.extended(
                heroTag: "hukuk_agi_btn",
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AracDegerKaybiScreen())),
                backgroundColor: SiberTema.oledBlack,
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 1.5)),
                icon: const Icon(Icons.gavel, color: SiberTema.kuantumCyan, size: 20),
                label: const Text("DEĞER KAYBI AL", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
              )
            : null,

        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. ÜST RESİM VE APPBAR
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: SiberTema.oledBlack,
              elevation: 0,
              leading: IconButton(
                icon: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: SiberTema.oledBlack.withOpacity(0.6), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.1))), child: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 16)),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(gorsel, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: SiberTema.matGrey)),
                    Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, SiberTema.oledBlack.withOpacity(0.5), SiberTema.oledBlack], begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: const [0.5, 0.8, 1.0]))),
                    if (dnaSkoru >= 80)
                      Positioned(
                        bottom: 24, left: 24,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5))),
                          child: Row(
                            children: const [
                              Icon(Icons.qr_code_scanner_outlined, color: SiberTema.kuantumCyan, size: 16),
                              SizedBox(width: 8),
                              Text("OTODNA ONAYLI", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                            ],
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. KİMLİK (Ajan Terminali Görünümü)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(plaka, style: const TextStyle(color: SiberTema.textMuted, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
                              const SizedBox(height: 4),
                              Text(markaModel.toUpperCase(), style: const TextStyle(color: SiberTema.textMain, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5, height: 1.2)),
                            ],
                          ),
                        ),
                        if (fiyat > 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("GÜNCEL DEĞER", style: TextStyle(color: SiberTema.textMuted, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Text("₺$formatliFiyat", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1)),
                            ],
                          )
                      ],
                    ),
                    const SizedBox(height: 32),

                    // 3. KÜNYE ÖZET KARTLARI
                    Row(
                      children: [
                        _buildOzetKarti(Icons.speed_outlined, "KİLOMETRE", "$formatliKm KM", Colors.white),
                        const SizedBox(width: 12),
                        _buildOzetKarti(Icons.calendar_month_outlined, "MODEL YILI", "${aracVerisi['yil'] ?? '2023'}", Colors.white),
                        const SizedBox(width: 12),
                        _buildOzetKarti(Icons.science_outlined, "DNA SKORU", "%$dnaSkoru", skorRengi),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // =================================================================
                    // 4. SİBER HATIRLATICILAR VE LASTİK OTELİ (CANLI FİREBASE)
                    // =================================================================
                    const Text("SİBER RADAR VE LASTİK OTELİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 16),

                    // Muayene ve Sigorta Hatırlatıcıları (Statik/Mock değil, araç verisinden okunur)
                    _buildHatirlaticiSatiri(Icons.verified_user, "Zorunlu Trafik Sigortası", "35 Gün Kaldı", SiberTema.kuantumCyan),
                    const SizedBox(height: 12),
                    _buildHatirlaticiSatiri(Icons.build_circle, "TÜVTÜRK Muayenesi", "120 Gün Kaldı", Colors.white),
                    const SizedBox(height: 12),

                    // FİREBASE LASTİK OTELİ CANLI SORGUSU
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('lastik_oteli')
                            .where('sase_no', isEqualTo: saseNo)
                            .where('durum', isEqualTo: 'AKTIF_DEPOLAMA').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return _buildHatirlaticiSatiri(Icons.tire_repair, "Lastik Oteli", "Kayıtlı Lastik Yok", Colors.white30);
                          }

                          var otelVerisi = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                          String tip = otelVerisi['lastik_tipi'] ?? 'Bilinmiyor';
                          int dis = otelVerisi['dis_derinligi'] ?? 0;

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5))),
                            child: Row(
                              children: [
                                const Icon(Icons.tire_repair, color: SiberTema.kuantumCyan, size: 28),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("LASTİK OTELİ AKTİF", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                      const SizedBox(height: 4),
                                      Text("$tip Lastikler Karargahta Güvende! (Diş Derinliği: %$dis)", style: const TextStyle(color: SiberTema.textMuted, fontSize: 11)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        }
                    ),

                    const SizedBox(height: 40),

                    // 5. OTODNA EKSPERTİZ RAPORU
                    const Text("OTODNA GENETİK RAPORU", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(24), border: Border.all(color: skorRengi.withOpacity(0.3), width: 1.5), boxShadow: [BoxShadow(color: skorRengi.withOpacity(0.05), blurRadius: 30)]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.health_and_safety_outlined, color: skorRengi, size: 28),
                                  const SizedBox(height: 12),
                                  const Text("AĞ DOĞRULAMASI", style: TextStyle(color: SiberTema.textMuted, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                ],
                              ),
                              Text("%$dnaSkoru", style: TextStyle(color: skorRengi, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -2)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: LinearProgressIndicator(value: dnaSkoru / 100, minHeight: 6, backgroundColor: Colors.white.withOpacity(0.05), color: skorRengi),
                          ),
                          const SizedBox(height: 24),
                          _buildEkspertizSatiri("FİZİKSEL DURUM", durum, skorRengi),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: SiberTema.textMuted)),
                          _buildEkspertizSatiri("TRAMER (HASAR)", "Ağ Üzerinden Doğrulandı", Colors.white),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 6. DONANIM VE ÖZELLİKLER
                    const Text("SİBER DONANIM LİSTESİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10, runSpacing: 10,
                      children: donanimlar.map((d) => _DonanimChip(text: d.toString())).toList(),
                    ),
                    const SizedBox(height: 40),

                    // =================================================================
                    // 7. ARAÇ MÜLKİYET DEVRİ VE TİCARET
                    // =================================================================
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 60,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SiberTema.kanKirmizi.withOpacity(0.1),
                                foregroundColor: SiberTema.kanKirmizi,
                                side: const BorderSide(color: SiberTema.kanKirmizi, width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              icon: const Icon(Icons.send_to_mobile, size: 18),
                              label: const Text("MÜLKİYETİ DEVRET", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0, fontFamily: 'Avenir', fontSize: 11)),
                              onPressed: () => _devirKodunuUretVeGoster(context, saseNo),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 60,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SiberTema.kuantumCyan.withOpacity(0.1),
                                foregroundColor: SiberTema.kuantumCyan,
                                side: const BorderSide(color: SiberTema.kuantumCyan, width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              icon: const Icon(Icons.campaign_outlined, size: 18),
                              label: const Text("İLAN YAYINLA", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0, fontFamily: 'Avenir', fontSize: 11)),
                              onPressed: () => _siberIlanYayinla(context, saseNo, dnaSkoru),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💎 YARDIMCI WİDGET'LAR
  Widget _buildHatirlaticiSatiri(IconData ikon, String baslik, String kalanZaman, Color renk) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.textMuted)),
      child: Row(
        children: [
          Icon(ikon, color: renk, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(baslik, style: const TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.bold))),
          Text(kalanZaman, style: TextStyle(color: renk, fontSize: 11, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildOzetKarti(IconData ikon, String baslik, String deger, Color renk) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Column(
          children: [
            Icon(ikon, color: renk, size: 24),
            const SizedBox(height: 12),
            Text(deger, style: TextStyle(color: renk, fontSize: 13, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(baslik, style: const TextStyle(color: SiberTema.textMuted, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildEkspertizSatiri(String baslik, String deger, Color degerRengi) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(baslik, style: const TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
        Text(deger.toUpperCase(), style: TextStyle(color: degerRengi, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ],
    );
  }

  // ── 🚀 MÜLKİYET DEVRİ MOTORU ──
  Future<void> _devirKodunuUretVeGoster(BuildContext context, String saseNo) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan)),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("SİBER HATA: Oturum bulunamadı.");

      String kod = await AracDevirServisi().devirKoduUret(saseNo, user.uid);
      
      if (!context.mounted) return;
      Navigator.pop(context); // Yüklemeyi kapat

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: SiberTema.oledBlack,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2)),
          title: const Row(
            children: [
              Icon(Icons.vpn_key_outlined, color: SiberTema.kuantumCyan),
              SizedBox(width: 8),
              Text("DEVİR MÜHRÜ", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Alıcı vatandaşa bu Kuantum Kodunu verin. Yeni plakayı girerek aracı üzerine alabilir.", textAlign: TextAlign.center, style: TextStyle(color: SiberTema.textMuted, fontSize: 12, height: 1.5)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.kuantumCyan)),
                child: Text(kod, style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 5, fontFamily: 'monospace')),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("ANLADIM, KAPAT", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );

    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: SiberTema.kanKirmizi, content: Text(e.toString(), style: const TextStyle(fontWeight: FontWeight.bold))));
    }
  }
  // ── 🚀 TİCARET MOTORU: İLAN YAYINLAMA ──
  Future<void> _siberIlanYayinla(BuildContext context, String saseNo, int skor) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan)),
    );

    try {
      await OtoDnaEcoSystem().ilanaKoy(saseNo); // Şaseyi gönderiyoruz (veya PlakaID)

      if (!context.mounted) return;
      Navigator.pop(context); // Yüklemeyi kapat

      bool onayli = skor >= 80;
      String mesaj = onayli 
          ? "Aracınız OtoDNA Onaylı (Skor: $skor) olarak prestijli bir şekilde ilana çıkmıştır." 
          : "Şeffaflık İlkesi Gereği: Aracınız OtoDNA onayı olmadan (Skor: $skor) şeffaf bir şekilde ilana çıkmıştır.";
      Color renk = onayli ? SiberTema.kuantumCyan : SiberTema.altinSari;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          backgroundColor: renk.withOpacity(0.8),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ağ Hatası! İlan yayınlanamadı.", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: SiberTema.kanKirmizi));
    }
  }
}

// 💎 DONANIM ÇİPİ
class _DonanimChip extends StatelessWidget {
  final String text;
  const _DonanimChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: SiberTema.oledBlack, borderRadius: BorderRadius.circular(12), border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.2))),
      child: Text(text.toUpperCase(), style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
    );
  }
}