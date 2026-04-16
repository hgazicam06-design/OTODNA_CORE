// lib/screens/kullanici/randevu_sistemi.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

// 🚀 KARARGAH ZIRHLARI VE MERKEZİ TEMA BAĞLANTISI (2 Kat Yukarı)
import '../../../../core/siber_tema.dart';
import '../../../../core/responsive_kalkan.dart';
import '../../../../core/otodna_hizmet_kutuphanesi.dart'; // 🧠 Kuantum Sözlük Bağlandı!

/// 🛡️ KUANTUM RANDEVU VE PLANLAMA MOTORU (SiberRandevuSistemi)
/// Müşterinin seçtiği hizmet ve zamanı doğrudan Karargaha (Firebase) mühürler.
class SiberRandevuSistemi extends StatefulWidget {
  final String musteriId; // Randevuyu alan müşterinin Karargah kimliği
  final String bayiId; // Randevu talep edilen bayinin kimliği

  const SiberRandevuSistemi({super.key, required this.musteriId, required this.bayiId});

  @override
  State<SiberRandevuSistemi> createState() => _SiberRandevuSistemiState();
}

class _SiberRandevuSistemiState extends State<SiberRandevuSistemi> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _notCtrl = TextEditingController();

  // ── SİBER PLANLAMA DEĞİŞKENLERİ ──
  DateTime? _secilenTarih;
  TimeOfDay? _secilenSaat;
  String? _secilenHizmet;
  bool _islemSuruyor = false;

  // 🔥 KUANTUM AĞA BAĞLANTI: Listeyi gerçek kütüphaneden çekiyoruz!
  final List<String> _hizmetListesi = SiberHizmetKutuphanesi.tumHizmetleriGetir();

  // ── 🚀 FİREBASE MÜHÜR MOTORU (ATOMİK ZIRHLI) ──
  Future<void> _randevuyuMuhurle() async {
    if (_secilenHizmet == null || _secilenTarih == null || _secilenSaat == null) {
      HapticFeedback.heavyImpact();
      _siberUyariGoster("SİBER İHLAL", "Hizmet, tarih ve saat seçimi zorunludur!", SiberTema.kanKirmizi);
      return;
    }

    if (_islemSuruyor) return;
    setState(() => _islemSuruyor = true);
    HapticFeedback.lightImpact();

    developer.log("🚀 SİBER PLANLAMA: Randevu talebi Karargaha iletiliyor...");

    try {
      // Tarih ve saati birleştir
      DateTime randevuZamani = DateTime(
        _secilenTarih!.year,
        _secilenTarih!.month,
        _secilenTarih!.day,
        _secilenSaat!.hour,
        _secilenSaat!.minute,
      );

      // 🛡️ ATOMİK ZIRH DEVREDE
      WriteBatch batch = _db.batch();

      DocumentReference randevuRef = _db.collection('randevular').doc();
      batch.set(randevuRef, {
        'musteri_id': widget.musteriId,
        'bayi_id': widget.bayiId,
        'hizmet_turu': _secilenHizmet,
        'randevu_tarihi': randevuZamani,
        'ariza_notu': _notCtrl.text.trim(),
        'durum': 'ONAY_BEKLIYOR',
        'olusturulma_tarihi': FieldValue.serverTimestamp(),
      });

      DocumentReference logRef = _db.collection('sistem_loglari').doc();
      batch.set(logRef, {
        'islem_turu': 'YENI_RANDEVU',
        'islem_detayi': 'SİBER PLANLAMA: ${widget.musteriId} kullanıcısı ${widget.bayiId} bayisinden $_secilenHizmet randevusu aldı.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      HapticFeedback.vibrate();
      developer.log("✅ RANDEVU MÜHÜRLENDİ: Talep bayinin radarına düştü.");

      if (mounted) {
        _siberUyariGoster("MÜHÜRLENDİ", "Randevunuz oluşturuldu. Bayi onayından sonra bildirim alacaksınız.", SiberTema.kuantumCyan);
        Navigator.pop(context); // İşlem bitince ekranı kapat
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      developer.log("🚨 AĞ ÇÖKTÜ: Randevu iletilemedi!", error: e);
      _siberUyariGoster("BAĞLANTI HATASI", "Randevu oluşturulamadı. Matrix'i kontrol edin.", SiberTema.kanKirmizi);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── ⏳ ZAMAN SEÇİCİLER (Siber Temalı) ──
  Future<void> _tarihSec(BuildContext context) async {
    final DateTime? secilen = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: SiberTema.kuantumCyan,
              onPrimary: SiberTema.oledBlack,
              surface: SiberTema.matGrey, // Takvim arka planı
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (secilen != null && secilen != _secilenTarih) {
      setState(() => _secilenTarih = secilen);
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _saatSec(BuildContext context) async {
    final TimeOfDay? secilen = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: SiberTema.kuantumCyan,
              surface: SiberTema.matGrey,
            ),
          ),
          child: child!,
        );
      },
    );
    if (secilen != null && secilen != _secilenSaat) {
      setState(() => _secilenSaat = secilen);
      HapticFeedback.selectionClick();
    }
  }

  // ── 🚨 ARAYÜZ YARDIMCILARI ──
  void _siberUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SiberTema.matGrey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text(mesaj, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveKalkan(
      isOledBackground: true,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Kalkan aydınlatması arkadan
        appBar: AppBar(
          title: const Text("SİBER PLANLAMA VE RANDEVU", style: TextStyle(color: SiberTema.kuantumCyan, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: SiberTema.kuantumCyan),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BİLGİ PANELİ
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: SiberTema.matGrey.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SiberTema.kuantumCyan.withOpacity(0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: SiberTema.kuantumCyan.withOpacity(0.05), blurRadius: 15, spreadRadius: 1)
                      ]
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.calendar_month_outlined, color: SiberTema.kuantumCyan, size: 28),
                      SizedBox(width: 12),
                      Expanded(child: Text("Siber ağ üzerinden randevunuzu mühürleyin. Ustanız sizin için hazırlık yapacaktır.", style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5, letterSpacing: 0.5, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 1. HİZMET SEÇİCİ
                const Text("1. İŞLEM TÜRÜ", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: SiberTema.matGrey.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: SiberTema.matGrey,
                      icon: const Icon(Icons.keyboard_arrow_down, color: SiberTema.kuantumCyan),
                      hint: const Text("Hizmet Branşını Seçin", style: TextStyle(color: Colors.white30, fontSize: 13, fontWeight: FontWeight.bold)),
                      value: _secilenHizmet,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      items: _hizmetListesi.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() => _secilenHizmet = newValue);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. TARİH VE SAAT SEÇİCİ
                const Text("2. ZAMAN KOORDİNATLARI", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildZamanButonu(
                        etiket: _secilenTarih == null ? "TARİH SEÇ" : "${_secilenTarih!.day}/${_secilenTarih!.month}/${_secilenTarih!.year}",
                        ikon: Icons.calendar_today,
                        onTap: () => _tarihSec(context),
                        aktif: _secilenTarih != null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildZamanButonu(
                        etiket: _secilenSaat == null ? "SAAT SEÇ" : _secilenSaat!.format(context),
                        ikon: Icons.access_time,
                        onTap: () => _saatSec(context),
                        aktif: _secilenSaat != null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. ARIZA NOTU
                const Text("3. İSTİHBARAT NOTU (OPSİYONEL)", style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: SiberTema.matGrey.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                  child: TextField(
                    controller: _notCtrl,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      hintText: "Sorunu veya talebinizi kısaca Karargaha iletin...",
                      hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 🚀 MÜHÜRLEME BUTONU
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: _islemSuruyor
                      ? const Center(child: CircularProgressIndicator(color: SiberTema.kuantumCyan))
                      : ElevatedButton.icon(
                    icon: const Icon(Icons.verified, color: SiberTema.oledBlack, size: 24),
                    label: const Text("RANDEVUYU MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, color: SiberTema.oledBlack)),
                    style: SiberTema.kuantumButonStili(),
                    onPressed: _randevuyuMuhurle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Özel Zaman Seçim Butonu
  Widget _buildZamanButonu({required String etiket, required IconData ikon, required VoidCallback onTap, required bool aktif}) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(ikon, size: 18, color: aktif ? SiberTema.kuantumCyan : Colors.white54),
      label: Text(etiket, style: TextStyle(color: aktif ? Colors.white : Colors.white54, fontWeight: aktif ? FontWeight.w900 : FontWeight.bold, fontSize: 12)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: aktif ? SiberTema.kuantumCyan : Colors.white24, width: aktif ? 1.5 : 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: aktif ? SiberTema.kuantumCyan.withOpacity(0.05) : SiberTema.matGrey.withOpacity(0.8),
      ),
    );
  }
}