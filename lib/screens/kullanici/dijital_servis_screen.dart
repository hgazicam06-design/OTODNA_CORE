import 'package:flutter/material.dart';

class DijitalServisScreen extends StatefulWidget {
  const DijitalServisScreen({super.key});

  @override
  State<DijitalServisScreen> createState() => _DijitalServisScreenState();
}

class _DijitalServisScreenState extends State<DijitalServisScreen> {
  final List<Map<String, dynamic>> _servisKategorileri = [
    {'baslik': 'Kaporta & Boya Motoru', 'ikon': Icons.format_paint_outlined, 'alt_kategoriler': ['Ön Kaput', 'Sağ Ön Çamurluk', 'Tavan', 'Bagaj Kapağı'], 'video_istiyor_mu': true},
    {'baslik': 'Motor & Mekanik (Arıza Kaydı)', 'ikon': Icons.build_circle_outlined, 'alt_kategoriler': ['Şanzıman', 'Triger Kayışı', 'Motor Bloğu', 'Yağ/Sıvı Bakımı'], 'video_istiyor_mu': false},
    {'baslik': 'Oto Elektrik & Elektronik', 'ikon': Icons.electrical_services_outlined, 'alt_kategoriler': ['Motor Beyni (ECU)', 'Sensörler', 'Ateşleme Bobini', 'Sigorta Kutusu'], 'video_istiyor_mu': false},
    {'baslik': 'İç Donanım & Dizayn', 'ikon': Icons.chair_alt_outlined, 'alt_kategoriler': ['Koltuk & Döşeme', 'Double Teyp', 'Direksiyon Kılıfı', 'Tepe Lambası'], 'video_istiyor_mu': false},
    {'baslik': 'Dış Donanım & Aksesuar', 'ikon': Icons.airport_shuttle_outlined, 'alt_kategoriler': ['Body Kit & Tampon', 'Alaşımlı Jant', 'Spor Egzoz'], 'video_istiyor_mu': false},
  ];

  void _gorseldenParcaAra() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
        title: const Row(children: [Icon(Icons.camera_alt_outlined, color: Colors.white), SizedBox(width: 8), Text("Siber Vizyon", style: TextStyle(color: Colors.white, fontSize: 16))]),
        content: const Text("Kameranız üzerinden arızalı parçayı veya OEM kodunu taratarak küresel ağda eşleşme arayın.", style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lens Aktif Ediliyor...'), backgroundColor: Colors.white));
            },
            child: const Text("Taramayı Başlat", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _islemSecimi(String parcaAdi, bool videoIstiyorMu) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Color(0xFF111111), borderRadius: BorderRadius.vertical(top: Radius.circular(24)), border: Border(top: BorderSide(color: Colors.white12))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(parcaAdi, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            const Text("Bu parçanın dijital genetiğine işlenecek işlemi seçin.", style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIslemButonu(Icons.autorenew_outlined, "Değişti", Colors.redAccent),
                _buildIslemButonu(Icons.format_paint_outlined, "Boyandı", Colors.orangeAccent),
                _buildIslemButonu(Icons.build_outlined, "Onarıldı", Colors.blueAccent),
              ],
            ),
            if (videoIstiyorMu) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF000000), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white12)), elevation: 0),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kamera Açılıyor...'), backgroundColor: Colors.white));
                  },
                  icon: const Icon(Icons.videocam_outlined, color: Colors.white, size: 20),
                  label: const Text("İşlem Anı Videosu Yükle", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildIslemButonu(IconData icon, String text, Color color) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sisteme işlendi.'), backgroundColor: Colors.green));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100, padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: const Color(0xFF000000), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.5))),
        child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12))
            ]
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF000000);
    const surfaceColor = Color(0xFF111111);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('SERVIS & BAKIM', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, letterSpacing: 4, fontSize: 11)),
          centerTitle: true,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18), onPressed: () => Navigator.pop(context))
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GÖRSELDEN ARAMA
            InkWell(
              onTap: _gorseldenParcaAra,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
                child: Row(
                  children: [
                    const Icon(Icons.document_scanner_outlined, color: Colors.white, size: 32),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Akıllı Parça Taraması", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text("Arızalı OEM kodunu kameraya okutun.", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.3), size: 16)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 3D ARAÇ
            const Text("Dinamik Şema", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
            const SizedBox(height: 16),
            Container(
              height: 180, width: double.infinity,
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12), image: const DecorationImage(image: NetworkImage('https://img.freepik.com/free-vector/car-wireframe-transparent-background_1284-41132.jpg'), fit: BoxFit.cover, opacity: 0.2)),
              child: Center(
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: const Text("3D ŞEMAYI YÜKLE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1))
                  )
              ),
            ),
            const SizedBox(height: 40),

            const Text("Donanım Kaydı", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
            const SizedBox(height: 16),

            // KATEGORİLER
            ListView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _servisKategorileri.length,
              itemBuilder: (context, index) {
                var kategori = _servisKategorileri[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Icon(kategori['ikon'], color: Colors.white70, size: 22),
                      title: Text(kategori['baslik'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                      iconColor: Colors.white, collapsedIconColor: Colors.white54,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8), decoration: const BoxDecoration(color: bgColor, borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
                          child: Column(
                            children: (kategori['alt_kategoriler'] as List<String>).map((parca) {
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                title: Text(parca, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                                trailing: const Icon(Icons.add, color: Colors.white38, size: 18),
                                onTap: () => _islemSecimi(parca, kategori['video_istiyor_mu']),
                              );
                            }).toList(),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}