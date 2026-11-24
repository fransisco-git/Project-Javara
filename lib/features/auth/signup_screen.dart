import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../../core/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/javara_widgets.dart';
import '../../widgets/motion.dart';
import '../home/home_screen.dart';

/// SIGN UP: nama lengkap, email, password, link ke Log In.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _shake = GlobalKey<ShakeState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);

    if (!_form.currentState!.validate()) {
      HapticFeedback.lightImpact();
      _shake.currentState?.shake();
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.instance.signUp(
        name: _name.text,
        email: _email.text,
        password: _password.text,
      );
      if (!mounted) return;
      TextInput.finishAutofillContext();
      Navigator.of(context)
          .pushAndRemoveUntil(fadeSlideRoute(const HomeScreen()), (_) => false);
    } on AuthException catch (e) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() {
        _loading = false;
        _error = e.message;
      });
      _shake.currentState?.shake();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      children: [
        StaggerIn(
          index: 0,
          child: Text('Sign Up', style: JText.serif(28, height: 1.1)),
        ),
        const SizedBox(height: 6),
        StaggerIn(
          index: 1,
          child: Text(
            'Buat akun untuk memulai menjelajahi budaya Jawa!',
            style: JText.serif(13, weight: FontWeight.w700, height: 1.35),
          ),
        ),
        const SizedBox(height: 18),
        AutofillGroup(
          child: Form(
            key: _form,
            child: StaggerIn(
              index: 2,
              child: Shake(
                key: _shake,
                child: Column(
                  children: [
                    AuthField(
                      hint: 'Nama lengkap',
                      controller: _name,
                      validator: Validators.name,
                      capitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      enabled: !_loading,
                      onSubmitted: (_) => _emailFocus.requestFocus(),
                    ),
                    const SizedBox(height: 14),
                    AuthField(
                      hint: 'Email',
                      controller: _email,
                      focusNode: _emailFocus,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      enabled: !_loading,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                    ),
                    const SizedBox(height: 14),
                    AuthField(
                      hint: 'Password (minimal 8 karakter)',
                      controller: _password,
                      focusNode: _passwordFocus,
                      validator: Validators.passwordNew,
                      obscure: _obscure,
                      onToggleObscure: () =>
                          setState(() => _obscure = !_obscure),
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      enabled: !_loading,
                      onSubmitted: (_) => _submit(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        InlineMessage(message: _error),
        const SizedBox(height: 18),
        StaggerIn(
          index: 3,
          child: JButton(
            label: 'Sign Up',
            loading: _loading,
            onPressed: _submit,
          ),
        ),
        const SizedBox(height: 20),
        StaggerIn(
          index: 4,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sudah punya akun?',
                  style: JText.serif(12, color: JColors.muted),
                ),
                InkWell(
                  onTap: _loading
                      ? null
                      : () => Navigator.of(context).maybePop(),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 12,
                    ),
                    child: Text(
                      'Log In',
                      style: JText.serif(
                        12,
                        weight: FontWeight.w700,
                        color: JColors.button,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
