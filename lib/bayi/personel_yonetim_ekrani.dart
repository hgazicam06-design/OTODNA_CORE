import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:otodna/core/siber_tema.dart';
import 'package:otodna/core/responsive_kalkan.dart';

/// 👥 BAYİ PERSONEL KOMUTA MERKEZİ
/// Bayilerin kendi bünyelerindeki Ustaları, Danışmanları ve diğer personelleri yönettiği ekran.
class PersonelYonetimEkrani extends StatefulWidget {
  final String bayiId;
  const PersonelYonetimEkrani({super.key, required this.bayiId});

  @override
  State<PersonelYonetimEkrani> createState() => _PersonelYonetimEkraniState();
}

class _PersonelYonetimEkraniState extends State<PersonelYonetimEkrani> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  void _personelEkleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final emailCtrl = TextEditingController();
        final nameCtrl = TextEditingController();
        String seciliRol = "USTA"; // USTA veya DANISMAN

        return StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            backgroundColor: SiberTema.oledBlack,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: SiberTema.kuantumCyan, width: 1.5)),
            title: Row(
              children: [
                Icon(Icons.person_add_alt_1_outlined, color: SiberTema.kuantumCyan),
                const SizedBox(width: 10),
                Text("YENİ PERSONEL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    style: TextStyle(color: Colors.white),
                    decoration: SiberTema.siberInputDecor("Personel Adı Soyadı", Icons.badge),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailCtrl,
                    style: TextStyle(color: Colors.white),
                    decoration: SiberTema.siberInputDecor("E-Posta Adresi", Icons.email),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: seciliRol,
                    dropdownColor: SiberTema.oledBlack,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: SiberTema.siberInputDecor("Personel Yetkisi", Icons.security),
                    items: [
                      DropdownMenuItem(value: "USTA", child: Text("Araç Servis Ustası", style: TextStyle(color: SiberTema.kuantumCyan))),
                      DropdownMenuItem(value: "DANISMAN", child: Text("Müşteri Danışmanı", style: TextStyle(color: SiberTema.kuantumCyan))),
                    ],
                    onChanged: (val) {
                      if (val != null) setStateDialog(() => seciliRol = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Personel, bu e-posta ile giriş yaptığında otomatik olarak ağınıza bağlanacaktır.",
                    style: TextStyle(color: Colors.white54, fontSize: 10, height: 1.5),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("İPTAL", style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: SiberTema.kuantumButonStili(),
                onPressed: () async {
                  HapticFeedback.heavyImpact();
                  if (emailCtrl.text.isEmpty || nameCtrl.text.isEmpty) return;
                  
                  // Firebase Fonksiyonu ile veya doğrudan Firestore (Güvenlik kuralları izin veriyorsa)
                  await _db.collection('bayi_davetleri').add({
                    'bayi_id': widget.bayiId,
                    'personel_email': emailCtrl.text.trim(),
                    'personel_ad': nameCtrl.text.trim(),
                    'rol': seciliRol,
                    'durum': 'bekliyor',
                    'tarih': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Davetiye Sinyali Gönderildi!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      backgroundColor: SiberTema.kuantumCyan,
                    ));
                  }
                },
                child: Text("AĞA DAVET ET", style: TextStyle(fontWeight: FontWeight.w900)),
              )
            ],
          ),
        );
      },
    );
  }

  void _personeliUzaklastir(String id, String ad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SiberTema.oledBlack,
        shape: RoundedRectangleBorder(side: BorderSide(color: SiberTema.kanKirmizi)),
        title: Text("YETKİ İPTALİ", style: TextStyle(color: SiberTema.kanKirmizi, fontWeight: FontWeight.bold)),
        content: Text("$ad adlı personelin bayi ağınıza erişimini kesmek istediğinize emin misiniz?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("İPTAL", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kanKirmizi),
            onPressed: () {
              // Firebase'den bayi_id alanını temizle
              _db.collection('kullanicilar').doc(id).update({'bagli_bayi_id': FieldValue.delete(), 'rol': 'USER'});
              Navigator.pop(context);
            },
            child: Text("AĞDAN UZAKLAŞTIR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          title: Text("PERSONEL AĞI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontFamily: 'Avenir', letterSpacing: 2.0)),
          centerTitle: true,
          actions: [
            IconButton(icon: Icon(Icons.person_add_alt_1, color: SiberTema.kuantumCyan), onPressed: _personelEkleDialog),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          // 'bagli_bayi_id' değeri bu bayinin ID'si olan kullanıcıları dinle
          stream: _db.collection('kullanicilar').where('bagli_bayi_id', isEqualTo: widget.bayiId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
            }
            if (snapshot.hasError) {
              return Center(child: Text("SİBER İHLAL: ${snapshot.error}", style: TextStyle(color: SiberTema.kanKirmizi)));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.engineering_outlined, color: Colors.white12, size: 80),
                    const SizedBox(height: 16),
                    Text("AĞ BOŞ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Text("Henüz karargahınıza bağlı bir\nusta veya personel bulunmuyor.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: SiberTema.kuantumButonStili(),
                      icon: Icon(Icons.add, color: SiberTema.oledBlack),
                      label: Text("PERSONEL DAVET ET", style: TextStyle(fontWeight: FontWeight.w900)),
                      onPressed: _personelEkleDialog,
                    )
                  ],
                ),
              );
            }

            var personeller = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: personeller.length,
              itemBuilder: (context, index) {
                var p = personeller[index].data() as Map<String, dynamic>;
                String pId = personeller[index].id;
                String rol = p['rol'] ?? 'BELİRSİZ';
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: SiberTema.siberKutuZirhi,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: SiberTema.kuantumCyan.withOpacity(0.1),
                      child: Icon(rol == "USTA" ? Icons.build_circle : Icons.support_agent, color: SiberTema.kuantumCyan),
                    ),
                    title: Text(p['isim'] ?? p['email'] ?? 'İsimsiz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(rol, style: TextStyle(color: SiberTema.siberGold, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
                        const SizedBox(height: 4),
                        Text("Son Sinyal: Bugün 14:30", style: TextStyle(color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle_outline, color: SiberTema.kanKirmizi),
                      onPressed: () => _personeliUzaklastir(pId, p['isim'] ?? 'Personel'),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
