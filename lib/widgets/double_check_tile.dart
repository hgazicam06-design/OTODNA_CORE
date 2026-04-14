// lib/widgets/double_check_tile.dart
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

/// 🛡️ KUANTUM ÇİFTE MÜHÜR VE DENETİM MODÜLÜ (SiberCifteMuhur)
/// Parçanın durumunu (Kontrol/Değişim) şeffafça alır, Kuantum temasıyla parlar ve veriyi ana motora fırlatır.
class SiberCifteMuhur extends StatefulWidget {
  final String baslik;
  final bool initialKontrol; // Dışarıdan gelen başlangıç durumu
  final bool initialDegisim; // Dışarıdan gelen başlangıç durumu

  // Seçim değiştiğinde ana sayfaya (örn: Firebase'e yazacak olan metoda) veriyi yollar
  final Function(bool kontrolEdildi, bool degisti) onDegisim;

  const SiberCifteMuhur({
    super.key,
    required this.baslik,
    this.initialKontrol = false,
    this.initialDegisim = false,
    required this.onDegisim,
  });

  @override
  State<SiberCifteMuhur> createState() => _SiberCifteMuhurState();
}

class _SiberCifteMuhurState extends State<SiberCifteMuhur> {
  late bool _kontrolEdildi;
  late bool _degisti;

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);
  static const Color _uyariOrange = Colors.orangeAccent;

  @override
  void initState() {
    super.initState();
    // Karargah hafızasından gelen eski verileri yükle
    _kontrolEdildi = widget.initialKontrol;
    _degisti = widget.initialDegisim;
  }

  // Dışarıdan veri güncellendiğinde senkronize ol
  @override
  void didUpdateWidget(covariant SiberCifteMuhur oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialKontrol != widget.initialKontrol ||
        oldWidget.initialDegisim != widget.initialDegisim) {
      _kontrolEdildi = widget.initialKontrol;
      _degisti = widget.initialDegisim;
    }
  }

  // ── ⚙️ OTONOM ONAY MANTIĞI ──
  void _durumGuncelle({bool? kontrol, bool? degisim}) {
    setState(() {
      if (kontrol != null) _kontrolEdildi = kontrol;

      if (degisim != null) {
        _degisti = degisim;
        // ZIRH: Eğer parça "Değişti" işaretlenirse, otonom olarak "Kontrol" de edilmiştir!
        if (_degisti) {
          _kontrolEdildi = true;
          developer.log("AI KALFA: ${widget.baslik} değiştiği için 'Kontrol Edildi' mührü otomatik vuruldu.");
        }
      }
    });

    // Değişikliği ana Karargah paneline (WriteBatch için) fırlat
    widget.onDegisim(_kontrolEdildi, _degisti);
  }

  @override
  Widget build(BuildContext context) {
    bool isAktif = _kontrolEdildi || _degisti;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isAktif ? _kuantumCyan.withOpacity(0.05) : _matGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAktif ? _kuantumCyan.withOpacity(0.5) : Colors.white12,
          width: isAktif ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Başlık
          Expanded(
            flex: 3,
            child: Text(
              widget.baslik.toUpperCase(),
              style: TextStyle(
                color: isAktif ? _kuantumCyan : Colors.white70,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ),

          // 1. Mühür: KONTROL EDİLDİ
          Expanded(
            flex: 2,
            child: _buildSiberOnayKutusu(
              baslik: "KONTROL",
              deger: _kontrolEdildi,
              renk: _kuantumCyan,
              onChanged: (val) => _durumGuncelle(kontrol: val),
            ),
          ),

          // 2. Mühür: DEĞİŞTİ (Kritik İşlem)
          Expanded(
            flex: 2,
            child: _buildSiberOnayKutusu(
              baslik: "DEĞİŞTİ",
              deger: _degisti,
              renk: _uyariOrange, // Değişim kritik olduğu için Turuncu
              onChanged: (val) => _durumGuncelle(degisim: val),
            ),
          ),
        ],
      ),
    );
  }

  // ── 🔧 ARAYÜZ YARDIMCISI (SİBER CHECKBOX) ──
  Widget _buildSiberOnayKutusu({
    required String baslik,
    required bool deger,
    required Color renk,
    required Function(bool?) onChanged,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Theme(
          data: Theme.of(context).copyWith(
            unselectedWidgetColor: Colors.white30,
          ),
          child: Checkbox(
            value: deger,
            activeColor: renk,
            checkColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: onChanged,
          ),
        ),
        Text(
          baslik,
          style: TextStyle(
            color: deger ? renk : Colors.white54,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}