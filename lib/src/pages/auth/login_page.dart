import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import 'dart:math' as math; // For animations

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _busy = false;

  // --- NEW: FocusNode and Animation for Pichu's sparkle effect ---
  final FocusNode _passwordFocusNode = FocusNode();
  AnimationController? _sparkleController;

  // Animation controller for Pichu's subtle floating effect
  AnimationController? _floatAnimationController;
  Animation<Offset>? _floatAnimation;

  // URL for the Pichu sprite
  final String pichuSpriteUrl =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/172.png';

  @override
  void initState() {
    super.initState();

    // Listener for password field focus to trigger sparkle
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        _sparkleController?.forward(from: 0.0);
      }
    });

    // Setup the floating animation
    _floatAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: const Offset(0, 0.05),
    ).animate(CurvedAnimation(
      parent: _floatAnimationController!,
      curve: Curves.easeInOut,
    ));

    // Setup the sparkle animation controller
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
  }

  void _go(String r) => Navigator.of(context).pushReplacementNamed(r);

  Future<void> _handleLogin() async {
    setState(() => _busy = true);
    final ok = await context.read<AppState>().signIn(
      email: _email.text.trim(),
      password: _pass.text,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      _go('/home-choice');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed! Check your credentials.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _floatAnimationController?.dispose();
    _sparkleController?.dispose();
    _passwordFocusNode.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // RESTORED: Green and teal gradient to match the signup page
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF81C784), // A light, grassy green
              Color(0xFF4DB6AC), // A soft teal
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Animated Pichu on top ---
                if (_floatAnimation != null)
                  SlideTransition(
                    position: _floatAnimation!,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pichu Image
                        Image.network(
                          pichuSpriteUrl,
                          height: 140,
                          fit: BoxFit.contain,
                        ),
                        // Sparkle Animation on Cheeks
                        _Sparkle(controller: _sparkleController!),
                      ],
                    ),
                  ),
                // --- Main Login Card ---
                Card(
                  color: Colors.white.withOpacity(0.95),
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Welcome Trainer',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            // RESTORED: Pokémon blue color
                            color: Color(0xFF3B4CCA),
                          ),
                        ),
                        const SizedBox(height: 25),
                        _buildTextField(
                          controller: _email,
                          labelText: 'Email',
                          icon: Icons.alternate_email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _pass,
                          labelText: 'Password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          focusNode: _passwordFocusNode, // Assign FocusNode
                        ),
                        const SizedBox(height: 20),
                        _buildPokeballLoginButton(),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pushReplacementNamed('/signup'),
                              child: const Text('Create Account'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pushNamed('/forgot'),
                              child: const Text('Forgot Password?'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // RESTORED: This widget is styled to match the signup page
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    FocusNode? focusNode,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      focusNode: focusNode,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF3B4CCA)),
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: const BorderSide(color: Color(0xFFFFDE00), width: 3), // Pokémon Yellow
        ),
      ),
    );
  }

  // RESTORED: The custom Poké Ball button from the signup page
  Widget _buildPokeballLoginButton() {
    return GestureDetector(
      onTap: _busy ? null : _handleLogin,
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE53935), // Pokémon Red
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              ),
              height: 40,
              margin: const EdgeInsets.only(bottom: 40),
            ),
            Container(height: 8, color: Colors.black87),
            _busy
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF3B4CCA)),
            )
                : Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.black87, width: 4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- NEW HELPER WIDGET FOR PICHU'S SPARKLE ---
class _Sparkle extends AnimatedWidget {
  const _Sparkle({required AnimationController controller})
      : super(listenable: controller);

  Animation<double> get _progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Left Sparkle
        _buildSparkle(offset: const Offset(-25, 20)),
        // Right Sparkle
        _buildSparkle(offset: const Offset(25, 20), isReflected: true),
      ],
    );
  }

  Widget _buildSparkle({required Offset offset, bool isReflected = false}) {
    final double size = 20.0 * (1 - _progress.value); // Shrinks
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: (isReflected ? -1 : 1) * math.pi * 2 * _progress.value, // Spins
        child: Opacity(
          opacity: 1.0 - _progress.value, // Fades out
          child: Icon(
            Icons.star, // CORRECTED: Replaced non-existent 'spark' with 'star'
            color: const Color(0xFFFFDE00), // Pokémon Yellow
            size: size,
            shadows: const [
              Shadow(color: Colors.orange, blurRadius: 8),
            ],
          ),
        ),
      ),
    );
  }
}
