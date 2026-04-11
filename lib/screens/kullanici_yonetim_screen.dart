import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🚀 KARARGAH ZIRHLARI VE SERVİSLER
import '../core/siber_tema.dart';
import '../core/responsive_kalkan.dart';
import '../core/turkiye_haritasi.dart';
import '../services/bolge_yonetimi.dart'; // Siber Yetki Motorumuz

class KullaniciYonetimScreen extends StatefulWidget {
  const KullaniciYonetimScreen({super.key});

  @override
  State<KullaniciYonetimScreen> createState() => _KullaniciYonetimScreenState();
}

class _KullaniciYonetimScreenState extends State<KullaniciYonetimScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AdminYetkiServisi _yetkiServisi = AdminYetkiServisi();
  late TabController _tabController;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- 🔴 SİBER İHRAÇ PROTOKOLÜ ---
  // Rütbeyi geri alır ve personeli standart kullanıcı statüsüne çeker
  Future<void> _komutanliktanIhracEt(String kullaniciId, String isim) async {
    setState(() => _isProcessing = true);

    final sonuc = await _yetkiServisi.komutanliktanIhracEt(kullaniciId, isim);

    if (!mounted) return;
    setState(() => _isProcessing = false);

    _siberUyariVer(
        sonuc['mesaj'],
        isError: !sonuc['basarili'],
        icon: sonuc['basarili'] ? Icons.security_update_warning : Icons.error_outline
    );
  }

  // --- 🟢 SİBER ATAMA PROTOKOLÜ VE BÖLGE SEÇİM EKRANI ---
  // Personeli seçilen bölgenin mutlak komutanı olarak mühürler
  void _komutanAtaDialogAc(String kullaniciId, String isim) {
    String? seciliBolge;

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setStateDialog) {
                return AlertDialog(
                  backgroundColor: SiberTema.matGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5)),
                  ),
                  title: Row(
                    children: [
                      const Icon(Icons.military_tech, color: SiberTema.kuantumCyan),
                      const SizedBox(width: 8),
                      Text("RÜTBE ATAMASI: $isim", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Bu personele Bölge Komutanlığı yetkisi verilecek.", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                      const SizedBox(height: 20),
                      Text("SORUMLU BÖLGE SEÇİN:", style: TextStyle(color: SiberTema.kuantumCyan.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: SiberTema.oledBlack,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            dropdownColor: SiberTema.oledBlack,
                            hint: Text("Bölge Seçiniz", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13)),
                            value: seciliBolge,
                            icon: const Icon(Icons.arrow_drop_down, color: SiberTema.kuantumCyan),
                            items: TurkiyeHaritasi.bolgeler.map((bolge) => DropdownMenuItem(value: bolge, child: Text(bolge, style: const TextStyle(color: Colors.white)))).toList(),
                            onChanged: (val) => setStateDialog(() => seciliBolge = val),
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("İPTAL", style: TextStyle(color: Colors.white.withOpacity(0.5))),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SiberTema.kuantumCyan,
                        foregroundColor: SiberTema.oledBlack,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: seciliBolge == null ? null : () async {
                        Navigator.pop(context);
                        setState(() => _isProcessing = true);

                        final sonuc = await _yetkiServisi.bolgeKomutaniAta(
                            kullaniciId: kullaniciId,
                            isim: isim,
                            bolge: seciliBolge!
                        );

                        if (!mounted) return;
                        setState(() => _isProcessing = false);
                        _siberUyariVer(sonuc['mesaj'], isError: !sonuc['basarili']);
                      },
                      icon: const Icon(Icons.check_circle, size: 16),
                      label: const Text("MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                  ],
                );
              }
          );
        }
    );
  }

  void _siberUyariVer(String mesaj, {required bool isError, IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon ?? (isError ? Icons.warning_amber_rounded : Icons.security), color: isError ? Colors.white : SiberTema.oledBlack, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(mesaj, style: TextStyle(color: isError ? Colors.white : SiberTema.oledBlack, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
          ],
        ),
        backgroundColor: isError ? SiberTema.kanKirmizi : SiberTema.kuantumCyan,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          leading: IconButton(icon: const Icon(Icons.shield, color: SiberTema.kuantumCyan), onPressed: () => Navigator.pop(context)),
          title: Text("PERSONEL & YETKİ MERKEZİ", style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 2)),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: SiberTema.kuantumCyan,
            indicatorWeight: 3,
            labelColor: SiberTema.kuantumCyan,
            unselectedLabelColor: Colors.white.withOpacity(0.4),
            labelStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 12),
            tabs: const [
              Tab(text: "AKTİF KOMUTANLAR", icon: Icon(Icons.military_tech)),
              Tab(text: "STANDART PERSONEL", icon: Icon(Icons.people_alt_outlined)),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildAktifKomutanlarSekmesi(),
                _buildStandartKullanicilarSekmesi(),
              ],
            ),
            if (_isProcessing)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan, strokeWidth: 3)),
              ),
          ],
        ),
      ),
    );
  }

  // --- 🛡️ 1. SEKME: AKTİF BÖLGE KOMUTANLARI ---
  Widget _buildAktifKomutanlarSekmesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('kullanicilar').where('rol', isEqualTo: 'bolge_komutani').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return _buildBosDurum("SAHADA AKTİF KOMUTAN BULUNAMADI");

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final id = docs[index].id;
            final isim = data['isim'] ?? 'İsimsiz Personel';
            final bolge = data['sorumlu_bolge'] ?? 'Bilinmeyen Bölge';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: SiberTema.siberCamDekorasyonu(renk: SiberTema.kuantumCyan),
              child: Row(
                children: [
                  const Icon(Icons.military_tech, color: SiberTema.kuantumCyan, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isim, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                        Text("Sorumlu: $bolge Bölgesi", style: const TextStyle(color: SiberTema.kuantumCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: SiberTema.kanKirmizi),
                    onPressed: () => _komutanliktanIhracEt(id, isim),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- 👥 2. SEKME: STANDART KULLANICILAR ---
  Widget _buildStandartKullanicilarSekmesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('kullanicilar').where('rol', isEqualTo: 'kullanici').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan));

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return _buildBosDurum("STANDART PERSONEL BULUNAMADI");

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final id = docs[index].id;
            final isim = data['isim'] ?? 'İsimsiz Personel';
            final email = data['email'] ?? 'E-Posta Yok';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SiberTema.matGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline, color: Colors.white38, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isim, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                        Text(email, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: SiberTema.kuantumCyan.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _komutanAtaDialogAc(id, isim),
                    child: const Text("YETKİ VER", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 10, fontWeight: FontWeight.w900)),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBosDurum(String mesaj) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radar, size: 64, color: SiberTema.kuantumCyan.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(mesaj, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}