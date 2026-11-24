import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../../core/validators.dart';
import '../../services/auth_service.dart';
import '../../widgets/javara_widgets.dart';
import '../../widgets/motion.dart';
import '../home/home_screen.dart';
import 'forgot/forgot_email_screen.dart';
import 'signup_screen.dart';

/// LOG IN: email + password, Lupa Password?, Log In, link ke Sign Up.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.notice});

  /// Pesan sukses opsional (mis. setelah password berhasil diubah).
  final String? notice;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _shake = GlobalKey<ShakeState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();

  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
      await AuthService.instance.signIn(
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
    final showNotice = _error == null && widget.notice != null;
    return AuthScaffold(
      children: [
        StaggerIn(
          index: 0,
          child: Text('Log In', style: JText.serif(28, height: 1.1)),
        ),
        const SizedBox(height: 6),
        StaggerIn(
          index: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat datang kembali!',
                style: JText.serif(14, weight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                'Lanjutkan perjalananmu bersama JAVARA',
                style: JText.serif(12, color: JColors.muted),
              ),
            ],
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
                      hint: 'Email',
                      controller: _email,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      enabled: !_loading,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                    ),
                    const SizedBox(height: 14),
                    AuthField(
                      hint: 'Password',
                      controller: _password,
                      focusNode: _passwordFocus,
                      validator: Validators.passwordRequired,
                      obscure: _obscure,
                      onToggleObscure: () =>
                          setState(() => _obscure = !_obscure),
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      enabled: !_loading,
                      onSubmitted: (_) => _submit(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        StaggerIn(
          index: 3,
          child: Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: _loading
                  ? null
                  : () => Navigator.of(context).push(
                      fadeSlideRoute(
                        ForgotEmailScreen(initialEmail: _email.text.trim()),
                      ),
                    ),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 12,
                ),
                child: Text(
                  'Lupa Password?',
                  style: JText.serif(
                    12,
                    weight: FontWeight.w600,
                    color: JColors.button,
                  ),
                ),
              ),
            ),
          ),
        ),
        InlineMessage(
          message: _error ?? (showNotice ? widget.notice : null),
          success: showNotice,
        ),
        const SizedBox(height: 6),
        StaggerIn(
          index: 4,
          child: JButton(
            label: 'Log In',
            loading: _loading,
            onPressed: _submit,
          ),
        ),
        const SizedBox(height: 20),
        StaggerIn(
          index: 5,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Belum punya akun?',
                  style: JText.serif(12, color: JColors.muted),
                ),
                InkWell(
                  onTap: _loading
                      ? null
                      : () =>
                            Navigator.of(context)
                                .push(fadeSlideRoute(const SignUpScreen())),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 12,
                    ),
                    child: Text(
                      'Sign Up',
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
