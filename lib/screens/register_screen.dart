import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';

/// 🦅 OTO DNA KAYIT VE ATOMİK İSTİHBARAT MOTORU
/// [2026-03-28] GÜNCELLEME: KURUMSAL BAŞVURU SİNYALİ VE BATCH YAZMA
class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

  // 🚀 FİREBASE: SİBER KAYIT VE ATOMİK VERİ MÜHÜRLERİ
  Future<void> _kayitProtokolunuBaslat() async {
    final isim = _isimController.text.trim();
    final email = _emailController.text.trim();
    final telefon = _telefonController.text.trim();
    final sifre = _sifreController.text.trim();

    // 1. GÜVENLİK ZIRHI KONTROLLERİ
    if (isim.isEmpty || email.isEmpty || telefon.isEmpty || sifre.isEmpty) {
      _siberMesajGoster("SİBER İHLAL: TÜM ALANLAR DOLDURULMALIDIR!", isError: true);
      return;
    }
    if (sifre.length < 6) {
      _siberMesajGoster("ZAYIF ŞİFRE: Kuantum şifresi en az 6 haneli olmalıdır!", isError: true);
      return;
    }
    if (!_isKullanici && !_garantiSozlesmesiKabul) {
      _siberMesajGoster("GÜVENLİK İHLALİ: Finansal Protokolü onaylamanız zorunludur!", isError: true);
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

      // 3. ATOMİK VERİ YAZMA (WriteBatch)
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
        'durum': _isKullanici ? 'AKTIF' : 'ONAY_BEKLIYOR',
      });

      // EĞER BAYİ İSE ANKARA MERKEZ KARARGAHA SİNYAL GÖNDER
      if (!_isKullanici) {
        DocumentReference bayiRef = _db.collection('bayi_basvurulari').doc(uid);
        batch.set(bayiRef, {
          'isim': isim.toUpperCase(),
          'email': email,
          'telefon': telefon,
          'durum': 'Bekliyor', // Admin radarında parlaması için
          'basvuru_tarihi': FieldValue.serverTimestamp(),
          'not': 'YENİ SİBER BAYİ BAŞVURUSU',
        });
      }

      await batch.commit();

      if (!mounted) return;
      _siberMesajGoster(_isKullanici ? "AĞA KATILIM BAŞARILI! 🦅" : "BAŞVURU MERKEZE İLETİLDİ! ONAY BEKLENİYOR 🦅");

      Future.delayed(Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });

    } on FirebaseAuthException catch (e) {
      String hata = "AĞ ÇÖKTÜ: Kayıt başarısız!";
      if (e.code == 'email-already-in-use') hata = "BU SİBER KİMLİK ZATEN KULLANIMDA!";
      _siberMesajGoster(hata, isError: true);
    } catch (e) {
      _siberMesajGoster("SİSTEM HATASI: Veritabanı mühürlenemedi.", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _siberMesajGoster(String mesaj, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color activeAccent = _isKullanici ? SiberTema.kuantumCyan : SiberTema.bayiAkis;

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: activeAccent, size: 20), onPressed: () => Navigator.pop(context)),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("AĞA KATIL", style: TextStyle(color: activeAccent, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  SizedBox(height: 8),
                  Text("OtoDNA Kuantum Ekosistemine entegre olun.", style: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  SizedBox(height: 40),

                  // 1. KULLANICI / FİRMA SEÇİM ZIRHI
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(color: SiberTema.matGrey.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
                    child: Row(
                      children: [
                        _buildTypeButton("BİREYSEL", _isKullanici, SiberTema.kuantumCyan, () => setState(() { _isKullanici = true; _garantiSozlesmesiKabul = false; })),
                        _buildTypeButton("KURUMSAL", !_isKullanici, SiberTema.bayiAkis, () => setState(() => _isKullanici = false)),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),

                  // 2. DİNAMİK FORMLAR
                  _buildKayitField(_isimController, _isKullanici ? "AD SOYAD" : "FİRMA UNVANI", Icons.person_outline, activeAccent),
                  SizedBox(height: 16),
                  _buildKayitField(_emailController, "SİBER E-POSTA", Icons.alternate_email, activeAccent, isEmail: true),
                  SizedBox(height: 16),
                  _buildKayitField(_telefonController, "TELEFON NUMARASI", Icons.phone_android, activeAccent, isPhone: true),
                  SizedBox(height: 16),
                  _buildKayitField(_sifreController, "KUANTUM ŞİFRESİ", Icons.lock_outline, activeAccent, isPassword: true),
                  SizedBox(height: 24),

                  // 3. KURUMSAL ONAY
                  if (!_isKullanici) ...[
                    _buildKurumsalOnay(activeAccent),
                    SizedBox(height: 32),
                  ],

                  // 4. ATEŞLEME BUTONU
                  SizedBox(
                    height: 64,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeAccent,
                        foregroundColor: SiberTema.oledBlack,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _isProcessing ? null : _kayitProtokolunuBaslat,
                      icon: _isProcessing
                          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: SiberTema.oledBlack, strokeWidth: 2))
                          : Icon(Icons.power_settings_new, size: 24),
                      label: Text(
                          _isProcessing ? "MÜHÜRLENİYOR..." : "HESAP OLUŞTUR",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)
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

  Widget _buildTypeButton(String label, bool isActive, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isActive ? color.withOpacity(0.5) : Colors.transparent),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: isActive ? color : Colors.white24, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ),
      ),
    );
  }

  Widget _buildKayitField(TextEditingController controller, String hint, IconData icon, Color accent, {bool isPassword = false, bool isEmail = false, bool isPhone = false}) {
    return Container(
      decoration: BoxDecoration(color: SiberTema.matGrey.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isPhone ? TextInputType.phone : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        style: TextStyle(color: SiberTema.textMain, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: SiberTema.textMuted, size: 20),
          hintText: hint,
          hintStyle: TextStyle(color: SiberTema.textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: accent, width: 1.5)),
        ),
      ),
    );
  }

  Widget _buildKurumsalOnay(Color accent) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: accent.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: accent.withOpacity(0.3))),
      child: Row(
        children: [
          Checkbox(
            value: _garantiSozlesmesiKabul,
            activeColor: accent,
            checkColor: SiberTema.oledBlack,
            onChanged: (value) => setState(() => _garantiSozlesmesiKabul = value!),
          ),
          Expanded(
            child: Text("OtoDNA Ulusal Çapraz Garanti Sözleşmesi şartlarını ve %12 Finansal Kesinti Protokolünü kabul ediyorum.", style: TextStyle(color: SiberTema.textMuted, fontSize: 10, fontWeight: FontWeight.bold, height: 1.5)),
          ),
        ],
      ),
    );
  }
}