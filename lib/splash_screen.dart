import 'package:flutter/material.dart';

import 'brand.dart';

/// Animated launch screen: logo pops in, app name slides up, then a soft
/// cross-fade into [next]. Skips most of the animation if the phone has
/// "remove animations" turned on.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.next});
  final Widget next;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final bool _reduce =
      WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _reduce ? 300 : 1800),
  );

  late final Animation<double> _logoScale = Tween<double>(begin: 0.55, end: 1).animate(
    CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack)),
  );
  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
  );
  late final Animation<double> _textFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
  );
  late final Animation<Offset> _textSlide = Tween<Offset>(
    begin: const Offset(0, 0.6),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic)));

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(() async {
      await Future<void>.delayed(Duration(milliseconds: _reduce ? 0 : 350));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder<void>(
        transitionDuration: Duration(milliseconds: _reduce ? 1 : 450),
        pageBuilder: (_, __, ___) => widget.next,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: const LogoMark(size: 180, tint: Colors.black),
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: const BrandName(size: 22, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
