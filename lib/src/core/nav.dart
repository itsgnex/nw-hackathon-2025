import 'package:flutter/material.dart';

PageRouteBuilder<T> fade<T>(Widget page) => PageRouteBuilder(
  transitionDuration: const Duration(milliseconds: 280),
  pageBuilder: (_, __, ___) => page,
  transitionsBuilder: (_, Animation<double> a, __, Widget child) =>
      FadeTransition(opacity: a, child: child),
);

PageRouteBuilder<T> slideUp<T>(Widget page) => PageRouteBuilder(
  transitionDuration: const Duration(milliseconds: 380),
  reverseTransitionDuration: const Duration(milliseconds: 280),
  pageBuilder: (_, __, ___) => page,
  transitionsBuilder: (_, Animation<double> a, __, Widget child) {
    final curved = CurvedAnimation(parent: a, curve: Curves.easeInOutCubic);
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, .06), end: Offset.zero).animate(curved),
      child: FadeTransition(opacity: curved, child: child),
    );
  },
);

PageRouteBuilder<T> fadeScale<T>(Widget page) => PageRouteBuilder(
  transitionDuration: const Duration(milliseconds: 380),
  reverseTransitionDuration: const Duration(milliseconds: 280),
  pageBuilder: (_, __, ___) => page,
  transitionsBuilder: (_, Animation<double> a, __, Widget child) {
    final curved = CurvedAnimation(parent: a, curve: Curves.easeInOutCubicEmphasized);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(scale: Tween<double>(begin: .98, end: 1).animate(curved), child: child),
    );
  },
);
