import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/responsive_kalkan.dart';

class KvkkOnayScreen extends StatefulWidget {
  final String hedefRota; // Onaylandıktan sonra nereye gidilecek? (Örn: /home)

  const KvkkOnayScreen({super.key, required this.hedefRota});

  @override
  State<KvkkOnayScreen> createState() => _KvkkOnayScreenState();
}

class _KvkkOnayScreenState extends State<KvkkOnayScreen> {
  // ⚜️ RENK PALETİ (Fildişi Sedef & Metalik Gold)
  static const Color darkGold = Color(0xFFB8860B);
  static const Color bgIvory = Color(0xFFFAFAFC);
  static const Color textDark = Color(0xFF2C2519);
  static const Color cardWhite = Colors.white;

  bool _kvkkOnay = false;
  bool _kullanimSartlariOnay = false;
  bool _acikRizaOnay = false; // Pazarlama izni

  bool get _zorunluOnaylarTamam => _kvkkOnay && _kullanimSartlariOnay;

  Future<void> _sistemeGirisYap() async {
    if (_zorunluOnaylarTamam) {
      HapticFeedback.mediumImpact();
      
      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          await FirebaseFirestore.instance.collection('kullanicilar').doc(userId).update({
            'kvkk_onay': true,
            'pazarlama_onay': _acikRizaOnay,
            'sozlesme_onay_tarihi': FieldValue.serverTimestamp(),
          });
          // AuthGate Firestore stream'i dinlediği için state otomatik yenilenip kullanıcıyı içeri alacak.
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ağ Hatası. Lütfen tekrar deneyin.", style: TextStyle(color: Colors.white, fontFamily: 'Avenir')), backgroundColor: Colors.redAccent));
      }

    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("SİSTEM UYARISI: Zorunlu hukuki sözleşmeleri onaylamadan platforma giriş yapamazsınız.", style: TextStyle(color: Colors.white, fontFamily: 'Avenir')),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgIvory,
        appBar: AppBar(
          backgroundColor: bgIvory,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: textDark, size: 20),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.pop();
            },
          ),
          title: const Text(
            "YASAL ONAY PROTOKOLÜ",
            style: TextStyle(
              color: textDark,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              fontFamily: 'Avenir',
              letterSpacing: 2.0,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.security_outlined, color: darkGold, size: 60),
                const SizedBox(height: 24),
                const Text(
                  "SİBER ZIRH VE HUKUKİ GÜVENLİK",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir'),
                ),
                const SizedBox(height: 12),
                Text(
                  "Platformu kullanmaya başlamadan önce sizin güvenliğiniz ve 6698 sayılı KVKK gereği aşağıdaki metinleri okuyup onaylamanız zorunludur.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textDark.withOpacity(0.7), fontSize: 12, height: 1.5, fontFamily: 'Avenir'),
                ),
                const SizedBox(height: 40),

                // ZORUNLU: Kullanım Şartları
                _buildOnayKutusu(
                  "Kullanım Koşulları ve Gizlilik Politikası'nı okudum, anladım ve kabul ediyorum.",
                  _kullanimSartlariOnay,
                  (val) => setState(() => _kullanimSartlariOnay = val ?? false),
                  true,
                ),

                // ZORUNLU: KVKK
                _buildOnayKutusu(
                  "KVKK Aydınlatma Metni kapsamında kişisel verilerimin işlenmesini onaylıyorum.",
                  _kvkkOnay,
                  (val) => setState(() => _kvkkOnay = val ?? false),
                  true,
                ),

                // OPSIYONEL: Açık Rıza
                _buildOnayKutusu(
                  "Açık Rıza Beyanı kapsamında tarafıma kampanyalar ve bilgilendirmeler (SMS/E-Posta) gönderilmesini kabul ediyorum.",
                  _acikRizaOnay,
                  (val) => setState(() => _acikRizaOnay = val ?? false),
                  false,
                ),

                const Spacer(),

                // ONAYLA BUTONU
                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _zorunluOnaylarTamam ? darkGold : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      elevation: _zorunluOnaylarTamam ? 4 : 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _sistemeGirisYap,
                    child: const Text(
                      "SÖZLEŞMELERİ ONAYLA VE GİRİŞ YAP",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, fontFamily: 'Avenir'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/hukuki_metinler'),
                    child: const Text("Metinlerin Tamamını Oku", style: TextStyle(color: darkGold, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, fontFamily: 'Avenir')),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnayKutusu(String metin, bool deger, Function(bool?) onChange, bool zorunlu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: deger ? darkGold : Colors.black12, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
      ),
      child: CheckboxListTile(
        value: deger,
        onChanged: onChange,
        activeColor: darkGold,
        checkColor: Colors.white,
        side: const BorderSide(color: Colors.black26),
        controlAffinity: ListTileControlAffinity.leading,
        title: RichText(
          text: TextSpan(
            children: [
              if (zorunlu) const TextSpan(text: "* ", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              TextSpan(
                text: metin,
                style: const TextStyle(color: textDark, fontSize: 12, height: 1.4, fontFamily: 'Avenir'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
