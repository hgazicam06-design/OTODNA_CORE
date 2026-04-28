import 'package:otodna/core/siber_tema.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ad_campaign_model.dart';
import '../core/siber_tema.dart';

class SiberHedefliReklamPanosu extends StatelessWidget {
  final OtoDNACampaign kampanya;
  
  SiberHedefliReklamPanosu({super.key, required this.kampanya});

  void _reklamaTikla(BuildContext context) async {
    // 🔥 KARARGAH FİNANS PROTOKOLÜ: Tıklanma %12 Komisyon İçin Atomik Olarak İşlenir
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      DocumentReference docRef = FirebaseFirestore.instance.collection('market_reklamlar').doc(kampanya.id);
      
      batch.update(docRef, {
        'tiklanma_sayisi': FieldValue.increment(1),
        'son_tiklanma_tarihi': FieldValue.serverTimestamp(),
      });
      
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("🚀 ${kampanya.sirketAd} Sistemine Yönlendiriliyor... (Ağ Komisyonu İşlendi)"),
          backgroundColor: SiberTema.kuantumCyan,
        )
      );

      // İleride buraya url_launcher eklenecek.
      // launchUrl(Uri.parse(kampanya.hedefLink));

    } catch (e) {
      debugPrint("SİBER HATA: Reklam Tıklaması Karargaha İletilemedi!");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kampanya.aktifMi) return SizedBox.shrink();

    return GestureDetector(
      onTap: () => _reklamaTikla(context),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: SiberTema.siberGold.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: SiberTema.siberGold.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 2,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // ARKA PLAN GÖRSELİ VEYA RENGİ
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  image: kampanya.gorselUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(kampanya.gorselUrl),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                        )
                      : null,
                ),
              ),
              
              // SİBER CAM EFEKTİ (Glassmorphism)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(color: Colors.transparent),
                ),
              ),

              // İÇERİK
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // REKLAM İKONU / ROZETİ
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: SiberTema.siberGold.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: SiberTema.siberGold),
                      ),
                      child: Icon(Icons.star_rounded, color: SiberTema.siberGold, size: 28),
                    ),
                    SizedBox(width: 16),
                    
                    // METİNLER
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: SiberTema.kuantumCyan.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "SPONSORLU KAMPANYA", 
                              style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            kampanya.kampanyaBaslik,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Avenir',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            kampanya.sirketAd.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              fontFamily: 'Avenir',
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // GİT BUTONU
                    Icon(Icons.arrow_forward_ios, color: SiberTema.siberGold, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
