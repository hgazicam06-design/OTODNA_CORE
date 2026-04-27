import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 SİBER KÖPRÜLER VE TEMA
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

// 🏢 ULTRA PROFESYONEL KURUMSAL PALET
const Color bgColor = Color(0xFFF4F6F8);
const Color surfaceColor = Colors.white;
const Color primaryTeal = Color(0xFF005A64);
const Color secondaryTeal = Color(0xFF009688);
const Color textMain = Color(0xFF1E293B);
const Color textMuted = Color(0xFF64748B);
const Color dangerColor = Color(0xFFD32F2F);

/// 🛡️ SİBER GÜVENLİK ONAY MODÜLÜ (KURUMSAL MÜHÜR)
class SiberOnayKutusu extends StatefulWidget {
  final Function(bool) onChanged;

  const SiberOnayKutusu({super.key, required this.onChanged});

  @override
  State<SiberOnayKutusu> createState() => _SiberOnayKutusuState();
}

class _SiberOnayKutusuState extends State<SiberOnayKutusu> {
  bool _onayliMi = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _onayliMi = !_onayliMi);
        widget.onChanged(_onayliMi);
        if (_onayliMi) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kurumsal Güvenlik Protokolü Aktif. Mühür Hazırlanıyor... 🚀',
                    style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                backgroundColor: primaryTeal,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              )
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _onayliMi ? secondaryTeal.withOpacity(0.05) : surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: _onayliMi ? secondaryTeal : Colors.black.withOpacity(0.05),
              width: 1.5
          ),
          boxShadow: _onayliMi 
            ? [BoxShadow(color: secondaryTeal.withOpacity(0.1), blurRadius: 20)] 
            : [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Siber Mühür (Check Kutusu)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: _onayliMi ? secondaryTeal : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _onayliMi ? secondaryTeal : textMuted.withOpacity(0.3), width: 2),
              ),
              child: _onayliMi ? const Icon(Icons.verified_user, color: SiberTema.kuantumCyan, size: 18) : null,
            ),
            const SizedBox(width: 20),

            // Protokol Metni
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("OTODNA GÜVENLİK PROTOKOLÜ",
                      style: TextStyle(color: _onayliMi ? primaryTeal : textMuted,
                          fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
                  const SizedBox(height: 6),
                  const Text(
                      "Kuantum Ağı Veri Gizliliği Sözleşmesi'ni okudum. Aracımın dijital DNA'sının şifreli işlenmesini ve kurumsal arşive mühürlenmesini onaylıyorum.",
                      style: TextStyle(color: textMain, fontSize: 11, height: 1.4, fontWeight: FontWeight.w600, fontFamily: 'Avenir')),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AnalysisReportScreen extends StatefulWidget {
  const AnalysisReportScreen({super.key});

  @override
  State<AnalysisReportScreen> createState() => _AnalysisReportScreenState();
}

class _AnalysisReportScreenState extends State<AnalysisReportScreen> {
  bool _sistemOnaylandi = false;
  bool _isProcessing = false;

  // --- 🔴 FİREBASE: PROTOKOL MÜHÜRLEME MOTORU ---
  Future<void> _protokoluMuhurleVeGirisYap() async {
    setState(() => _isProcessing = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Protokol Onayını Firestore'a Kalıcı Olarak İşliyoruz (Gerçek Sistem)
      await FirebaseFirestore.instance.collection('kullanicilar').doc(user.uid).update({
        'siber_onay_durumu': true,
        'onay_tarihi': FieldValue.serverTimestamp(),
        'protokolu_onaylayan_ip': 'DYNAMIC_IP_LOGGED', // Simüle edilmiş siber veri
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("ERİŞİM YETKİSİ ONAYLANDI. AĞA GİRİLİYOR...", style: TextStyle(fontFamily: 'Avenir', fontWeight: FontWeight.bold)), backgroundColor: primaryTeal)
        );
        // Burada bir sonraki ana ekrana veya radar ekranına yönlendirme yapılabilir.
        // Navigator.pushReplacementNamed(context, '/ana_ekran');
      }
    } catch (e) {
      debugPrint("SİBER HATA: Protokol mühürlenemedi: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: surfaceColor,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 20),
              onPressed: () => Navigator.pop(context)
          ),
          title: const Text('A N A L İ Z   R A P O R U',
              style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3, fontFamily: 'Avenir')),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: Colors.white.withOpacity(0.05), height: 1.0),
          ),
        ),
        body: Container(
          // Kurumsal filigran
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/radar_grid.png'),
              fit: BoxFit.cover,
              opacity: 0.02,
              colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Üst Kuantum İkonu
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: const Icon(Icons.security_update_good, color: primaryTeal, size: 64),
                ),
                const SizedBox(height: 32),
                const Text("ERİŞİM İZNİ BEKLENİYOR",
                    style: TextStyle(color: textMain, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'Avenir')),
                const SizedBox(height: 12),
                const Text("Sisteme devam etmek için güvenlik protokolünü okuyup onaylamanız gerekmektedir.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Avenir', height: 1.5)),

                const SizedBox(height: 40),

                // Siber Onay Modülü
                SiberOnayKutusu(
                  onChanged: (val) => setState(() => _sistemOnaylandi = val),
                ),

                const SizedBox(height: 32),

                // Aksiyon Butonu
                SizedBox(
                  width: double.infinity, height: 65,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _sistemOnaylandi ? primaryTeal : Colors.black.withOpacity(0.05),
                      foregroundColor: _sistemOnaylandi ? Colors.white : textMuted,
                      elevation: _sistemOnaylandi ? 15 : 0,
                      shadowColor: primaryTeal.withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: BorderSide.none,
                    ),
                    onPressed: (_sistemOnaylandi && !_isProcessing) ? _protokoluMuhurleVeGirisYap : null,
                    icon: _isProcessing
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Icon(_sistemOnaylandi ? Icons.lock_open_rounded : Icons.lock_person_rounded, size: 22),
                    label: Text(
                        _isProcessing ? "YETKİ ALINIYOR..." : (_sistemOnaylandi ? "SİSTEME GİRİŞ YAP" : "PROTOKOLÜ ONAYLAYIN"),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.5, fontFamily: 'Avenir')
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}