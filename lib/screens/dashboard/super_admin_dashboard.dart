import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _siberUyari(String mesaj) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: const Color(0xFF00FFC2),
    ));
  }

  // 💸 PARA ÇEKME TALEBİNİ ONAYLAMA (ADMİN YETKİSİ)
  Future<void> _paraTalebiniOnayla(String talepId) async {
    try {
      await _db.collection('para_cekme_talepleri').doc(talepId).update({
        'durum': 'Ödendi',
        'onay_tarihi': FieldValue.serverTimestamp(),
      });
      _siberUyari("Ödeme Onaylandı! Para Bayinin IBAN'ına Gönderildi. 💸");
    } catch (e) {
      _siberUyari("Hata: $e");
    }
  }

  // ⚖️ HAKEM HEYETİ KARARI (ADMİN YETKİSİ)
  Future<void> _hakemKarariVer(String talepId, bool sucluRaporlayanMi) async {
    try {
      await _db.collection('garanti_talepleri').doc(talepId).update({
        'durum': sucluRaporlayanMi ? 'Adli Süreç (Raporlayan Hatalı)' : 'Adli Süreç (İşlemi Yapan Hatalı)',
        'karar_tarihi': FieldValue.serverTimestamp(),
      });
      _siberUyari("OtoDNA Hakem Kararı Mühürlendi! ⚖️");
    } catch (e) {
      _siberUyari("Hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F172A);
    const primaryCyan = Color(0xFF00FFC2);
    const cardColor = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor, elevation: 0,
        title: const Text('OtoDNA Merkez Karargah', style: TextStyle(color: primaryCyan, fontWeight: FontWeight.w900, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. MERKEZ KASA (TOPLAM SİSTEM PAYI)
            const Text("SİBER KASA DURUMU", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF008080), primaryCyan], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("OtoDNA Toplam Platform Geliri", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                      stream: _db.collection('kullanicilar').where('rol', isEqualTo: 'bayi').snapshots(),
                      builder: (context, snapshot) {
                        double toplamPlatformPayi = 0.0;
                        if (snapshot.hasData) {
                          for (var doc in snapshot.data!.docs) {
                            var data = doc.data() as Map<String, dynamic>;
                            double ciro = (data['aylik_ciro'] ?? 0).toDouble();
                            String ad = (data['ad'] ?? "").toUpperCase();
                            double oran = ad.contains("MURAT PLAZA") ? 0.30 : 0.12;
                            toplamPlatformPayi += (ciro * oran);
                          }
                        }
                        return Text("₺${toplamPlatformPayi.toStringAsFixed(2)}", style: const TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.w900));
                      }
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. BEKLEYEN PARA ÇEKME TALEPLERİ
            const Text("FİNANS ONAY BEKLEYENLER", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
                stream: _db.collection('para_cekme_talepleri').where('durum', isEqualTo: 'İnceleniyor').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator(color: primaryCyan);
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text("Bekleyen ödeme talebi yok.", style: TextStyle(color: primaryCyan));

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orangeAccent)),
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance, color: Colors.orangeAccent),
                            const SizedBox(width: 16),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("IBAN: ${data['iban']}", style: const TextStyle(color: Colors.white, fontSize: 12)), Text("Tutar: ₺${data['tutar']}", style: const TextStyle(color: primaryCyan, fontWeight: FontWeight.bold, fontSize: 16))])),
                            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: primaryCyan), onPressed: () => _paraTalebiniOnayla(doc.id), child: const Text("ÖDENDİ YAP", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
            ),
            const SizedBox(height: 32),

            // 3. HAKEM HEYETİNE DÜŞEN DOSYALAR
            const Text("ADLİ SÜREÇ / HAKEM HEYETİ DOSYALARI", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
                stream: _db.collection('garanti_talepleri').where('durum', isEqualTo: 'Hakem Heyeti / Adli Süreç').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator(color: Colors.redAccent);
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text("Hakem heyetine intikal eden dosya yok.", style: TextStyle(color: primaryCyan));

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.redAccent)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Araç: ${data['arac']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text("Sorun: ${data['sorun']}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            const Divider(color: Colors.white24),
                            Text("Raporlayan Bayi: ${data['raporlayan_firma']}", style: const TextStyle(color: Colors.orangeAccent, fontSize: 12)),
                            Text("İşlemi Yapan Bayi: ${data['hatali_firma']}", style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.orangeAccent)), onPressed: () => _hakemKarariVer(doc.id, true), child: const Text("Raporlayan Hatalı", style: TextStyle(color: Colors.orangeAccent, fontSize: 10)))),
                                const SizedBox(width: 8),
                                Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)), onPressed: () => _hakemKarariVer(doc.id, false), child: const Text("İşlem Yapan Hatalı", style: TextStyle(color: Colors.redAccent, fontSize: 10)))),
                              ],
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
            ),
          ],
        ),
      ),
    );
  }
}