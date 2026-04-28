import 'package:otodna/core/siber_tema.dart';
import 'package:flutter/material.dart';

class KurumsalBaglayicilarScreen extends StatefulWidget {
  KurumsalBaglayicilarScreen({super.key});

  @override
  State<KurumsalBaglayicilarScreen> createState() => _KurumsalBaglayicilarScreenState();
}

class _KurumsalBaglayicilarScreenState extends State<KurumsalBaglayicilarScreen> {
  // Entegrasyon Durumları (Simülasyon)
  bool _driveBagli = false;
  bool _calendarBagli = true; // Örnek olarak Takvim bağlı gelsin
  bool _gmailBagli = false;
  bool _jiraBagli = false;

  // 🔐 OAUTH 2.0 SİMÜLASYONU
  void _entegrasyonTetikle(String servisAdi, bool mevcutDurum, Function(bool) onUpdate) {
    if (mevcutDurum) {
      // Bağlantıyı Kes
      onUpdate(false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$servisAdi bağlantısı ağdan koparıldı.", style: TextStyle(color: SiberTema.textMain)), backgroundColor: Colors.redAccent));
      return;
    }

    // Bağlantı Kurma Animasyonu
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            CircularProgressIndicator(color: Color(0xFF00FFC2)),
            SizedBox(height: 24),
            Text("$servisAdi Enterprise API'si Bekleniyor...", style: TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontSize: 13)),
            SizedBox(height: 8),
            Text("Gemini OAuth 2.0 Anahtarı Doğrulanıyor", style: TextStyle(color: SiberTema.textMuted, fontSize: 11)),
            SizedBox(height: 16),
          ],
        ),
      ),
    );

    // 2 Saniye Sonra Başarılı Bağlantı
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context); // Yükleniyor ekranını kapat
      onUpdate(true); // Switch'i aktif et
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$servisAdi Kuantum Ağına Başarıyla Mühürlendi! 🦅", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: Color(0xFF00FFC2)));
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🌑 TESLA / APPLE ULTRA-MİNİMALİST PALET
    const bgColor = Color(0xFF000000);
    const surfaceColor = Color(0xFF111111);
    const accentColor = Colors.white;
    const textMuted = Colors.white54;
    const primaryCyan = Color(0xFF00FFC2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: accentColor, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('E N T E R P R I S E', style: TextStyle(color: accentColor, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 6)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================================================
            // BÜYÜK BAŞLIK VE AÇIKLAMA
            // =========================================================
            Text("Bağlayıcılar", style: TextStyle(color: accentColor, fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -1)),
            SizedBox(height: 8),
            Text("OtoDNA ağını Google Workspace ve harici kurumsal API'ler ile senkronize edin. Tüm veri akışı uçtan uca şifrelenir.", style: TextStyle(color: textMuted, fontSize: 13, height: 1.5)),
            SizedBox(height: 40),

            // =========================================================
            // 1. GOOGLE DRIVE (Belge Arşivi)
            // =========================================================
            _buildConnectorCard(
              servisAdi: "Google Drive",
              aciklama: "Ekspertiz raporlarını ve araç sicil belgelerini (PDF) güvenli bulut klasörlerine otomatik yedekler.",
              ikon: Icons.cloud_outlined,
              ikonRengi: Colors.blueAccent,
              bagliMi: _driveBagli,
              onToggle: () => _entegrasyonTetikle("Google Drive", _driveBagli, (val) => setState(() => _driveBagli = val)),
              surfaceColor: surfaceColor,
              primaryCyan: primaryCyan,
            ),
            SizedBox(height: 16),

            // =========================================================
            // 2. GOOGLE CALENDAR (Takvim)
            // =========================================================
            _buildConnectorCard(
              servisAdi: "Google Calendar",
              aciklama: "Periyodik bakım ve TÜVTÜRK randevularını bayilerin ve müşterilerin akıllı takvimlerine işler.",
              ikon: Icons.calendar_month_outlined,
              ikonRengi: Colors.orangeAccent,
              bagliMi: _calendarBagli,
              onToggle: () => _entegrasyonTetikle("Google Calendar", _calendarBagli, (val) => setState(() => _calendarBagli = val)),
              surfaceColor: surfaceColor,
              primaryCyan: primaryCyan,
            ),
            SizedBox(height: 16),

            // =========================================================
            // 3. GMAIL ENTERPRISE (Resmi Evrak)
            // =========================================================
            _buildConnectorCard(
              servisAdi: "Gmail Entegrasyonu",
              aciklama: "Araç alım-satım sözleşmelerini ve Iyzico dijital dekontlarını resmi ağ üzerinden taraflara iletir.",
              ikon: Icons.mail_outline,
              ikonRengi: Colors.redAccent,
              bagliMi: _gmailBagli,
              onToggle: () => _entegrasyonTetikle("Gmail Entegrasyonu", _gmailBagli, (val) => setState(() => _gmailBagli = val)),
              surfaceColor: surfaceColor,
              primaryCyan: primaryCyan,
            ),
            SizedBox(height: 16),

            // =========================================================
            // 4. JIRA / HUBSPOT (İş Takibi)
            // =========================================================
            _buildConnectorCard(
              servisAdi: "Jira / İş Takibi",
              aciklama: "Bayilerdeki açık servis kayıtlarını ve usta görevlerini B2B proje yönetimi paneline aktarır.",
              ikon: Icons.integration_instructions_outlined,
              ikonRengi: Colors.blueGrey,
              bagliMi: _jiraBagli,
              onToggle: () => _entegrasyonTetikle("Jira İş Takibi", _jiraBagli, (val) => setState(() => _jiraBagli = val)),
              surfaceColor: surfaceColor,
              primaryCyan: primaryCyan,
            ),

            SizedBox(height: 48),

            // =========================================================
            // GÜVENLİK MÜHRÜ
            // =========================================================
            Center(
              child: Column(
                children: [
                  Icon(Icons.gpp_good_outlined, color: Colors.white.withOpacity(0.2), size: 32),
                  SizedBox(height: 12),
                  Text("Gemini AI API altyapısı ile korunmaktadır.", style: TextStyle(color: SiberTema.textMain.withOpacity(0.3), fontSize: 11)),
                ],
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 💎 TESLA MİMARİSİ: BAĞLAYICI (CONNECTOR) KARTI
  Widget _buildConnectorCard({required String servisAdi, required String aciklama, required IconData ikon, required Color ikonRengi, required bool bagliMi, required VoidCallback onToggle, required Color surfaceColor, required Color primaryCyan}) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bagliMi ? primaryCyan.withOpacity(0.3) : Colors.transparent, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ikon, color: bagliMi ? primaryCyan : ikonRengi, size: 28),
              SizedBox(width: 16),
              Expanded(
                child: Text(servisAdi, style: TextStyle(color: bagliMi ? primaryCyan : Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
              // TESLA STİLİ ZARİF BAĞLANTI BUTONU
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                      color: bagliMi ? primaryCyan.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: bagliMi ? primaryCyan.withOpacity(0.5) : Colors.white12)
                  ),
                  child: Text(
                    bagliMi ? "Bağlı" : "Bağla",
                    style: TextStyle(color: bagliMi ? primaryCyan : Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 12),
          Text(aciklama, style: TextStyle(color: SiberTema.textMuted, fontSize: 12, height: 1.5)),
        ],
      ),
    );
  }
}