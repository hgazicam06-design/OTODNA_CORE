import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// İŞLEM KAYIT EKRANINA BAĞLANTI (Önceden yazdığımız AI ekranı)
import 'muayene_onay_ekrani.dart';

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

class UstaAracKabulScreen extends StatefulWidget {
  final String saseVeyaPlaka;
  const UstaAracKabulScreen({super.key, required this.saseVeyaPlaka});

  @override
  State<UstaAracKabulScreen> createState() => _UstaAracKabulScreenState();
}

class _UstaAracKabulScreenState extends State<UstaAracKabulScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _videoKanitGoster(String firma, String islem) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.kuantumCyan)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [const Icon(Icons.verified_user, color: SiberTema.kuantumCyan), const SizedBox(width: 8), Expanded(child: Text("$firma - Zaman Damgalı Kanıt", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))]),
              const SizedBox(height: 16),
              Container(height: 200, width: double.infinity, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white54, size: 64))),
              const SizedBox(height: 16),
              Text("İşlem: $islem", style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context), child: const Text("Kapat", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.bold)))),
            ],
          ),
        ),
      ),
    );
  }

  // Ustanın veya firmanın adını ID'sinden çeken yardımcı fonksiyon (Gelecek sürümlerde bu veri rapora direkt yazılmalı)
  Future<String> _firmaAdiniGetir(String firmaId) async {
    try {
      var doc = await _db.collection('kullanicilar').doc(firmaId).get();
      if (doc.exists) return doc.data()?['ad'] ?? "Bilinmeyen Firma";
    } catch (e) {
      return "Bilinmeyen Firma";
    }
    return "Bilinmeyen Firma";
  }

  @override
  Widget build(BuildContext context) {
    const primaryCyan = SiberTema.kuantumCyan;
    const bgColor = SiberTema.oledBlack;
    const cardColor = SiberTema.matGrey;

    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          title: const Text('OtoDNA Araç Sicili', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          centerTitle: true, iconTheme: const IconThemeData(color: primaryCyan),
        ),
      body: Column(
        children: [
          // =================================================================
          // 🚗 ARAÇ KÜNYESİ (SABİT BAŞLIK)
          // =================================================================
          Container(
            padding: const EdgeInsets.all(20), margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryCyan.withOpacity(0.2), Colors.transparent], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryCyan.withOpacity(0.5))),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.directions_car, color: primaryCyan, size: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.saseVeyaPlaka, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      const SizedBox(height: 4),
                      const Text("OtoDNA Referanslı Araç", style: TextStyle(color: primaryCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Icon(Icons.qr_code_2, color: Colors.white38, size: 32)
              ],
            ),
          ),

          const Padding(padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0), child: Align(alignment: Alignment.centerLeft, child: Text("Türkiye Geneli İşlem Geçmişi (Zaman Çizelgesi)", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)))),

          // =================================================================
          // ⏳ DNA ZAMAN ÇİZELGESİ (FİREBASE CANLI RADAR)
          // =================================================================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Bu plakaya ait tüm geçmiş raporları tarihe göre (en yeni en üstte) çekiyoruz
                stream: _db.collection('raporlar').where('plaka', isEqualTo: widget.saseVeyaPlaka).orderBy('tarih', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: primaryCyan));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("Bu araca ait henüz bir OtoDNA geçmişi bulunmuyor.", style: TextStyle(color: Colors.white54)));
                  }

                  var raporlar = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16), physics: const BouncingScrollPhysics(), itemCount: raporlar.length,
                    itemBuilder: (context, index) {
                      var raporDoc = raporlar[index];
                      var raporData = raporDoc.data() as Map<String, dynamic>;

                      // Tarih Formatlama
                      String formatliTarih = "Tarih Yok";
                      if (raporData['tarih'] != null) {
                        formatliTarih = DateFormat('dd MMM yyyy - HH:mm', 'tr_TR').format((raporData['tarih'] as Timestamp).toDate());
                      }

                      // Dinamik Firma Adı Çekimi (FutureBuilder ile)
                      return FutureBuilder<String>(
                          future: _firmaAdiniGetir(raporData['usta_id'] ?? 'Bilinmiyor'),
                          builder: (context, firmaSnapshot) {
                            String firmaAdi = firmaSnapshot.data ?? "Firma Aranıyor...";

                            // Rapor detaylarını (Mekanik/Kaporta vs) analiz et
                            String islemBasligi = "Genel Kontrol";
                            String ustaNotu = "Not girilmemiş.";
                            bool isRiskli = false;

                            if (raporData['rapor_tipi'] == "Kaporta & Boya") {
                              islemBasligi = "Kaporta ve Boya Ekspertizi";
                              ustaNotu = raporData['usta_notu'] ?? "Not Yok";
                              isRiskli = (raporData['kesilen_ceza_puani'] ?? 0) > 0;
                            } else if (raporData['kontrol_listesi'] != null) {
                              islemBasligi = "Mekanik ve Aksam Kontrolü";
                              // Eğer herhangi bir parça "2" (Kırmızı X) ise riskli sayılır
                              Map<String, dynamic> liste = raporData['kontrol_listesi'];
                              if (liste.values.contains(2)) isRiskli = true;
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Çizgi ve Nokta (Timeline)
                                Column(
                                  children: [
                                    Container(width: 16, height: 16, decoration: BoxDecoration(color: isRiskli ? Colors.redAccent : primaryCyan, shape: BoxShape.circle, border: Border.all(color: bgColor, width: 3))),
                                    if (index != raporlar.length - 1)
                                      Container(width: 2, height: 150, color: Colors.white12), // Çizgi boyu
                                  ],
                                ),
                                const SizedBox(width: 16),

                                // İçerik Kartı
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 24), padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isRiskli ? Colors.redAccent.withOpacity(0.5) : Colors.white12)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // İleride burası bayinin il/ilçe bilgisinden çekilebilir
                                            Row(children: [const Icon(Icons.location_on, color: Colors.white54, size: 14), const SizedBox(width: 4), Text(firmaAdi, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))]),
                                            Text(formatliTarih, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(isRiskli ? '❌' : '✅', style: const TextStyle(fontSize: 20)),
                                            const SizedBox(width: 12),
                                            Expanded(child: Text(islemBasligi, style: TextStyle(color: isRiskli ? Colors.redAccent : Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text("DNA Skoru Değişimi: -> ${raporData['yeni_dna_skoru'] ?? 'Bilinmiyor'}", style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 12),
                                        const Divider(color: Colors.white12),
                                        const SizedBox(height: 8),

                                        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.comment, color: Colors.white38, size: 14), const SizedBox(width: 8), Expanded(child: Text(ustaNotu, style: const TextStyle(color: Colors.white70, fontSize: 11, fontStyle: FontStyle.italic)))])),

                                        // İleride Firebase Storage'a yüklenen video URL'sine göre bu buton açılır
                                        const SizedBox(height: 16),
                                        OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(side: const BorderSide(color: primaryCyan), minimumSize: const Size(double.infinity, 40)),
                                            onPressed: () => _videoKanitGoster(firmaAdi, islemBasligi), // Video URL'si eklendiğinde buradan basılacak
                                            icon: const Icon(Icons.play_circle_outline, color: primaryCyan, size: 18),
                                            label: const Text("Zaman Damgalı İşlem Videosunu İzle", style: TextStyle(color: primaryCyan, fontSize: 12))
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                      );
                    },
                  );
                }
            ),
          ),

          // =================================================================
          // YENİ İŞLEM BAŞLAT BUTONU
          // =================================================================
          Container(
            padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: bgColor, border: Border(top: BorderSide(color: Colors.white12))),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  // 🚀 YAPAY ZEKA ONAY EKRANINA (MUAYENE) GÖNDER!
                  // Not: Gerçek senaryoda usta önce işlemi seçer, sonra AI ekranına geçer.
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MuayeneOnayEkrani(
                    plakaID: widget.saseVeyaPlaka,
                    islenenKontrolListesi: const {"Mekanik Kontrol": 1}, // Test için gönderildi
                    yeniDnaSkoru: 95, // Test için gönderildi
                  )));
                },
                icon: const Icon(Icons.add_task, color: bgColor),
                label: const Text("Bu Araca Yeni İşlem Kaydet", style: TextStyle(color: bgColor, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          )
        ],
      ),
      ),
    );
  }
}