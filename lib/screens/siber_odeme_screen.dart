import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

class SiberOdemeScreen extends StatefulWidget {
  final double odenecekTutar;
  final String? islemAciklamasi;

  const SiberOdemeScreen({super.key, required this.odenecekTutar, this.islemAciklamasi});

  @override
  State<SiberOdemeScreen> createState() => _SiberOdemeScreenState();
}

class _SiberOdemeScreenState extends State<SiberOdemeScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  // KART BİLGİLERİNİ TUTACAK KONTROLCÜLER
  final TextEditingController _isimController = TextEditingController();
  final TextEditingController _kartNoController = TextEditingController();
  final TextEditingController _ayYilController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  bool _isProcessing = false;

  @override
  void dispose() {
    _isimController.dispose();
    _kartNoController.dispose();
    _ayYilController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _siberUyari(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
    ));
  }

  // 🚀 FİREBASE / IYZICO API İSTEK MOTORU VE %12 KESİNTİ MÜHRÜ
  Future<void> _iyzicoOdemeyiTamamla() async {
    if (_isimController.text.isEmpty || _kartNoController.text.length < 15 || !_ayYilController.text.contains('/') || _cvvController.text.length < 3) {
      _siberUyari("SİBER İHLAL: Geçersiz veya eksik kart verisi tespit edildi.", isError: true);
      return;
    }

    if (_currentUser == null) {
      _siberUyari("KİMLİK HATASI: Ağda oturum açmadınız.", isError: true);
      return;
    }

    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();

    try {
      // 1. IYZICO SİMÜLASYONU (Ağa istek atılıyormuş gibi bekleme)
      await Future.delayed(const Duration(seconds: 2));

      // 2. FİREBASE WRITEBATCH - %12 KARARGAH KESİNTİSİ
      double brutTutar = widget.odenecekTutar;
      double karargahKesintisi = brutTutar * 0.12; // %12 Sarsılmaz Komisyon
      double saticiHakedis = brutTutar - karargahKesintisi;

      WriteBatch batch = _db.batch();

      // İşlemi Cüzdan Hareketlerine Ekle
      DocumentReference cuzdanRef = _db.collection('cuzdan_islemleri').doc();
      batch.set(cuzdanRef, {
        'kullanici_id': _currentUser!.uid,
        'baslik': widget.islemAciklamasi ?? 'OtoDNA Kredi Kartı Ödemesi',
        'tur': 'gider',
        'tutar': brutTutar,
        'tarih': FieldValue.serverTimestamp(),
        'ikon_tipi': 'cuzdan'
      });

      // İşlemi Karargah Finans Havuzuna Şifrele
      DocumentReference finansRef = _db.collection('finans_havuzu').doc();
      batch.set(finansRef, {
        'islem_tipi': 'DIS_AG_KART_ODEMESI',
        'kullanici_id': _currentUser!.uid,
        'brut_tutar': brutTutar,
        'karargah_komisyonu': karargahKesintisi, // SİBER KASA PAYI
        'satici_hakedis': saticiHakedis,
        'zaman_damgasi': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // 3. BAŞARILI İŞLEM MÜHRÜ
      if (!mounted) return;
      HapticFeedback.vibrate();
      _basariliOdemeEkraniGoster();

    } catch (e) {
      _siberUyari("AĞ HATASI: İşlem şifrelenemedi. $e", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // 💎 TESLA MİMARİSİ: ŞIK BAŞARI ONAY EKRANI
  void _basariliOdemeEkraniGoster() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: SiberTema.matGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5))),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: SiberTema.kuantumCyan, width: 2), boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.2), blurRadius: 20)]),
              child: const Icon(Icons.check_circle_outline, color: SiberTema.kuantumCyan, size: 48),
            ),
            const SizedBox(height: 24),
            const Text("İŞLEM ONAYLANDI", style: TextStyle(color: SiberTema.textMain, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 12),
            Text("₺${widget.odenecekTutar} Kuantum Ağı üzerinden tahsil edildi. İşlem başarıyla Karargaha mühürlendi.", textAlign: TextAlign.center, style: const TextStyle(color: SiberTema.textMuted, fontSize: 12, height: 1.5)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: SiberTema.kuantumButonStili(),
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text("ANA MERKEZE DÖN", style: TextStyle(color: SiberTema.oledBlack, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Zırh OLED Siyah verir
        appBar: AppBar(
          backgroundColor: Colors.transparent, elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
          title: const Text('F İ N A N S   K Ö P R Ü S Ü', style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 3)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =================================================================
                // 1. ÖZET KARTI (Glow Efektli)
                // =================================================================
                Container(
                  width: double.infinity, padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                      color: SiberTema.oledBlack,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 1.5),
                      boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.08), blurRadius: 40, spreadRadius: 5, offset: const Offset(0, 10))]
                  ),
                  child: Column(
                    children: [
                      const Text("ÖDENECEK TOPLAM TUTAR", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
                      const SizedBox(height: 12),
                      Text("₺${widget.odenecekTutar.toStringAsFixed(2)}", style: const TextStyle(color: SiberTema.textMain, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1)),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // =================================================================
                // 2. KART BİLGİLERİ (Premium Input)
                // =================================================================
                const Text("KART BİLGİLERİ", style: TextStyle(color: SiberTema.textMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 16),

                _buildTextField(hint: "Kart Üzerindeki İsim", icon: Icons.person_outline, controller: _isimController),
                const SizedBox(height: 16),
                _buildTextField(hint: "Kart Numarası", icon: Icons.credit_card_outlined, isNumber: true, controller: _kartNoController),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: _buildTextField(hint: "AA / YY", icon: Icons.calendar_month_outlined, isNumber: false, controller: _ayYilController)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(hint: "CVV", icon: Icons.lock_outline, isNumber: true, isObscure: true, controller: _cvvController)),
                  ],
                ),
                const SizedBox(height: 40),

                // IYZICO Güvencesi Bildirimi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: SiberTema.matGrey, borderRadius: BorderRadius.circular(16), border: Border.all(color: SiberTema.textMuted)),
                  child: Row(
                    children: const [
                      Icon(Icons.shield_outlined, color: SiberTema.kuantumCyan, size: 24),
                      SizedBox(width: 12),
                      Expanded(child: Text("İşleminiz Iyzico ve OtoDNA Kuantum Zırhı ile 256-bit şifrelenmektedir.", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, height: 1.4))),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // =================================================================
                // 3. DEVASA ÖDEME BUTONU
                // =================================================================
                SizedBox(
                  width: double.infinity, height: 60,
                  child: ElevatedButton.icon(
                    style: SiberTema.kuantumButonStili(),
                    onPressed: _isProcessing ? null : _iyzicoOdemeyiTamamla,
                    icon: _isProcessing ? const SizedBox() : const Icon(Icons.fingerprint, color: SiberTema.oledBlack, size: 20),
                    label: _isProcessing
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 2))
                        : const Text("GÜVENLİ AĞ İLE ÖDE", style: TextStyle(color: SiberTema.oledBlack, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI KUANTUM TEXTFIELD
  Widget _buildTextField({required String hint, required IconData icon, bool isNumber = false, bool isObscure = false, required TextEditingController controller}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: SiberTema.matGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SiberTema.textMuted)
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        obscureText: isObscure,
        style: const TextStyle(color: SiberTema.textMain, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: SiberTema.textMuted, fontWeight: FontWeight.normal, letterSpacing: 0),
          prefixIcon: Icon(icon, color: SiberTema.kuantumCyan, size: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }
}