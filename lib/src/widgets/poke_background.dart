import 'package:flutter/material.dart';

class PokeBackground extends StatelessWidget {
  final Widget child;
  const PokeBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1.0, -1.0),
          end: Alignment(1.0, 1.0),
          colors: [
            Color(0xFFEDE7F6), // soft purple
            Color(0xFFE1F5FE), // sky
            Color(0xFFFFF8E1), // warm
          ],
          stops: [0, .55, 1],
        ),
      ),
      child: child,
    );
  }
}
