import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MusteriCuzdanScreen extends StatefulWidget {
  const MusteriCuzdanScreen({super.key});

  @override
  State<MusteriCuzdanScreen> createState() => _MusteriCuzdanScreenState();
}

class _MusteriCuzdanScreenState extends State<MusteriCuzdanScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;
  static const Color warningColor = Colors.orangeAccent;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // SİBER GÜVENLİK: Kullanıcı giriş yapmamışsa uyar
    if (_user == null) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: Text("SİBER İHLAL: KULLANICI KİMLİĞİ BULUNAMADI!", style: TextStyle(color: dangerColor, fontWeight: FontWeight.bold))),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("SİBER TEMİNAT CÜZDANI", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // 🖥️ Web & Teyp Kalkanı
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 💰 1. CANLI FİREBASE BAKİYE KARTI
                        _buildKuantumBakiyeKarti(),

                        const SizedBox(height: 48),

                        // 📜 2. İŞLEM GEÇMİŞİ BAŞLIĞI
                        Row(
                          children: [
                            Icon(Icons.history_toggle_off, color: primaryCyan.withOpacity(0.5), size: 20),
                            const SizedBox(width: 12),
                            const Text("SON SİBER İŞLEMLER", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white12, thickness: 1)),

                        // 🔄 3. CANLI FİREBASE İŞLEM LİSTESİ
                        _buildIslemGecmisiListesi(),
                      ],
                    ),
                  ),
                ),

                // ⚠️ 4. MERKEZ KARARGAH BİLGİLENDİRMESİ
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: surfaceColor, border: const Border(top: BorderSide(color: Colors.white12))),
                  child: const Text(
                      "MERKEZ BİLGİSİ: Randevuya gittiğinizde bloke edilen kaporalar toplam faturadan düşülecektir. OtoDNA %12 Kuantum Kesinti Protokolü devrededir.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1, height: 1.5)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: KUANTUM BAKİYE KARTI (Firebase Stream)
  Widget _buildKuantumBakiyeKarti() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _db.collection('kullanicilar').doc(_user!.uid).snapshots(),
      builder: (context, snapshot) {
        double bakiye = 0.0;

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          bakiye = (data['cuzdan_bakiyesi'] ?? 0.0).toDouble();
        }

        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: primaryCyan.withOpacity(0.5), width: 2),
            boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.1), blurRadius: 30, spreadRadius: 5)],
          ),
          child: Column(
            children: [
              const Text("HAVUZDAKİ SİBER TEMİNATINIZ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 16),
              snapshot.connectionState == ConnectionState.waiting
                  ? const CircularProgressIndicator(color: primaryCyan)
                  : Text(
                  "₺${bakiye.toStringAsFixed(2)}",
                  style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 2)
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text("ANKARA MERKEZ GÜVENCESİNDE", style: TextStyle(color: primaryCyan, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const SizedBox(height: 24),
              // BAKİYE YÜKLE BUTONU
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryCyan,
                    side: const BorderSide(color: primaryCyan, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // TODO: İyzico veya PayTR entegrasyon ekranına yönlendir
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ÖDEME AĞINA BAĞLANILIYOR...", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan));
                  },
                  icon: const Icon(Icons.add_card, size: 18),
                  label: const Text("TEMİNAT YÜKLE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // 💎 YARDIMCI BİLEŞEN: İŞLEM LİSTESİ (Firebase Stream)
  Widget _buildIslemGecmisiListesi() {
    return StreamBuilder<QuerySnapshot>(
      // İşlemleri tarihe göre azalan sırayla çekiyoruz
      stream: _db.collection('kullanicilar').doc(_user!.uid).collection('islemler').orderBy('tarih', descending: true).limit(10).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: primaryCyan)));
        }

        // EĞER AĞDA İŞLEM YOKSA (Sıfır Bakiye)
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.receipt_long, color: Colors.white.withOpacity(0.1), size: 48),
                  const SizedBox(height: 16),
                  const Text("SİBER KAYIT BULUNAMADI", style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const Text("Henüz bir işlem gerçekleştirmediniz.", style: TextStyle(color: Colors.white24, fontSize: 10)),
                ],
              ),
            ),
          );
        }

        // 🚀 GERÇEK FİREBASE VERİSİ
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // Scroll çakışmasını önlemek için
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;

            String baslik = data['baslik'] ?? 'BİLİNMEYEN İŞLEM';
            String altBaslik = data['alt_baslik'] ?? 'Detay Yok';
            double tutar = (data['tutar'] ?? 0.0).toDouble();
            bool isGider = tutar < 0; // Tutar eksiyse Kırmızı (Gider), artıysa Turkuaz (Gelir/Yükleme)

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: isGider ? warningColor.withOpacity(0.1) : primaryCyan.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(isGider ? Icons.shopping_cart_checkout : Icons.account_balance_wallet, color: isGider ? warningColor : primaryCyan, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(baslik.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text(altBaslik.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ],
                    ),
                  ),
                  Text(
                    "${isGider ? '' : '+'}₺${tutar.abs().toStringAsFixed(2)}",
                    style: TextStyle(color: isGider ? dangerColor : primaryCyan, fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}