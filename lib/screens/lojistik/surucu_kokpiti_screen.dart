import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/siber_tema.dart';
import '../../core/responsive_kalkan.dart';
import '../../widgets/siber_rehber_dialog.dart';

/// 🚖 OTODNA SÜRÜCÜ KOKPİTİ (Taksici / Servis Şoförü Ekranı)
/// Şoförün canlı durumunu (Boşta/Dolu) yönettiği, çağrıları karşıladığı ve
/// Kuantum Puanını (Ceza/Ödül) takip ettiği ana radar.
class SurucuKokpitiScreen extends StatefulWidget {
  const SurucuKokpitiScreen({super.key});

  @override
  State<SurucuKokpitiScreen> createState() => _SurucuKokpitiScreenState();
}

class _SurucuKokpitiScreenState extends State<SurucuKokpitiScreen> {
  // 🏢 FİLDİŞİ SEDEF PALET
  final Color bgColor = const Color(0xFFFDFBF7);
  final Color surfaceColor = Colors.white;
  final Color primaryTeal = Colors.teal.shade700;
  final Color textMain = const Color(0xFF1E293B);
  final Color textMuted = const Color(0xFF64748B);
  final Color accentGold = Colors.amber.shade700;
  final Color dangerColor = SiberTema.kanKirmizi;

