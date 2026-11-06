import 'package:flutter/material.dart';
import 'l10n.dart';

/// The app name in a wide, bold "tech" style (Krona One, SIL Open Font License).
/// Arabic has no glyphs in that font, so Arabic keeps the normal bold style.
class BrandName extends StatelessWidget {
  const BrandName({super.key, this.size = 24, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    final spacing = ar ? 0.0 : size * 0.14;
    return Padding(
      // balances the trailing letter-spacing so the word looks centered
      padding: EdgeInsetsDirectional.only(start: spacing),
      child: Text(
        ar ? context.t('appName') : 'HABIDZ',
        maxLines: 1,
        style: TextStyle(
          fontFamily: ar ? null : 'KronaOne',
          fontWeight: ar ? FontWeight.w800 : FontWeight.w400,
          fontSize: size,
          letterSpacing: spacing,
          color: color,
        ),
      ),
    );
  }
}

/// assets/logo.png recolored to the current theme's text color, so ONE single-color
/// logo works on light, dark and purple backgrounds (black on light, white on dark).
/// Pass [tint] to force a color.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 96, this.tint});
  final double size;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      width: size,
      height: size,
      color: tint ?? Theme.of(context).colorScheme.onSurface,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}
