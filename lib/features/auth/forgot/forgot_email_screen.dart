import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/transitions.dart';
import '../../../core/validators.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/javara_widgets.dart';
import '../../../widgets/motion.dart';
import 'verify_code_screen.dart';

/// LUPA PASSWORD 1–3: masukkan email, tombol Reset Password.
class ForgotEmailScreen extends StatefulWidget {
  const ForgotEmailScreen({super.key, this.initialEmail});
  final String? initialEmail;

  @override
  State<ForgotEmailScreen> createState() => _ForgotEmailScreenState();
}

class _ForgotEmailScreenState extends State<ForgotEmailScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _email = TextEditingController(
    text: widget.initialEmail,
  );
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_form.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await AuthService.instance.requestReset(_email.text);
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.of(context)
          .push(fadeSlideRoute(VerifyCodeScreen(email: _email.text.trim())));
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
    return AuthScaffold(
      showBack: true,
      children: [
        StaggerIn(
          index: 0,
          child: Text('Lupa Password?', style: JText.serif(26, height: 1.1)),
        ),
        const SizedBox(height: 6),
        StaggerIn(
          index: 1,
          child: Text(
            'Masukkan email yang terdaftar untuk mereset password',
            style: JText.serif(12, color: JColors.muted, height: 1.4),
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _form,
          child: StaggerIn(
            index: 2,
            child: AuthField(
              hint: 'Email',
              controller: _email,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              enabled: !_loading,
              onSubmitted: (_) => _submit(),
            ),
          ),
        ),
        InlineMessage(message: _error),
        const SizedBox(height: 22),
        StaggerIn(
          index: 3,
          child: JButton(
            label: 'Reset Password',
            loading: _loading,
            onPressed: _submit,
          ),
        ),
      ],
    );
  }
}
