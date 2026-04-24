// lib/screens/bayi/dukkan_vitrin_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI
import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';

/// 🦅 OTODNA DÜKKAN VİTRİNİ VE TEŞHİR MERKEZİ
/// Firmanın puanına göre (Altın, Gümüş, Bronz veya KARA LİSTE) otonom şekil alır.
class DukkanVitrinScreen extends StatelessWidget {
  final String bayiId;

  const DukkanVitrinScreen({super.key, required this.bayiId});

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("FİRMA VİTRİNİ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 14, fontFamily: 'Avenir')),
          centerTitle: true,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 18), onPressed: () => Navigator.pop(context)),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          // 📡 FİREBASE CANLI RADAR BAĞLANTISI (Kuantum Standart Tablo: kullanicilar)
          stream: FirebaseFirestore.instance.collection('kullanicilar').doc(bayiId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return _buildHataEkrani("SİBER İHLAL: FİRMA BULUNAMADI!");
            }

            var firmaData = snapshot.data!.data() as Map<String, dynamic>;
            String firmaAdi = firmaData['firma_adi'] ?? "Bilinmeyen Firma";
            int yildizSayisi = (firmaData['yildiz_sayisi'] ?? 3).toInt();
            String rozet = firmaData['rozet'] ?? "BRONZ";

            // 🔥 KARA LİSTE KONTROL MOTORU (1 Yıldız = Kara Liste)
            bool isKaraListe = yildizSayisi <= 1 || rozet.toUpperCase() == "KARA LİSTE" || rozet.toUpperCase() == "BLACKLIST";

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🛑 EĞER FİRMA KARA LİSTEDEYSE DEV UYARI BANDI ÇIKAR
                  if (isKaraListe) _buildKaraListeDamgasi(),

                  const SizedBox(height: 24),

                  // ── FİRMA KİMLİK KARTI ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isKaraListe ? SiberTema.kanKirmizi.withOpacity(0.05) : SiberTema.matGrey,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isKaraListe ? SiberTema.kanKirmizi.withOpacity(0.5) : SiberTema.kuantumCyan.withOpacity(0.3),
                          width: 2
                      ),
                      boxShadow: isKaraListe
                          ? [BoxShadow(color: SiberTema.kanKirmizi.withOpacity(0.2), blurRadius: 20)]
                          : [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 20)],
                    ),
                    child: Column(
                      children: [
                        Icon(
                            isKaraListe ? Icons.warning_rounded : Icons.store_mall_directory_outlined,
                            color: isKaraListe ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
                            size: 60
                        ),
                        const SizedBox(height: 16),
                        Text(
                          firmaAdi.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: isKaraListe ? SiberTema.kanKirmizi : Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              fontFamily: 'Avenir'
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 🌟 YILDIZ VE ROZET SİSTEMİ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...List.generate(5, (index) => Icon(
                              index < yildizSayisi ? Icons.star : Icons.star_border,
                              color: isKaraListe ? SiberTema.kanKirmizi : SiberTema.altinSari,
                              size: 20,
                            )),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isKaraListe ? SiberTema.kanKirmizi : SiberTema.siberGold.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                rozet.toUpperCase(),
                                style: TextStyle(
                                    color: isKaraListe ? SiberTema.oledBlack : SiberTema.siberGold,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── İŞLEM BUTONLARI (KARA LİSTEDEYSE KİLİTLENİR VEYA UYARI VERİR) ──
                  if (!isKaraListe) ...[
                    _buildSiberButon("RANDEVU AL", Icons.calendar_month, SiberTema.kuantumCyan, () {
                      FirebaseFirestore.instance.collection('siber_istihbarat_loglari').add({
                        'kategori': 'KULLANICI',
                        'seviye': 'BİLGİ',
                        'mesaj': 'YENİ RANDEVU TALEBİ: Bir müşteri $firmaAdi firmasından randevu talep etti.',
                        'hedef_id': bayiId,
                        'tarih': FieldValue.serverTimestamp(),
                      });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Randevu talebi Karargaha ve bayiye iletildi!", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.bold)), backgroundColor: SiberTema.kuantumCyan));
                    }),
                    const SizedBox(height: 16),
                    _buildSiberButon("S.O.S YARDIM ÇAĞIR", Icons.sos, SiberTema.altinSari, () {
                      WriteBatch batch = FirebaseFirestore.instance.batch();
                      
                      // 1. SOS Sinyalini Oluştur
                      DocumentReference sosRef = FirebaseFirestore.instance.collection('sos_sinyalleri').doc();
                      batch.set(sosRef, {
                        'hedef_bayi_1': bayiId,
                        'durum': 'YENI_SINYAL',
                        'plaka': 'ACİL YARDIM',
                        'sinyal_zamani': FieldValue.serverTimestamp(),
                      });
                      
                      // 2. Siber İstihbarata Mühürle
                      DocumentReference logRef = FirebaseFirestore.instance.collection('siber_istihbarat_loglari').doc();
                      batch.set(logRef, {
                        'kategori': 'GÜVENLİK',
                        'seviye': 'KRİTİK',
                        'mesaj': 'KIRMIZI KOD: Müşteri doğrudan $firmaAdi firmasına acil S.O.S çağrısı gönderdi!',
                        'hedef_id': bayiId,
                        'tarih': FieldValue.serverTimestamp(),
                      });
                      
                      batch.commit();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("S.O.S Sinyali Fırlatıldı! Ekip yola çıkıyor!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: SiberTema.kanKirmizi));
                    }),
                  ] else ...[
                    // KARA LİSTE FİRMASINDA BUTONLAR PASİFTİR VEYA FARKLI ÇALIŞIR
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10)
                      ),
                      child: const Text(
                        "SİBER KİLİT: Bu firma Karargah kurallarını ihlal ettiği için sistem üzerinden yeni işlem veya randevu kabul edemez. Sadece geçmiş kayıtları görüntülenebilir.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, height: 1.5, fontFamily: 'Avenir'),
                      ),
                    )
                  ]
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 🛑 DEVASA KARA LİSTE DAMGASI
  Widget _buildKaraListeDamgasi() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SiberTema.kanKirmizi.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiberTema.kanKirmizi, width: 2),
      ),
      child: const Column(
        children: [
          Icon(Icons.gavel_rounded, color: SiberTema.kanKirmizi, size: 40),
          SizedBox(height: 12),
          Text("SİBER KARARGAH İHLALİ", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 3, fontFamily: 'Avenir')),
          SizedBox(height: 8),
          Text(
            "BU FİRMA OTODNA STANDARTLARINA UYMAYAN İŞLEMLER SEBEBİYLE KARA LİSTEYE ALINMIŞTIR. GÜVENLİĞİNİZ İÇİN TERCİH ETMENİZ ÖNERİLMEZ.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, height: 1.5, fontFamily: 'Avenir'),
          ),
        ],
      ),
    );
  }

  // ⚡ STANDART SİBER BUTON
  Widget _buildSiberButon(String text, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        icon: Icon(icon, size: 20),
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, fontFamily: 'Avenir')),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildHataEkrani(String mesaj) {
    return Center(
      child: Text(mesaj, style: const TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
    );
  }
}