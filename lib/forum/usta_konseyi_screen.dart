import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🦅 SİBER USTA KONSEYİ (Lonca Meclisi)
/// Esnaflar arası teknik yardımlaşma, parça ticareti ve gizli iletişim protokolü.
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

  // 🎨 Siber Renk Paleti (Kuantum Standartları)
  static const _neonGreen = Color(0xFF00FFCC);
  static const _cyberBlack = Color(0xFF0D0D0D);
  static const _cyberCard = Color(0xFF1E1E2E);

  String _seciliGonderiTipi = "Arıza Danışma";
  final List<String> _gonderiTipleri = ["Arıza Danışma", "Kritik Arıza (Video)", "Parça Aranıyor", "Genel Bilgi"];

  @override
  Widget build(BuildContext context) {
    bool isBaskan = widget.kullaniciRolUnvan.contains("BAŞKAN") || widget.kullaniciRolUnvan == "ADMIN";
    bool isEsnaf = widget.kullaniciRolUnvan != "USER" && widget.kullaniciRolUnvan != "Kullanıcı";

    return Scaffold(
      backgroundColor: _cyberBlack,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.handyman, color: _neonGreen),
            SizedBox(width: 10),
            Text('Siber Usta Konseyi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          if (isBaskan)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Colors.amber),
              onPressed: () => _baskanlikPaneliniAc(),
              tooltip: "Başkanlık Paneli",
            )
        ],
      ),
      body: Column(
        children: [
          _buildYapayZekaUyarisi(),
          Expanded(child: _buildCanliAkis(isBaskan, isEsnaf)),
        ],
      ),
      floatingActionButton: isEsnaf ? FloatingActionButton.extended(
        backgroundColor: _neonGreen,
        icon: const Icon(Icons.add_comment, color: Colors.black),
        label: const Text("Konseye Yaz", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        onPressed: () => _yeniGonderiDialog(),
      ) : null,
    );
  }

  Widget _buildYapayZekaUyarisi() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Colors.amber.withOpacity(0.1),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.memory, color: Colors.amber, size: 16),
          SizedBox(width: 8),
          Text("OtoDNA Kuantum AI, B2B Ticaret ve Kuralları Denetler.", style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCanliAkis(bool isBaskan, bool isEsnaf) {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('usta_konseyi').orderBy('tarih', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _neonGreen));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Konseyde henüz bir hareket yok.", style: TextStyle(color: Colors.white54)));
        }

        var gonderiler = snapshot.data!.docs.where((doc) {
          var veri = doc.data() as Map<String, dynamic>;
          bool herkeseAcik = veri['herkese_ac_ik'] ?? true;
          if (!isEsnaf && !herkeseAcik) return false;
          return true;
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(12),
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
    bool herkeseAcik = veri['herkese_ac_ik'] ?? true;
    Color tipRengi = _getTipRengi(tip);
    IconData tipIkoni = _getTipIkoni(tip);

    return Card(
      color: _cyberCard,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.white12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: tipRengi.withOpacity(0.2), child: Icon(tipIkoni, color: tipRengi)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(veri['yazar_adi'] ?? 'Gizli Usta', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text(veri['yazar_rol'] ?? 'Üye', style: TextStyle(color: tipRengi, fontSize: 11)),
                          const SizedBox(width: 8),
                          Icon(herkeseAcik ? Icons.public : Icons.lock, color: Colors.grey, size: 12),
                          const SizedBox(width: 4),
                          Text(herkeseAcik ? "Herkese Açık" : "Sadece Lonca", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isBaskan || veri['yazar_id'] == widget.aktifKullaniciId)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 20),
                    onPressed: () => _gonderiyiSil(docId),
                  )
              ],
            ),
            const SizedBox(height: 12),
            Text(veri['icerik'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 16),
            if (tip == "Parça Aranıyor" && veri['yazar_id'] != widget.aktifKullaniciId)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: _neonGreen, foregroundColor: Colors.black),
                  icon: const Icon(Icons.handshake),
                  label: const Text("Bende Var! Ticaret Başlat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () => _siberTicaretBaslat(veri['yazar_id']),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _yeniGonderiDialog() {
    bool localHerkeseAcik = false;
    showModalBottomSheet(
      context: context,
      backgroundColor: _cyberCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Lonca'ya Seslen", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _seciliGonderiTipi,
                      dropdownColor: _cyberBlack,
                      style: const TextStyle(color: _neonGreen),
                      items: _gonderiTipleri.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) => setModalState(() => _seciliGonderiTipi = val!),
                      decoration: _siberInputDecoration("Gönderi Tipi"),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _gonderiController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: _siberInputDecoration("Arıza detayı veya parça kodu..."),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
                      child: SwitchListTile(
                        activeColor: _neonGreen,
                        title: const Text("Kullanıcılar Görebilir", style: TextStyle(color: Colors.white, fontSize: 14)),
                        value: localHerkeseAcik,
                        onChanged: (val) => setModalState(() => localHerkeseAcik = val),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: _neonGreen, padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: () => _yapayZekaIleDenetleVeGonder(ctx, localHerkeseAcik),
                        child: const Text("Kuantum Ağına Gönder", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }
        );
      },
    );
  }

  InputDecoration _siberInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: _neonGreen), borderRadius: BorderRadius.circular(10)),
    );
  }

  Future<void> _yapayZekaIleDenetleVeGonder(BuildContext ctx, bool herkeseAcik) async {
    String metin = _gonderiController.text.trim();
    if (metin.isEmpty) return;

    if (metin.contains(RegExp(r'[0-9]{10}')) || metin.toLowerCase().contains("iban")) {
      Navigator.pop(ctx);
      _siberHata("🚨 AI ENGELİ: B2B Ticaret Kasası üzerinden yapılmalıdır! (IBAN/Tel yasak).");
      return;
    }

    await _db.collection('usta_konseyi').add({
      'yazar_id': widget.aktifKullaniciId,
      'yazar_adi': widget.aktifKullaniciAdi,
      'yazar_rol': widget.kullaniciRolUnvan,
      'tip': _seciliGonderiTipi,
      'icerik': metin,
      'herkese_ac_ik': herkeseAcik,
      'tarih': FieldValue.serverTimestamp(),
    });
    _gonderiController.clear();
    Navigator.pop(ctx);
  }

  void _siberTicaretBaslat(String saticiId) {
    _siberHata("TİCARET MOTORU YÜKLENİYOR: Güvenli Sohbet Kanalı Açılıyor...");
  }

  Future<void> _gonderiyiSil(String docId) async {
    await _db.collection('usta_konseyi').doc(docId).delete();
  }

  void _baskanlikPaneliniAc() {
    _siberHata("🛡️ BAŞKANLIK MODU AKTİF");
  }

  void _siberHata(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.bold)), backgroundColor: _neonGreen));
  }

  Color _getTipRengi(String tip) {
    if (tip == "Kritik Arıza (Video)") return Colors.redAccent;
    if (tip == "Parça Aranıyor") return Colors.amber;
    if (tip == "Arıza Danışma") return Colors.blueAccent;
    return Colors.grey;
  }

  IconData _getTipIkoni(String tip) {
    if (tip == "Kritik Arıza (Video)") return Icons.video_camera_back;
    if (tip == "Parça Aranıyor") return Icons.search;
    if (tip == "Arıza Danışma") return Icons.help_outline;
    return Icons.forum;
  }
}