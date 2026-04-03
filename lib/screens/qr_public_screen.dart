import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Saat ve tarih formatı için

class QrPublicScreen extends StatefulWidget {
  final String vehicleId; // Firebase'deki araç ID'si veya Plaka

  const QrPublicScreen({super.key, required this.vehicleId});

  @override
  State<QrPublicScreen> createState() => _QrPublicScreenState();
}

class _QrPublicScreenState extends State<QrPublicScreen> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _selectedOption = '';
  bool _shareLocation = true;
  bool _isProcessing = false;

  // SİBER ENGEL (Anti-Spam) KONTROLLERİ
  bool _isBlocked = false;
  int _spamSayaci = 0;

  @override
  void initState() {
    super.initState();
    // Ekran açılır açılmaz (Adam QR'ı okuttuğu saniye) sessiz istihbarat sinyalini ateşle!
    _sessizSinyalFirlat();
  }

  // 🕵️‍♂️ GİZLİ MOTOR: QR OKUTULDUĞU AN ÇALIŞAN SESSİZ SİNYAL
  Future<void> _sessizSinyalFirlat() async {
    try {
      var aracSorgu = await _db.collection('araclar').where('plaka', isEqualTo: widget.vehicleId).limit(1).get();
      if (aracSorgu.docs.isEmpty) return;

      String sahipId = aracSorgu.docs.first.data()['sahip_id'];
      String anlikSaat = DateFormat('HH:mm:ss').format(DateTime.now());

      // TODO: İleride gerçek GPS koordinatı çekilecek. Şimdilik simüle ediyoruz.
      String anlikKonum = "Çankaya, Ankara";

      // Sahibe sessizce arka plan bildirimi (Log) atılır
      await _db.collection('kullanicilar').doc(sahipId).collection('bildirimler').add({
        'baslik': '👁️ SESSİZ İSTİHBARAT: QR TARANDI!',
        'mesaj': 'Aracınızın (${widget.vehicleId}) QR Kodu $anlikKonum adresinde, saat $anlikSaat itibariyle bir cihaz tarafından tarandı.',
        'tip': 'SISTEM',
        'okundu': false,
        'tarih': FieldValue.serverTimestamp(),
      });

      print("SİBER KOMUTA: Sessiz İstihbarat Sinyali Başarıyla Fırlatıldı.");
    } catch (e) {
      print("SİBER KOMUTA HATA: Sessiz Sinyal Başarısız.");
    }
  }

  // 🚀 FİREBASE: ANA SİNYAL FIRLATMA VE ANTİ-SPAM MOTORU
  Future<void> _sendNotification() async {
    if (_isBlocked) {
      _uyariGoster("SİBER ENGEL: Çok fazla istek attınız. Sisteme erişiminiz kilitlendi!", isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      var aracSorgu = await _db.collection('araclar').where('plaka', isEqualTo: widget.vehicleId).limit(1).get();

      if (aracSorgu.docs.isEmpty) {
        _uyariGoster("SİBER HATA: Araç Kuantum Ağında bulunamadı!", isError: true);
        setState(() => _isProcessing = false);
        return;
      }

      String sahipId = aracSorgu.docs.first.data()['sahip_id'];

      await _db.collection('kullanicilar').doc(sahipId).collection('bildirimler').add({
        'baslik': '🚨 $_selectedOption',
        'mesaj': 'Aracınız (${widget.vehicleId}) hakkında acil bildirim: ${_shareLocation ? "Konum Ekli" : "Konum Gizli"}',
        'tip': 'SOS',
        'okundu': false,
        'tarih': FieldValue.serverTimestamp(),
      });

      // ANTİ-SPAM SAYACINI ARTIR
      _spamSayaci++;
      if (_spamSayaci >= 2) {
        // İkinci kez bildirim atarsa cihazı bu ekran için kilitler!
        setState(() => _isBlocked = true);
      }

      if (!mounted) return;
      _uyariGoster("SİNYAL ARAÇ SAHİBİNE İLETİLDİ! 🦅");

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !_isBlocked) Navigator.pop(context); // Terminali kapat
      });

    } catch (e) {
      _uyariGoster("AĞ ÇÖKTÜ: Sinyal iletilemedi!", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _uyariGoster(String mesaj, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1)),
        backgroundColor: isError ? dangerColor : primaryCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("SİBER BİLDİRİM MERKEZİ", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // 🖥️ Web / Double Teyp Kalkanı
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. ARAÇ BİLGİ KARTI
                  _buildVehicleInfoCard(),
                  const SizedBox(height: 48),

                  // EĞER CİHAZ SPAM YAPMIŞ VE KİLİTLENMİŞSE EKRANI KIRMIZIYA BOYA
                  if (_isBlocked)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(color: dangerColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: dangerColor, width: 2)),
                      child: const Column(
                        children: [
                          Icon(Icons.block, color: dangerColor, size: 64),
                          SizedBox(height: 16),
                          Text("SİBER ENGEL DEVREDE", style: TextStyle(color: dangerColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
                          SizedBox(height: 8),
                          Text("Sistemi suistimal ettiğiniz tespit edildi. Bu araca daha fazla sinyal gönderemezsiniz.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  else ...[
                    // 2. NET VE HIZLI 3 SEÇENEK
                    const Text("SİNYAL TİPİNİ SEÇİN", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 24),

                    _buildOptionCard('HATALI PARK ETMİŞ', Icons.local_parking_rounded),
                    const SizedBox(height: 16),
                    _buildOptionCard('ARACA ÇARPTILAR (KAZA)', Icons.warning_rounded, isAlert: true),
                    const SizedBox(height: 16),
                    _buildOptionCard('GENEL BİLGİLENDİRME', Icons.notifications_active_rounded),

                    const SizedBox(height: 48),

                    // 3. KONUM İZNİ
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
                      child: Row(
                        children: [
                          Icon(Icons.radar, color: _shareLocation ? primaryCyan : Colors.white38, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("GPS SİNYALİ", style: TextStyle(color: _shareLocation ? Colors.white : Colors.white54, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
                                const SizedBox(height: 4),
                                Text("Güvenlik gereği konumunuz sahibine şifreli iletilir.", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Switch(
                            value: _shareLocation,
                            onChanged: (val) => setState(() => _shareLocation = val),
                            activeColor: primaryCyan,
                            activeTrackColor: primaryCyan.withOpacity(0.3),
                            inactiveTrackColor: Colors.white12,
                            inactiveThumbColor: Colors.white38,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 4. ATEŞLEME BUTONU
                    SizedBox(
                      height: 64,
                      child: ElevatedButton.icon(
                        onPressed: (_selectedOption.isNotEmpty && !_isProcessing) ? _sendNotification : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedOption == 'ARACA ÇARPTILAR (KAZA)' ? dangerColor : primaryCyan,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          disabledBackgroundColor: primaryCyan.withOpacity(0.2),
                        ),
                        icon: _isProcessing
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                            : const Icon(Icons.satellite_alt, size: 24),
                        label: Text(
                          _isProcessing ? "SİNYAL İLETİLİYOR..." : "BİLDİRİMİ FIRLAT",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SEÇİM BUTONLARI
  Widget _buildOptionCard(String title, IconData icon, {bool isAlert = false}) {
    final isSelected = _selectedOption == title;
    final activeColor = isAlert ? dangerColor : primaryCyan;

    return InkWell(
      onTap: () => setState(() => _selectedOption = title),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? activeColor : Colors.white12, width: 1.5),
          boxShadow: isSelected ? [BoxShadow(color: activeColor.withOpacity(0.2), blurRadius: 20)] : [],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? activeColor : Colors.white38, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: isSelected ? activeColor : Colors.white70, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
            ),
            if (isSelected)
              Icon(Icons.my_location, color: activeColor, size: 24),
          ],
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: ARAÇ BİLGİ KARTI
  Widget _buildVehicleInfoCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _isBlocked ? dangerColor.withOpacity(0.5) : primaryCyan.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: _isBlocked ? dangerColor.withOpacity(0.1) : primaryCyan.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _isBlocked ? dangerColor.withOpacity(0.1) : primaryCyan.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.directions_car, color: _isBlocked ? dangerColor : primaryCyan, size: 32),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("HEDEF ARAÇ", style: TextStyle(color: _isBlocked ? dangerColor : Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const SizedBox(height: 8),
                Text(widget.vehicleId.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}