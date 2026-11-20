import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/transitions.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/javara_widgets.dart';
import '../../../widgets/motion.dart';
import 'new_password_screen.dart';

/// LUPA PASSWORD 4–6: "Check Email Kamu", kotak kode, tombol Verify Kode.
class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key, required this.email});
  final String email;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  static const _cooldown = 30;

  String _code = '';
  bool _loading = false;
  String? _error;
  int _seconds = _cooldown;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = _cooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      if (_seconds <= 1) {
        t.cancel();
        setState(() => _seconds = 0);
      } else {
        setState(() => _seconds--);
      }
    });
  }

  Future<void> _resend() async {
    await AuthService.instance.requestReset(widget.email);
    if (!mounted) return;
    _startTimer();
    showJavaraSnack(context, 'Kode baru sudah dikirim ke emailmu.');
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await AuthService.instance.verifyCode(widget.email, _code);
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.of(context)
          .push(fadeSlideRoute(NewPasswordScreen(email: widget.email)));
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final complete = _code.length == AuthService.codeLength;
    return AuthScaffold(
      showBack: true,
      children: [
        StaggerIn(
          index: 0,
          child: Text('Check Email Kamu', style: JText.serif(26, height: 1.1)),
        ),
        const SizedBox(height: 6),
        StaggerIn(
          index: 1,
          child: Text(
            'Kami udah ngirim link atur ulang ke contact ${widget.email} masukkan ${AuthService.codeLength} digit kode yang ada di email',
            style: JText.serif(12, color: JColors.muted, height: 1.4),
          ),
        ),
        const SizedBox(height: 22),
        StaggerIn(
          index: 2,
          child: CodeInput(
            length: AuthService.codeLength,
            hasError: _error != null,
            onChanged: (v) => setState(() {
              _code = v;
              _error = null;
            }),
          ),
        ),
        const DemoCodeHint(code: AuthService.demoCode),
        InlineMessage(message: _error),
        const SizedBox(height: 22),
        StaggerIn(
          index: 3,
          child: JButton(
            label: 'Verify Kode',
            loading: _loading,
            onPressed: complete ? _verify : null,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: _seconds > 0
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Kirim ulang kode dalam $_seconds detik',
                    style: JText.serif(12, color: JColors.muted),
                  ),
                )
              : InkWell(
                  onTap: _resend,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    child: Text(
                      'Kirim ulang kode',
                      style: JText.serif(
                        12,
                        weight: FontWeight.w700,
                        color: JColors.button,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
