import 'package:flutter/material.dart';

// 💎 YARDIMCI BİLEŞEN: SİBER GÜVENLİK ONAY MODÜLÜ
class SiberOnayKutusu extends StatefulWidget {
  final Function(bool) onChanged;

  const SiberOnayKutusu({super.key, required this.onChanged});

  @override
  State<SiberOnayKutusu> createState() => _SiberOnayKutusuState();
}

class _SiberOnayKutusuState extends State<SiberOnayKutusu> {
  bool _onayliMi = false;
  final Color primaryCyan = const Color(0xFF00FFC2);
  final Color surfaceColor = const Color(0xFF111111);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _onayliMi = !_onayliMi);
        widget.onChanged(_onayliMi);
        if (_onayliMi) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Siber Güvenlik Protokolü Onaylandı. Ağa Bağlanıyor... 🚀', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                backgroundColor: primaryCyan,
                duration: const Duration(seconds: 1),
              )
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _onayliMi ? primaryCyan.withOpacity(0.05) : surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _onayliMi ? primaryCyan.withOpacity(0.5) : Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Siber Mühür (Kutu)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 24, height: 24,
              decoration: BoxDecoration(
                color: _onayliMi ? primaryCyan : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _onayliMi ? primaryCyan : Colors.white38, width: 2),
                boxShadow: _onayliMi ? [BoxShadow(color: primaryCyan.withOpacity(0.5), blurRadius: 10)] : [],
              ),
              child: _onayliMi ? const Icon(Icons.check, color: Colors.black, size: 16, weight: 900) : null,
            ),
            const SizedBox(width: 16),

            // Sözleşme Metni
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("OTODNA SİBER GÜVENLİK PROTOKOLÜ", style: TextStyle(color: _onayliMi ? primaryCyan : Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  const Text("Kuantum Ağı Veri Gizliliği Sözleşmesi'ni okudum, anladım ve aracıma ait dijital DNA'nın işlenmesini şifreli olarak onaylıyorum.", style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------------------
// EĞER SENİN DOSYANIN TAMAMI SADECE BİR CHECKBOXTAN İBARETSE (Ki sanmıyorum),
// BU DA O DOSYANIN (analysis_report.dart) TAM KULLANIMA HAZIR HALİ:
// -----------------------------------------------------------------------------------------

class AnalysisReportScreen extends StatefulWidget {
  const AnalysisReportScreen({super.key});

  @override
  State<AnalysisReportScreen> createState() => _AnalysisReportScreenState();
}

class _AnalysisReportScreenState extends State<AnalysisReportScreen> {
  final Color bgColor = const Color(0xFF000000);
  final Color primaryCyan = const Color(0xFF00FFC2);
  bool _sistemOnaylandi = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('A N A L İ Z   R A P O R U', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 3)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),

            // İşte o zırhladığımız onay modülü burada çağrılıyor:
            SiberOnayKutusu(
              onChanged: (val) {
                setState(() => _sistemOnaylandi = val);
              },
            ),

            const SizedBox(height: 24),

            // Onaylanmadan basılamayan İleri Butonu
            SizedBox(
              width: double.infinity, height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _sistemOnaylandi ? primaryCyan : Colors.white.withOpacity(0.05),
                  foregroundColor: _sistemOnaylandi ? Colors.black : Colors.white38,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _sistemOnaylandi ? () {
                  // İŞLEMİ BAŞLAT
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ağa Bağlanıyor...")));
                } : null, // Onay yoksa buton ölüdür!
                icon: Icon(_sistemOnaylandi ? Icons.lock_open : Icons.lock_outline, size: 24),
                label: Text(_sistemOnaylandi ? "SİSTEME GİRİŞ YAP" : "ÖNCE PROTOKOLÜ ONAYLAYIN", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}