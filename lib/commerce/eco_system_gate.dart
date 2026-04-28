import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/usta_paneli.dart';
import '../bayi/distributor_terminali.dart';
import '../screens/super_admin_screen.dart';
import '../core/siber_tema.dart';

/// 🦅 OTODNA EKO-SİSTEM GEÇİDİ (Ecosystem Gate)
/// Kullanıcı giriş yaptığında Firestore'dan yetki seviyesine bakar 
/// ve Kuantum Yönlendirmesini (Router) gerçekleştirir.
class EcoSystemGate extends StatefulWidget {
  EcoSystemGate({super.key});

  @override
  State<EcoSystemGate> createState() => _EcoSystemGateState();
}

class _EcoSystemGateState extends State<EcoSystemGate> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _yetkiDogrulaVeYonlendir();
  }

  Future<void> _yetkiDogrulaVeYonlendir() async {
    User? user = _auth.currentUser;
    
    // Eğer kullanıcı yoksa (Olamaz ama güvenlik kalkanı)
    if (user == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      // SİBER İSTİHBARAT: Kullanıcı DNA'sını (Profilini) Getir
      DocumentSnapshot userDoc = await _db.collection('users').doc(user.uid).get();
      
      String yetki = 'kullanici'; // Varsayılan: Standart Araç Sahibi
      
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        yetki = data?['yetki'] ?? 'kullanici';
      } else {
        // Yeni kayıt olmuş kullanıcılar için varsayılan profili veritabanına mühürle
        await _db.collection('users').doc(user.uid).set({
          'email': user.email,
          'yetki': 'kullanici',
          'kayit_tarihi': FieldValue.serverTimestamp(),
          'siber_genetik_skor': 100, // Başlangıç skoru
        });
      }

      if (!mounted) return;

      // 🚪 KUANTUM GEÇİTLERİ
      switch (yetki) {
        case 'usta':
        case 'bayi':
          // Ustalara ve Bayilere Özel Kokpit
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UstaPaneli()));
          break;
        case 'distributor':
        case 'toptanci':
          // V.I.P B2B Terminali
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DistributorTerminali()));
          break;
        case 'admin':
          // Karargah Komutanı
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SuperAdminScreen()));
          break;
        case 'kullanici':
        default:
          // Standart Araç Sahibi Ana Ekranı
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
          break;
      }
    } catch (e) {
      debugPrint("SİBER HATA: Eko-Sistem Geçidi Çöktü! Hata: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Ağ Hatası: Karargaha ulaşılamıyor.", style: TextStyle(color: Colors.black)), backgroundColor: SiberTema.kanKirmizi));
        // Güvenli Limana Dön
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: SiberTema.kuantumCyan.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.5), width: 2),
                boxShadow: [BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.2), blurRadius: 40)],
              ),
              child: Icon(Icons.fingerprint, color: SiberTema.kuantumCyan, size: 48),
            ),
            SizedBox(height: 32),
            Text(
              "E K O - S İ S T E M   G E Ç İ D İ",
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 4, fontFamily: 'Avenir'),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: 150,
              child: LinearProgressIndicator(color: SiberTema.kuantumCyan, backgroundColor: Colors.white10),
            ),
            SizedBox(height: 16),
            Text(
              "Kimlik Doğrulanıyor ve Kuantum Ağına Bağlanılıyor...",
              style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1, fontFamily: 'Avenir'),
            ),
          ],
        ),
      ),
    );
  }
}