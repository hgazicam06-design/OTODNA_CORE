import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI VE KÖPRÜLER
import '../../core/siber_tema.dart';
// import '../../core/siber_yetki_kalkani.dart'; // Yetki kalkanını daha önce yazmıştık, aktif edebilirsin.

/// 🦅 SİBER USTA KONSEYİ VE LONCA MATRİSİ (V4 - Çok Katmanlı Ağ)
/// Tüm otomotiv sektörünün (Mekanik, Elektrik, Kaporta, Fan Club) branşlara ayrıldığı devasa Kuantum Forumu.
class UstaKonseyiScreen extends StatefulWidget {
  final String aktifKullaniciId;
  final String aktifKullaniciAdi;
  final String kullaniciRolUnvan; // "Mekanik Ustası", "Parçacı", "BAŞKAN" veya "USER"

  const UstaKonseyiScreen({
    super.key,
    required this.aktifKullaniciId,
    required this.aktifKullaniciAdi,
    required this.kullaniciRolUnvan,
  });

  @override
  State<UstaKonseyiScreen> createState() => _UstaKonseyiScreenState();
}

class _UstaKonseyiScreenState extends State<UstaKonseyiScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _gonderiController = TextEditingController();
  final TextEditingController _baslikController = TextEditingController();

  // 🌍 KUANTUM BRANŞLARI (Alt-Loncalar)
  final List<String> _loncaKategorileri = [
    "Tüm Karargah",
    "Oto Mekanik & Motor",
    "Oto Elektrik & Beyin",
    "Kaporta & Boya",
    "Tornacı & İşleme",
    "Performans & Tuning",
    "Sivil Fan Club (Kullanıcılar)"
  ];
  String _seciliKategori = "Tüm Karargah";

  String _seciliGonderiTipi = "Arıza Danışma";
  final List<String> _gonderiTipleri = ["Arıza Danışma", "Kritik Arıza (Video)", "Parça Aranıyor", "Genel Bilgi"];

  @override
  Widget build(BuildContext context) {
    bool isBaskan = widget.kullaniciRolUnvan.contains("BAŞKAN") || widget.kullaniciRolUnvan == "ADMIN";
    // Sivil Fan Club dışındaki odalara sivillerin konu açmasını engelleme kalkanı
    bool isEsnaf = widget.kullaniciRolUnvan != "USER" && widget.kullaniciRolUnvan != "Kullanıcı";

    return Scaffold(
      backgroundColor: SiberTema.oledBlack,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.hub_outlined, color: SiberTema.kuantumCyan),
            SizedBox(width: 10),
            Text('Siber Lonca Ağı', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1, fontFamily: 'Avenir')),
          ],
        ),
        actions: [
          if (isBaskan)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: SiberTema.siberGold),
              onPressed: () => _baskanlikPaneliniAc(),
              tooltip: "Başkanlık Paneli",
            )
        ],
      ),
      body: Column(
        children: [
          _buildYapayZekaUyarisi(),
          _buildKategoriRadari(), // 🚀 Yeni Yatay Branş Seçici
          const Divider(color: Colors.white10, height: 1),
          Expanded(child: _buildCanliAkis(isBaskan, isEsnaf)),
        ],
      ),
      // 🛡️ SİBER YETKİ: Kullanıcılar da form açabilir ama sadece Fan Club'da veya yetkisi varsa!
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: SiberTema.kuantumCyan,
        icon: const Icon(Icons.add_comment, color: Colors.black),
        label: const Text("SİBER KONU AÇ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
        onPressed: () => _yeniGonderiDialog(isEsnaf),
      ),
    );
  }

  // ─── 1. KATEGORİ (BRANŞ) RADARI ───
  Widget _buildKategoriRadari() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _loncaKategorileri.length,
        itemBuilder: (context, index) {
          String kategori = _loncaKategorileri[index];
          bool isSelected = _seciliKategori == kategori;

          return GestureDetector(
            onTap: () => setState(() => _seciliKategori = kategori),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? SiberTema.kuantumCyan.withOpacity(0.15) : SiberTema.matGrey,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? SiberTema.kuantumCyan : Colors.white10, width: isSelected ? 1.5 : 1),
              ),
              child: Center(
                child: Text(
                  kategori.toUpperCase(),
                  style: TextStyle(
                      color: isSelected ? SiberTema.kuantumCyan : Colors.white54,
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                      letterSpacing: 1,
                      fontFamily: 'Avenir'
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildYapayZekaUyarisi() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: SiberTema.siberGold.withOpacity(0.1),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.memory, color: SiberTema.siberGold, size: 16),
          SizedBox(width: 8),
          Text("OtoDNA Kuantum AI, Branş İçi Ticareti ve İhlalleri Denetler.", style: TextStyle(color: SiberTema.siberGold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  // ─── 2. CANLI AKIŞ (KATEGORİYE GÖRE FİLTRELİ) ───
  Widget _buildCanliAkis(bool isBaskan, bool isEsnaf) {
    // Kategoriye göre Kuantum Filtreleme
    Query query = _db.collection('usta_konseyi').orderBy('tarih', descending: true);
    if (_seciliKategori != "Tüm Karargah") {
      query = _db.collection('usta_konseyi').where('kategori', isEqualTo: _seciliKategori).orderBy('tarih', descending: true);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("Bu Kuantum Odasında henüz veri yok.", style: TextStyle(color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.bold, fontFamily: 'Avenir')));
        }

        var gonderiler = snapshot.data!.docs.where((doc) {
          var veri = doc.data() as Map<String, dynamic>;
          bool herkeseAcik = veri['herkese_ac_ik'] ?? true;
          // Sivil Kullanıcı isEsnaf == false'dur. Eğer gönderi sadece Lonca'ya (esnafa) özgüyse sivil bunu göremez.
          if (!isEsnaf && !herkeseAcik) return false;
          return true;
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          itemCount: gonderiler.length,
          itemBuilder: (context, index) {
            var veri = gonderiler[index].data() as Map<String, dynamic>;
            String docId = gonderiler[index].id;
            return _buildGonderiKarti(veri, docId, isBaskan);
          },
        );
      },
    );
  }

  Widget _buildGonderiKarti(Map<String, dynamic> veri, String docId, bool isBaskan) {
    String tip = veri['tip'] ?? 'Genel';
    String baslik = veri['baslik'] ?? 'Konu Başlığı';
    String kategori = veri['kategori'] ?? 'Genel';
    bool herkeseAcik = veri['herkese_ac_ik'] ?? true;
    Color tipRengi = _getTipRengi(tip);
    IconData tipIkoni = _getTipIkoni(tip);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: SiberTema.matGrey,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ÜST BİLGİ: Kategori ve Kimlik
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: SiberTema.kuantumCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(kategori, style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 9, fontWeight: FontWeight.w900)),
                ),
                const Spacer(),
                Icon(herkeseAcik ? Icons.public : Icons.lock, color: Colors.white24, size: 12),
                const SizedBox(width: 4),
                Text(herkeseAcik ? "Açık Ağ" : "Gizli Lonca", style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            // İÇERİK BAŞLIĞI
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(backgroundColor: tipRengi.withOpacity(0.2), radius: 20, child: Icon(tipIkoni, color: tipRengi, size: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(baslik, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(veri['yazar_adi'] ?? 'Gizli Sürücü', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          Text("• ${veri['yazar_rol']}", style: TextStyle(color: tipRengi, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isBaskan || veri['yazar_id'] == widget.aktifKullaniciId)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep, color: SiberTema.kanKirmizi, size: 20),
                    onPressed: () => _gonderiyiSil(docId),
                  )
              ],
            ),
            const SizedBox(height: 16),
            Text(veri['icerik'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 20),

            // TİCARET VEYA YANIT BUTONU
            if (tip == "Parça Aranıyor" && veri['yazar_id'] != widget.aktifKullaniciId)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: SiberTema.kuantumButonStili(),
                  icon: const Icon(Icons.handshake, color: Colors.black, size: 18),
                  label: const Text("BENDE VAR! TİCARET HAVUZUNU AÇ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                  onPressed: () => _siberTicaretBaslat(veri['yazar_id']),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── 3. SİBER KONU AÇMA PANELİ ───
  void _yeniGonderiDialog(bool isEsnaf) {
    bool localHerkeseAcik = true;
    String localKategori = _seciliKategori == "Tüm Karargah" ? _loncaKategorileri[1] : _seciliKategori; // Varsayılan kategori

    showModalBottomSheet(
      context: context,
      backgroundColor: SiberTema.matGrey,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("YENİ SİBER BAŞLIK OLUŞTUR", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1, fontFamily: 'Avenir')),
                    const SizedBox(height: 24),

                    // BRANŞ (KATEGORİ) SEÇİMİ
                    _buildDropdownContainer(
                        hint: "Branş (Oda) Seçin",
                        value: localKategori,
                        items: _loncaKategorileri.where((k) => k != "Tüm Karargah").toList(),
                        onChanged: (val) {
                          // Siviller sadece Fan Club'a yazabilir kalkanı!
                          if (!isEsnaf && val != "Sivil Fan Club (Kullanıcılar)") {
                            _siberHata("SİBER İHLAL: Sivil kullanıcılar sadece 'Fan Club' odasında konu açabilir!");
                            return;
                          }
                          setModalState(() => localKategori = val!);
                        }
                    ),

                    // GÖNDERİ TİPİ
                    _buildDropdownContainer(
                        hint: "Gönderi Tipi",
                        value: _seciliGonderiTipi,
                        items: _gonderiTipleri,
                        onChanged: (val) => setModalState(() => _seciliGonderiTipi = val!)
                    ),

                    const SizedBox(height: 8),
                    TextField(
                      controller: _baslikController,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Avenir', fontWeight: FontWeight.bold),
                      decoration: SiberTema.siberInputDecor("Konu Başlığı", Icons.title),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _gonderiController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Avenir'),
                      decoration: SiberTema.siberInputDecor("Açıklama, arıza detayı veya oem kodu...", Icons.description),
                    ),
                    const SizedBox(height: 16),

                    if (isEsnaf) // Siviller gizlilik ayarıyla oynayamaz
                      Container(
                        decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
                        child: SwitchListTile(
                          activeColor: SiberTema.kuantumCyan,
                          title: const Text("Sivil Kullanıcılar da Görebilir", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          value: localHerkeseAcik,
                          onChanged: (val) => setModalState(() => localHerkeseAcik = val),
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: SiberTema.kuantumButonStili(),
                        onPressed: () => _yapayZekaIleDenetleVeGonder(ctx, localHerkeseAcik, localKategori),
                        icon: const Icon(Icons.satellite_alt, color: Colors.black),
                        label: const Text("AĞA YAYINLA", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            }
        );
      },
    );
  }

  // YARDIMCI DROPDOWN METODU
  Widget _buildDropdownContainer({required String hint, required String? value, required List<String> items, required void Function(String?)? onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: SiberTema.oledBlack, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true, dropdownColor: SiberTema.matGrey,
          icon: const Icon(Icons.arrow_drop_down, color: SiberTema.kuantumCyan),
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Avenir')))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ─── 4. KUANTUM DENETİM VE MÜHÜRLEME (ATOMİK) ───
  Future<void> _yapayZekaIleDenetleVeGonder(BuildContext ctx, bool herkeseAcik, String kategori) async {
    String metin = _gonderiController.text.trim();
    String baslik = _baslikController.text.trim();
    if (metin.isEmpty || baslik.isEmpty) return;

    // AI KURAL İHLALİ: IBAN VEYA TELEFON KORUMASI
    if (metin.contains(RegExp(r'[0-9]{10}')) || metin.toLowerCase().contains("iban")) {
      Navigator.pop(ctx);
      _siberHata("🚨 AI ENGELİ: B2B Ticaret Karargah Havuzu üzerinden yapılmalıdır! (Açıktan iletişim yasak).");
      return;
    }

    try {
      WriteBatch batch = _db.batch();

      DocumentReference yeniGonderiRef = _db.collection('usta_konseyi').doc();
      batch.set(yeniGonderiRef, {
        'yazar_id': widget.aktifKullaniciId,
        'yazar_adi': widget.aktifKullaniciAdi,
        'yazar_rol': widget.kullaniciRolUnvan,
        'baslik': baslik,
        'kategori': kategori,
        'tip': _seciliGonderiTipi,
        'icerik': metin,
        'herkese_ac_ik': herkeseAcik,
        'tarih': FieldValue.serverTimestamp(),
      });

      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'FORUM_BASLIK_ACILDI',
        'yazar_id': widget.aktifKullaniciId,
        'islem_detayi': '[$kategori] odasında "$baslik" isimli Kuantum Başlığı açıldı.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      _gonderiController.clear();
      _baslikController.clear();
      if (mounted) Navigator.pop(ctx);

    } catch (e) {
      _siberHata("🚨 AĞ ÇÖKTÜ: Gönderi mühürlenemedi!");
    }
  }

  void _siberTicaretBaslat(String saticiId) {
    _siberHata("TİCARET MOTORU YÜKLENİYOR: Kasa Güvenceli Kanal Açılıyor...");
  }

  Future<void> _gonderiyiSil(String docId) async {
    await _db.collection('usta_konseyi').doc(docId).delete();
  }

  void _baskanlikPaneliniAc() {
    _siberHata("🛡️ BAŞKANLIK MODU AKTİF: Siber Sansür ve Engelleme Yetkisi Verildi.");
  }

  void _siberHata(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Avenir')), backgroundColor: SiberTema.kuantumCyan));
  }

  Color _getTipRengi(String tip) {
    if (tip == "Kritik Arıza (Video)") return SiberTema.kanKirmizi;
    if (tip == "Parça Aranıyor") return SiberTema.siberGold;
    if (tip == "Arıza Danışma") return SiberTema.kuantumCyan;
    return Colors.grey;
  }

  IconData _getTipIkoni(String tip) {
    if (tip == "Kritik Arıza (Video)") return Icons.video_camera_back;
    if (tip == "Parça Aranıyor") return Icons.search;
    if (tip == "Arıza Danışma") return Icons.memory;
    return Icons.forum;
  }
}