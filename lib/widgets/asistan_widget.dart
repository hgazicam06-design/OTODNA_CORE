import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/asistan_service.dart';

/// Uygulamanın herhangi bir ekranına eklenebilen yüzen AI asistan baloncuğu.
/// Kullanım: Stack içine AsistanWidget(ekran: 'ana_sayfa') ekle.
class AsistanWidget extends StatefulWidget {
  final String ekran;
  final AsistanService asistan;

  const AsistanWidget({
    super.key,
    required this.ekran,
    required this.asistan,
  });

  @override
  State<AsistanWidget> createState() => _AsistanWidgetState();
}

class _AsistanWidgetState extends State<AsistanWidget>
    with SingleTickerProviderStateMixin {
  static const _cyan = Color(0xFF03f0c8);
  static const _gold = Color(0xFFFF9C1A);
  static const _dark = Color(0xFF0A0A0F);
  static const _card = Color(0xFF111118);

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
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

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
    final mesaj = await widget.asistan.karsilamaGonder(widget.ekran);
    if (mounted) setState(() => _karsilama = mesaj);
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

  Future<void> _gonder() async {
    final soru = _mesajCtrl.text.trim();
    if (soru.isEmpty) return;
    _mesajCtrl.clear();

    setState(() {
      _mesajlar.add(AsistanMesaj(metin: soru, kullanici: true));
      _yukleniyor = true;
    });
    _asagiKaydir();

    final cevap = await widget.asistan.sor(soru);

    if (mounted) {
      setState(() {
        _mesajlar.add(AsistanMesaj(metin: cevap.metin, kullanici: false));
        _yukleniyor = false;
      });
      _asagiKaydir();
    }
  }

  void _asagiKaydir() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
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
          const SizedBox(height: 12),
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
                  colors: [_cyan, _cyan.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                      color: _cyan.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2),
                ],
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
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _cyan.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 24,
                spreadRadius: 4),
          ],
        ),
        child: Column(children: [
          _buildPanelBaslik(),
          Expanded(child: _buildMesajlar()),
          _buildGirisAlan(),
        ]),
      );

  Widget _buildPanelBaslik() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          gradient: LinearGradient(
            colors: [_cyan.withValues(alpha: 0.15), _dark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _cyan.withValues(alpha: 0.2),
              border: Border.all(color: _cyan.withValues(alpha: 0.5)),
            ),
            child: const Icon(Icons.smart_toy_rounded, color: _cyan, size: 18),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('OtoDNA Asistan',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
            Row(children: [
              Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: _cyan)),
              const SizedBox(width: 4),
              Text('Çevrimiçi',
                  style: TextStyle(
                      color: _cyan.withValues(alpha: 0.8), fontSize: 10)),
            ]),
          ]),
          const Spacer(),
          GestureDetector(
            onTap: () {
              widget.asistan.sifirla();
              setState(() { _mesajlar.clear(); _karsilamaGosterildi = false; });
            },
            child: Icon(Icons.refresh_rounded,
                color: Colors.white.withValues(alpha: 0.4), size: 18),
          ),
        ]),
      );

  Widget _buildMesajlar() => ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        itemCount: _mesajlar.length + (_yukleniyor ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == _mesajlar.length) return _buildYukleniyor();
          final m = _mesajlar[i];
          return _buildMesajBalonu(m);
        },
      );

  Widget _buildMesajBalonu(AsistanMesaj m) => Align(
        alignment: m.kullanici ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 230),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14).copyWith(
              bottomRight: m.kullanici ? const Radius.circular(4) : null,
              bottomLeft: !m.kullanici ? const Radius.circular(4) : null,
            ),
            color: m.kullanici
                ? _cyan.withValues(alpha: 0.15)
                : const Color(0xFF1A1A25),
            border: Border.all(
                color: m.kullanici
                    ? _cyan.withValues(alpha: 0.3)
                    : const Color(0xFF2A2A3A)),
          ),
          child: m.kullanici
              ? Text(m.metin,
                  style: const TextStyle(color: Colors.white, fontSize: 12))
              : MarkdownBody(
                  data: m.metin,
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                    strong: const TextStyle(
                        color: _cyan, fontWeight: FontWeight.w700, fontSize: 12),
                    listBullet: TextStyle(
                        color: _cyan.withValues(alpha: 0.8), fontSize: 12),
                  ),
                ),
        ),
      );

  Widget _buildYukleniyor() => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xFF1A1A25),
            border: Border.all(color: const Color(0xFF2A2A3A)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _nokta(0), const SizedBox(width: 4),
            _nokta(1), const SizedBox(width: 4),
            _nokta(2),
          ]),
        ),
      );

  Widget _nokta(int i) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.3, end: 1.0),
        duration: Duration(milliseconds: 400 + i * 150),
        curve: Curves.easeInOut,
        builder: (_, v, __) => Opacity(
          opacity: v,
          child: Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: _cyan),
          ),
        ),
      );

  Widget _buildGirisAlan() => Container(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
        decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(color: Color(0xFF1E1E2E))),
        ),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _mesajCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              maxLines: 1,
              onSubmitted: (_) => _gonder(),
              decoration: InputDecoration(
                hintText: 'Nasıl yardımcı olabilirim?',
                hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF0E0E18),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1E1E2E))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1E1E2E))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: _cyan.withValues(alpha: 0.5))),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _gonder,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _cyan.withValues(alpha: 0.15),
                border: Border.all(color: _cyan.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.send_rounded, color: _cyan, size: 18),
            ),
          ),
        ]),
      );
}

