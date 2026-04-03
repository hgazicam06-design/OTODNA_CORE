import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color firmAccent = Colors.purpleAccent;
  static const Color dangerColor = Colors.redAccent;

  // Kullanıcı Tipi: true ise Bireysel, false ise Firma (Bayi)
  bool _isKullanici = true;
  bool _garantiSozlesmesiKabul = false;
  bool _isProcessing = false;

  final TextEditingController _isimController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void dispose() {
    _isimController.dispose();
    _emailController.dispose();
    _telefonController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  // 🚀 FİREBASE: SİBER KAYIT VE ATOMİK İSTİHBARAT MOTORU
  Future<void> _kayitProtokolunuBaslat() async {
    final isim = _isimController.text.trim();
    final email = _emailController.text.trim();
    final telefon = _telefonController.text.trim();
    final sifre = _sifreController.text.trim();

    // 1. ZIRH KONTROLLERİ
    if (isim.isEmpty || email.isEmpty || telefon.isEmpty || sifre.isEmpty) {
      _uyariGoster("SİBER İHLAL: TÜM ALANLAR DOLDURULMALIDIR!", isError: true);
      return;
    }
    if (sifre.length < 6) {
      _uyariGoster("ZAYIF ŞİFRE: Kuantum şifresi en az 6 haneli olmalıdır!", isError: true);
      return;
    }
    if (!_isKullanici && !_garantiSozlesmesiKabul) {
      _uyariGoster("GÜVENLİK İHLALİ: Ulusal Garanti Sözleşmesini onaylamanız zorunludur!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 2. KİMLİK OLUŞTURMA (Auth)
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: sifre,
      );

      String uid = userCredential.user!.uid;

      // 3. ATOMİK VERİ YAZMA (Kullanıcı profili ve Bayi ise Karargah Sinyali)
      WriteBatch batch = _db.batch();

      // Ana Kullanıcı Profili
      DocumentReference userRef = _db.collection('kullanicilar').doc(uid);
      batch.set(userRef, {
        'isim_unvan': isim.toUpperCase(),
        'email': email,
        'telefon': telefon,
        'rol': _isKullanici ? 'MUSTERI' : 'BAYI',
        'cuzdan_bakiyesi': 0.0,
        'kayit_tarihi': FieldValue.serverTimestamp(),
      });

      // EĞER BAYİ İSE ANKARA MERKEZ KARARGAHA SİNYAL GÖNDER (bayi_basvurulari)
      if (!_isKullanici) {
        DocumentReference bayiRef = _db.collection('bayi_basvurulari').doc(uid);
        batch.set(bayiRef, {
          'isim': isim.toUpperCase(),
          'email': email,
          'telefon': telefon,
          'bolge': 'BÖLGE ATANMADI',
          'durum': 'Bekliyor', // AnkaraMerkezAdmin ekranına düşmesi için sihirli kelime!
          'not': 'YENİ SİBER BAŞVURU',
          'basvuru_tarihi': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (!mounted) return;
      _uyariGoster(_isKullanici ? "AĞA KATILIM BAŞARILI! 🦅" : "BAŞVURU MERKEZE İLETİLDİ! ONAY BEKLENİYOR 🦅");

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context); // Kayıt bitince Login'e geri dön
      });

    } on FirebaseAuthException catch (e) {
      String hata = "AĞ ÇÖKTÜ: Kayıt başarısız!";
      if (e.code == 'email-already-in-use') hata = "BU SİBER KİMLİK (E-POSTA) ZATEN KULLANIMDA!";
      if (e.code == 'invalid-email') hata = "GEÇERSİZ SİNYAL: E-Posta formatı hatalı!";
      _uyariGoster(hata, isError: true);
    } catch (e) {
      _uyariGoster("SİSTEM HATASI: Veritabanı mühürlenemedi.", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _uyariGoster(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1)),
        backgroundColor: isError ? dangerColor : primaryCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color activeAccent = _isKullanici ? primaryCyan : firmAccent;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: activeAccent, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500), // 🖥️ Web / Double Teyp Kalkanı
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("AĞA KATIL", style: TextStyle(color: activeAccent, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  const Text("OtoDNA Kuantum Ekosistemine entegre olun.", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 40),

                  // 1. KULLANICI / FİRMA SEÇİM ZIRHI (TOGGLE)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() { _isKullanici = true; _garantiSozlesmesiKabul = false; }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: _isKullanici ? primaryCyan.withOpacity(0.15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _isKullanici ? primaryCyan.withOpacity(0.5) : Colors.transparent),
                              ),
                              child: Text("BİREYSEL", textAlign: TextAlign.center, style: TextStyle(color: _isKullanici ? primaryCyan : Colors.white38, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isKullanici = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: !_isKullanici ? firmAccent.withOpacity(0.15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: !_isKullanici ? firmAccent.withOpacity(0.5) : Colors.transparent),
                              ),
                              child: Text("KURUMSAL", textAlign: TextAlign.center, style: TextStyle(color: !_isKullanici ? firmAccent : Colors.white38, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 2. DİNAMİK KAYIT FORMLARI
                  _buildKayitTextField(controller: _isimController, hint: _isKullanici ? "AD SOYAD" : "FİRMA UNVANI", icon: Icons.person_outline, accentColor: activeAccent),
                  const SizedBox(height: 16),
                  _buildKayitTextField(controller: _emailController, hint: "SİBER E-POSTA", icon: Icons.alternate_email, isEmail: true, accentColor: activeAccent),
                  const SizedBox(height: 16),
                  _buildKayitTextField(controller: _telefonController, hint: "TELEFON NUMARASI", icon: Icons.phone_android, isPhone: true, accentColor: activeAccent),
                  const SizedBox(height: 16),
                  _buildKayitTextField(controller: _sifreController, hint: "KUANTUM ŞİFRESİ", icon: Icons.lock_outline, isPassword: true, accentColor: activeAccent),
                  const SizedBox(height: 24),

                  // 3. FİRMAYA ÖZEL: ULUSAL GARANTİ SÖZLEŞMESİ ONAYI
                  if (!_isKullanici) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: firmAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: firmAccent.withOpacity(0.3))),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _garantiSozlesmesiKabul,
                            activeColor: firmAccent,
                            checkColor: Colors.black,
                            side: const BorderSide(color: firmAccent),
                            onChanged: (value) => setState(() => _garantiSozlesmesiKabul = value!),
                          ),
                          const Expanded(
                            child: Text("OtoDNA Ulusal Çapraz Garanti Sözleşmesi şartlarını ve %12 Finansal Kesinti Protokolünü kabul ediyorum.", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, height: 1.5)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // 4. KAYDI TAMAMLA (ATEŞLEME) BUTONU
                  SizedBox(
                    height: 64,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeAccent,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        disabledBackgroundColor: activeAccent.withOpacity(0.2),
                      ),
                      onPressed: _isProcessing ? null : _kayitProtokolunuBaslat,
                      icon: _isProcessing
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Icon(Icons.power_settings_new, size: 24),
                      child: Text(
                          _isProcessing ? "MÜHÜRLENİYOR..." : "HESAP OLUŞTUR",
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER METİN KUTUSU
  Widget _buildKayitTextField({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, bool isEmail = false, bool isPhone = false, required Color accentColor}) {
    return Container(
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isPhone ? TextInputType.phone : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white38, size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: accentColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}