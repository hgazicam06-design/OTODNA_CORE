// lib/widgets/otodna_logo_painter.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 🛡️ KUANTUM ANİMASYONLU SİBER LOGO MOTORU (OtoDNALogo)
/// OtoDNA'nın yaşayan, nefes alan ve devreleri Kuantum Turkuazı ile parlayan kalbi.
class OtoDNALogo extends StatefulWidget {
  final double size;
  const OtoDNALogo({super.key, this.size = 110});

  @override
  State<OtoDNALogo> createState() => _OtoDNALogoState();
}

class _OtoDNALogoState extends State<OtoDNALogo> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    // 1.8 saniyelik Siber Nefes (Pulse) Döngüsü
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size * 2.6, widget.size * 1.6),
        painter: _SiberLogoPainter(_ctrl.value),
      ),
    );
  }
}

class _SiberLogoPainter extends CustomPainter {
  final double t;

  // ── 🎨 KARARGAH TASARIM DOKTRİNİ ──
  static const Color _matGrey = Color(0xFF111111);
  static const Color _kuantumCyan = Color(0xFF00FFC2);
  static const Color _oledBlack = Color(0xFF000000);

  _SiberLogoPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final gr = size.height * 0.44; // Dişli yarıçapı

    _drawSiberGear(canvas, cx, cy, gr);
    _drawHolographicCore(canvas, cx, cy, gr * 0.62);
    _drawSiberCar(canvas, cx, cy, gr * 0.38);
    _drawKuantumBranches(canvas, cx, cy, gr);
  }

  // ── 1. SİBER DİŞLİ (Ana Gövde) ──────────────────────────────────────────
  void _drawSiberGear(Canvas canvas, double cx, double cy, double r) {
    const n = 10;
    final outer = r;
    final inner = r * 0.80;
    final half = math.pi / n * 0.55;
    final step = 2 * math.pi / n;

    final path = Path();
    for (int i = 0; i < n; i++) {
      final a = step * i - math.pi / 2;
      _addToothArc(path, cx, cy, inner, outer, a - half, a + half, i == 0);
    }
    path.close();

    // Kuantum Turkuazı Arkadan Vuran Parlama (Neon Glow)
    canvas.drawPath(path, Paint()
      ..color = _kuantumCyan.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15)
      ..style = PaintingStyle.fill);

    // Dişlinin Mat Gri Gövdesi
    canvas.drawPath(path, Paint()
      ..color = _matGrey
      ..style = PaintingStyle.fill);

    // Dişliyi Saran İnce Neon Çizgi
    canvas.drawPath(path, Paint()
      ..color = _kuantumCyan.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke);
  }

  void _addToothArc(Path p, double cx, double cy, double inner, double outer, double a1, double a2, bool first) {
    final p1 = _pt(cx, cy, inner, a1);
    final p2 = _pt(cx, cy, outer, a1);
    final p3 = _pt(cx, cy, outer, a2);
    final p4 = _pt(cx, cy, inner, a2);
    if (first) p.moveTo(p1.dx, p1.dy); else p.lineTo(p1.dx, p1.dy);
    p.lineTo(p2.dx, p2.dy);
    p.lineTo(p3.dx, p3.dy);
    p.lineTo(p4.dx, p4.dy);
    p.arcToPoint(_pt(cx, cy, inner, a2 + (2 * math.pi / 10 - 2 * (a2 - a1))),
        radius: Radius.circular(inner), clockwise: true);
  }

  // ── 2. HOLOGRAFİK İÇ ÇEKİRDEK ───────────────────────────────────────────
  void _drawHolographicCore(Canvas canvas, double cx, double cy, double r) {
    // İç siyah delik
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = _oledBlack..style = PaintingStyle.fill);

    // Çekirdek neon halkası
    canvas.drawCircle(Offset(cx, cy), r, Paint()
      ..color = _kuantumCyan.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke);
  }

  // ── 3. SİBER ARAÇ SİLUETİ ───────────────────────────────────────────────
  void _drawSiberCar(Canvas canvas, double cx, double cy, double s) {
    // Gövde (Beyaz/Açık Gri)
    final body = Path()
      ..moveTo(cx - s,        cy + s * 0.30)
      ..lineTo(cx - s,        cy + s * 0.05)
      ..lineTo(cx - s * 0.65, cy - s * 0.50)
      ..lineTo(cx - s * 0.15, cy - s * 0.80)
      ..lineTo(cx + s * 0.15, cy - s * 0.80)
      ..lineTo(cx + s * 0.65, cy - s * 0.50)
      ..lineTo(cx + s,        cy + s * 0.05)
      ..lineTo(cx + s,        cy + s * 0.30)
      ..close();
    canvas.drawPath(body, Paint()..color = Colors.white..style = PaintingStyle.fill);

    // Camlar (OLED Siyah)
    final glass = Path()
      ..moveTo(cx - s * 0.55, cy + s * 0.02)
      ..lineTo(cx - s * 0.30, cy - s * 0.68)
      ..lineTo(cx + s * 0.30, cy - s * 0.68)
      ..lineTo(cx + s * 0.55, cy + s * 0.02)
      ..close();
    canvas.drawPath(glass, Paint()..color = _oledBlack..style = PaintingStyle.fill);

    // Alt şerit (Mat Gri)
    canvas.drawRect(
      Rect.fromLTWH(cx - s, cy + s * 0.28, s * 2, s * 0.22),
      Paint()..color = _matGrey..style = PaintingStyle.fill,
    );

    // Tekerlekler (Neon Turkuaz Jantlar)
    for (final wx in [cx - s * 0.60, cx + s * 0.60]) {
      canvas.drawCircle(Offset(wx, cy + s * 0.42), s * 0.20, Paint()..color = _oledBlack..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(wx, cy + s * 0.42), s * 0.11, Paint()..color = _kuantumCyan..style = PaintingStyle.fill);
    }

    // Farlar (Parlan Kuantum Turkuazı)
    for (final fx in [cx - s * 0.90, cx + s * 0.62]) {
      final rect = RRect.fromRectAndRadius(Rect.fromLTWH(fx, cy - s * 0.12, s * 0.30, s * 0.13), const Radius.circular(3));
      // Far Glow
      canvas.drawRRect(rect, Paint()
        ..color = _kuantumCyan.withOpacity(0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
        ..style = PaintingStyle.fill);
      // Far Core
      canvas.drawRRect(rect, Paint()..color = Colors.white..style = PaintingStyle.fill);
    }
  }

  // ── 4. KUANTUM DEVRE DALLARI (Yanıp Sönen Ağlar) ─────────────────────────
  void _drawKuantumBranches(Canvas canvas, double cx, double cy, double r) {
    final gearEdge = r * 0.82;

    // Sol 3 dal
    _branch(canvas, cx - gearEdge, cy, -1, 0);
    _branch(canvas, cx - gearEdge, cy, -1, 1);
    _branch(canvas, cx - gearEdge, cy, -1, 2);

    // Sağ 3 dal
    _branch(canvas, cx + gearEdge, cy,  1, 0);
    _branch(canvas, cx + gearEdge, cy,  1, 1);
    _branch(canvas, cx + gearEdge, cy,  1, 2);
  }

  void _branch(Canvas canvas, double sx, double sy, double dir, int idx) {
    // Faz farkıyla yanıp sönme (Pulse)
    final phase  = (t + idx / 3.0) % 1.0;
    final blink  = (math.sin(phase * math.pi * 2) + 1) / 2;
    final alpha  = 0.35 + blink * 0.65; // Parlaklık dalgalanması

    final hLen = 44.0;
    final vLen = 20.0;

    late List<Offset> pts;
    switch (idx) {
      case 0:
        pts = [Offset(sx, sy), Offset(sx + dir * hLen * 0.50, sy), Offset(sx + dir * hLen * 0.50, sy - vLen), Offset(sx + dir * hLen, sy - vLen)];
        break;
      case 1:
        pts = [Offset(sx, sy), Offset(sx + dir * hLen, sy)];
        break;
      default:
        pts = [Offset(sx, sy), Offset(sx + dir * hLen * 0.50, sy), Offset(sx + dir * hLen * 0.50, sy + vLen), Offset(sx + dir * hLen, sy + vLen)];
    }

    // Glow çizgi
    _polyline(canvas, pts, Paint()
      ..color = _kuantumCyan.withOpacity(alpha * 0.55)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));

    // Ana çizgi
    _polyline(canvas, pts, Paint()
      ..color = _kuantumCyan.withOpacity(alpha)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    // Uç nokta dairesi (Veri Terminali Bağlantı Noktası)
    final ep  = pts.last;
    final er  = 5.0;

    canvas.drawCircle(ep, er + 4, Paint()
      ..color = _kuantumCyan.withOpacity(alpha * 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

    canvas.drawCircle(ep, er, Paint()..color = _oledBlack.withOpacity(alpha * 0.25)..style = PaintingStyle.fill);

    canvas.drawCircle(ep, er, Paint()
      ..color = _kuantumCyan.withOpacity(alpha)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke);

    if (pts.length > 2) {
      canvas.drawCircle(pts[1], 2.5, Paint()..color = _kuantumCyan.withOpacity(alpha));
    }
  }

  void _polyline(Canvas canvas, List<Offset> pts, Paint paint) {
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) path.lineTo(pts[i].dx, pts[i].dy);
    canvas.drawPath(path, paint);
  }

  Offset _pt(double cx, double cy, double r, double a) => Offset(cx + r * math.cos(a), cy + r * math.sin(a));

  @override
  bool shouldRepaint(_SiberLogoPainter o) => o.t != t;
}