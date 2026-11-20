import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';

/// Logo JAVARA: Tipografi adiluhung budaya Jawa Tengah (Aksara Jawa & Serif Elegan),
/// bersih tanpa stempel bundar "Warisane Jowo" yang terkesan AI slop.
class JavaraLogo extends StatelessWidget {
  const JavaraLogo({super.key, this.size = 110});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'ꦗ ꦮ ꦫ',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFFC79B3A),
            fontWeight: FontWeight.w700,
            letterSpacing: 8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'JAVARA',
          style: JText.serif(
            24,
            weight: FontWeight.w700,
            color: JColors.ink,
          ).copyWith(letterSpacing: 4),
        ),
        const SizedBox(height: 3),
        Container(
          width: 40,
          height: 1.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            gradient: const LinearGradient(
              colors: [
                Colors.transparent,
                Color(0xFFC79B3A),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Kerangka halaman auth: latar, tombol kembali (opsional), logo, lalu isi.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.children,
    this.showBack = false,
    this.logoSize = 108,
  });

  final List<Widget> children;
  final bool showBack;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: JColors.sand,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: JBackground(
          child: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(28, 4, 28, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showBack)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            tooltip: 'Kembali',
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                            ),
                            color: JColors.ink,
                          ),
                        )
                      else
                        const SizedBox(height: 12),
                      Center(child: JavaraLogo(size: logoSize)),
                      const SizedBox(height: 20),
                      ...children,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Input berlatar pasir, tanpa garis; garis emas saat fokus.
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.hint,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.autofillHints,
    this.onChanged,
    this.obscure = false,
    this.onToggleObscure,
    this.enabled = true,
    this.capitalization = TextCapitalization.none,
  });

  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final bool enabled;
  final TextCapitalization capitalization;

  OutlineInputBorder _border([Color? c, double w = 1.5]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: c == null ? BorderSide.none : BorderSide(color: c, width: w),
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: capitalization,
      autofillHints: autofillHints,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: JText.serif(14),
      cursorColor: JColors.button,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: JColors.field,
        hintText: hint,
        hintStyle: JText.serif(13, color: JColors.hint),
        errorStyle: JText.serif(11, color: JColors.error, height: 1.3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        suffixIcon: onToggleObscure == null
            ? null
            : IconButton(
                onPressed: onToggleObscure,
                tooltip: obscure
                    ? 'Tampilkan password'
                    : 'Sembunyikan password',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                color: JColors.hint,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (c, a) => ScaleTransition(
                    scale: a,
                    child: FadeTransition(opacity: a, child: c),
                  ),
                  child: Icon(
                    obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    key: ValueKey(obscure),
                    size: 19,
                  ),
                ),
              ),
        enabledBorder: _border(),
        disabledBorder: _border(),
        focusedBorder: _border(JColors.gold),
        errorBorder: _border(JColors.error, 1),
        focusedErrorBorder: _border(JColors.error),
      ),
    );
  }
}

enum JButtonKind { dark, gold }

/// Tombol 46px: efek tekan, haptic, spinner saat loading.
class JButton extends StatefulWidget {
  const JButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.kind = JButtonKind.dark,
  });

  final String label;
  final VoidCallback? onPressed; // null => nonaktif
  final bool loading;
  final JButtonKind kind;

  @override
  State<JButton> createState() => _JButtonState();
}

