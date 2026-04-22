import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/siber_tema.dart';
import '../../models/car_ad_model.dart';

class SiberIlanDetayScreen extends StatefulWidget {
  final CarAd ad;

  const SiberIlanDetayScreen({super.key, required this.ad});

  @override
  State<SiberIlanDetayScreen> createState() => _SiberIlanDetayScreenState();
}

class _SiberIlanDetayScreenState extends State<SiberIlanDetayScreen> {
  static const Color primaryCyan = SiberTema.kuantumCyan;
  static const Color siberGold = SiberTema.siberGold;
  static const Color dangerColor = SiberTema.kanKirmizi;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isReserving = false;

  Future<void> _kuantumKaporaYatir() async {
    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Siber Kimliğiniz doğrulanamadı. Giriş yapmalısınız."), backgroundColor: dangerColor));
      return;
    }

    // 💰 MOCK ÖDEME ONAYI
    bool? odemeOnayi = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), border: Border.all(color: siberGold.withOpacity(0.5))),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: siberGold),
            SizedBox(width: 8),
            Text("Siber Havuz Blokajı", style: TextStyle(color: siberGold, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
          ],
        ),
        content: Text(
          "Bu aracı rezerve etmek için ₺${widget.ad.kaporaBedeli.toStringAsFixed(0)} tutarındaki kapora bedeli Karargah Havuzuna çekilecektir. Araç devri yapılana kadar para güvende tutulur. Onaylıyor musunuz?",
          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5, fontFamily: 'Avenir'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("İPTAL", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: siberGold, foregroundColor: Colors.black),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("KAPORAYI KİLİTLE", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (odemeOnayi == true) {
      setState(() => _isReserving = true);

      try {
        // ⛓️ ATOMİK İŞLEM: İlan Durumunu Güncelle ve Kaporayı Havuza İşle
        WriteBatch batch = _db.batch();

        // 1. İlanı Rezerve yap
        DocumentReference adRef = _db.collection('vehicles_ads').doc(widget.ad.id);
        batch.update(adRef, {'ilan_durumu': 'Rezerve Edildi'});

        // 2. Kaporayı Havuza İşle (Log)
        DocumentReference logRef = _db.collection('sistem_loglari').doc();
        batch.set(logRef, {
          'islem_turu': 'KAPORA_BLOKAJI',
          'islem_detayi': '${user.uid} numaralı kullanıcı, ${widget.ad.brandModel} için ₺${widget.ad.kaporaBedeli} kapora kilitledi.',
          'ilan_id': widget.ad.id,
          'alic_uid': user.uid,
          'tarih': FieldValue.serverTimestamp()
        });

        await batch.commit();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ ARAÇ REZERVE EDİLDİ! Kapora havuza kilitlendi."), backgroundColor: primaryCyan));
          Navigator.pop(context); // Vitrine geri dön
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ağ Çöktü: $e"), backgroundColor: dangerColor));
        }
      } finally {
        if (mounted) setState(() => _isReserving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String formatliFiyat = "₺${widget.ad.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
    String coverImg = widget.ad.images.isNotEmpty ? widget.ad.images.first : 'https://via.placeholder.com/600x400/111111/00FFC2?text=SİBER+GÖRSEL';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. ÜST DEV GÖRSEL VE GRADYAN
          Positioned(
            top: 0, left: 0, right: 0,
            height: 350,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(coverImg, fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.black],
                    ),
                  ),
                )
              ],
            ),
          ),

          // 2. ANA İÇERİK (KAYDIRILABİLİR)
          SafeArea(
            child: Column(
              children: [
                _buildSiberAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 200, left: 24, right: 24, bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBaslikVeFiyat(formatliFiyat),
                        const SizedBox(height: 24),
                        _buildGuvenlikKalkani(),
                        const SizedBox(height: 32),
                        const Text("İSTİHBARAT DETAYI", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, fontFamily: 'Avenir')),
                        const SizedBox(height: 12),
                        Text(widget.ad.description, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5, fontFamily: 'Avenir')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. EN ALT SABİT KAPORA BUTONU
          Positioned(bottom: 0, left: 0, right: 0, child: _buildKaporaTerminali()),
        ],
      ),
    );
  }

  Widget _buildSiberAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle), child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18)),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle), child: const Icon(Icons.favorite_border, color: Colors.white, size: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaslikVeFiyat(String fiyat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(widget.ad.brandModel.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Avenir', height: 1.2)),
            ),
            if (widget.ad.otodnaReferansliMi)
              Container(
                margin: const EdgeInsets.only(left: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: primaryCyan.withOpacity(0.5))),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: primaryCyan, size: 14),
                    SizedBox(width: 4),
                    Text("ONAYLI", style: TextStyle(color: primaryCyan, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                  ],
                ),
              )
          ],
        ),
        const SizedBox(height: 12),
        Text(fiyat, style: const TextStyle(color: primaryCyan, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.storefront, color: Colors.white38, size: 14),
            const SizedBox(width: 6),
            Text(widget.ad.saticiAdi, style: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'Avenir')),
          ],
        )
      ],
    );
  }

  Widget _buildGuvenlikKalkani() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: siberGold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: siberGold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: siberGold.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.shield_outlined, color: siberGold, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SİBER KAPORA GÜVENCESİ", style: TextStyle(color: siberGold, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                const SizedBox(height: 4),
                Text(
                  widget.ad.isSecureDeposit 
                    ? "Satıcı bu aracı Karargah Havuzu güvencesine açtı. Kaporanız araç size geçene kadar OtoDNA sisteminde kilitli kalır." 
                    : "Bu ilan Güvenli Kapora korumasında değildir.",
                  style: const TextStyle(color: Colors.white54, fontSize: 10, height: 1.4, fontFamily: 'Avenir'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildKaporaTerminali() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20).copyWith(bottom: MediaQuery.of(context).padding.bottom + 20),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.8), border: const Border(top: BorderSide(color: Colors.white10))),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("KAPORA BEDELİ", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Avenir')),
                  const SizedBox(height: 4),
                  Text("₺${widget.ad.kaporaBedeli.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.ad.isSecureDeposit ? siberGold : Colors.white10,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: (widget.ad.isSecureDeposit && !_isReserving) ? _kuantumKaporaYatir : null,
                    child: _isReserving
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          widget.ad.isSecureDeposit ? "GÜVENLİ REZERVE ET" : "KORUMA YOK", 
                          style: TextStyle(color: widget.ad.isSecureDeposit ? Colors.black : Colors.white54, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')
                        ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
