import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../models/service_model.dart';
import '../models/ad_campaign_model.dart';
import '../widgets/siber_hedefli_reklam_panosu.dart';

/// 🧬 DİJİTAL BAKIM AĞI (DNA RADARI)
/// Aracın servis geçmişini Kuantum İstihbarat lokasyonlarıyla birlikte Siber Zaman Çizelgesinde (Timeline) gösterir.
class SiberBakimKarnesiScreen extends StatefulWidget {
  final String plaka;
  final String markaModel;
  final String saseNo;

  const SiberBakimKarnesiScreen({
    super.key,
    required this.plaka,
    required this.markaModel,
    required this.saseNo,
  });

  @override
  State<SiberBakimKarnesiScreen> createState() => _SiberBakimKarnesiScreenState();
}

class _SiberBakimKarnesiScreenState extends State<SiberBakimKarnesiScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text('🧬 DİJİTAL BAKIM AĞI', style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5))),
              child: const Icon(Icons.qr_code_scanner, color: SiberTema.kuantumCyan, size: 16),
            )
          ],
        ),
        body: Column(
          children: [
            // =================================================================
            // 1. ARAÇ KİMLİĞİ VE DNA DURUMU (Holografik Kart)
            // =================================================================
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: SiberTema.matGrey,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
                  boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 40)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.markaModel.toUpperCase(), style: const TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                              const SizedBox(height: 8),
                              Text(widget.plaka.toUpperCase(), style: const TextStyle(color: SiberTema.textMain, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
                          child: const Icon(Icons.health_and_safety_outlined, color: SiberTema.kuantumCyan, size: 32),
                        )
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: SiberTema.textMuted)),
                    Row(
                      children: [
                        const Icon(Icons.memory, color: SiberTema.textMuted, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text("ŞASE (VIN): ${widget.saseNo.toUpperCase()}", style: const TextStyle(color: SiberTema.textMuted, fontSize: 11, fontFamily: 'monospace', letterSpacing: 1.5, fontWeight: FontWeight.bold))),
                      ],
                    )
                  ],
                ),
              ),
            ),

            // =================================================================
            // 1.5 SİBER HEDEFLİ REKLAM (KESTİRİMCİ BAKIM UYARISI)
            // =================================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SiberHedefliReklamPanosu(
                kampanya: OtoDNACampaign(
                  id: "cmp_brakes_001",
                  sirketAd: "Bosch Kuantum Fren Sistemleri",
                  kampanyaBaslik: "Aracınızın Fren Balata Ömrü %15 Kaldı! Kuantum Karargahından Hemen Sipariş Ver",
                  gorselUrl: "https://via.placeholder.com/600x200/000000/00FFC2?text=FREN+BALATASI",
                  hedefLink: "https://otodna.com/parca/fren",
                  tiklanmaSayisi: 85,
                  aktifMi: true,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // =================================================================
            // 2. GELECEK BAKIM RADARI (SİBER TİMELİNE) BAŞLIĞI
            // =================================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.timeline, color: Colors.white.withOpacity(0.3), size: 20),
                  const SizedBox(width: 12),
                  const Text("SİBER BAKIM GEÇMİŞİ VE İŞLEM LOGLARI", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // =================================================================
            // 3. FİREBASE'DEN ÇEKİLEN BAKIM LOGLARI (Siber Timeline)
            // =================================================================
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db.collection('bakim_kayitlari')
                    .where('sase_no', isEqualTo: widget.saseNo)
                    .orderBy('islem_tarihi', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
                  }

                  // 🚨 VERİ YOKSA SİMÜLASYON MOCK (Arayüzü Geliştirmek İçin)
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      children: [
                        _buildBakimLogu(
                          ServiceRecord(
                            saseNo: widget.saseNo,
                            plaka: widget.plaka,
                            dukkanId: "D-001",
                            dukkanAdi: "GAZİ OTOMOTİV HQ",
                            countryId: "TR",
                            regionId: "MARMARA",
                            cityId: "İSTANBUL",
                            districtId: "MASLAK",
                            kilometre: 112500,
                            yapilanIslemler: ["TRİGER SETİ", "V KAYIŞI", "DEVİRDAİM"],
                            ustaNotu: "Tüm ağır bakımlar Kuantum standartlarına göre yapıldı.",
                            toplamTutar: 8500.0,
                            islemTarihi: DateTime.now().subtract(const Duration(days: 15)),
                          ),
                          true,
                        ),
                        _buildBakimLogu(
                          ServiceRecord(
                            saseNo: widget.saseNo,
                            plaka: widget.plaka,
                            dukkanId: "UNKNOWN",
                            dukkanAdi: "KAYIT DIŞI SERVİS",
                            countryId: "TR",
                            regionId: "İÇ ANADOLU",
                            cityId: "ANKARA",
                            districtId: "OSTİM",
                            kilometre: 95000,
                            yapilanIslemler: ["FREN BALATASI DEĞİŞİMİ"],
                            ustaNotu: "Balata bittiği için yan sanayi ile değiştirildi.",
                            toplamTutar: 1200.0,
                            islemTarihi: DateTime.now().subtract(const Duration(days: 300)),
                          ),
                          false, // Ağa entegre olmayan riskli esnaf
                        ),
                      ],
                    );
                  }

                  // GERÇEK VERİLER
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var record = ServiceRecord.fromFirestore(snapshot.data!.docs[index]);
                      
                      // Kırmızı İhlal Kartı kontrolü: Eğer dükkanId geçersizse veya sistem dışıysa
                      bool otoDnaOnayli = record.dukkanId.isNotEmpty && record.dukkanId != "UNKNOWN";
                      return _buildBakimLogu(record, otoDnaOnayli);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER BAKIM TİMELİNE LOGU (ADLİ KONUM İÇERİR)
  Widget _buildBakimLogu(ServiceRecord record, bool otoDnaOnayli) {
    Color durumRengi = otoDnaOnayli ? SiberTema.kuantumCyan : SiberTema.kanKirmizi;
    String islemTarihiStr = "${record.islemTarihi.day.toString().padLeft(2,'0')}.${record.islemTarihi.month.toString().padLeft(2,'0')}.${record.islemTarihi.year}";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: SiberTema.matGrey,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: otoDnaOnayli ? Colors.white.withOpacity(0.05) : SiberTema.kanKirmizi.withOpacity(0.3)),
        boxShadow: otoDnaOnayli ? [] : [BoxShadow(color: SiberTema.kanKirmizi.withOpacity(0.1), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ÜST BİLGİ BARI (Tarih & KM & Onay)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: otoDnaOnayli ? Colors.black : SiberTema.kanKirmizi.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.speed, color: durumRengi, size: 16),
                    const SizedBox(width: 8),
                    Text("${record.kilometre} KM", style: TextStyle(color: durumRengi, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
                  ],
                ),
                Text(islemTarihiStr, style: const TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
          ),

          // İÇERİK ALANI (Servis & Parçalar & Adli Konum)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Servis Bilgisi ve Adli Konum
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(otoDnaOnayli ? Icons.verified : Icons.warning_amber_rounded, color: durumRengi, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(record.dukkanAdi.toUpperCase(), style: TextStyle(color: otoDnaOnayli ? Colors.white : SiberTema.kanKirmizi, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          // 🕸️ ADLİ KONUM MÜHRÜ
                          Row(
                            children: [
                              Icon(Icons.location_on, color: durumRengi.withOpacity(0.7), size: 12),
                              const SizedBox(width: 4),
                              Text("${record.cityId} / ${record.districtId}", style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      )
                    ),
                    if (otoDnaOnayli) ...[
                      const SizedBox(width: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5))), child: const Text("AĞ ONAYLI", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 8, fontWeight: FontWeight.w900)))
                    ]
                  ],
                ),
                const SizedBox(height: 20),

                // Değişen Parçalar (Kuantum Çipler)
                const Text("MÜDAHALE EDİLEN DONANIMLAR:", style: TextStyle(color: SiberTema.textMuted, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: record.yapilanIslemler.map((p) => _buildParcaCipi(p, otoDnaOnayli)).toList(),
                ),

                if (record.ustaNotu.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white45, borderRadius: BorderRadius.circular(8), border: Border.all(color: SiberTema.textMuted)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("USTA NOTU:", style: TextStyle(color: SiberTema.sariAltin, fontSize: 9, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(record.ustaNotu, style: const TextStyle(color: SiberTema.textMuted, fontSize: 11, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  )
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: DEĞİŞEN PARÇA ÇİPİ
  Widget _buildParcaCipi(String parcaAdi, bool otoDnaOnayli) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: otoDnaOnayli ? SiberTema.kuantumCyan.withOpacity(0.3) : SiberTema.kanKirmizi.withOpacity(0.3)),
      ),
      child: Text(
        parcaAdi.toUpperCase(),
        style: TextStyle(color: otoDnaOnayli ? Colors.white70 : SiberTema.kanKirmizi, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }
}