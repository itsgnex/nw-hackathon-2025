import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();
  bool _busy = false;

  Future<void> _send() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reset link sent to ${_email.text.trim()}')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('We’ll email a reset link.', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                TextField(controller: _email, decoration: const InputDecoration(prefixIcon: Icon(Icons.alternate_email), labelText: 'Email')),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _busy ? null : _send,
                  icon: _busy ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send),
                  label: const Text('Send reset link'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