  int _kuantumPuani = 98; // 100 üzerinden başlar
  String _anlikDurum = "BOŞTA"; // BOŞTA, DOLU, SERVIS_DISI
  bool _cagriVar = false; // Simülasyon için çağrı durumu
  bool _islemSuruyor = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rehberiGoster(otomatik: true);
    });

    // Simülasyon: 5 saniye sonra ekrana çağrı düşür
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _anlikDurum == "BOŞTA") {
        setState(() => _cagriVar = true);
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _rehberiGoster({bool otomatik = false}) {
    const String baslik = "OTODNA SÜRÜCÜ KOKPİTİ";
    const String icerik = "Şoför Karargahına Hoş Geldiniz.\n\n"
        "Burası sizin çalışma merkezinizdir. Durumunuzu 'Boşta' yaptığınız an 10 km çapındaki müşteriler sizi görür ve çağrı ('Çığır') atabilir.\n\n"
        "DİKKAT: 'Boşta' iken gelen çağrıyı reddetmek size Kuantum Puanı kaybettirir (-1, -5, -10 katlamalı). Eğer mola verecekseniz mutlaka 'Servis Dışı' moduna geçiniz. Puanı 95'i geçen şoförler haritada VIP olarak görünür ve daha fazla kazanır!";

    if (otomatik) {
      SiberRehber.otomatikGoster(context: context, screenKey: 'surucu_kokpiti_rehber', baslik: baslik, icerik: icerik);
    } else {
      SiberRehber.goster(context: context, screenKey: 'surucu_kokpiti_rehber', baslik: baslik, icerik: icerik);
    }
  }

  void _siberUyari(String mesaj, Color renk) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mesaj, style: const TextStyle(color: SiberTema.textMain, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: renk,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── ÇAĞRI AKSİYONLARI ──
  void _cagriKabulEt() {
    setState(() {
      _cagriVar = false;
      _anlikDurum = "DOLU"; // Yolcu alındı
      _kuantumPuani += 1; // Küçük sadakat ödülü
    });
    HapticFeedback.vibrate();
    _siberUyari("✅ GÖREV KABUL EDİLDİ! Navigasyon Başlıyor...", primaryTeal);
  }

  void _cagriReddet() {
    setState(() {
      _cagriVar = false;
      _kuantumPuani -= 5; // CEZA: 5 Puan silinir
    });
    HapticFeedback.heavyImpact();
    _siberUyari("❌ GÖREV REDDEDİLDİ! Kuantum Puanınızdan -5 silindi.", dangerColor);
  }

  // ── DURUM DEĞİŞTİRİCİ ──
  void _durumDegistir(String yeniDurum) {
    if (_cagriVar && yeniDurum != "DOLU") {
      _siberUyari("Önce mevcut çağrıyı yanıtlamalısınız!", dangerColor);
      return;
    }
    setState(() => _anlikDurum = yeniDurum);
    HapticFeedback.selectionClick();
    _siberUyari("Durumunuz '$yeniDurum' olarak güncellendi.", primaryTeal);
  }

  @override
  Widget build(BuildContext context) {
    bool isVIP = _kuantumPuani >= 95;
    Color anaRenk = isVIP ? accentGold : primaryTeal;

    return ResponsiveKalkan(
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: anaRenk, size: 20), onPressed: () => context.pop()),
          title: Text(isVIP ? "VIP ŞOFÖR KOKPİTİ" : "ŞOFÖR KOKPİTİ", style: TextStyle(color: anaRenk, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2, fontFamily: 'Avenir')),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline_rounded, color: anaRenk),
              tooltip: "Siber Rehber",
              onPressed: () => _rehberiGoster(otomatik: false),
            )
          ],
        ),
        body: Column(
          children: [
            // ── ÜST KISIM: PUAN VE PERFORMANS ──
            _buildPerformansPaneli(anaRenk, isVIP),

            const SizedBox(height: 16),

            // ── ORTA KISIM: CANLI DURUM BUTONLARI ──
            _buildDurumKontrolPaneli(),

            // ── ALT KISIM: ÇAĞRI RADARI VE KÖR NOKTA ──
            Expanded(
              child: _cagriVar ? _buildCagriKarti() : _buildKaranlikGorevBeklemeEkran(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformansPaneli(Color anaRenk, bool isVIP) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: anaRenk, width: 2)),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("SİBER KARİYER PUANI", style: TextStyle(color: textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text("$_kuantumPuani", style: TextStyle(color: anaRenk, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2)),
                    Text(" / 100", style: TextStyle(color: textMuted.withOpacity(0.5), fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                if (isVIP)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: accentGold.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text("🔥 VIP ALTIN STATÜSÜ", style: TextStyle(color: accentGold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                
                const SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.05)),
                const SizedBox(height: 8),

                // ADLİ BİLİŞİM (GÜNLÜK ÖZET LOGLARI)
                Text("ADLİ İSTİHBARAT LOGU (BUGÜN)", style: TextStyle(color: textMuted.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people, color: textMuted, size: 14),
                    const SizedBox(width: 4),
                    Text("12 Yolcu", style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Icon(Icons.speed, color: textMuted, size: 14),
                    const SizedBox(width: 4),
                    Text("140 KM", style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Icon(Icons.account_balance_wallet, color: primaryTeal, size: 14),
                    const SizedBox(width: 4),
                    Text("₺3,500", style: TextStyle(color: primaryTeal, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          ),
          
          const SizedBox(width: 16),

          // GÜNLÜK HEDEF DAİRESİ
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80, height: 80,
                child: CircularProgressIndicator(value: 0.75, backgroundColor: Colors.black.withOpacity(0.05), color: anaRenk, strokeWidth: 6),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("GÜNLÜK", style: TextStyle(color: textMuted, fontSize: 8, fontWeight: FontWeight.bold)),
                  Text("12 İş", style: TextStyle(color: textMain, fontSize: 16, fontWeight: FontWeight.w900)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDurumKontrolPaneli() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _buildDurumButonu("BOŞTA", primaryTeal, Icons.radar)),
          const SizedBox(width: 8),
          Expanded(child: _buildDurumButonu("DOLU", accentGold, Icons.directions_car)),
          const SizedBox(width: 8),
          Expanded(child: _buildDurumButonu("SERVİS DIŞI", textMuted, Icons.power_settings_new)),
        ],
      ),
    );
  }

  Widget _buildDurumButonu(String durum, Color renk, IconData ikon) {
    bool aktif = _anlikDurum == durum;
    Color buttonColor = aktif ? renk : surfaceColor;
    Color textColor = aktif ? Colors.white : textMuted;

    return GestureDetector(
      onTap: () => _durumDegistir(durum),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: aktif ? renk : Colors.black.withOpacity(0.05)),
          boxShadow: aktif && durum != "SERVİS DIŞI" ? [BoxShadow(color: renk.withOpacity(0.3), blurRadius: 15)] : [BoxShadow(color: Colors.white.withOpacity(0.02), blurRadius: 5)],
        ),
        child: Column(
          children: [
            Icon(ikon, color: textColor, size: 24),
            const SizedBox(height: 8),
            Text(durum, style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildCagriKarti() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: dangerColor, width: 2),
          boxShadow: [
            BoxShadow(color: dangerColor.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cell_tower, color: dangerColor, size: 48),
            const SizedBox(height: 16),
            Text("YENİ ÇIĞIR TALEBİ!", style: TextStyle(color: dangerColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 8),
            Text("Müşteri: Gazi Y*** (Siber Puan: 1500)\nRota: Maslak -> Kadıköy (8.5 KM)\nNET KAZANÇ: ₺196.00", textAlign: TextAlign.center, style: TextStyle(color: textMain, fontSize: 14, height: 1.5, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _cagriReddet,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: dangerColor, side: BorderSide(color: dangerColor), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text("REDDET (-5 PUAN)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _cagriKabulEt,
                    style: ElevatedButton.styleFrom(backgroundColor: primaryTeal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text("KABUL ET & GİT", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildKaranlikGorevBeklemeEkran() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _anlikDurum == "SERVİS DIŞI" ? Icons.bedtime_rounded : Icons.radar_rounded, 
          color: _anlikDurum == "SERVİS DIŞI" ? textMuted.withOpacity(0.3) : primaryTeal.withOpacity(0.5), 
          size: 80
        ),
        const SizedBox(height: 24),
        Text(
          _anlikDurum == "SERVİS DIŞI" ? "PAYDOS MODU AKTİF" : (_anlikDurum == "DOLU" ? "MÜŞTERİ YOLCULUĞU SÜRÜYOR" : "BÖLGESEL RADAR DİNLENİYOR..."), 
          style: TextStyle(color: _anlikDurum == "SERVİS DIŞI" ? textMuted : textMain, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)
        ),
        const SizedBox(height: 8),
        Text(
          _anlikDurum == "SERVİS DIŞI" ? "Bu modda çağrı almaz ve puan kaybetmezsiniz." : "Sinyal yakalandığında ekran uyanacaktır.", 
          style: TextStyle(color: textMuted, fontSize: 11)
        ),

        const Spacer(),
        
        // KÖR NOKTA (TACİZ KALKANI) AYARLARI
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: InkWell(
            onTap: () => _siberUyari("Kör Nokta Paneli Açılıyor... Bloklu müşteriler düzenlenebilir.", dangerColor),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
              child: Row(
                children: [
                  Icon(Icons.block, color: dangerColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Kör Nokta Yönetimi (Taciz Kalkanı)", style: TextStyle(color: textMain, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text("Size çağrı atmasını engellediğiniz müşteriler.", style: TextStyle(color: textMuted, fontSize: 10)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: textMuted.withOpacity(0.5), size: 14)
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
