// lib/src/pages/auth/signup_page.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _busy = false; // To handle loading state

  // Animation controller for Pikachu's floating effect
  AnimationController? _animationController;
  Animation<Offset>? _animation;

  // URL for the Pikachu sprite
  final String pikachuSpriteUrl =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png';

  @override
  void initState() {
    super.initState();

    // Setup the floating animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: const Offset(0, 0.05),
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
  }

  // --- NEW: Handle Sign-Up Logic ---
  Future<void> _handleSignUp() async {
    setState(() => _busy = true);

    // Perform the sign-up
    final ok = await context.read<AppState>().signUp(
      name: _name.text.trim(),
      email: _email.text.trim(),
      password: _pass.text,
    );

    if (!mounted) return; // Good practice for async gaps

    setState(() => _busy = false);

    if (ok) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hooray! You're now a Trainer!"),
          backgroundColor: Colors.green,
        ),
      );
      // Wait a moment, then navigate to login page
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          // --- FIX: Changed '/' to '/login' ---
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign-up failed. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                if (_animation != null)
                  SlideTransition(
                    position: _animation!,
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Image.network(pikachuSpriteUrl, height: 140, fit: BoxFit.contain),
                    ),
                  ),
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
                          'Become a Trainer',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B4CCA),
                          ),
                        ),
                        const SizedBox(height: 25),
                        _buildTextField(
                          controller: _name,
                          labelText: 'Trainer Name',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
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
                        ),
                        const SizedBox(height: 30),
                        _buildPokeballButton(context),
                        const SizedBox(height: 15),

                        // --- NEW: Link to Login Page ---
                        TextButton(
                          // --- FIX: Changed '/' to '/login' ---
                          onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                          child: const Text('Already have an account? Login'),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
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
          borderSide: const BorderSide(color: Color(0xFFFFDE00), width: 3),
        ),
      ),
    );
  }

  // --- UPDATED: Poké Ball Button now handles loading state ---
  Widget _buildPokeballButton(BuildContext context) {
    return GestureDetector(
      onTap: _busy ? null : _handleSignUp, // Use the new handler
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              height: 40,
              margin: const EdgeInsets.only(bottom: 40),
            ),
            Container(height: 8, color: Colors.black87),

            // Show spinner when busy, otherwise show button
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
