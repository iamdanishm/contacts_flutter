import 'package:contacts/router/bottom_bar.dart';
import 'package:contacts/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      path: "/",
      name: "splash",
      builder: (context, state) => const Splash(),
    ),
    GoRoute(
      path: "/bottom_bar",
      name: "bottomBar",
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const BottomBar(),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
      body: Center(
    child: Text('No route defined for ${state.uri}'),
  )),
);
