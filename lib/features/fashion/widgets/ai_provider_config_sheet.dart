import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme.dart';
import '../../../services/ai_cultural_assistant_service.dart';

/// Menampilkan bottom sheet pengaturan koneksi AI (Gemini, Groq, OpenRouter, Pollinations, OpenAI).
Future<bool?> showAiProviderConfigSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AiProviderConfigSheet(),
  );
}

class _AiProviderConfigSheet extends StatefulWidget {
  const _AiProviderConfigSheet();

  @override
  State<_AiProviderConfigSheet> createState() => _AiProviderConfigSheetState();
}

class _AiProviderConfigSheetState extends State<_AiProviderConfigSheet> {
  late final TextEditingController _keyController;
  late final TextEditingController _modelController;

  AiProviderMode _selectedProvider = AiProviderMode.auto;
  bool _obscureKey = true;
  bool _showAdvancedModel = false;
  bool _isTesting = false;
  String? _statusMessage;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    final service = AiCulturalAssistantService.instance;
    _keyController = TextEditingController(
      text: service.hasRuntimeApiKey ? service.effectiveApiKey : '',
    );
    _modelController = TextEditingController(text: service.savedRuntimeModel);
    _selectedProvider = service.savedRuntimeProvider;
    if (service.savedRuntimeModel.isNotEmpty) {
      _showAdvancedModel = true;
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  AiProviderMode get _effectiveSelection {
    if (_selectedProvider != AiProviderMode.auto) return _selectedProvider;
    final typed = _keyController.text.trim();
    if (typed.isEmpty) return AiProviderMode.auto;
    return AiCulturalAssistantService.detectProviderFromKey(typed);
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final clip = data?.text?.trim() ?? '';
    if (!mounted) return;
    if (clip.isEmpty) {
      setState(() {
        _statusMessage = 'Clipboard kosong. Salin API Key Anda terlebih dahulu.';
        _isError = true;
      });
      return;
    }
    setState(() {
      _keyController.text = clip;
      _statusMessage = null;
      _isError = false;
    });
  }

  Future<void> _openGoogleAiStudio() async {
    final uri = Uri.parse('https://aistudio.google.com/apikey');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _statusMessage =
            'Buka https://aistudio.google.com/apikey di browser untuk membuat key gratis.';
        _isError = false;
      });
    }
  }

  Future<void> _handleTestAndSave() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _statusMessage = 'Masukkan API Key atau tutup untuk pakai Live AI Publik.';
        _isError = true;
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _statusMessage = 'Menguji sambungan langsung ke server AI...';
      _isError = false;
    });

    final result = await AiCulturalAssistantService.instance
        .testAndSaveRuntimeConfig(
      apiKey: key,
      provider: _selectedProvider,
      model: _modelController.text.trim(),
    );

    if (!mounted) return;
    if (result.ok) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          backgroundColor: const Color(0xFF1F2B1D),
          behavior: SnackBarBehavior.floating,
          content: Text(
            result.message,
            style: const TextStyle(color: Color(0xFFFAF6F0), fontSize: 12.5),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isTesting = false;
      _statusMessage = result.message;
      _isError = true;
    });
  }

  Future<void> _handleClearKey() async {
    await AiCulturalAssistantService.instance.clearRuntimeConfig();
    if (!mounted) return;
    _keyController.clear();
    _modelController.clear();
    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF241A14),
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Beralih ke mode Live AI Publik (tanpa API Key).',
          style: TextStyle(color: Color(0xFFFAF6F0), fontSize: 12.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final service = AiCulturalAssistantService.instance;
    final detected = _effectiveSelection;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF17120F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: Color(0x55DFB76C), width: 0.9),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 18 + bottomInset),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0x44DFB76C),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Koneksi Mesin AI JAVARA',
                  style: JText.serif(
                    18,
                    weight: FontWeight.w700,
                    color: const Color(0xFFFAF6F0),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  service.isConfigured
                      ? 'Status aktif: ${service.activeEngineStatusLabel}'
                      : 'Tanpa API Key, JAVARA memakai Live AI Publik (gratis, 1 pesan / 45 dtk) + Pustaka Budaya & Wikipedia. Pasang API Key pribadi di bawah untuk akses instan tanpa jeda.',
                  style: JText.sans(
                    12,
                    color: const Color(0xFFCBBBA8),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),

                // Pilihan Provider
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final mode in AiProviderMode.values)
                      ChoiceChip(
                        label: Text(
                          mode.label.split('(').first.trim(),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: _selectedProvider == mode
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: _selectedProvider == mode
                                ? const Color(0xFF181310)
                                : const Color(0xFFE4C590),
                          ),
                        ),
                        selected: _selectedProvider == mode,
                        selectedColor: const Color(0xFFDFB76C),
                        backgroundColor: const Color(0xFF241C17),
                        side: const BorderSide(
                          color: Color(0x44DFB76C),
                          width: 0.8,
                        ),
                        onSelected: _isTesting
                            ? null
                            : (_) => setState(() => _selectedProvider = mode),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Input API Key
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF241C17),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0x55DFB76C),
                      width: 0.8,
                    ),
                  ),
                  child: TextField(
                    controller: _keyController,
                    obscureText: _obscureKey,
                    enabled: !_isTesting,
                    style: const TextStyle(
                      color: Color(0xFFFAF6F0),
                      fontSize: 13,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'API Key (AIza..., gsk_..., sk-or-...)',
                      labelStyle: const TextStyle(
                        color: Color(0xFF9E8E80),
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Tempel Key',
                            icon: const Icon(
                              Icons.content_paste_rounded,
                              size: 18,
                              color: Color(0xFFDFB76C),
                            ),
                            onPressed: _isTesting ? null : _pasteFromClipboard,
                          ),
                          IconButton(
                            tooltip:
                                _obscureKey ? 'Tampilkan' : 'Sembunyikan',
                            icon: Icon(
                              _obscureKey
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: const Color(0xFFB8A898),
                            ),
                            onPressed: () =>
                                setState(() => _obscureKey = !_obscureKey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (_keyController.text.trim().isNotEmpty &&
                    _selectedProvider == AiProviderMode.auto) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Terdeteksi otomatis: ${detected.label} (Model: ${detected.defaultModel})',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFE4C590),
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Toggle nama model opsional + link AI Studio gratis
                Row(
                  children: [
                    Flexible(
                      child: TextButton(
                        onPressed: _openGoogleAiStudio,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(48, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Buat Key Gemini Gratis (AI Studio) →',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFFDFB76C),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => setState(
                          () => _showAdvancedModel = !_showAdvancedModel),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(48, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _showAdvancedModel ? 'Tutup Model' : 'Atur Model',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFFAFA08F),
                        ),
                      ),
                    ),
                  ],
                ),

                if (_showAdvancedModel) ...[
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF241C17),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0x33DFB76C),
                        width: 0.8,
                      ),
                    ),
                    child: TextField(
                      controller: _modelController,
                      enabled: !_isTesting,
                      style: const TextStyle(
                        color: Color(0xFFFAF6F0),
                        fontSize: 12.5,
                      ),
                      decoration: InputDecoration(
                        labelText:
                            'Nama Model (Kosongkan untuk default: ${detected.defaultModel})',
                        labelStyle: const TextStyle(
                          color: Color(0xFF9E8E80),
                          fontSize: 11.5,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ],

                if (_statusMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isError
                          ? const Color(0x28F87171)
                          : const Color(0x22DFB76C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isError
                            ? const Color(0x66F87171)
                            : const Color(0x55DFB76C),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      _statusMessage!,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: _isError
                            ? const Color(0xFFFCA5A5)
                            : const Color(0xFFE4C590),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDFB76C),
                      foregroundColor: const Color(0xFF181310),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isTesting ? null : _handleTestAndSave,
                    child: _isTesting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF181310),
                            ),
                          )
                        : const Text(
                            'Uji & Hubungkan AI',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),

                if (service.hasRuntimeApiKey) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: TextButton(
                      onPressed: _isTesting ? null : _handleClearKey,
                      child: const Text(
                        'Putuskan Key & Pakai Mode Publik Gratis',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFAFA08F),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