class _JButtonState extends State<JButton> {
  bool _down = false;
  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  Widget build(BuildContext context) {
    final gold = widget.kind == JButtonKind.gold;
    final bg = gold ? JColors.gold : JColors.button;
    // Teks gelap di atas emas supaya kontras cukup (krem di atas emas hanya ±2:1).
    final fg = gold ? JColors.night : JColors.cream;

    return AnimatedScale(
      scale: _down ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: widget.onPressed == null ? 0.45 : 1,
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: bg,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: InkWell(
            onTap: _enabled
                ? () {
                    HapticFeedback.selectionClick();
                    widget.onPressed!();
                  }
                : null,
            onHighlightChanged: (v) => setState(() => _down = v && _enabled),
            splashColor: fg.withAlpha(30),
            highlightColor: Colors.transparent,
            child: SizedBox(
              height: 46,
              width: double.infinity,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: widget.loading
                      ? SizedBox(
                          key: const ValueKey('loading'),
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation(fg),
                          ),
                        )
                      : Text(
                          widget.label,
                          key: const ValueKey('label'),
                          style: JText.serif(
                            14,
                            weight: FontWeight.w600,
                            color: fg,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol ikon Google / Apple.
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final Widget icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: JColors.field,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onPressed!();
                },
          child: SizedBox(height: 44, child: Center(child: icon)),
        ),
      ),
    );
  }
}

/// Ikon Google sederhana (huruf G). Ganti dengan logo resmi dari assets jika ada.
class GoogleGlyph extends StatelessWidget {
  const GoogleGlyph({super.key});
  @override
  Widget build(BuildContext context) => const Text(
    'G',
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: Color(0xFF4285F4),
    ),
  );
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(height: 1, color: JColors.muted)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('atau', style: JText.serif(12, color: JColors.muted)),
        ),
        const Expanded(child: Divider(height: 1, color: JColors.muted)),
      ],
    );
  }
}

/// Pesan error / sukses yang muncul dan hilang dengan animasi.
class InlineMessage extends StatelessWidget {
  const InlineMessage({super.key, required this.message, this.success = false});
  final String? message;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final color = success ? JColors.success : JColors.error;
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: message == null
            ? const SizedBox(width: double.infinity)
            : Container(
                key: ValueKey(message),
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: success ? JColors.successSoft : JColors.errorSoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: success ? JColors.successLine : JColors.errorLine,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      success
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      size: 18,
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message!,
                        style: JText.serif(
                          12,
                          weight: FontWeight.w600,
                          color: color,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

void showJavaraSnack(BuildContext context, String message) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: JColors.night,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
      content: Text(message, style: JText.serif(13, color: JColors.cream)),
    ),
  );
}

/// Kotak kode verifikasi (hijau sage). Satu TextField tersembunyi menampung ketikan,
/// jadi tempel (paste) dan isi otomatis dari SMS/email juga bisa.
class CodeInput extends StatefulWidget {
  const CodeInput({
    super.key,
    required this.length,
    required this.onChanged,
    this.hasError = false,
  });
  final int length;
  final ValueChanged<String> onChanged;
  final bool hasError;

  @override
  State<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  final _c = TextEditingController();
  final _f = FocusNode();

  @override
  void initState() {
    super.initState();
    _f.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _c.dispose();
    _f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _c.text;
    return Semantics(
      textField: true,
      label: 'Kode verifikasi ${widget.length} digit',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _f.requestFocus(),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(widget.length, (i) {
                final filled = i < text.length;
                final active =
                    _f.hasFocus && i == text.length.clamp(0, widget.length - 1);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 50,
                  height: 58,
                  decoration: BoxDecoration(
                    color: JColors.sage,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.hasError
                          ? JColors.error
                          : active
                          ? JColors.gold
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: AnimatedScale(
                    scale: filled ? 1 : 0.4,
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOutBack,
                    child: AnimatedOpacity(
                      opacity: filled ? 1 : 0,
                      duration: const Duration(milliseconds: 120),
                      child: Text(
                        filled ? text[i] : '',
                        style: JText.serif(
                          24,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: _c,
                  focusNode: _f,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                  enableInteractiveSelection: false,
                  showCursor: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                  ),
                  onChanged: (v) {
                    setState(() {});
                    widget.onChanged(v);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Petunjuk kode demo, hanya tampil saat mode debug.
class DemoCodeHint extends StatelessWidget {
  const DemoCodeHint({super.key, required this.code});
  final String code;
  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        'Mode demo — kode: $code',
        style: JText.serif(11, color: JColors.muted, style: FontStyle.italic),
      ),
    );
  }
}
