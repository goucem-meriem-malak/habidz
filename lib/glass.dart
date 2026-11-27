import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'settings.dart';

/// Glassmorphism kit. Colors of the existing themes are untouched; this only adds
/// a soft glowing backdrop and frosted, translucent surfaces on top of them.
///
/// Performance note: list items use "cheap glass" (gradient + border, NO blur) because the
/// backdrop is made of smooth glows, which look the same blurred or not. Real blur
/// (BackdropFilter) is only used on sheets and dialogs.

class _Orb {
  const _Orb(this.at, this.radius, this.color);
  final Alignment at;
  final double radius; // fraction of screen width
  final Color color;
}

class GlassPalette {
  const GlassPalette({
    required this.orbs,
    required this.fillTop,
    required this.fillBottom,
    required this.border,
    required this.sheen,
    required this.shadow,
  });

  final List<_Orb> orbs;
  final Color fillTop, fillBottom, border, sheen, shadow;

  static const _dark = GlassPalette(
    orbs: [
      _Orb(Alignment(-1.0, -0.95), 0.95, Color(0x591F6FEB)),
      _Orb(Alignment(1.1, -0.15), 0.85, Color(0x478957E5)),
      _Orb(Alignment(-0.7, 1.05), 0.95, Color(0x3339C5CF)),
    ],
    fillTop: Color(0x1AFFFFFF),
    fillBottom: Color(0x08FFFFFF),
    border: Color(0x2EFFFFFF),
    sheen: Color(0x14FFFFFF),
    shadow: Color(0x40000000),
  );

  static const _light = GlassPalette(
    orbs: [
      _Orb(Alignment(-1.0, -0.95), 0.95, Color(0x809EC9FF)),
      _Orb(Alignment(1.1, -0.15), 0.85, Color(0x80D2B8FF)),
      _Orb(Alignment(-0.7, 1.05), 0.95, Color(0x59FFC2E2)),
    ],
    fillTop: Color(0xB3FFFFFF),
    fillBottom: Color(0x66FFFFFF),
    border: Color(0xCCFFFFFF),
    sheen: Color(0x80FFFFFF),
    shadow: Color(0x141F2328),
  );

  static const _purple = GlassPalette(
    orbs: [
      _Orb(Alignment(-1.0, -0.95), 0.95, Color(0x4DB388FF)),
      _Orb(Alignment(1.1, -0.15), 0.85, Color(0x38DB61A2)),
      _Orb(Alignment(-0.7, 1.05), 0.95, Color(0x405B6CFF)),
    ],
    fillTop: Color(0x1FFFFFFF),
    fillBottom: Color(0x0AFFFFFF),
    border: Color(0x38FFFFFF),
    sheen: Color(0x18FFFFFF),
    shadow: Color(0x59000000),
  );

  static GlassPalette of(BuildContext context) {
    if (settings.theme == 'purple') return _purple;
    return Theme.of(context).brightness == Brightness.dark ? _dark : _light;
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter(this.base, this.palette);
  final Color base;
  final GlassPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = base);
    for (final o in palette.orbs) {
      final center = o.at.alongSize(size);
      final r = size.width * o.radius;
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(colors: [o.color, o.color.withAlpha(0)])
              .createShader(Rect.fromCircle(center: center, radius: r)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter old) => old.base != base || old.palette != palette;
}

/// The soft glowing background behind every screen.
class GlassBackground extends StatelessWidget {
  const GlassBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _BackdropPainter(Theme.of(context).scaffoldBackgroundColor, GlassPalette.of(context)),
      ),
    );
  }
}

/// A Scaffold that sits on the glass backdrop (AppBar and body are transparent).
class GlassScaffold extends StatelessWidget {
  const GlassScaffold({super.key, this.appBar, required this.body, this.floatingActionButton});
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const GlassBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: appBar,
          body: body,
          floatingActionButton: floatingActionButton,
        ),
      ],
    );
  }
}

/// Frosted card. [blur] > 0 adds a real backdrop blur (use sparingly, not in long lists).
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = 20,
    this.blur = 0,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final p = GlassPalette.of(context);
    final shape = BorderRadius.circular(radius);
    Widget card = Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: shape,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [p.fillTop, p.fillBottom],
        ),
        border: Border.all(color: p.border),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: shape,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [p.sheen, p.sheen.withAlpha(0)],
        ),
      ),
      child: child,
    );
    if (blur > 0) {
      card = ClipRRect(
        borderRadius: shape,
        child: BackdropFilter(filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur), child: card),
      );
    }
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: [BoxShadow(color: p.shadow, blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: card,
    );
  }
}

/// Bottom-sheet surface: blurred, frosted, and mostly opaque underneath so nothing
/// from the screen behind (like the habit grids) can show through.
class GlassSheet extends StatelessWidget {
  const GlassSheet({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = GlassPalette.of(context);
    final cs = Theme.of(context).colorScheme;
    final base = Theme.of(context).scaffoldBackgroundColor;
    const r = BorderRadius.vertical(top: Radius.circular(28));
    return ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: base.withAlpha(224),
            borderRadius: r,
            border: Border.all(color: p.border),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: r,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [p.fillTop, p.fillBottom],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 14),
                  decoration: BoxDecoration(
                    color: cs.onSurface.withAlpha(70),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Flexible(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> showGlassSheet<T>({required BuildContext context, required WidgetBuilder builder}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (c) => GlassSheet(child: builder(c)),
  );
}

/// Dialog with a softly blurred screen behind it.
Future<T?> showGlassDialog<T>({required BuildContext context, required WidgetBuilder builder}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black38,
    builder: (c) => BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: builder(c),
    ),
  );
}

/// AlertDialog styled as frosted glass.
class GlassAlert extends StatelessWidget {
  const GlassAlert({super.key, this.title, this.content, this.actions});
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final p = GlassPalette.of(context);
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor.withAlpha(232),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: p.border),
      ),
      title: title,
      content: content,
      actions: actions,
    );
  }
}
