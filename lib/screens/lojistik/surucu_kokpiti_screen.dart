import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      content: Text(mesaj, style: TextStyle(color: renk, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(side: BorderSide(color: renk), borderRadius: BorderRadius.circular(8)),
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
    _siberUyari("✅ GÖREV KABUL EDİLDİ! Navigasyon Başlıyor...", Colors.greenAccent);
  }

  void _cagriReddet() {
    setState(() {
      _cagriVar = false;
      _kuantumPuani -= 5; // CEZA: 5 Puan silinir
    });
    HapticFeedback.heavyImpact();
    _siberUyari("❌ GÖREV REDDEDİLDİ! Kuantum Puanınızdan -5 silindi.", SiberTema.kanKirmizi);
  }

  // ── DURUM DEĞİŞTİRİCİ ──
  void _durumDegistir(String yeniDurum) {
    if (_cagriVar && yeniDurum != "DOLU") {
      _siberUyari("Önce mevcut çağrıyı yanıtlamalısınız!", SiberTema.kanKirmizi);
      return;
    }
    setState(() => _anlikDurum = yeniDurum);
    HapticFeedback.selectionClick();
    _siberUyari("Durumunuz '$yeniDurum' olarak güncellendi.", SiberTema.kuantumCyan);
  }

  @override
  Widget build(BuildContext context) {
    bool isVIP = _kuantumPuani >= 95;
    Color anaRenk = isVIP ? SiberTema.sariAltin : SiberTema.kuantumCyan;

    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.8),
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: SiberTema.kuantumCyan, size: 20), onPressed: () => Navigator.pop(context)),
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
        color: Colors.black,
        border: Border(bottom: BorderSide(color: anaRenk, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SİBER KARİYER PUANI", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text("$_kuantumPuani", style: TextStyle(color: anaRenk, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2)),
                    const Text(" / 100", style: TextStyle(color: Colors.white38, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                if (isVIP)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: SiberTema.sariAltin.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: const Text("🔥 VIP ALTIN STATÜSÜ", style: TextStyle(color: SiberTema.sariAltin, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),

                // ADLİ BİLİŞİM (GÜNLÜK ÖZET LOGLARI)
                const Text("ADLİ İSTİHBARAT LOGU (BUGÜN)", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.people, color: Colors.white54, size: 14),
                    SizedBox(width: 4),
                    Text("12 Yolcu", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    SizedBox(width: 16),
                    Icon(Icons.speed, color: Colors.white54, size: 14),
                    SizedBox(width: 4),
                    Text("140 KM", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    SizedBox(width: 16),
                    Icon(Icons.account_balance_wallet, color: SiberTema.kuantumCyan, size: 14),
                    SizedBox(width: 4),
                    Text("₺3,500", style: TextStyle(color: SiberTema.kuantumCyan, fontSize: 12, fontWeight: FontWeight.bold)),
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
                child: CircularProgressIndicator(value: 0.75, backgroundColor: Colors.white12, color: anaRenk, strokeWidth: 6),
              ),
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("GÜNLÜK", style: TextStyle(color: Colors.white54, fontSize: 8, fontWeight: FontWeight.bold)),
                  Text("12 İş", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
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
          Expanded(child: _buildDurumButonu("BOŞTA", SiberTema.kuantumCyan, Icons.radar)),
          const SizedBox(width: 8),
          Expanded(child: _buildDurumButonu("DOLU", SiberTema.sariAltin, Icons.directions_car)),
          const SizedBox(width: 8),
          Expanded(child: _buildDurumButonu("SERVİS DIŞI", SiberTema.matGrey, Icons.power_settings_new)),
        ],
      ),
    );
  }

  Widget _buildDurumButonu(String durum, Color renk, IconData ikon) {
    bool aktif = _anlikDurum == durum;
    Color buttonColor = aktif ? renk : Colors.black45;
    Color textColor = aktif ? (durum == "SERVİS DIŞI" ? Colors.white : Colors.black) : Colors.white54;

    return GestureDetector(
      onTap: () => _durumDegistir(durum),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: aktif ? renk : Colors.white12),
          boxShadow: aktif && durum != "SERVİS DIŞI" ? [BoxShadow(color: renk.withOpacity(0.3), blurRadius: 15)] : [],
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
          color: SiberTema.matGrey,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: SiberTema.kanKirmizi, width: 2),
          boxShadow: [
            BoxShadow(color: SiberTema.kanKirmizi.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cell_tower, color: SiberTema.kanKirmizi, size: 48),
            const SizedBox(height: 16),
            const Text("YENİ ÇIĞIR TALEBİ!", style: TextStyle(color: SiberTema.kanKirmizi, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
            const SizedBox(height: 8),
            const Text("Müşteri: Gazi Y*** (Siber Puan: 1500)\nRota: Maslak -> Kadıköy (8.5 KM)\nNET KAZANÇ: ₺196.00", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _cagriReddet,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: SiberTema.kanKirmizi, side: const BorderSide(color: SiberTema.kanKirmizi), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text("REDDET (-5 PUAN)", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _cagriKabulEt,
                    style: ElevatedButton.styleFrom(backgroundColor: SiberTema.kuantumCyan, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16)),
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
          color: _anlikDurum == "SERVİS DIŞI" ? Colors.white24 : SiberTema.kuantumCyan.withOpacity(0.5), 
          size: 80
        ),
        const SizedBox(height: 24),
        Text(
          _anlikDurum == "SERVİS DIŞI" ? "PAYDOS MODU AKTİF" : (_anlikDurum == "DOLU" ? "MÜŞTERİ YOLCULUĞU SÜRÜYOR" : "BÖLGESEL RADAR DİNLENİYOR..."), 
          style: TextStyle(color: _anlikDurum == "SERVİS DIŞI" ? Colors.white38 : Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)
        ),
        const SizedBox(height: 8),
        Text(
          _anlikDurum == "SERVİS DIŞI" ? "Bu modda çağrı almaz ve puan kaybetmezsiniz." : "Sinyal yakalandığında ekran uyanacaktır.", 
          style: const TextStyle(color: Colors.white38, fontSize: 11)
        ),

        const Spacer(),
        
        // KÖR NOKTA (TACİZ KALKANI) AYARLARI
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: InkWell(
            onTap: () => _siberUyari("Kör Nokta Paneli Açılıyor... Bloklu müşteriler düzenlenebilir.", SiberTema.kanKirmizi),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
              child: const Row(
                children: [
                  Icon(Icons.block, color: SiberTema.kanKirmizi, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Kör Nokta Yönetimi (Taciz Kalkanı)", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text("Size çağrı atmasını engellediğiniz müşteriler.", style: TextStyle(color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14)
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
