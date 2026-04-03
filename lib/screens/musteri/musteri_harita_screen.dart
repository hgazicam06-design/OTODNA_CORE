import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MusteriHaritaScreen extends StatefulWidget {
  final String? ilkAramaKelimesi; // Keşfet ekranından gelen kelime

  const MusteriHaritaScreen({super.key, this.ilkAramaKelimesi});

  @override
  State<MusteriHaritaScreen> createState() => _MusteriHaritaScreenState();
}

class _MusteriHaritaScreenState extends State<MusteriHaritaScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = const Color(0xFF000000);
  final Color surfaceColor = const Color(0xFF111111);
  final Color primaryCyan = const Color(0xFF00FFC2);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late TextEditingController _aramaController;
  String _aramaKelimesi = "";

  @override
  void initState() {
    super.initState();
    // Eğer Keşfet ekranından bir kelimeyle gelindiyse, onu hemen set et
    _aramaKelimesi = (widget.ilkAramaKelimesi ?? "").toLowerCase();
    _aramaController = TextEditingController(text: widget.ilkAramaKelimesi);
  }

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('S İ B E R   R A D A R', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 💎 ARAMA ÇUBUĞU (KUANTUM FİLTRESİ)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  boxShadow: [BoxShadow(color: primaryCyan.withOpacity(0.05), blurRadius: 20)]
              ),
              child: TextField(
                controller: _aramaController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                onChanged: (val) => setState(() => _aramaKelimesi = val.toLowerCase()),
                decoration: InputDecoration(
                  hintText: "Örn: DSG, Kaporta, BMW...",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                  suffixIcon: _aramaKelimesi.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white38, size: 20),
                    onPressed: () {
                      _aramaController.clear();
                      setState(() => _aramaKelimesi = "");
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          // 📍 HARİTA SİMÜLASYONU VE LİSTE
          Expanded(
            child: Stack(
              children: [
                // Arka plan Harita Deseni (İleride Google Maps gelecek)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.03,
                    child: Icon(Icons.map_outlined, size: 400, color: primaryCyan),
                  ),
                ),

                // 💎 CANLI FİREBASE BAYİ RADARI
                StreamBuilder<QuerySnapshot>(
                    stream: _db.collection('kullanicilar').where('rol', isEqualTo: 'bayi').where('aktif_mi', isEqualTo: true).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF00FFC2)));
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Bölgenizde aktif usta bulunamadı.", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)));

                      // Arama kelimesine göre filtreleme (Uzmanlık dalları veya isme göre)
                      var ustalar = snapshot.data!.docs.where((doc) {
                        var data = doc.data() as Map<String, dynamic>;
                        String firmaAdi = (data['ad'] ?? "").toLowerCase();
                        List<dynamic> uzmanliklar = data['uzmanlik_alt_dallari'] ?? [];
                        List<dynamic> markalar = data['hizmet_verilen_markalar'] ?? [];

                        if (_aramaKelimesi.isEmpty) return true;

                        bool isimdeVar = firmaAdi.contains(_aramaKelimesi);
                        bool uzmanliktaVar = uzmanliklar.any((u) => u.toString().toLowerCase().contains(_aramaKelimesi));
                        bool markadaVar = markalar.any((m) => m.toString().toLowerCase().contains(_aramaKelimesi));

                        return isimdeVar || uzmanliktaVar || markadaVar;
                      }).toList();

                      if (ustalar.isEmpty) return const Center(child: Text("Aradığınız kritere uygun usta bulunamadı.", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)));

                      return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          physics: const BouncingScrollPhysics(),
                          itemCount: ustalar.length,
                          itemBuilder: (context, index) {
                            var usta = ustalar[index].data() as Map<String, dynamic>;
                            String rozet = usta['rozet'] ?? 'Standart';
                            bool isVip = usta['is_vip'] ?? false;

                            // VIP veya Murat Plaza için renk ayarı
                            Color kartRengi = isVip ? (rozet == "Murat Plaza" ? primaryCyan : Colors.amber) : Colors.white24;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: isVip ? kartRengi.withOpacity(0.4) : Colors.white.withOpacity(0.05), width: isVip ? 1.5 : 1),
                                  boxShadow: isVip ? [BoxShadow(color: kartRengi.withOpacity(0.05), blurRadius: 20)] : []
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(color: isVip ? kartRengi.withOpacity(0.1) : Colors.white.withOpacity(0.05), shape: BoxShape.circle, border: Border.all(color: isVip ? kartRengi.withOpacity(0.5) : Colors.transparent)),
                                                  child: Icon(Icons.storefront_outlined, color: isVip ? kartRengi : Colors.white54, size: 20)
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(usta['ad']?.toString().toUpperCase() ?? 'İSİMSİZ FİRMA', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                                                    const SizedBox(height: 4),
                                                    if (isVip) Text("$rozet İSTASYON".toUpperCase(), style: TextStyle(color: kartRengi, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1))
                                                  ],
                                                ),
                                              )
                                            ]
                                        ),
                                      ),
                                      Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
                                          child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.star, color: kartRengi, size: 12),
                                                const SizedBox(width: 4),
                                                Text("${usta['puan'] ?? 5.0}", style: TextStyle(color: kartRengi, fontWeight: FontWeight.w900, fontSize: 11))
                                              ]
                                          )
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(usta['firma_tanitimi'] ?? 'OtoDNA Onaylı Yetkili Servis Noktası', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 11, height: 1.4)),
                                  const SizedBox(height: 16),

                                  // Uzmanlık Etiketleri
                                  Wrap(
                                    spacing: 8, runSpacing: 8,
                                    children: (usta['uzmanlik_alt_dallari'] as List<dynamic>? ?? []).take(3).map((uzmanlik) {
                                      return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(color: primaryCyan.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: primaryCyan.withOpacity(0.2))),
                                          child: Text(uzmanlik.toString().toUpperCase(), style: const TextStyle(color: primaryCyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1))
                                      );
                                    }).toList(),
                                  ),

                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity, height: 50,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(backgroundColor: primaryCyan, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${usta['ad']} için Randevu Ekranı Açılıyor...", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: primaryCyan));
                                      },
                                      icon: const Icon(Icons.navigation_outlined, size: 18),
                                      label: const Text("ROTA ÇİZ & RANDEVU AL", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                                    ),
                                  )
                                ],
                              ),
                            );
                          }
                      );
                    }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}