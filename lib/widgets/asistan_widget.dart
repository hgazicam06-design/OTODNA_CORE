import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🚀 SİBER LOGLAMA İÇİN EKLENDİ
import 'package:firebase_auth/firebase_auth.dart'; // 🚀 KİMLİK TESPİTİ İÇİN EKLENDİ
import 'dart:developer' as developer;
import '../services/asistan_service.dart';

/// 🛡️ KUANTUM SİBER ASİSTAN (Yüzen AI Balonu)
/// Uygulamanın her ekranına eklenebilen, Karargah bağlantılı AI asistanı.
class AsistanWidget extends StatefulWidget {
  final String ekran;
  final AsistanService asistan;

  AsistanWidget({
    super.key,
    required this.ekran,
    required this.asistan,
  });

  @override
  State<AsistanWidget> createState() => _AsistanWidgetState();
}

class _AsistanWidgetState extends State<AsistanWidget> with SingleTickerProviderStateMixin {
  // 🎨 SİBER RENK PALETİ (Karargah Standartları)
  static const _cyan = Color(0xFF00FFC2); // Kuantum Turkuazı
  static const _dark = Color(0xFF0A0A0F); // OLED Siyah
  static const _card = Color(0xFF111118); // Siber Cam Arka Plan
  static const _alertRed = Color(0xFFFF4D4D); // İhlal Kırmızısı

  bool _acik = false;
  bool _yukleniyor = false;
  bool _karsilamaGosterildi = false;
  String _karsilama = '';

  final _mesajCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<AsistanMesaj> _mesajlar = [];

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _karsilamaHazirla();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _mesajCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _karsilamaHazirla() async {
    try {
      final mesaj = await widget.asistan.karsilamaGonder(widget.ekran);
      if (mounted) setState(() => _karsilama = mesaj);
    } catch (e) {
      developer.log("SİBER UYARI: Asistan karşılama mesajı çekilemedi.", error: e);
    }
  }

  void _toggle() {
    setState(() => _acik = !_acik);
    if (_acik && !_karsilamaGosterildi && _karsilama.isNotEmpty) {
      setState(() {
        _mesajlar.add(AsistanMesaj(metin: _karsilama, kullanici: false));
        _karsilamaGosterildi = true;
      });
      _asagiKaydir();
    }
  }

  // 🚀 AI SORGULAMA VE SİBER LOGLAMA MOTORU (Sessiz Çöküş Engellendi!)
  Future<void> _gonder() async {
    final soru = _mesajCtrl.text.trim();
    if (soru.isEmpty) return;
    _mesajCtrl.clear();

    setState(() {
      _mesajlar.add(AsistanMesaj(metin: soru, kullanici: true));
      _yukleniyor = true;
    });
    _asagiKaydir();

    try {
      // 1. Asistandan Cevabı Çek
      final cevap = await widget.asistan.sor(soru);

      if (mounted) {
        setState(() {
          _mesajlar.add(AsistanMesaj(metin: cevap.metin, kullanici: false));
          _yukleniyor = false;
        });
        _asagiKaydir();
      }

      // 2. ⛓️ ATOMİK ZIRH: Asistanla Konuşulanları Karargah Radarına Logla!
      _sorguyuKarargahaLogla(soru);

    } catch (e) {
      // 🚨 SİBER KALKAN: İnternet koparsa asistan kilitlenmez, uyarı verir!
      developer.log("AĞ ÇÖKTÜ: Asistan zekası yanıt veremiyor!", error: e);
      if (mounted) {
        setState(() {
          _mesajlar.add(AsistanMesaj(metin: "⚠️ SİBER BAĞLANTI HATASI: Kuantum Ağına şu an erişilemiyor. Lütfen Karargah bağlantınızı kontrol edin.", kullanici: false));
          _yukleniyor = false;
        });
        _asagiKaydir();
      }
    }
  }

  // 📡 İÇ PROTOKOL: KULLANICI EĞİLİMLERİNİ İZLEME MOTORU
  Future<void> _sorguyuKarargahaLogla(String soru) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "ANONİM_KULLANICI";

