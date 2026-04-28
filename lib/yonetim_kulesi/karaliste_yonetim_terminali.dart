import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otodna/core/siber_tema.dart';
import 'package:otodna/core/responsive_kalkan.dart';

/// 🏴 BLACK STAR PROTOKOLÜ (KARALİSTE YÖNETİMİ)
/// Yöneticilerin, hileli işlem yapan bayi veya kullanıcıları kalıcı olarak ağdan men ettikleri terminal.
class KaralisteYonetimTerminali extends StatefulWidget {
  const KaralisteYonetimTerminali({super.key});

  @override
  State<KaralisteYonetimTerminali> createState() => _KaralisteYonetimTerminaliState();
}

class _KaralisteYonetimTerminaliState extends State<KaralisteYonetimTerminali> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _aramaController = TextEditingController();
  String _aramaSorgusu = "";

  void _karaListeDurumunuDegistir(String userId, bool mevcutDurum, String isim) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SiberTema.oledBlack,
        shape: RoundedRectangleBorder(side: BorderSide(color: mevcutDurum ? SiberTema.kuantumCyan : SiberTema.kanKirmizi, width: 2)),
        title: Text(
          mevcutDurum ? "MÜHRÜ KALDIR" : "BLACK STAR MÜHÜRLE",
          style: TextStyle(color: mevcutDurum ? SiberTema.kuantumCyan : SiberTema.kanKirmizi, fontWeight: FontWeight.bold),
        ),
        content: Text(
          mevcutDurum
              ? "$isim adlı hesabın üzerindeki Black Star yasağını kaldırmak istiyor musunuz?"
              : "$isim adlı hesabı Karargah ağına kalıcı olarak kapatmak (banlamak) istediğinize emin misiniz?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İPTAL", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: mevcutDurum ? SiberTema.kuantumCyan : SiberTema.kanKirmizi),
            onPressed: () {
              _db.collection('kullanicilar').doc(userId).update({'is_blacklisted': !mevcutDurum});
              
              // Log Kaydı
              _db.collection('sistem_loglari').add({
                'islem_turu': mevcutDurum ? 'YASAK_KALDIRILDI' : 'BLACK_STAR_MUHRU',
                'islem_detayi': 'Admin, $isim ($userId) hesabı için işlem yaptı.',
                'tarih': FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
            },
            child: Text("ONAYLA", style: TextStyle(color: mevcutDurum ? SiberTema.oledBlack : Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => context.pop()),
          title: const Text("BLACK STAR PROTOKOLÜ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 2.0, fontSize: 13)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _aramaController,
                style: const TextStyle(color: Colors.white),
                onChanged: (val) => setState(() => _aramaSorgusu = val.toLowerCase()),
                decoration: SiberTema.siberInputDecor("Email veya İsim ile Arama", Icons.search).copyWith(
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: SiberTema.kanKirmizi), borderRadius: BorderRadius.circular(12)),
                  prefixIcon: Icon(Icons.search, color: SiberTema.kanKirmizi),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _db.collection('kullanicilar').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: SiberTema.kanKirmizi));
                  if (!snapshot.hasData) return const SizedBox.shrink();

                  var kullanicilar = snapshot.data!.docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String email = (data['email'] ?? '').toString().toLowerCase();
                    String isim = (data['isim'] ?? '').toString().toLowerCase();
                    return email.contains(_aramaSorgusu) || isim.contains(_aramaSorgusu);
                  }).toList();

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: kullanicilar.length,
                    itemBuilder: (context, index) {
                      var data = kullanicilar[index].data() as Map<String, dynamic>;
                      String id = kullanicilar[index].id;
                      bool isBanned = data['is_blacklisted'] ?? false;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isBanned ? SiberTema.kanKirmizi.withOpacity(0.05) : SiberTema.siberKutuZirhi.color,
                          border: Border.all(color: isBanned ? SiberTema.kanKirmizi : Colors.white12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Icon(
                            isBanned ? Icons.block : Icons.person_outline,
                            color: isBanned ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
                            size: 32,
                          ),
                          title: Text(data['isim'] ?? data['email'] ?? 'İsimsiz Ajan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text("ROL: ${data['rol'] ?? 'USER'}", style: TextStyle(color: SiberTema.siberGold, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
                              const SizedBox(height: 4),
                              Text(data['email'] ?? '', style: TextStyle(color: Colors.white54, fontSize: 11)),
                            ],
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isBanned ? Colors.transparent : SiberTema.kanKirmizi.withOpacity(0.1),
                              side: BorderSide(color: isBanned ? SiberTema.kuantumCyan : SiberTema.kanKirmizi),
                              elevation: 0,
                            ),
                            onPressed: () {
                              HapticFeedback.heavyImpact();
                              _karaListeDurumunuDegistir(id, isBanned, data['isim'] ?? data['email'] ?? 'Kullanıcı');
                            },
                            child: Text(
                              isBanned ? "MÜHRÜ AÇ" : "MÜHÜRLE",
                              style: TextStyle(color: isBanned ? SiberTema.kuantumCyan : SiberTema.kanKirmizi, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
