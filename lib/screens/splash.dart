import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Splash extends ConsumerStatefulWidget {
  const Splash({super.key});

  @override
  ConsumerState createState() => _SplashState();
}

class _SplashState extends ConsumerState<Splash> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      context.pushReplacementNamed("bottomBar");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 160,
          width: 160,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: Transform.flip(
            flipX: true,
            child: Icon(
              Icons.phone_enabled_rounded,
              size: 90,
              color: Theme.of(context).primaryColorDark,
              shadows: [
                Shadow(
                  color: Theme.of(context).primaryColorDark.withOpacity(0.3),
                  offset: const Offset(0, -8),
                  blurRadius: 5,
                ),
              ],
            ).animate().shake(duration: 2.seconds, hz: 5, curve: Curves.linear),
          ),
        ).animate().fadeIn(duration: 500.ms, curve: Curves.easeIn),
      ),
    );
  }
}
