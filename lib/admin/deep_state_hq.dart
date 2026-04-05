import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔥 SİBER KÖPRÜLER (Mutlak Rota ile Zırhlandı - Asla kopmaz!)
import 'package:otodna/screens/bayi_yonetim_merkezi_screen.dart';
import 'package:otodna/screens/kullanici_yonetim_screen.dart';
import 'package:otodna/screens/bayi_paneli.dart';

class AmiralGemisi extends StatefulWidget {
  const AmiralGemisi({super.key});

  @override
  _AmiralGemisiState createState() => _AmiralGemisiState();
}

class _AmiralGemisiState extends State<AmiralGemisi> {
  bool _isLocked = true;
  String _masterKey = "";
  bool _isChecking = false;

  // Siber Renk Paleti
  static const _darkSpace = Color(0xFF00050A); // Otorite Siyahı/Gece Mavisi
  static const _cyan = Color(0xFF00FFC2); // Kuantum Turkuazı
  static const _neonBlue = Color(0xFF2979FF); // Derin İstihbarat Mavisi
  static const _alertRed = Color(0xFFFF2A2A); // İhlal Kırmızısı

  @override
  Widget build(BuildContext context) {
    // 🛡️ SİBER KİLİT EKRANI (MASTER KEY PROTOKOLÜ)
    if (_isLocked) {
      return _buildSiberKilitEkrani();
    }

    // 🚀 AMİRAL GEMİSİ ANA KONTROL PANELİ
    return Scaffold(
      backgroundColor: _darkSpace,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/radar_grid.png'), // Siber ızgara arka planı
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: Row(
          children: [
            _buildSiberYanMenu(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildKuantumBaslik("AMİRAL GEMİSİ FİNANSAL RADARI", Icons.account_balance),
                    _ustFinansalBant(), // FİREBASE CANLI FİNANS

                    const SizedBox(height: 30),

                    // 🟢 YENİ: HIZLI ERİŞİM SİBER KAPILARI 🟢
                    _buildKuantumBaslik("HIZLI OPERASYON KAPILARI", Icons.api),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRotaButonu(
                              "BAYİ AĞI MERKEZİ",
                              Icons.business,
                                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BayiYonetimMerkeziScreen()))
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildRotaButonu(
                              "BAYİ PANELİ GİRİŞİ",
                              Icons.store_mall_directory,
                                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => BayiPaneliScreen(bayiId: FirebaseAuth.instance.currentUser?.uid ?? 'ADMIN_BYPASS')))
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildRotaButonu(
                              "KULLANICI PANELİ",
                              Icons.people_alt,
                                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KullaniciYonetimScreen()))
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildRotaButonu(
                              "YAPILANDIRMA",
                              Icons.architecture,
                                  () => _rotaUyari("YAPILANDIRMA MERKEZİ")
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildKuantumBaslik("SİBER GÜVENLİK VE SİSTEM SAĞLIĞI", Icons.security),
                              _teknikSistemSagligi(), // FİREBASE CANLI LOGLAR
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildKuantumBaslik("ELİT BAYİ PERFORMANS MATRİSİ", Icons.leaderboard),
                              _bayiPerformansMatrisi(), // FİREBASE CANLI BAYİ LİDERLİK TABLOSU
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    _buildKuantumBaslik("CANLI OPERASYON HARİTASI", Icons.map),
                    _canliHaritaKatmani(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- YENİ: ROTA UYARISI ---
  void _rotaUyari(String modulAdi) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _cyan,
        content: Text("$modulAdi BAĞLANTISI BEKLENİYOR...", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- YENİ: ŞIK ROTA BUTONU TASARIMI ---
  Widget _buildRotaButonu(String baslik, IconData ikon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: _neonBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _neonBlue.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: _neonBlue.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ikon, color: _cyan, size: 28),
            const SizedBox(height: 12),
            Text(
              baslik,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1, fontFamily: 'Avenir'),
            ),
          ],
        ),
      ),
    );
  }

  // --- 🔴 FİREBASE MOTORLARI VE DERİN DEVLET FONKSİYONLARI ---

  Widget _ustFinansalBant() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('sistem_verileri').doc('finans').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildKuantumLoader(_cyan);

        double gunlukSatis = 0.0;
        if (snapshot.hasData && snapshot.data!.exists) {
          gunlukSatis = ((snapshot.data!.data() as Map<String, dynamic>)['gunluk_ciro'] ?? 0).toDouble();
        }

        double gaziNetPay = gunlukSatis * 0.10; // %10 Net Pay
        double devletVergi = gunlukSatis * 0.02; // %2 Vergi

        return _buildCamEfektliKutu(
          borderColor: _neonBlue.withOpacity(0.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _finansVeri("GÜNLÜK TOPLAM SATIŞ", "₺${gunlukSatis.toStringAsFixed(2)}", Colors.white),
              Container(height: 60, width: 1, color: _neonBlue.withOpacity(0.3)),
              _finansVeri("KOMUTAN NET PAY (%10)", "₺${gaziNetPay.toStringAsFixed(2)}", _cyan),
              Container(height: 60, width: 1, color: _neonBlue.withOpacity(0.3)),
              _finansVeri("DEVLET VERGİSİ (%2)", "₺${devletVergi.toStringAsFixed(2)}", Colors.orangeAccent),
            ],
          ),
        );
      },
    );
  }

  Widget _teknikSistemSagligi() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('sistem_loglari').where('islem_turu', isEqualTo: 'hata').limit(5).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildKuantumLoader(_neonBlue);

        int ihlalSayisi = snapshot.hasData ? snapshot.data!.docs.length : 0;
        bool guvendeMi = ihlalSayisi == 0;

        return _buildCamEfektliKutu(
          borderColor: guvendeMi ? Colors.green.withOpacity(0.4) : _alertRed.withOpacity(0.5),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: _buildNeonIkon(guvendeMi ? Icons.shield : Icons.warning_amber_rounded, guvendeMi ? Colors.greenAccent : _alertRed),
                title: const Text("Kuantum Ağ Güvenliği", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(
                    guvendeMi ? "Saldırı Girişimi: 0 | Kalkanlar Aktif ✅" : "DİKKAT! $ihlalSayisi İhlal Tespit Edildi!",
                    style: TextStyle(color: guvendeMi ? Colors.greenAccent : _alertRed, fontWeight: FontWeight.bold, fontSize: 12)
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bayiPerformansMatrisi() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bayiler').where('aktif_mi', isEqualTo: true).orderBy('aylik_ciro', descending: true).limit(3).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return _buildKuantumLoader(_cyan);
        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return _buildCamEfektliKutu(borderColor: Colors.white12, child: const Center(child: Text("Henüz ciro verisi yok.", style: TextStyle(color: Colors.white54))));
        }

        return _buildCamEfektliKutu(
          borderColor: _cyan.withOpacity(0.3),
          child: Column(
            children: docs.asMap().entries.map((entry) {
              int index = entry.key;
              var data = entry.value.data() as Map<String, dynamic>;
              String isim = data['firma_adi'] ?? 'Bilinmeyen Bayi';
              double ciro = (data['aylik_ciro'] ?? 0).toDouble();

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text("#${index + 1}", style: const TextStyle(color: _cyan, fontSize: 18, fontWeight: FontWeight.w900)),
                title: Text(isim, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                trailing: Text("₺${ciro.toStringAsFixed(2)}", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // --- 🎨 SİBER GÖRSEL ZIRHLAR VE UI BİLEŞENLERİ ---

  Widget _buildSiberKilitEkrani() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          radialGradient: RadialGradient(colors: [_neonBlue.withOpacity(0.2), Colors.black], radius: 1.5),
        ),
        child: Center(
          child: _buildCamEfektliKutu(
            borderColor: _cyan.withOpacity(0.5),
            child: SizedBox(
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fingerprint, size: 80, color: _cyan),
                  const SizedBox(height: 16),
                  const Text("AMİRAL GEMİSİ", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 4)),
                  const Text("DERİN DEVLET YETKİSİ GEREKLİ", style: TextStyle(color: _alertRed, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 30),
                  TextField(
                    obscureText: true,
                    textAlign: TextAlign.center,
                    onChanged: (v) => _masterKey = v,
                    style: const TextStyle(color: _cyan, fontSize: 20, letterSpacing: 5, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: "MASTER KEY",
                      hintStyle: TextStyle(color: _cyan.withOpacity(0.2), letterSpacing: 5),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.5),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _neonBlue.withOpacity(0.3))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _cyan, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _cyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 10,
                        shadowColor: _cyan.withOpacity(0.5),
                      ),
                      onPressed: () async {
                        setState(() => _isChecking = true);
                        await Future.delayed(const Duration(milliseconds: 800)); // Siber doğrulama simülasyonu
                        if (_masterKey == "GAZI1923") {
                          setState(() { _isLocked = false; _isChecking = false; });
                        } else {
                          setState(() => _isChecking = false);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ERİŞİM REDDEDİLDİ: SİBER İHLAL!"), backgroundColor: _alertRed));
                        }
                      },
                      child: _isChecking
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Text("MÜHRÜ ONAYLA", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKuantumBaslik(String metin, IconData icon) => Padding(
    padding: const EdgeInsets.only(bottom: 16, top: 10),
    child: Row(
      children: [
        Icon(icon, color: _cyan, size: 20),
        const SizedBox(width: 10),
        Text(metin, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12)),
      ],
    ),
  );

  Widget _finansVeri(String baslik, String deger, Color renk) => Column(
    children: [
      Text(baslik, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
      const SizedBox(height: 8),
      Text(deger, style: TextStyle(color: renk, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1))
    ],
  );

  Widget _buildSiberYanMenu() => Container(
    width: 80,
    decoration: BoxDecoration(
      color: Colors.black,
      border: Border(right: BorderSide(color: _neonBlue.withOpacity(0.2))),
    ),
    child: Column(
      children: [
        const SizedBox(height: 40),
        _buildNeonIkon(Icons.remove_red_eye, _cyan),
        const SizedBox(height: 30),
        _buildNeonIkon(Icons.language, _neonBlue),
        const Spacer(),
        IconButton(icon: const Icon(Icons.power_settings_new, color: _alertRed), onPressed: () => setState(() => _isLocked = true)),
        const SizedBox(height: 20),
      ],
    ),
  );

  Widget _canliHaritaKatmani() => _buildCamEfektliKutu(
    borderColor: _neonBlue.withOpacity(0.3),
    child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          image: const DecorationImage(image: AssetImage('assets/images/radar_grid.png'), fit: BoxFit.cover, opacity: 0.2),
        ),
        child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.radar, color: _cyan, size: 40),
                SizedBox(height: 12),
                Text("📡 CANLI KONUM VE OPERASYON RADARI AKTİF", style: TextStyle(color: _cyan, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ],
            )
        )
    ),
  );

  // Ortak Cam Efekti (Glassmorphism) Mimarisi
  Widget _buildCamEfektliKutu({required Widget child, required Color borderColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [BoxShadow(color: _cyan.withOpacity(0.02), blurRadius: 20)],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildNeonIkon(IconData icon, Color renk) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: renk.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: renk.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: renk.withOpacity(0.2), blurRadius: 10)],
      ),
      child: Icon(icon, color: renk, size: 24),
    );
  }

  Widget _buildKuantumLoader(Color renk) => Center(child: Padding(padding: const EdgeInsets.all(20.0), child: CircularProgressIndicator(color: renk, strokeWidth: 2)));
}