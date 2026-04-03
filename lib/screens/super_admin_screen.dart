import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> with TickerProviderStateMixin {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color adminPurple = Colors.purpleAccent;
  static const Color dangerColor = Colors.redAccent;
  static const Color warningColor = Colors.orangeAccent;

  late TabController _tabController;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // =========================================================================
  // 🔓 İKİLİ ONAY: MÜHÜR KIRMA VE DÜZELTME TALEBİ DETAYI (Canlı Sistem)
  // =========================================================================
  void _muhurKirmaTalebiIncele(String islemId, String firma, String musteri, String sebep) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: const Border(top: BorderSide(color: adminPurple, width: 2))
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                  children: [
                    Icon(Icons.gavel, color: adminPurple, size: 32),
                    SizedBox(width: 12),
                    Text("ADMİN YETKİSİ: MÜHÜR KIRMA", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5))
                  ]
              ),
              const SizedBox(height: 16),
              const Text("Bu servis kaydı için Müşteri ve Firma 'İkili Onay' ile düzeltme talep etmiştir. Sadece Super Admin (Karargah) bu Kuantum mührünü kırabilir.", style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.5, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: adminPurple.withOpacity(0.3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("KAYIT NO: $islemId", style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    const SizedBox(height: 12),
                    Text("FİRMA: ${firma.toUpperCase()}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text("MÜŞTERİ: ${musteri.toUpperCase()}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 16),
                    const Text("İTİRAZ SEBEBİ:", style: TextStyle(color: warningColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    Text(sebep, style: const TextStyle(color: Colors.white70, fontSize: 11, fontStyle: FontStyle.italic, height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                      child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: dangerColor), padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.block, color: dangerColor, size: 20),
                          label: const Text("TALEBİ REDDET", style: TextStyle(color: dangerColor, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1))
                      )
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                      child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: adminPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: () {
                            // TODO: Firebase üzerinden kaydın mühür durumu 'KIRIK' olarak güncellenecek
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SİBER MÜHÜR KIRILDI! Düzenleme yetkisi verildi. 🔓', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)), backgroundColor: adminPurple));
                          },
                          icon: const Icon(Icons.lock_open, size: 20),
                          label: const Text("MÜHRÜ KIR (ONAY)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1))
                      )
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, color: primaryCyan, size: 24),
            SizedBox(width: 12),
            Text('ANKARA MERKEZ KARARGAH', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryCyan),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryCyan,
          labelColor: primaryCyan,
          unselectedLabelColor: Colors.white38,
          isScrollable: true,
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
          tabs: const [
            Tab(icon: Icon(Icons.account_balance), text: "KASA & FİNANS"),
            Tab(icon: Icon(Icons.gavel), text: "MÜHÜR & İTİRAZ"),
            Tab(icon: Icon(Icons.satellite_alt), text: "S.O.S RADAR"),
            Tab(icon: Icon(Icons.warning_amber_rounded), text: "KARA LİSTE"),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900), // 🖥️ Web / Double Teyp Kalkanı
            child: TabBarView(
              controller: _tabController,
              children: [
                // =========================================================
                // 1. SEKME: KASA VE FİNANS (Gerçek Zamanlı Simülasyon)
                // =========================================================
                ListView(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: primaryCyan.withOpacity(0.3))),
                      child: const Column(
                        children: [
                          Text("OTODNA KÜRESEL SİSTEM HACMİ", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          SizedBox(height: 12),
                          Text("₺ 14.550.000", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildFinansKarti("BAYİ KOMİSYON\nHAVUZU (%12)", "₺ 1.746.000", primaryCyan, Icons.pie_chart)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFinansKarti("MURAT PLAZA\nGİZLİ SATIŞ KÂRI (%30)", "₺ 850.000", adminPurple, Icons.store)),
                      ],
                    ),
                    const SizedBox(height: 48),
                    const Text("SON OTONOM İŞLEMLER", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 16),
                    _buildIslemSatiri("BOSCH FREN BALATASI (MURAT PLAZA)", "GİZLİ SİBER SATIŞ", "+ ₺375.00 (%30)", adminPurple),
                    _buildIslemSatiri("ŞANZIMAN MÜDAHALESİ (BORUSAN)", "AĞ KOMİSYONU", "+ ₺1,020.00 (%12)", primaryCyan),
                  ],
                ),

                // =========================================================
                // 2. SEKME: MÜHÜR & İTİRAZ (İKİLİ ONAY MERKEZİ)
                // =========================================================
                ListView(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(color: adminPurple.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: adminPurple.withOpacity(0.3))),
                        child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: adminPurple),
                              SizedBox(width: 16),
                              Expanded(child: Text("Sistemde 'İkili Onay' ile gelen mühür kırma itirazlarını bu panelden yönetebilirsiniz.", style: TextStyle(color: adminPurple, fontSize: 10, fontWeight: FontWeight.bold, height: 1.5)))
                            ]
                        )
                    ),

                    GestureDetector(
                      onTap: () => _muhurKirmaTalebiIncele("SRV-2026-901", "HASSAS MOTOR REKTEFİYE", "GAZİ (34 DNA 2026)", "Müşterinin telefonu kapandığı için işlem iptali sisteme girilemedi. İşlem gerçekleşmedi, kaydın silinmesi talep ediliyor."),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: adminPurple.withOpacity(0.5))),
                        child: Row(
                          children: [
                            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: adminPurple.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.lock_clock, color: adminPurple)),
                            const SizedBox(width: 20),
                            const Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("İPTAL TALEBİ: SRV-2026-901", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                      SizedBox(height: 6),
                                      Text("İkili Onay Sağlandı: Müşteri & Firma", style: TextStyle(color: adminPurple, fontSize: 10, fontWeight: FontWeight.bold))
                                    ]
                                )
                            ),
                            const Icon(Icons.arrow_forward_ios, color: adminPurple, size: 16)
                          ],
                        ),
                      ),
                    )
                  ],
                ),

                // =========================================================
                // 3. SEKME: S.O.S RADAR (81 İL CANLI TAKİP)
                // =========================================================
                ListView(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Container(
                      height: 220, width: double.infinity,
                      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: dangerColor.withOpacity(0.5))),
                      child: Stack(
                        children: [
                          // Gerçek harita gelene kadar Siber Radar görünümü
                          Center(child: Icon(Icons.radar, color: dangerColor.withOpacity(0.1), size: 120)),
                          const Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.satellite_alt, color: dangerColor, size: 40),
                                    SizedBox(height: 12),
                                    Text("TÜRKİYE S.O.S AĞI AKTİF", style: TextStyle(color: dangerColor, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 3))
                                  ]
                              )
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSosSatiri("34 DNA 2026 (GAZİ)", "ANKARA / ÇANKAYA", "ÇEKİCİ YÖNLENDİRİLDİ", warningColor),
                    _buildSosSatiri("06 ABC 123 (AHMET)", "İSTANBUL / ŞİŞLİ", "KARARGAH MÜDAHALESİ BEKLİYOR!", dangerColor),
                  ],
                ),

                // =========================================================
                // 4. SEKME: KARA LİSTE VE FİRMA DENETİMİ
                // =========================================================
                ListView(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const Text("SİBER İHLAL YAPAN FİRMALAR", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 16),
                    _buildKaraListeKarti("KORSAN GÖSTERGE VE ELEKTRONİK", "İSKİTLER / ANKARA", "3 ŞİKAYET: KİLOMETRE DÜŞÜRME ŞÜPHESİ"),
                    _buildKaraListeKarti("STANDART KAPORTA BOYA", "OSTİM / ANKARA", "SİSTEMATİK SLA İHLALİ (RANDEVU İPTALİ)"),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: FİNANS KARTI
  Widget _buildFinansKarti(String baslik, String tutar, Color renk, IconData ikon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: renk.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: renk, size: 28),
          const SizedBox(height: 16),
          Text(tutar, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(baslik, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold, height: 1.5, letterSpacing: 1)),
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: İŞLEM SATIRI
  Widget _buildIslemSatiri(String islem, String detay, String kazanc, Color renk) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(islem, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
                    const SizedBox(height: 6),
                    Text(detay, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1))
                  ]
              )
          ),
          Text(kazanc, style: TextStyle(color: renk, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: S.O.S RADAR SATIRI
  Widget _buildSosSatiri(String plaka, String konum, String durum, Color renk) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: renk.withOpacity(0.5))),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: renk, size: 28),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plaka, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    Text(konum, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1))
                  ]
              )
          ),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: renk.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(durum, style: TextStyle(color: renk, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1))
          ),
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: KARA LİSTE KARTI
  Widget _buildKaraListeKarti(String firma, String konum, String sebep) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: dangerColor.withOpacity(0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(firma, style: const TextStyle(color: dangerColor, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5))),
                const Icon(Icons.block, color: dangerColor, size: 20)
              ]
          ),
          const SizedBox(height: 8),
          Text(konum, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          Text("SİBER İHLAL: $sebep", style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () {}, child: const Text("UYARI SİNYALİ", style: TextStyle(color: warningColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))),
              const SizedBox(width: 16),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: dangerColor, foregroundColor: Colors.black, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () {},
                  child: const Text("SİSTEMDEN MEN ET", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))
              ),
            ],
          )
        ],
      ),
    );
  }
}