import 'package:flutter/material.dart';

class DijitalTorpidoScreen extends StatefulWidget {
  const DijitalTorpidoScreen({super.key});

  @override
  State<DijitalTorpidoScreen> createState() => _DijitalTorpidoScreenState();
}

class _DijitalTorpidoScreenState extends State<DijitalTorpidoScreen> {
  // 🌑 TESLA KLASMANI VERİ YAPISI (Emojiler ve kaba renkler silindi, statü renkleri sadeleştirildi)
  final List<Map<String, dynamic>> _evraklar = [
    {
      'baslik': 'Zorunlu Trafik Sigortası',
      'kurum': 'OtoDNA Güvencesi',
      'bitis_tarihi': '12.10.2026',
      'ikon': Icons.shield_outlined,
      'durum': 'GEÇERLİ',
      'renk': const Color(0xFF00FFC2), // Kuantum Turkuazı
      'belge_var_mi': true,
    },
    {
      'baslik': 'TÜVTÜRK Araç Muayenesi',
      'kurum': 'Ulaştırma Bakanlığı',
      'bitis_tarihi': '25.03.2026',
      'ikon': Icons.fact_check_outlined,
      'durum': 'YAKLAŞIYOR',
      'renk': Colors.orangeAccent,
      'belge_var_mi': true,
    },
    {
      'baslik': 'Motorlu Taşıtlar Vergisi (MTV)',
      'kurum': 'Gelir İdaresi Başkanlığı (GİB)',
      'bitis_tarihi': '31.07.2026 (2. Taksit)',
      'ikon': Icons.account_balance_outlined,
      'durum': 'BEKLİYOR',
      'renk': Colors.white54,
      'belge_var_mi': false,
    },
    {
      'baslik': 'Trafik Cezaları & OGS/HGS',
      'kurum': 'Emniyet Genel Müdürlüğü',
      'bitis_tarihi': 'Son Tebliğ: 02.03.2026',
      'ikon': Icons.receipt_long_outlined,
      'durum': 'ÖDEME BEKLİYOR',
      'renk': Colors.redAccent,
      'belge_var_mi': true,
    },
    {
      'baslik': 'Egzoz Emisyon Ölçümü',
      'kurum': 'Çevre ve Şehircilik Bakanlığı',
      'bitis_tarihi': '25.03.2026',
      'ikon': Icons.cloud_outlined,
      'durum': 'YAKLAŞIYOR',
      'renk': Colors.orangeAccent,
      'belge_var_mi': true,
    },
    {
      'baslik': 'Kasko Poliçesi',
      'kurum': 'Belge Yüklenmedi',
      'bitis_tarihi': '--.--.----',
      'ikon': Icons.health_and_safety_outlined,
      'durum': 'EKSİK',
      'renk': Colors.redAccent,
      'belge_var_mi': false,
    },
    {
      'baslik': 'Servis ve Bakım Formları',
      'kurum': 'OtoDNA Onaylı Ustalar',
      'bitis_tarihi': 'Son Kayıt: 12.02.2026',
      'ikon': Icons.build_circle_outlined,
      'durum': 'ARŞİVLENDİ',
      'renk': Colors.white54,
      'belge_var_mi': true,
    },
  ];

  // 📸 SADE VE MİNİMALİST YÜKLEME PANELİ (Bottom Sheet)
  void _belgeYukleSimulasyonu(String belgeAdi) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Color(0xFF111111), // Çok koyu gri
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(belgeAdi, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            const Text("Belgenin orijinalini düz bir zemine koyarak fotoğrafını çekin veya cihazınızdan PDF formatında yükleyin.", style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.5)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: _buildModalButonu(Icons.camera_alt_outlined, "Kamera")),
                const SizedBox(width: 16),
                Expanded(child: _buildModalButonu(Icons.file_upload_outlined, "Dosya Seç")),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildModalButonu(IconData icon, String text) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$text başlatılıyor...'), backgroundColor: const Color(0xFF111111)));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF000000), // Siyah buton
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 ULTRA MİNİMALİST TASARIM DEĞİŞKENLERİ
    const bgColor = Color(0xFF000000); // Saf OLED Siyahı
    const surfaceColor = Color(0xFF111111); // Koyu Gri Yüzey (Tesla tarzı kart)
    const primaryCyan = Color(0xFF00FFC2); // Kuantum Vurgusu

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Dijital Torpido', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.5)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================================
            // GÜVENLİK BİLGİLENDİRMESİ (Sıfır renk, tamamen tipografik)
            // =================================================================
            Row(
              children: [
                const Icon(Icons.lock_outline, color: Colors.white38, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text("Tüm evraklarınız uçtan uca şifrelenmiş kasa içerisinde saklanmaktadır.", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, letterSpacing: 0.5))),
              ],
            ),
            const SizedBox(height: 24),

            // =================================================================
            // EVRAKLAR LİSTESİ (Tesla Kart Mimarisi)
            // =================================================================
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _evraklar.length,
              itemBuilder: (context, index) {
                var evrak = _evraklar[index];
                bool isEksik = evrak['belge_var_mi'] == false;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surfaceColor, // Dümdüz koyu gri kart
                    borderRadius: BorderRadius.circular(16),
                    // Eğer belge yoksa hafif kırmızımsı, yoksa beyazın %5'i ince bir sınır çizgisi
                    border: Border.all(color: isEksik ? Colors.redAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ÜST BÖLÜM (İkon, Başlık ve Durum)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(evrak['ikon'], color: Colors.white, size: 24), // İnce beyaz ikon
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(evrak['baslik'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                                const SizedBox(height: 4),
                                Text(evrak['kurum'], style: const TextStyle(color: Colors.white38, fontSize: 12)),
                              ],
                            ),
                          ),
                          // Minimalist Durum Belirteci (Sadece bir nokta ve ince yazı)
                          Row(
                            children: [
                              Container(width: 6, height: 6, decoration: BoxDecoration(color: evrak['renk'], shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text(evrak['durum'], style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ALT BÖLÜM (Tarih ve Aksiyon Butonu)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Bitiş / Son İşlem", style: TextStyle(color: Colors.white38, fontSize: 10)),
                              const SizedBox(height: 4),
                              Text(evrak['bitis_tarihi'], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'monospace')), // Tarih fontu teknik (monospace)
                            ],
                          ),

                          // ZARİF AKSİYON BUTONLARI (Flat Design)
                          if (!isEksik)
                            InkWell(
                              onTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Belge Ekranda Açılıyor...'), backgroundColor: Color(0xFF111111))); },
                              borderRadius: BorderRadius.circular(8),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text("Görüntüle", style: TextStyle(color: primaryCyan, fontSize: 13, fontWeight: FontWeight.w600)),
                              ),
                            )
                          else
                            InkWell(
                              onTap: () => _belgeYukleSimulasyonu(evrak['baslik']),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8)
                                ),
                                child: const Text("Yükle", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            )
                        ],
                      )
                    ],
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