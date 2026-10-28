import 'package:flutter/material.dart';

/// Animated splash shown right after the native splash.
///
/// The first frame matches the native splash exactly (white background,
/// 313px centered logo) so the handoff is seamless, then the logo shrinks
/// and pulses while the title fades in and a charging bar fills up.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.next});

  final Widget next;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _darkGreen = Color(0xFF078C45);
  static const _limeGreen = Color(0xFF9BD820);
  // Logical size of the logo in the native splash (1254px image at 4x).
  static const _nativeLogoSize = 313.0;

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  late final Animation<double> _logoScale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.06,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.06,
        end: 0.6,
      ).chain(CurveTween(curve: Curves.easeInOutCubic)),
      weight: 3,
    ),
  ]).animate(CurvedAnimation(parent: _intro, curve: const Interval(0.0, 0.35)));

  late final Animation<double> _logoLift = Tween(begin: 0.0, end: -70.0)
      .animate(
        CurvedAnimation(
          parent: _intro,
          curve: const Interval(0.1, 0.35, curve: Curves.easeInOutCubic),
        ),
      );

  late final Animation<double> _titleIn = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.3, 0.5, curve: Curves.easeOutCubic),
  );

  late final Animation<double> _taglineIn = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.38, 0.58, curve: Curves.easeOutCubic),
  );

  late final Animation<double> _charge = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.45, 0.95, curve: Curves.easeInOut),
  );

  @override
  void initState() {
    super.initState();
    _intro.addStatusListener((status) {
      if (status == AnimationStatus.completed) _goNext();
    });
    _intro.forward();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _pulse.repeat();
    });
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, _, _) => widget.next,
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge([_intro, _pulse]),
        builder: (context, _) {
          final logoSize = _nativeLogoSize * _logoScale.value;
          // Fill the screen so everything stays centered while the
          // children (pulse rings, logo) change size.
          return SizedBox.expand(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, _logoLift.value),
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      _pulseRing(logoSize, 0.0),
                      _pulseRing(logoSize, 0.5),
                      Image.asset(
                        'assets/images/logo.png',
                        width: logoSize,
                        height: logoSize,
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, 110),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _slideFade(
                        _titleIn,
                        const Text(
                          'EV Finder',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: _darkGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _slideFade(
                        _taglineIn,
                        Text(
                          'Find a charger, anywhere',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Opacity(opacity: _taglineIn.value, child: _chargeBar()),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// An expanding, fading ring behind the logo, like a charging signal.
  Widget _pulseRing(double logoSize, double phase) {
    if (!_pulse.isAnimating) return const SizedBox.shrink();
    final t = (_pulse.value + phase) % 1.0;
    final size = logoSize * (0.7 + 0.6 * Curves.easeOut.transform(t));
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _limeGreen.withValues(alpha: (1 - t) * 0.6),
            width: 3,
          ),
        ),
      ),
    );
  }

  Widget _slideFade(Animation<double> animation, Widget child) {
    return Opacity(
      opacity: animation.value,
      child: Transform.translate(
        offset: Offset(0, 16 * (1 - animation.value)),
        child: child,
      ),
    );
  }

  Widget _chargeBar() {
    const width = 160.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.bolt,
          size: 20,
          color: Color.lerp(Colors.grey.shade400, _darkGreen, _charge.value),
        ),
        const SizedBox(width: 6),
        Container(
          width: width,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.centerLeft,
          child: Container(
            width: width * _charge.value,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(colors: [_darkGreen, _limeGreen]),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          // Single line + scale down so "100%" can never wrap and push
          // the layout around.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${(_charge.value * 100).round()}%',
              maxLines: 1,
              softWrap: false,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _darkGreen,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
