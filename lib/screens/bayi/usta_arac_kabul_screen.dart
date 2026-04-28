import 'package:otodna/core/siber_tema.dart';
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
  UstaAracKabulScreen({super.key, required this.saseVeyaPlaka});

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
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.kuantumCyan)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [Icon(Icons.verified_user, color: SiberTema.kuantumCyan), SizedBox(width: 8), Expanded(child: Text("$firma - Zaman Damgalı Kanıt", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold)))]),
              SizedBox(height: 16),
              Container(height: 200, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Center(child: Icon(Icons.play_circle_fill, color: SiberTema.textMuted, size: 64))),
              SizedBox(height: 16),
              Text("İşlem: $islem", style: TextStyle(color: SiberTema.textMuted, fontSize: 12)),
              SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context), child: Text("Kapat", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.bold)))),
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
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          title: Text('OtoDNA Araç Sicili', style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          centerTitle: true, iconTheme: IconThemeData(color: primaryCyan),
        ),
      body: Column(
        children: [
          // =================================================================
          // 🚗 ARAÇ KÜNYESİ (SABİT BAŞLIK)
          // =================================================================
          Container(
            padding: EdgeInsets.all(20), margin: EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryCyan.withOpacity(0.2), Colors.transparent], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryCyan.withOpacity(0.5))),
            child: Row(
              children: [
                Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.directions_car, color: primaryCyan, size: 32)),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.saseVeyaPlaka, style: TextStyle(color: SiberTema.textMain, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      SizedBox(height: 4),
                      Text("OtoDNA Referanslı Araç", style: TextStyle(color: primaryCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Icon(Icons.qr_code_2, color: SiberTema.textMuted, size: 32)
              ],
            ),
          ),

          Padding(padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0), child: Align(alignment: Alignment.centerLeft, child: Text("Türkiye Geneli İşlem Geçmişi (Zaman Çizelgesi)", style: TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.bold)))),

          // =================================================================
          // ⏳ DNA ZAMAN ÇİZELGESİ (FİREBASE CANLI RADAR)
          // =================================================================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Bu plakaya ait tüm geçmiş raporları tarihe göre (en yeni en üstte) çekiyoruz
                stream: _db.collection('raporlar').where('plaka', isEqualTo: widget.saseVeyaPlaka).orderBy('tarih', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: primaryCyan));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("Bu araca ait henüz bir OtoDNA geçmişi bulunmuyor.", style: TextStyle(color: SiberTema.textMuted)));
                  }

                  var raporlar = snapshot.data!.docs;

                  return ListView.builder(
                    padding: EdgeInsets.all(16), physics: BouncingScrollPhysics(), itemCount: raporlar.length,
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
                                      Container(width: 2, height: 150, color: SiberTema.textMuted), // Çizgi boyu
                                  ],
                                ),
                                SizedBox(width: 16),

                                // İçerik Kartı
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 24), padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isRiskli ? Colors.redAccent.withOpacity(0.5) : Colors.white12)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // İleride burası bayinin il/ilçe bilgisinden çekilebilir
                                            Row(children: [Icon(Icons.location_on, color: SiberTema.textMuted, size: 14), SizedBox(width: 4), Text(firmaAdi, style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: FontWeight.bold))]),
                                            Text(formatliTarih, style: TextStyle(color: SiberTema.textMuted, fontSize: 11)),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(isRiskli ? '❌' : '✅', style: TextStyle(fontSize: 20)),
                                            SizedBox(width: 12),
                                            Expanded(child: Text(islemBasligi, style: TextStyle(color: isRiskli ? Colors.redAccent : Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Text("DNA Skoru Değişimi: -> ${raporData['yeni_dna_skoru'] ?? 'Bilinmiyor'}", style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                                        SizedBox(height: 12),
                                        Divider(color: SiberTema.textMuted),
                                        SizedBox(height: 8),

                                        Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.comment, color: SiberTema.textMuted, size: 14), SizedBox(width: 8), Expanded(child: Text(ustaNotu, style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontStyle: FontStyle.italic)))])),

                                        // İleride Firebase Storage'a yüklenen video URL'sine göre bu buton açılır
                                        SizedBox(height: 16),
                                        OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(side: BorderSide(color: primaryCyan), minimumSize: Size(double.infinity, 40)),
                                            onPressed: () => _videoKanitGoster(firmaAdi, islemBasligi), // Video URL'si eklendiğinde buradan basılacak
                                            icon: Icon(Icons.play_circle_outline, color: primaryCyan, size: 18),
                                            label: Text("Zaman Damgalı İşlem Videosunu İzle", style: TextStyle(color: primaryCyan, fontSize: 12))
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
            padding: EdgeInsets.all(20), decoration: BoxDecoration(color: bgColor, border: Border(top: BorderSide(color: SiberTema.textMuted))),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  // 🚀 YAPAY ZEKA ONAY EKRANINA (MUAYENE) GÖNDER!
                  // Not: Gerçek senaryoda usta önce işlemi seçer, sonra AI ekranına geçer.
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MuayeneOnayEkrani(
                    plakaID: widget.saseVeyaPlaka,
                    islenenKontrolListesi: {"Mekanik Kontrol": 1}, // Test için gönderildi
                    yeniDnaSkoru: 95, // Test için gönderildi
                  )));
                },
                icon: Icon(Icons.add_task, color: bgColor),
                label: Text("Bu Araca Yeni İşlem Kaydet", style: TextStyle(color: bgColor, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          )
        ],
      ),
      ),
    );
  }
}