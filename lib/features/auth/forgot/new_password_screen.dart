import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../../core/transitions.dart';
import '../../../core/validators.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/javara_widgets.dart';
import '../../../widgets/motion.dart';
import '../login_screen.dart';

/// LUPA PASSWORD 7+: buat password baru.
/// CATATAN: teks layar ini DIPERKIRAKAN (saya hanya melihat potongan kecil di screenshot).
/// Sesuaikan dengan kata-kata di Figma.
class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key, required this.email});
  final String email;

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  final _confirmFocus = FocusNode();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _pass.dispose();
    _confirm.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_form.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await AuthService.instance.resetPassword(widget.email, _pass.text);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        fadeSlideRoute(
          const LoginScreen(
            notice: 'Password berhasil diubah. Silakan Log In.',
          ),
        ),
        (_) => false,
      );
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
          child: Text('Password Baru', style: JText.serif(26, height: 1.1)),
        ),
        const SizedBox(height: 6),
        StaggerIn(
          index: 1,
          child: Text(
            'Buat password baru untuk akunmu. Minimal 8 karakter.',
            style: JText.serif(12, color: JColors.muted, height: 1.4),
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _form,
          child: StaggerIn(
            index: 2,
            child: Column(
              children: [
                AuthField(
                  hint: 'Password baru',
                  controller: _pass,
                  validator: Validators.passwordNew,
                  obscure: _obscure,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  enabled: !_loading,
                  onSubmitted: (_) => _confirmFocus.requestFocus(),
                ),
                const SizedBox(height: 14),
                AuthField(
                  hint: 'Ulangi password baru',
                  controller: _confirm,
                  focusNode: _confirmFocus,
                  validator: (v) => Validators.confirm(v, _pass.text),
                  obscure: _obscure,
                  textInputAction: TextInputAction.done,
                  enabled: !_loading,
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
        ),
        InlineMessage(message: _error),
        const SizedBox(height: 22),
        StaggerIn(
          index: 3,
          child: JButton(
            label: 'Simpan Password',
            loading: _loading,
            onPressed: _submit,
          ),
        ),
      ],
    );
  }
}