      await FirebaseFirestore.instance.collection('sistem_loglari').add({
        'islem_turu': 'YAPAY_ZEKA_SORGUSU',
        'islem_detayi': 'SİBER BİLGİ: $userId ID\'li kullanıcı "${widget.ekran}" ekranında Asistana şu soruyu sordu: "$soru"',
        'kullanici_id': userId,
        'tarih': FieldValue.serverTimestamp(),
      });
    } catch (logError) {
      developer.log("SİBER UYARI: Asistan sorgusu Karargaha mühürlenemedi!", error: logError);
    }
  }

  void _asagiKaydir() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── BUILD (UI) ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_acik) _buildPanel(),
          SizedBox(height: 12),
          _buildBalonButon(),
        ],
      ),
    );
  }

  Widget _buildBalonButon() => GestureDetector(
    onTap: _toggle,
    child: AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Transform.scale(
        scale: _acik ? 1.0 : _pulseAnim.value,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [_cyan, _cyan.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [BoxShadow(color: _cyan.withOpacity(0.4), blurRadius: 16, spreadRadius: 2)],
          ),
          child: Icon(
            _acik ? Icons.close_rounded : Icons.smart_toy_rounded,
            color: Colors.black,
            size: 26,
          ),
        ),
      ),
    ),
  );

  Widget _buildPanel() => Container(
    width: MediaQuery.of(context).size.width * 0.85 > 320 ? 320 : MediaQuery.of(context).size.width * 0.85,
    height: 420,
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _cyan.withOpacity(0.3)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 24, spreadRadius: 4)],
    ),
    child: Column(
        children: [
          _buildPanelBaslik(),
          Expanded(child: _buildMesajlar()),
          _buildGirisAlan(),
        ]
    ),
  );

  Widget _buildPanelBaslik() => Container(
    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      gradient: LinearGradient(
        colors: [_cyan.withOpacity(0.15), _dark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _cyan.withOpacity(0.2),
          border: Border.all(color: _cyan.withOpacity(0.5)),
        ),
        child: Icon(Icons.smart_toy_rounded, color: _cyan, size: 18),
      ),
      SizedBox(width: 10),
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OtoDNA AI Asistan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
            Row(
                children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: _cyan)),
                  SizedBox(width: 4),
                  Text('Kuantum Ağına Bağlı', style: TextStyle(color: _cyan.withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.bold)),
                ]
            ),
          ]
      ),
      Spacer(),
      GestureDetector(
        onTap: () {
          widget.asistan.sifirla();
          setState(() { _mesajlar.clear(); _karsilamaGosterildi = false; });
          developer.log("SİBER BİLGİ: Asistan hafızası sıfırlandı.");
        },
        child: Icon(Icons.refresh_rounded, color: Colors.white.withOpacity(0.4), size: 20),
      ),
    ]),
  );

  Widget _buildMesajlar() => ListView.builder(
    controller: _scrollCtrl,
    physics: BouncingScrollPhysics(),
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    itemCount: _mesajlar.length + (_yukleniyor ? 1 : 0),
    itemBuilder: (_, i) {
      if (i == _mesajlar.length) return _buildYukleniyor();
      return _buildMesajBalonu(_mesajlar[i]);
    },
  );

  Widget _buildMesajBalonu(AsistanMesaj m) {
    bool isErrorMsg = m.metin.contains("SİBER BAĞLANTI HATASI");
    Color borderColor = m.kullanici ? _cyan.withOpacity(0.3) : (isErrorMsg ? _alertRed.withOpacity(0.5) : Color(0xFF2A2A3A));
    Color bgColor = m.kullanici ? _cyan.withOpacity(0.15) : (isErrorMsg ? _alertRed.withOpacity(0.1) : Color(0xFF1A1A25));

    return Align(
      alignment: m.kullanici ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 240),
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14).copyWith(
            bottomRight: m.kullanici ? Radius.circular(4) : null,
            bottomLeft: !m.kullanici ? Radius.circular(4) : null,
          ),
          color: bgColor,
          border: Border.all(color: borderColor),
        ),
        child: m.kullanici
            ? Text(m.metin, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))
            : MarkdownBody(
          data: m.metin,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(color: isErrorMsg ? _alertRed : Colors.white, fontSize: 12, height: 1.5),
            strong: TextStyle(color: _cyan, fontWeight: FontWeight.w900, fontSize: 12),
            listBullet: TextStyle(color: _cyan.withOpacity(0.8), fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildYukleniyor() => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Color(0xFF1A1A25),
        border: Border.all(color: Color(0xFF2A2A3A)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _nokta(0), SizedBox(width: 4), _nokta(1), SizedBox(width: 4), _nokta(2),
      ]),
    ),
  );

  Widget _nokta(int i) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.3, end: 1.0),
    duration: Duration(milliseconds: 400 + i * 150),
    curve: Curves.easeInOut,
    builder: (_, v, __) => Opacity(
      opacity: v,
      child: Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: _cyan)),
    ),
  );

  Widget _buildGirisAlan() => Container(
    padding: EdgeInsets.fromLTRB(12, 10, 12, 12),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: Color(0xFF1E1E2E))),
    ),
    child: Row(children: [
      Expanded(
        child: TextField(
          controller: _mesajCtrl,
          style: TextStyle(color: Colors.white, fontSize: 13),
          maxLines: null, // Dinamik yükseklik için
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => _gonder(),
          decoration: InputDecoration(
            hintText: 'Karargaha bir şey sor...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
            filled: true,
            fillColor: Color(0xFF0E0E18),
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFF1E1E2E))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFF1E1E2E))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _cyan.withOpacity(0.5))),
          ),
        ),
      ),
      SizedBox(width: 10),
      GestureDetector(
        onTap: _yukleniyor ? null : _gonder,
        child: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _yukleniyor ? Colors.grey.withOpacity(0.1) : _cyan.withOpacity(0.15),
            border: Border.all(color: _yukleniyor ? Colors.transparent : _cyan.withOpacity(0.4)),
          ),
          child: Icon(Icons.send_rounded, color: _yukleniyor ? Colors.white30 : _cyan, size: 20),
        ),
      ),
    ]),
  );
}