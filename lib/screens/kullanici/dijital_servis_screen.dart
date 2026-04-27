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
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        title: Row(children: [Icon(Icons.camera_alt_outlined, color: Colors.teal.shade700), const SizedBox(width: 8), const Text("Siber Vizyon", style: TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontFamily: 'Avenir', fontWeight: FontWeight.bold))]),
        content: const Text("Kameranız üzerinden arızalı parçayı veya OEM kodunu taratarak küresel ağda eşleşme arayın.", style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5, fontFamily: 'Avenir')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal", style: TextStyle(color: Colors.white38, fontFamily: 'Avenir'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700, foregroundColor: Colors.white, elevation: 0),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Lens Aktif Ediliyor...', style: TextStyle(color: SiberTema.textMain)), backgroundColor: Colors.teal.shade700));
            },
            child: const Text("Taramayı Başlat", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.1), blurRadius: 20)]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(parcaAdi, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
            const SizedBox(height: 8),
            const Text("Bu parçanın dijital genetiğine işlenecek işlemi seçin.", style: TextStyle(color: Colors.white54, fontSize: 13, fontFamily: 'Avenir')),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIslemButonu(Icons.autorenew_outlined, "Değişti", Colors.redAccent),
                _buildIslemButonu(Icons.format_paint_outlined, "Boyandı", Colors.orange),
                _buildIslemButonu(Icons.build_outlined, "Onarıldı", Colors.blue),
              ],
            ),
            if (videoIstiyorMu) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.teal.shade700, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.teal.shade700.withValues(alpha: 0.5))), elevation: 0),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Kamera Açılıyor...', style: TextStyle(color: SiberTema.textMain)), backgroundColor: Colors.teal.shade700));
                  },
                  icon: Icon(Icons.videocam_outlined, color: Colors.teal.shade700, size: 20),
                  label: Text("İşlem Anı Videosu Yükle", style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.w900, fontSize: 13, fontFamily: 'Avenir')),
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.3)), boxShadow: [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10)]),
        child: Column(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 28)),
              const SizedBox(height: 12),
              Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Avenir'))
            ]
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🏢 PLAZA KALİTESİ PALET
    const bgColor = Color(0xFFFAFAFC);
    const surfaceColor = Colors.white;
    const textColor = Color(0xFF1E293B);
    final primaryTeal = Colors.teal.shade700;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
          backgroundColor: surfaceColor,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          title: Text('SERVIS & BAKIM', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, letterSpacing: 4, fontSize: 11, fontFamily: 'Avenir')),
          centerTitle: true,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: primaryTeal, size: 18), onPressed: () => Navigator.pop(context))
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
                decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10)]),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(Icons.document_scanner_outlined, color: primaryTeal, size: 32)),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Akıllı Parça Taraması", style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                          const SizedBox(height: 4),
                          const Text("Arızalı OEM kodunu kameraya okutun.", style: TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'Avenir')),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.2), size: 16)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 3D ARAÇ
            Text("Dinamik Şema", style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
            const SizedBox(height: 16),
            Container(
              height: 180, width: double.infinity,
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 10)], image: const DecorationImage(image: NetworkImage('https://img.freepik.com/free-vector/car-wireframe-transparent-background_1284-41132.jpg'), fit: BoxFit.cover, opacity: 0.1)),
              child: Center(
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryTeal.withValues(alpha: 0.2)), boxShadow: [BoxShadow(color: primaryTeal.withValues(alpha: 0.1), blurRadius: 8)]),
                      child: Text("3D ŞEMAYI YÜKLE", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1, fontFamily: 'Avenir'))
                  )
              ),
            ),
            const SizedBox(height: 40),

            Text("Donanım Kaydı", style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5, fontFamily: 'Avenir')),
            const SizedBox(height: 16),

            // KATEGORİLER
            ListView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _servisKategorileri.length,
              itemBuilder: (context, index) {
                var kategori = _servisKategorileri[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.05)), boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 8)]),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Icon(kategori['ikon'], color: primaryTeal, size: 22),
                      title: Text(kategori['baslik'], style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 14, fontFamily: 'Avenir')),
                      iconColor: primaryTeal, collapsedIconColor: Colors.black54,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8), decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)), border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05)))),
                          child: Column(
                            children: (kategori['alt_kategoriler'] as List<String>).map((parca) {
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                title: Text(parca, style: const TextStyle(color: Colors.white87, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Avenir')),
                                trailing: Icon(Icons.add, color: primaryTeal.withValues(alpha: 0.5), size: 18),
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