import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BildirimDetayScreen extends ConsumerStatefulWidget {
  const BildirimDetayScreen({super.key});

  @override
  ConsumerState<BildirimDetayScreen> createState() => _BildirimDetayScreenState();
}

class _BildirimDetayScreenState extends ConsumerState<BildirimDetayScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  final Color bgColor = const Color(0xFF000000);
  final Color primaryCyan = const Color(0xFF00FFC2);
  final Color alertRed = Colors.redAccent;
  final Color surfaceColor = const Color(0xFF111111);

  bool _isBlocked = false;

  void _hizliYanitGonder(String yanit) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: primaryCyan,
        content: Text(
          '"$yanit" mesajı ağ üzerinden karşı tarafa iletildi. 🦅',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
    );
    // Yönlendirmeyi kaldırdım çünkü Web panelindeyiz, anında kapanmasın
  }

  void _kullaniciyiEngelle() {
    setState(() => _isBlocked = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('İHLAL TESPİT EDİLDİ: Bu IP ve cihaz sistem tarafından kalıcı olarak ağdan engellendi.', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Web uyumluluğu için ekran genişliğini alıyoruz
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(
          'A C İ L   D U R U M   B İ L D İ R İ M İ',
          style: TextStyle(color: alertRed, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 3),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: isDesktop
              ? Row( // 💻 MASAÜSTÜ (WEB) GÖRÜNÜMÜ: Yan Yana İki Panel
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _buildSolPanel()),
              const SizedBox(width: 40),
              Expanded(flex: 4, child: _buildSagPanel()),
            ],
          )
              : SingleChildScrollView( // 📱 MOBİL GÖRÜNÜM: Alt Alta Liste
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSolPanel(),
                const SizedBox(height: 32),
                _buildSagPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =================================================================
  // SOL PANEL (DURUM VE İSTİHBARAT LOGLARI)
  // =================================================================
  Widget _buildSolPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAlertCard(),
        const SizedBox(height: 32),
        _buildSenderInfoPanel(),
      ],
    );
  }

  // =================================================================
  // SAĞ PANEL (AKSİYONLAR VE SAVUNMA)
  // =================================================================
  Widget _buildSagPanel() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('HIZLI YANIT PROTOKOLÜ', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 24),
          _buildActionCard(title: '5 DAKİKAYA GELİYORUM', icon: Icons.timer_outlined, color: primaryCyan, onTap: () => _hizliYanitGonder('5 Dakikaya Geliyorum, lütfen bekleyin.')),
          const SizedBox(height: 16),
          _buildActionCard(title: 'ARACIN BAŞINDAN AYRILMAYIN', icon: Icons.directions_run, color: primaryCyan, onTap: () => _hizliYanitGonder('Aracın başından ayrılmayın, hemen geliyorum.')),
          const SizedBox(height: 16),
          _buildActionCard(title: 'ÇEKİCİ / POLİS ÇAĞIRILDI', icon: Icons.local_police_outlined, color: Colors.orangeAccent, onTap: () => _hizliYanitGonder('İlgili birimler yönlendirildi.')),

          const SizedBox(height: 40),
          const Divider(color: Colors.white12),
          const SizedBox(height: 40),

          const Text('SİBER SAVUNMA', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 16),
          SizedBox(
            height: 64,
            child: ElevatedButton.icon(
              onPressed: _isBlocked ? null : _kullaniciyiEngelle,
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                disabledBackgroundColor: bgColor,
                side: BorderSide(color: _isBlocked ? Colors.white12 : alertRed.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: Icon(_isBlocked ? Icons.block : Icons.security, color: _isBlocked ? Colors.white38 : alertRed),
              label: Text(
                _isBlocked ? 'BU CİHAZ AĞDAN ENGELLENDİ' : 'RAHATSIZ EDİCİ BİLDİRİM (ENGELLE)',
                style: TextStyle(color: _isBlocked ? Colors.white38 : alertRed, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: KIRMIZI UYARI KARTI
  Widget _buildAlertCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: alertRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: alertRed.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: alertRed.withOpacity(0.1), blurRadius: 40)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: alertRed.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.local_parking_rounded, color: alertRed, size: 32)),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HATALI PARK BİLDİRİMİ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    SizedBox(height: 4),
                    Text('Sivil İstihbarat Ağı Üzerinden Gelen Bildirim', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: Colors.white12)),
          const Text('06 OTO *** plakalı aracınız için bir vatandaş acil durum/hatalı park bildirimi fırlattı. Karşı tarafın kimliği güvenlik amacıyla gizlidir ancak IP logları sistemimize mühürlenmiştir.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6)),
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: GÖNDERİCİ IP LOGLARI
  Widget _buildSenderInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.radar, color: primaryCyan, size: 20),
              const SizedBox(width: 12),
              const Text('GÖNDERİCİ LOG BİLGİLERİ', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow('IP ADRESİ', '192.168.***.*** (Kayıt Altında)', Icons.wifi_tethering),
          _buildInfoRow('CİHAZ KİMLİĞİ', 'OtoDNA_Device_#8492', Icons.memory),
          _buildInfoRow('GPS KONUMU', 'Gölbaşı, Ankara (±10m)', Icons.location_on_outlined),
          _buildInfoRow('TARİH / SAAT', 'Bugün, 21:05', Icons.access_time),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.white24, size: 16),
          const SizedBox(width: 12),
          SizedBox(width: 120, child: Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'monospace', letterSpacing: 1))),
        ],
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: YANIT BUTONU
  Widget _buildActionCard({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1))),
            Icon(Icons.send_rounded, color: color.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }
}