import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ai_chat_app/UI_Theme/home_page.dart';

class ProSplashScreen extends StatefulWidget {
  const ProSplashScreen({super.key});

  @override
  State<ProSplashScreen> createState() => _ProSplashScreenState();
}

class _ProSplashScreenState extends State<ProSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoRotate;
  late final Animation<double> _contentFade;
  late final Animation<double> _chipsSlide;
  late final Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _logoScale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    );

    _logoRotate = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _contentFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
    );

    _chipsSlide = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOutBack),
    );

    _footerFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 650),
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: const HomePage(),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LinearGradient _backgroundGradient(double t) {
    const c1 = Color(0xFFB39DDB);
    const c2 = Color(0xFF90CAF9);
    const c3 = Color(0xFF6D7CF4);

    double wave(double v) => (sin(v) + 1) / 2;

    final topMix = wave(t * 2 * pi);
    final bottomMix = wave((t + 0.35) * 2 * pi);

    Color mix(Color a, Color b, double v) => Color.fromARGB(
      255,
      (a.red + (b.red - a.red) * v).round(),
      (a.green + (b.green - a.green) * v).round(),
      (a.blue + (b.blue - a.blue) * v).round(),
    );

    final topColor = mix(c1, c2, topMix);
    final bottomColor = mix(c3, c2, bottomMix);

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [topColor, bottomColor],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;

        return Scaffold(
          body: Stack(
            children: [
              // Animated gradient background
              Container(
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  gradient: _backgroundGradient(t),
                ),
              ),

              // Floating glass blobs
              _blob(
                size: size,
                baseX: -0.2,
                baseY: -0.15,
                radius: 180,
                t: t,
                phase: 0.0,
              ),
              _blob(
                size: size,
                baseX: 1.1,
                baseY: 0.25,
                radius: 200,
                t: t,
                phase: 0.4,
              ),
              _blob(
                size: size,
                baseX: 0.25,
                baseY: 1.1,
                radius: 220,
                t: t,
                phase: 0.8,
              ),

              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: size.height),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // TOP ROW: pill
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              margin: const EdgeInsets.only(top: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.26),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Powered by SmileAI",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // MIDDLE: hero + chips
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FadeTransition(
                                opacity: _contentFade,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ScaleTransition(
                                      scale: Tween<double>(
                                        begin: 0.9,
                                        end: 1.05,
                                      ).animate(_logoScale),
                                      child: RotationTransition(
                                        turns: Tween<double>(
                                          begin: -0.015,
                                          end: 0.015,
                                        ).animate(_logoRotate),
                                        child: _HeroMark(),
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    const Text(
                                      "SmileAI",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.9,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Beautifully simple AI conversations.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              AnimatedBuilder(
                                animation: _chipsSlide,
                                builder: (context, _) {
                                  final raw = _chipsSlide.value;
                                  final clamped =
                                  raw.clamp(0.0, 1.0) as double;
                                  final eased = Curves.easeOut.transform(
                                    clamped,
                                  );
                                  final slide = 1 - eased;

                                  return Transform.translate(
                                    offset: Offset(0, 24 * slide),
                                    child: Opacity(
                                      opacity: clamped,
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: const [
                                          _FeatureChip(
                                            icon: Icons
                                                .chat_bubble_outline_rounded,
                                            label: "Natural chat",
                                          ),
                                          _FeatureChip(
                                            icon: Icons
                                                .tips_and_updates_outlined,
                                            label: "Smart ideas",
                                          ),
                                          _FeatureChip(
                                            icon: Icons
                                                .emoji_emotions_outlined,
                                            label: "Friendly tone",
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          // BOTTOM: loading + caption
                          FadeTransition(
                            opacity: _footerFade,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 24),
                                const _LoadingDots(),
                                const SizedBox(height: 14),
                                Text(
                                  "Preparing your conversation space...",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "SmileAI • Designed for everyday use",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.72),
                                    fontSize: 11,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _blob({
    required Size size,
    required double baseX,
    required double baseY,
    required double radius,
    required double t,
    required double phase,
  }) {
    final wave = sin(2 * pi * (t + phase)) * 0.05;
    final dx = baseX + wave;
    final dy = baseY + wave * 0.7;

    return Positioned(
      left: dx * size.width,
      top: dy * size.height,
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.12),
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: 0.6,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.15),
              blurRadius: 40,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

/// Abstract brand mark – fixed version
class _HeroMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6D7CF4),
            Color(0xFF8E5EC7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.35),
          width: 1.6,
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "S",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Safe bottom line instead of crashing borderRadius
                Container(
                  width: 40,
                  height: 2.5,
                  color: Colors.white.withOpacity(0.9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withOpacity(0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          _Dot(delay: 0),
          SizedBox(width: 4),
          _Dot(delay: 0.2),
          SizedBox(width: 4),
          _Dot(delay: 0.4),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final double delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    Future.delayed(
      Duration(milliseconds: (widget.delay * 1000).round()),
          () {
        if (!mounted) return;
        _controller.repeat(reverse: true);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.7, end: 1.2).animate(_scale),
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF6D7CF4),
        ),
      ),
    );
  }
}
