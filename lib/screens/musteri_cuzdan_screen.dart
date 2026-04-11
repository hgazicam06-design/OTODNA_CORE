import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🦅 OTO DNA SİBER TEMİNAT CÜZDANI - FİNANSAL TAKİP MOTORU
/// [2026-03-28] GÜNCELLEME: %100 GERÇEK FIREBASE STREAM AKIŞI
class MusteriCuzdanScreen extends StatefulWidget {
  const MusteriCuzdanScreen({super.key});

  @override
  State<MusteriCuzdanScreen> createState() => _MusteriCuzdanScreenState();
}

class _MusteriCuzdanScreenState extends State<MusteriCuzdanScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // SİBER GÜVENLİK: Kullanıcı giriş ihlali kontrolü
    if (_user == null) {
      return const Scaffold(
        backgroundColor: SiberTema.oledBlack,
        body: Center(child: Text("SİBER İHLAL: KİMLİK DOĞRULANAMADI!", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.bold))),
      );
    }

    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text("SİBER TEMİNAT CÜZDANI", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
          centerTitle: true,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 💰 1. CANLI KUANTUM BAKİYE KARTI
                        _buildKuantumBakiyeKarti(),

                        const SizedBox(height: 48),

                        // 📜 2. İŞLEM GEÇMİŞİ BAŞLIĞI
                        Row(
                          children: [
                            const Icon(Icons.history_toggle_off, color: SiberTema.kuantumCyan, size: 20),
                            const SizedBox(width: 12),
                            const Text("SON SİBER İŞLEMLER", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                            const Spacer(),
                            Text("DNA KESİNTİSİ: %12", style: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Colors.white10, thickness: 1)),

                        // 🔄 3. CANLI FIREBASE İŞLEM RADARI
                        _buildIslemGecmisiListesi(),
                      ],
                    ),
                  ),
                ),

                // ⚠️ 4. MERKEZ KARARGAH BİLGİ BANDI
                _buildMerkezBilgiBandi(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: KUANTUM BAKİYE KARTI (Siber Cam Efekti)
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
            color: SiberTema.matGrey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
            boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 30)],
          ),
          child: Column(
            children: [
              const Text("HAVUZDAKİ SİBER TEMİNATINIZ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 16),
              if (snapshot.connectionState == ConnectionState.waiting)
                const CircularProgressIndicator(color: SiberTema.kuantumCyan)
              else
                Text("₺${bakiye.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 2)),
              const SizedBox(height: 16),
              _buildGuvenlikRozeti(),
              const SizedBox(height: 32),
              _buildYuklemeButonu(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuvenlikRozeti() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.2))),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield, color: SiberTema.kuantumCyan, size: 12),
          SizedBox(width: 8),
          Text("ANKARA MERKEZ GÜVENCESİNDE", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildYuklemeButonu() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: SiberTema.kuantumCyan,
          side: const BorderSide(color: SiberTema.kuantumCyan, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _siberMesajGoster("ÖDEME AĞINA BAĞLANILIYOR..."),
        icon: const Icon(Icons.add_card, size: 18),
        label: const Text("TEMİNAT YÜKLE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: İŞLEM LİSTESİ (Gerçek Zamanlı)
  Widget _buildIslemGecmisiListesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('kullanicilar').doc(_user!.uid).collection('islemler').orderBy('tarih', descending: true).limit(20).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildBosDurum();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            double tutar = (data['tutar'] ?? 0.0).toDouble();
            bool isGider = tutar < 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SiberTema.matGrey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  _buildIslemIkonu(isGider),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((data['baslik'] ?? 'İŞLEM').toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                        Text((data['alt_baslik'] ?? '-').toString().toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Text(
                    "${isGider ? '' : '+'}${tutar.toStringAsFixed(2)} ₺",
                    style: TextStyle(color: isGider ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildIslemIkonu(bool isGider) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isGider ? SiberTema.kanKirmizi.withOpacity(0.1) : SiberTema.kuantumCyan.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(isGider ? Icons.outbox : Icons.account_balance_wallet, color: isGider ? SiberTema.kanKirmizi : SiberTema.kuantumCyan, size: 18),
    );
  }

  Widget _buildBosDurum() {
    return Column(
      children: [
        Icon(Icons.receipt_long, color: Colors.white.withOpacity(0.1), size: 48),
        const SizedBox(height: 16),
        const Text("SİBER KAYIT BULUNAMADI", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildMerkezBilgiBandi() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: SiberTema.matGrey, border: Border(top: BorderSide(color: Colors.white12))),
      child: const Text(
        "MERKEZ BİLGİSİ: Randevu kaporaları toplam faturadan düşülür. OtoDNA %12 Kuantum Kesinti Protokolü (Murat Plaza hariç) devrededir.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, height: 1.5),
      ),
    );
  }

  void _siberMesajGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: SiberTema.kuantumCyan));
  }
}