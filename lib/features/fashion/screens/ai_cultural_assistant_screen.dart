import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme.dart';
import '../../../core/transitions.dart';
import '../../../services/ai_cultural_assistant_service.dart';
import '../widgets/ai_provider_config_sheet.dart';
import 'ai_fashion_studio_screen.dart';
import 'clothing_detail_screen.dart';
import 'javanese_wardrobe_screen.dart';

/// Screen 09 — AI Cultural Fashion Assistant (Abdi Pakar Busana JAVARA)
///
/// Asisten kurasi cerdas berbasis kecerdasan buatan dan basis data terverifikasi
/// adat istiadat Jawa Tengah, dilengkapi function calling untuk mengontrol lemari 3D.
class AiCulturalAssistantScreen extends StatefulWidget {
  const AiCulturalAssistantScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  State<AiCulturalAssistantScreen> createState() =>
      _AiCulturalAssistantScreenState();
}

class _AiCulturalAssistantScreenState extends State<AiCulturalAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<AssistantChatMessage> _messages = [];
  bool _isTyping = false;

  static const List<String> _suggestedPrompts = [
    'Rekomendasi busana pernikahan adat Surakarta',
    'Makna filosofis Batik Parang Barong',
    'Pakem blangkon mondholan trepes Solo',
    'Perbedaan Beskap Langenharjan dan Sikepan',
  ];

  @override
  void initState() {
    super.initState();
    // Sinkronisasi sesi baru & muat konfigurasi runtime API Key bila tersimpan
    AiCulturalAssistantService.instance.clearSession();
    _initRuntimeConfig();

    // Pesan Pembuka Hangat dari Abdi Pakar Busana
    _messages.add(_createWelcomeMessage());

    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleSendMessage(widget.initialQuery!.trim());
        }
      });
    }
  }

  Future<void> _initRuntimeConfig() async {
    await AiCulturalAssistantService.instance.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  AssistantChatMessage _createWelcomeMessage() {
    return AssistantChatMessage(
      id: 'init_welcome_${DateTime.now().millisecondsSinceEpoch}',
      role: AssistantRole.assistant,
      text:
          'Sugeng rawuh ing JAVARA. Kula Abdi Pakar Busana, siap mbiyantu panjenengan nyinau lan milih busana adat Jawa Tengah ingkang laras kaliyan tatakrama karaton.\n\nApa sing pengin panjenengan ngerteni dina iki? Panjenengan bisa takon babagan busana manten, pakem keris, utawa filosofi batik.',
      timestamp: DateTime.now(),
      sourceReference: 'Kurasi Karaton Surakarta Hadiningrat',
    );
  }

  void _resetConversation() {
    if (_isTyping) return;
    HapticFeedback.lightImpact();
    AiCulturalAssistantService.instance.clearSession();
    setState(() {
      _messages
        ..clear()
        ..add(_createWelcomeMessage());
    });
  }

  Future<void> _openConfigSheet() async {
    HapticFeedback.lightImpact();
    final updated = await showAiProviderConfigSheet(context);
    if (updated == true && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    AiCulturalAssistantService.instance.clearSession();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage([String? predefinedText]) async {
    if (_isTyping) return;

    final text = predefinedText ?? _textController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    if (predefinedText == null) _textController.clear();

    final userMsg = AssistantChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: AssistantRole.user,
      text: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final reply = await AiCulturalAssistantService.instance.sendMessage(
        text,
        history: _messages,
      );
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(reply);
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            AssistantChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              role: AssistantRole.assistant,
              text:
                  'Nyuwun pangapunten, wonten pambengan sambungan. Mangga nyobi malih sakmenika utawi pirsani kurasi busana ing katalog.',
              timestamp: DateTime.now(),
              sourceReference: 'Kurasi Karaton Surakarta Hadiningrat',
            ),
          );
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = AiCulturalAssistantService.instance;
    final hasCustomKey = service.isConfigured;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFFE4C590), size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _openConfigSheet,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Abdi Pakar Busana JAVARA',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFAF6F0),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: hasCustomKey
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFFDFB76C),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      service.activeEngineStatusLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            const Color(0xFFE4C590).withValues(alpha: 0.88),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Atur Koneksi AI',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.vpn_key_outlined,
                  color: Color(0xFFE4C590),
                  size: 20,
                ),
                if (hasCustomKey)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _openConfigSheet,
          ),
          IconButton(
            tooltip: 'Mulai Sesi Baru',
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFFE4C590),
              size: 20,
            ),
            onPressed: _isTyping ? null : _resetConversation,
          ),
        ],
      ),
      body: JBackground(
        variant: HeritageBackgroundVariant.kuis,
        child: Column(
          children: [
            // 1. DAFTAR PESAN PERCAKAPAN
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                physics: const BouncingScrollPhysics(),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),

            // 2. CHIP REKOMENDASI PERTANYAAN
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: _suggestedPrompts.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final prompt = _suggestedPrompts[i];
                  return ActionChip(
                    backgroundColor: const Color(0x33281C15),
                    side: const BorderSide(color: Color(0x44DFB76C), width: 0.8),
                    label: Text(
                      prompt,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE4C590)),
                    ),
                    onPressed: _isTyping ? null : () => _handleSendMessage(prompt),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // 3. BARIS INPUT PESAN
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
                decoration: const BoxDecoration(
                  color: Color(0xD9181310),
                  border: Border(
                      top: BorderSide(color: Color(0x33DFB76C), width: 0.8)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF261D17),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: const Color(0x55DFB76C), width: 0.8),
                        ),
                        child: TextField(
                          controller: _textController,
                          enabled: !_isTyping,
                          style: const TextStyle(
                              color: Color(0xFFFAF6F0), fontSize: 13.5),
                          decoration: const InputDecoration(
                            hintText: 'Tanyakan pakem atau filosofi busana...',
                            hintStyle: TextStyle(
                                color: Color(0xFF9E8E80), fontSize: 13),
                            border: InputBorder.none,
                          ),
                          onSubmitted: _isTyping ? null : (_) => _handleSendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: _isTyping
                            ? const Color(0xFF5A4838)
                            : const Color(0xFFDFB76C),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_upward_rounded,
                            color: Color(0xFF1E1712), size: 20),
                        onPressed: _isTyping ? null : () => _handleSendMessage(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(AssistantChatMessage message) {
    final isUser = message.role == AssistantRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF261D17),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDFB76C), width: 1.0),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Color(0xFFDFB76C), size: 16),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF4A3222)
                        : const Color(0xFF1F1813),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isUser
                          ? const Color(0x66DFB76C)
                          : const Color(0x33DFB76C),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: isUser
                            ? const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFFAF6F0),
                                height: 1.45)
                            : JText.serif(13,
                                color: const Color(0xFFFAF6F0), height: 1.5),
                      ),
                      if (message.sourceReference != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          message.sourceReference!,
                          style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFFDFB76C),
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],
                  ),
                ),

                // ACTION CARD JIKA HASIL DARI FUNCTION CALLING AI
                if (message.action != null)
                  _buildFunctionCallActionCard(message.action!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionCallActionCard(AssistantAction action) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF281C15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDFB76C), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded,
                  color: Color(0xFFDFB76C), size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  action.title,
                  style: JText.serif(13,
                      weight: FontWeight.w800, color: const Color(0xFFFFDF9E)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            action.description,
            style: const TextStyle(fontSize: 11, color: Color(0xFFD6C8B8)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (action.targetOutfit != null) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDFB76C),
                      foregroundColor: const Color(0xFF1E1712),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.view_in_ar_rounded, size: 15),
                    label: const Text('Buka Studio 3D',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w800)),
                    onPressed: () {
                      Navigator.of(context).push(
                        fadeSlideRoute(JavaneseWardrobeScreen(
                            initialOutfit: action.targetOutfit)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDFB76C),
                      side: const BorderSide(color: Color(0xFFDFB76C)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.auto_awesome_rounded, size: 15),
                    label: const Text('Coba AI Studio',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700)),
                    onPressed: () {
                      Navigator.of(context).push(
                        fadeSlideRoute(const AiFashionStudioScreen()),
                      );
                    },
                  ),
                ),
              ] else if (action.targetGarment != null) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDFB76C),
                      foregroundColor: const Color(0xFF1E1712),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.menu_book_rounded, size: 15),
                    label: const Text('Pelajari Makna',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w800)),
                    onPressed: () {
                      Navigator.of(context).push(
                        fadeSlideRoute(
                            ClothingDetailScreen(item: action.targetGarment!)),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1813),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x33DFB76C)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.8, color: Color(0xFFDFB76C)),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Abdi Pakar sedang menimbang paugeran adat...',
                      style: JText.serif(
                        11,
                        color: const Color(0xFFE4C590),
                      ).copyWith(fontStyle: FontStyle.italic),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
