import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BayiUzmanlikProfilScreen extends StatefulWidget {
  const BayiUzmanlikProfilScreen({super.key});

  @override
  State<BayiUzmanlikProfilScreen> createState() => _BayiUzmanlikProfilScreenState();
}

class _BayiUzmanlikProfilScreenState extends State<BayiUzmanlikProfilScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  bool _isLoading = false;
  final TextEditingController _aciklamaController = TextEditingController();

  // SİBER KATEGORİ VE ALT BİLEŞEN AĞI
  String _secilenAnaKategori = "Mekanik & Motor"; // Varsayılan

  final List<String> _anaKategoriler = [
    "Mekanik & Motor",
    "Şase & Torna & Kaynak",
    "Elektronik & Oto Beyin",
    "Kaporta & Boya",
    "Yedek Parça Satışı"
  ];

  // Kategoriye Göre Dinamik Değişen Alt Uzmanlıklar
  final Map<String, List<String>> _altUzmanlikHavuzu = {
    "Mekanik & Motor": ["Periyodik Bakım", "Ağır Bakım (Triger vb.)", "Motor Rektefiye", "Otomatik Şanzıman (DSG/CVT)", "Alt Takım & Süspansiyon", "Turbo Revizyon"],
    "Şase & Torna & Kaynak": ["Torsiyon Tamiri", "Şase Düzeltme & Podye", "Argon & Alüminyum Kaynak", "Jant Düzeltme", "Disk Torna", "Özel Flanş Üretimi"],
    "Elektronik & Oto Beyin": ["ECU (Beyin) Tamiri", "Chip Tuning / Yazılım", "Airbag & Emniyet Kemeri", "ABS Beyni", "Tesisat Yenileme", "Gösterge Tamiri"],
    "Kaporta & Boya": ["Boyasız Göçük Düzeltme", "Fırın Boya", "Plastik Tampon Tamiri", "Pasta Cila & Seramik", "Dolu Hasarı Onarımı"],
    "Yedek Parça Satışı": ["Orijinal (OEM) Parça", "Çıkma (Hurdacı) Parça", "Yan Sanayi (Muadil)", "Karoser & Kaporta", "Mekanik Parçalar", "Elektronik Sensörler"],
  };

  // Ustanın baktığı araç grupları
  final List<String> _markaGruplari = [
    "Tüm Markalar", "VAG Grubu (VW, Audi, Seat, Skoda)", "BMW & MINI", "Mercedes-Benz", "Renault & Dacia", "Fiat & Alfa Romeo", "PSA (Peugeot, Citroen, Opel)", "Japon (Toyota, Honda, Nissan)", "Kore (Hyundai, Kia)", "Ford"
  ];

  // SEÇİLEN VERİLER (Firebase'e Gidecek Kuantum Mühürleri)
  List<String> _secilenAltUzmanliklar = [];
  List<String> _secilenMarkalar = ["Tüm Markalar"];

  @override
  void dispose() {
    _aciklamaController.dispose();
    super.dispose();
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: TextStyle(color: isError ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF00FFC2),
    ));
  }

  // 🚀 FİREBASE KİMLİK GÜNCELLEME (UZMANLIK MÜHRÜ)
  Future<void> _uzmanligiKuantumAginaKaydet() async {
    if (_currentUser == null) return;
    if (_secilenAltUzmanliklar.isEmpty) {
      _showSnackBar("Lütfen en az bir alt uzmanlık alanı seçin!", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Doğrudan kullanıcının belgesine uzmanlık radarlarını ekliyoruz
      await _db.collection('kullanicilar').doc(_currentUser!.uid).update({
        'uzmanlik_ana_kategori': _secilenAnaKategori,
        'uzmanlik_alt_dallari': _secilenAltUzmanliklar,
        'hizmet_verilen_markalar': _secilenMarkalar,
        'firma_tanitimi': _aciklamaController.text.trim(),
        'profil_tamamlandi_mi': true, // Arama motorunda görünür kılan şalter
        'guncellenme_tarihi': FieldValue.serverTimestamp(),
      });

      _showSnackBar("Siber Uzmanlık Profiliniz Kuantum Ağına Mühürlendi! 🛡️");

      // Kayıt başarılı ise ana ekrana veya bir önceki sayfaya fırlat
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });

    } catch (e) {
      _showSnackBar("Ağ Hatası: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan), onPressed: () => Navigator.pop(context)),
        title: const Text("Firma Uzmanlık Radarı", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.radar, color: primaryCyan, size: 28),
                SizedBox(width: 12),
                Expanded(child: Text("Müşteriler Sizi Nasıl Bulsun?", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 8),
            const Text("OtoDNA arama motorunda (Siber Radar) doğru müşterilerle ve B2B iş ortaklarıyla eşleşmek için uzmanlık alanlarınızı net bir şekilde belirleyin.", style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
            const SizedBox(height: 32),

            // 1. ANA BRANŞ SEÇİMİ (DROPDOWN)
            _buildSectionTitle(Icons.account_tree, "1. Ana İşletme Branşınız"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: cardColor,
                  value: _secilenAnaKategori,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: primaryCyan),
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  items: _anaKategoriler.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {
                    setState(() {
                      _secilenAnaKategori = val!;
                      _secilenAltUzmanliklar.clear(); // Branş değişince alt uzmanlıkları sıfırla
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 2. DİNAMİK ALT UZMANLIKLAR (CHIPS)
            _buildSectionTitle(Icons.precision_manufacturing, "2. Detaylı Hizmetler (Çoklu Seçim)"),
            const SizedBox(height: 8),
            const Text("Müşteriler arama çubuğuna 'Torsiyon' veya 'DSG' yazdığında sizin çıkmanızı sağlar.", style: TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _altUzmanlikHavuzu[_secilenAnaKategori]!.map((hizmet) {
                bool isSelected = _secilenAltUzmanliklar.contains(hizmet);
                return FilterChip(
                  label: Text(hizmet, style: TextStyle(color: isSelected ? bgColor : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
                  selected: isSelected,
                  selectedColor: primaryCyan,
                  backgroundColor: cardColor,
                  checkmarkColor: bgColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? primaryCyan : Colors.white12)),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _secilenAltUzmanliklar.add(hizmet);
                      } else {
                        _secilenAltUzmanliklar.remove(hizmet);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // 3. MARKA BAZLI UZMANLIK
            _buildSectionTitle(Icons.directions_car, "3. Hizmet Verilen Araç Grupları"),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _markaGruplari.map((marka) {
                bool isSelected = _secilenMarkalar.contains(marka);
                return FilterChip(
                  label: Text(marka, style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontSize: 11)),
                  selected: isSelected,
                  selectedColor: Colors.purpleAccent.withOpacity(0.4),
                  backgroundColor: bgColor,
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.purpleAccent : Colors.white12)),
                  onSelected: (bool selected) {
                    setState(() {
                      if (marka == "Tüm Markalar") {
                        _secilenMarkalar = ["Tüm Markalar"];
                      } else {
                        _secilenMarkalar.remove("Tüm Markalar");
                        if (selected) {
                          _secilenMarkalar.add(marka);
                        } else {
                          _secilenMarkalar.remove(marka);
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // 4. KENDİNİ TANIT (HAKKIMIZDA)
            _buildSectionTitle(Icons.edit_document, "4. Siber Vitrin Açıklaması"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
              child: TextField(
                controller: _aciklamaController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Müşterilerinize işletmenizin tecrübesinden, kullandığınız teknolojik cihazlardan veya garantili hizmetlerinizden bahsedin...",
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 13, height: 1.5),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // MÜHÜRLE BUTONU
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryCyan,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 10, shadowColor: primaryCyan.withOpacity(0.5)
                ),
                onPressed: _isLoading ? null : _uzmanligiKuantumAginaKaydet,
                icon: _isLoading ? const SizedBox() : const Icon(Icons.save, color: bgColor, size: 24),
                label: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: bgColor, strokeWidth: 2))
                    : const Text("Uzmanlık Profilimi Kuantum Ağına İşle", style: TextStyle(color: bgColor, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }
}