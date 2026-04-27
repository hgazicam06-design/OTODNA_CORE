// lib/screens/kullanici/randevu_sistemi.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

import '../../../../core/responsive_kalkan.dart';
import '../../../../core/otodna_hizmet_kutuphanesi.dart';

/// 🛡️ PLAZA RANDEVU VE PLANLAMA MOTORU (SiberRandevuSistemi)
/// Müşterinin seçtiği hizmet ve zamanı doğrudan Merkeze (Firebase) mühürler.
class SiberRandevuSistemi extends StatefulWidget {
  final String musteriId; // Randevuyu alan müşterinin kimliği
  final String bayiId; // Randevu talep edilen bayinin kimliği

  const SiberRandevuSistemi({super.key, required this.musteriId, required this.bayiId});

  @override
  State<SiberRandevuSistemi> createState() => _SiberRandevuSistemiState();
}

class _SiberRandevuSistemiState extends State<SiberRandevuSistemi> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _notCtrl = TextEditingController();

  final Color primaryTeal = Colors.teal.shade700;
  final Color dangerColor = Colors.redAccent;
  final Color textColor = const Color(0xFF1E293B);
  final Color bgColor = const Color(0xFFFAFAFC);

  // ── PLANLAMA DEĞİŞKENLERİ ──
  DateTime? _secilenTarih;
  TimeOfDay? _secilenSaat;
  String? _secilenHizmet;
  bool _islemSuruyor = false;

  // 🔥 AĞA BAĞLANTI: Listeyi gerçek kütüphaneden çekiyoruz!
  final List<String> _hizmetListesi = SiberHizmetKutuphanesi.tumHizmetleriGetir();

  // ── 🚀 FİREBASE MÜHÜR MOTORU (ATOMİK ZIRHLI) ──
  Future<void> _randevuyuMuhurle() async {
    if (_secilenHizmet == null || _secilenTarih == null || _secilenSaat == null) {
      HapticFeedback.heavyImpact();
      _plazaUyariGoster("BİLGİ EKSİK", "Hizmet, tarih ve saat seçimi zorunludur!", dangerColor);
      return;
    }

    if (_islemSuruyor) return;
    setState(() => _islemSuruyor = true);
    HapticFeedback.lightImpact();

    developer.log("🚀 PLAZA PLANLAMA: Randevu talebi Merkeze iletiliyor...");

    try {
      DateTime randevuZamani = DateTime(
        _secilenTarih!.year,
        _secilenTarih!.month,
        _secilenTarih!.day,
        _secilenSaat!.hour,
        _secilenSaat!.minute,
      );

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
        'islem_detayi': 'PLAZA PLANLAMA: ${widget.musteriId} kullanıcısı ${widget.bayiId} bayisinden $_secilenHizmet randevusu aldı.',
        'tarih': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      HapticFeedback.vibrate();
      developer.log("✅ RANDEVU MÜHÜRLENDİ: Talep bayinin radarına düştü.");

      if (mounted) {
        _plazaUyariGoster("MÜHÜRLENDİ", "Randevunuz oluşturuldu. Bayi onayından sonra bildirim alacaksınız.", primaryTeal);
        Navigator.pop(context);
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      developer.log("🚨 AĞ ÇÖKTÜ: Randevu iletilemedi!", error: e);
      _plazaUyariGoster("BAĞLANTI HATASI", "Randevu oluşturulamadı. Lütfen tekrar deneyin.", dangerColor);
    } finally {
      if (mounted) setState(() => _islemSuruyor = false);
    }
  }

  // ── ⏳ ZAMAN SEÇİCİLER ──
  Future<void> _tarihSec(BuildContext context) async {
    final DateTime? secilen = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryTeal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textColor,
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
            colorScheme: ColorScheme.light(
              primary: primaryTeal,
              surface: Colors.white,
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
  void _plazaUyariGoster(String baslik, String mesaj, Color renk) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: renk, width: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontFamily: 'Avenir')),
            const SizedBox(height: 4),
            Text(mesaj, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
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
      isOledBackground: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text("PLAZA RANDEVU MERKEZİ", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, fontFamily: 'Avenir')),
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          iconTheme: IconThemeData(color: primaryTeal),
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
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))]
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: primaryTeal.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(Icons.calendar_month_outlined, color: primaryTeal, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(child: Text("OtoDNA güvencesiyle randevunuzu mühürleyin. Ustanız sizin için hazırlık yapacaktır.", style: TextStyle(color: Colors.white87, fontSize: 11, height: 1.5, letterSpacing: 0.5, fontWeight: FontWeight.bold, fontFamily: 'Avenir'))),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 1. HİZMET SEÇİCİ
                const Text("1. İŞLEM TÜRÜ", style: TextStyle(color: Colors.white45, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 5)]
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      icon: Icon(Icons.keyboard_arrow_down, color: primaryTeal),
                      hint: const Text("Hizmet Branşını Seçin", style: TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir')),
                      value: _secilenHizmet,
                      style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'Avenir'),
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
                const Text("2. ZAMAN PLANI", style: TextStyle(color: Colors.white45, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
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
                const Text("3. BİLGİ NOTU (OPSİYONEL)", style: TextStyle(color: Colors.white45, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w900, fontFamily: 'Avenir')),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.02), blurRadius: 5)]
                  ),
                  child: TextField(
                    controller: _notCtrl,
                    maxLines: 3,
                    style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Avenir'),
                    decoration: const InputDecoration(
                      hintText: "Sorunu veya talebinizi kısaca ustaya iletin...",
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 12, fontFamily: 'Avenir', fontWeight: FontWeight.bold),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 🚀 MÜHÜRLEME BUTONU
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: _islemSuruyor
                      ? Center(child: CircularProgressIndicator(color: primaryTeal))
                      : ElevatedButton.icon(
                    icon: const Icon(Icons.verified, color: SiberTema.kuantumCyan, size: 24),
                    label: const Text("RANDEVUYU MÜHÜRLE", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 13, color: SiberTema.textMain, fontFamily: 'Avenir')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
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
      icon: Icon(ikon, size: 18, color: aktif ? primaryTeal : Colors.black38),
      label: Text(etiket, style: TextStyle(color: aktif ? primaryTeal : Colors.black45, fontWeight: aktif ? FontWeight.w900 : FontWeight.bold, fontSize: 12, fontFamily: 'Avenir')),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: aktif ? primaryTeal.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.05), width: aktif ? 2 : 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: aktif ? primaryTeal.withValues(alpha: 0.05) : Colors.white,
      ),
    );
  }
}