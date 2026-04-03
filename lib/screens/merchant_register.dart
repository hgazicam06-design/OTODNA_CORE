import 'package:flutter/material.dart';

class MerchantRegister extends StatefulWidget {
  const MerchantRegister({super.key});

  @override
  State<MerchantRegister> createState() => _MerchantRegisterState();
}

class _MerchantRegisterState extends State<MerchantRegister> {
  // 🌑 TESLA MİMARİSİ: OLED SİYAH PALET
  static const Color bgColor = Color(0xFF000000);
  static const Color surfaceColor = Color(0xFF111111);
  static const Color primaryCyan = Color(0xFF00FFC2);
  static const Color dangerColor = Colors.redAccent;

  bool _isUploadingVergi = false;
  bool _isUploadingRuhsat = false;
  bool _vergiYuklendi = false;
  bool _ruhsatYuklendi = false;

  // 🚀 FİREBASE: SİBER EVRAK YÜKLEME MOTORU (Simülasyon)
  Future<void> _evrakYukle(String belgeTuru) async {
    if (belgeTuru == 'VERGİ') setState(() => _isUploadingVergi = true);
    if (belgeTuru == 'RUHSAT') setState(() => _isUploadingRuhsat = true);

    // TODO: Gerçekte file_picker ve Firebase Storage uploadTask çalışacak
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (belgeTuru == 'VERGİ') {
      setState(() { _isUploadingVergi = false; _vergiYuklendi = true; });
    } else {
      setState(() { _isUploadingRuhsat = false; _ruhsatYuklendi = true; });
    }

    _uyariGoster("$belgeTuru LEVHASI KUANTUM AĞINA MÜHÜRLENDİ! 🦅");
  }

  void _uyariGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mesaj, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1)), backgroundColor: primaryCyan),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: primaryCyan, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("ESNAF KAYIT TERMİNALİ", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600), // 🖥️ Web & Teyp Kalkanı
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 🛡️ SİBER BİLGİLENDİRME PANELİ
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: primaryCyan.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryCyan.withOpacity(0.3), width: 1.5)),
                    child: Column(
                      children: [
                        const Icon(Icons.domain_verification, color: primaryCyan, size: 48),
                        const SizedBox(height: 16),
                        const Text("ANKARA MERKEZ ONAYI", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        const SizedBox(height: 8),
                        Text("Sisteme yüklenen tüm evraklar Kuantum Ağı üzerinden şifrelenerek Ankara Karargahına iletilir. Onay süreci maksimum 24 saat sürmektedir.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.bold, height: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 📄 1. VERGİ LEVHASI YÜKLEME MODÜLÜ
                  _buildYuklemeKarti(
                    title: "VERGİ LEVHASI (PDF/JPG)",
                    icon: Icons.account_balance_outlined,
                    isUploading: _isUploadingVergi,
                    isUploaded: _vergiYuklendi,
                    onTap: () => _evrakYukle('VERGİ'),
                  ),
                  const SizedBox(height: 24),

                  // 📄 2. İŞLETME RUHSATI YÜKLEME MODÜLÜ
                  _buildYuklemeKarti(
                    title: "İŞLETME RUHSATI (PDF/JPG)",
                    icon: Icons.store_mall_directory_outlined,
                    isUploading: _isUploadingRuhsat,
                    isUploaded: _ruhsatYuklendi,
                    onTap: () => _evrakYukle('RUHSAT'),
                  ),
                  const SizedBox(height: 48),

                  // 🚀 ATEŞLEME BUTONU (Sadece ikisi de yüklendiyse aktif olur)
                  SizedBox(
                    height: 64,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryCyan,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        disabledBackgroundColor: primaryCyan.withOpacity(0.2),
                      ),
                      onPressed: (_vergiYuklendi && _ruhsatYuklendi) ? () {
                        // TODO: Firebase Başvuru Gönderme Motoru
                        _uyariGoster("TÜM EVRAKLAR ANKARA KARARGAHINA GÖNDERİLDİ! 🚀");
                      } : null,
                      icon: const Icon(Icons.rocket_launch, size: 24),
                      label: Text(
                        (_vergiYuklendi && _ruhsatYuklendi) ? "BAŞVURUYU TAMAMLA" : "EVRAKLARIN YÜKLENMESİ BEKLENİYOR",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 💎 YARDIMCI BİLEŞEN: SİBER YÜKLEME KARTI
  Widget _buildYuklemeKarti({required String title, required IconData icon, required bool isUploading, required bool isUploaded, required VoidCallback onTap}) {
    Color kartRengi = isUploaded ? primaryCyan : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isUploaded ? primaryCyan.withOpacity(0.5) : Colors.white.withOpacity(0.05), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: (isUploading || isUploaded) ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: kartRengi.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(isUploaded ? Icons.verified : icon, color: kartRengi, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: kartRengi, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(isUploaded ? "SİSTEME MÜHÜRLENDİ" : "DOKÜMAN SEÇİNİZ", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                ),
                if (isUploading)
                  const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: primaryCyan, strokeWidth: 2))
                else if (!isUploaded)
                  const Icon(Icons.upload_file, color: Colors.white38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}