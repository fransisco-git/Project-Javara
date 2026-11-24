import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:jawara_app/features/fashion/screens/ai_cultural_assistant_screen.dart';
import 'package:jawara_app/services/ai_cultural_assistant_service.dart';

void main() {
  group('AiCulturalAssistantService Tests', () {
    test('Credentials and endpoint configuration match Gemini Pro specification', () {
      final service = AiCulturalAssistantService(
        apiKey: 'test-gemini-key',
        model: 'gemini-1.5-pro',
      );

      expect(service.isConfigured, isTrue);
      expect(service.effectiveApiKey, equals('test-gemini-key'));
      expect(service.effectiveModel, equals('gemini-1.5-pro'));

      final uri = service.buildEndpointUrl();
      expect(uri.scheme, equals('https'));
      expect(uri.host, equals('generativelanguage.googleapis.com'));
      expect(
        uri.path,
        equals('/v1beta/models/gemini-1.5-pro:generateContent'),
      );
      expect(uri.queryParameters['key'], equals('test-gemini-key'));
    });

    test('Live Gemini Pro request structure and response parsing', () async {
      late Uri capturedUri;
      late Map<String, dynamic> capturedBody;
      late Map<String, String> capturedHeaders;

      final mockClient = MockClient((request) async {
        capturedUri = request.url;
        capturedHeaders = request.headers;
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;

        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'text':
                          'Busana Solo Basahan Dodot Ageng merupakan busana kanarendran pengantin Jawa Surakarta yang sarat dengan pralambang kesuburan dan keluhuran budi.',
                    }
                  ],
                  'role': 'model',
                },
                'finishReason': 'STOP',
                'index': 0,
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = AiCulturalAssistantService(
        httpClient: mockClient,
        apiKey: 'AIzaSyFakeKey123',
        model: 'gemini-1.5-pro',
      );

      final reply = await service.sendMessage(
        'Jelaskan tentang busana Solo Basahan pengantin',
      );

      // Verify request dispatch details
      expect(capturedUri.host, equals('generativelanguage.googleapis.com'));
      expect(capturedHeaders['Content-Type'], equals('application/json'));
      expect(capturedBody.containsKey('system_instruction'), isTrue);
      expect(capturedBody.containsKey('contents'), isTrue);

      final contents = capturedBody['contents'] as List;
      expect(contents, isNotEmpty);
      expect(contents.first['role'], equals('user'));

      // Verify parsed response
      expect(reply.role, equals(AssistantRole.assistant));
      expect(reply.text, contains('Solo Basahan Dodot Ageng'));
      expect(reply.sourceReference, contains('Gemini Pro'));
      expect(reply.action, isNotNull);
      expect(reply.action!.type, equals('outfit_recommendation'));
    });

    test('Multi-turn conversation history is formatted and preserved across turns', () async {
      int requestCount = 0;
      final List<Map<String, dynamic>> recordedPayloads = [];

      final mockClient = MockClient((request) async {
        requestCount++;
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        recordedPayloads.add(body);

        if (requestCount == 1) {
          return http.Response(
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {
                        'text':
                            'Untuk upacara manten Surakarta, setelan Solo Basahan menggunakan kain dodot kampuh sekar semen.',
                      }
                    ],
                    'role': 'model',
                  }
                }
              ]
            }),
            200,
          );
        } else {
          return http.Response(
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {
                        'text':
                            'Makna motif sekar semen pada kain dodot melambangkan benih kehidupan yang terus bersemi.',
                      }
                    ],
                    'role': 'model',
                  }
                }
              ]
            }),
            200,
          );
        }
      });

      final service = AiCulturalAssistantService(
        httpClient: mockClient,
        apiKey: 'AIzaSyMultiTurnTest',
        model: 'gemini-1.5-pro',
      );

      // Turn 1
      final turn1 = await service.sendMessage('Rekomendasi busana pernikahan');
      expect(turn1.text, contains('Solo Basahan'));
      expect(service.sessionHistory.length, equals(2));

      // Turn 2: uses internal session history automatically
      final turn2 = await service.sendMessage('Apa filosofi motif kain dodotnya?');
      expect(turn2.text, contains('motif sekar semen'));
      expect(service.sessionHistory.length, equals(4));

      // Verify contents in Turn 2 request payload
      final turn2Contents = recordedPayloads[1]['contents'] as List;
      expect(turn2Contents.length, equals(3));
      expect(turn2Contents[0]['role'], equals('user'));
      expect(turn2Contents[0]['parts'][0]['text'], contains('Rekomendasi busana pernikahan'));
      expect(turn2Contents[1]['role'], equals('model'));
      expect(turn2Contents[1]['parts'][0]['text'], contains('Solo Basahan'));
      expect(turn2Contents[2]['role'], equals('user'));
      expect(turn2Contents[2]['parts'][0]['text'], contains('Apa filosofi motif kain dodotnya?'));

      // Test clearSession()
      service.clearSession();
      expect(service.sessionHistory.isEmpty, isTrue);
    });

    test('buildGeminiContents ignores leading assistant greetings and consolidates same-role messages', () {
      final service = AiCulturalAssistantService(apiKey: 'dummy-key');

      final history = [
        AssistantChatMessage(
          id: 'welcome',
          role: AssistantRole.assistant,
          text: 'Sugeng rawuh ing JAVARA.',
          timestamp: DateTime.now(),
        ),
        AssistantChatMessage(
          id: 'u1',
          role: AssistantRole.user,
          text: 'Halo pakar, saya mau tanya.',
          timestamp: DateTime.now(),
        ),
        AssistantChatMessage(
          id: 'u2',
          role: AssistantRole.user,
          text: 'Bagaimana pakem blangkon Solo?',
          timestamp: DateTime.now(),
        ),
        AssistantChatMessage(
          id: 'a1',
          role: AssistantRole.assistant,
          text: 'Blangkon Solo menggunakan mondholan trepes yang pipih.',
          timestamp: DateTime.now(),
        ),
      ];

      final contents = service.buildGeminiContents(
        query: 'Mengapa mondholannya pipih?',
        history: history,
      );

      // Must start with user (leading greeting dropped)
      expect(contents.first['role'], equals('user'));
      // Consecutive user messages (u1 + u2) merged
      expect(contents[0]['parts'][0]['text'], contains('Halo pakar, saya mau tanya.\n\nBagaimana pakem blangkon Solo?'));
      // Next is model
      expect(contents[1]['role'], equals('model'));
      expect(contents[1]['parts'][0]['text'], contains('Blangkon Solo menggunakan mondholan trepes'));
      // Last is current query as user
      expect(contents[2]['role'], equals('user'));
      expect(contents[2]['parts'][0]['text'], equals('Mengapa mondholannya pipih?'));
    });

    test('buildGeminiContents with long history (>20 messages) guarantees first turn role is user', () {
      final service = AiCulturalAssistantService(apiKey: 'dummy-key');

      // Create a 25-message history: u0, a0, u1, a1, ... u11, a11, u12
      final history = <AssistantChatMessage>[];
      for (int i = 0; i < 12; i++) {
        history.add(AssistantChatMessage(
          id: 'u$i',
          role: AssistantRole.user,
          text: 'User message $i',
          timestamp: DateTime.now(),
        ));
        history.add(AssistantChatMessage(
          id: 'a$i',
          role: AssistantRole.assistant,
          text: 'Assistant message $i',
          timestamp: DateTime.now(),
        ));
      }
      history.add(AssistantChatMessage(
        id: 'u12',
        role: AssistantRole.user,
        text: 'User message 12',
        timestamp: DateTime.now(),
      ));

      final contents = service.buildGeminiContents(
        query: 'User message 13',
        history: history,
      );

      // In Gemini API, the first content role MUST always be 'user'
      expect(contents.first['role'], equals('user'));
    });

    test('Automatic fallback retry when older Gemini endpoint rejects system_instruction', () async {
      int callCount = 0;
      late Map<String, dynamic> secondPayload;

      final mockClient = MockClient((request) async {
        callCount++;
        final body = jsonDecode(request.body) as Map<String, dynamic>;

        if (callCount == 1) {
          // Reject system_instruction with 400
          return http.Response(
            jsonEncode({
              'error': {
                'code': 400,
                'message': 'Unknown field: system_instruction',
                'status': 'INVALID_ARGUMENT',
              }
            }),
            400,
          );
        }

        secondPayload = body;
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'Jawaban hasil retry tanpa system_instruction.'}
                  ],
                  'role': 'model',
                }
              }
            ]
          }),
          200,
        );
      });

      final service = AiCulturalAssistantService(
        httpClient: mockClient,
        apiKey: 'key',
        model: 'gemini-pro',
      );

      final reply = await service.sendMessage('Tanya sejarah batik');
      expect(callCount, equals(2));
      expect(secondPayload.containsKey('system_instruction'), isFalse);
      expect(secondPayload['contents'][0]['parts'][0]['text'], contains('Abdi Pakar Busana JAVARA'));
      expect(reply.text, equals('Jawaban hasil retry tanpa system_instruction.'));
    });

    test('Gracefully falls back to curated local responses when API key is missing', () async {
      final service = AiCulturalAssistantService(
        apiKey: '', // not configured
      );

      expect(service.isConfigured, isFalse);

      final reply = await service.sendMessage('Rekomendasi busana pernikahan Surakarta');
      expect(reply.role, equals(AssistantRole.assistant));
      expect(reply.text, contains('Solo Basahan'));
      expect(reply.sourceReference, contains('Karaton Surakarta'));
      expect(reply.action, isNotNull);
    });

    test('Gracefully handles HTTP 400/401/403 invalid API key without crashing', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {
              'code': 400,
              'message': 'API key not valid.',
              'status': 'INVALID_ARGUMENT',
            }
          }),
          400,
        );
      });

      final service = AiCulturalAssistantService(
        httpClient: mockClient,
        apiKey: 'invalid-key',
      );

      final reply = await service.sendMessage('Makna motif batik parang');
      expect(reply.role, equals(AssistantRole.assistant));
      expect(reply.text, contains('Parang Barong'));
      expect(reply.action, isNotNull);
      expect(reply.action!.type, equals('batik_motif'));
    });

    test('Gracefully handles HTTP 429 rate limiting without crashing', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'error': {
              'code': 429,
              'message': 'Resource has been exhausted (rate limit).',
              'status': 'RESOURCE_EXHAUSTED',
            }
          }),
          429,
        );
      });

      final service = AiCulturalAssistantService(
        httpClient: mockClient,
        apiKey: 'valid-key-rate-limited',
      );

      final reply = await service.sendMessage('Pakem blangkon mondholan trepes Solo');
      expect(reply.role, equals(AssistantRole.assistant));
      expect(reply.text, contains('Blangkon Mondholan Trepes'));
      expect(reply.action, isNotNull);
      expect(reply.action!.type, equals('garment_detail'));
    });

    test('Gracefully handles HTTP timeout without crashing', () async {
      final mockClient = MockClient((request) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return http.Response('{}', 200);
      });

      final service = AiCulturalAssistantService(
        httpClient: mockClient,
        apiKey: 'timeout-key',
        requestTimeout: const Duration(milliseconds: 10), // Triggers timeout
      );

      final reply = await service.sendMessage('Filosofi keris ladrang');
      expect(reply.role, equals(AssistantRole.assistant));
      expect(reply.text, contains('Keris Gaya Ladrang Surakarta'));
      expect(reply.action, isNotNull);
    });

    test('Gracefully handles Network exception without crashing', () async {
      final mockClient = MockClient((request) async {
        throw http.ClientException('Failed to connect to host');
      });

      final service = AiCulturalAssistantService(
        httpClient: mockClient,
        apiKey: 'network-error-key',
      );

      final reply = await service.sendMessage('Busana kebaya putri Solo');
      expect(reply.role, equals(AssistantRole.assistant));
      expect(reply.text, contains('Kebaya Kartini'));
      expect(reply.action, isNotNull);
    });

    test('Gracefully handles empty candidates or malformed JSON from API', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'candidates': [],
            'promptFeedback': {'blockReason': 'SAFETY'},
          }),
          200,
        );
      });

      final service = AiCulturalAssistantService(
        httpClient: mockClient,
        apiKey: 'safety-block-key',
      );

      final reply = await service.sendMessage('Tanya busana manten');
      expect(reply.role, equals(AssistantRole.assistant));
      expect(reply.text, contains('Solo Basahan'));
    });

    test('Handles empty query safely', () async {
      final service = AiCulturalAssistantService();
      final reply = await service.sendMessage('   ');
      expect(reply.text, contains('katuran nyerat'));
    });

    test('Resolves contextual action for Kebaya / Busana Putri recommendation', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'text':
                          'Kebaya Kartini dan Kebaya Kutu Baru memancarkan keanggunan putri Keraton Kasunanan Surakarta.',
                    }
                  ],
                  'role': 'model',
                }
              }
            ]
          }),
          200,
        );
      });

      final service = AiCulturalAssistantService(
        httpClient: mockClient,
        apiKey: 'test-kebaya-key',
      );

      final reply = await service.sendMessage('Bagaimana pakem kebaya kutubaru putri?');
      expect(reply.role, equals(AssistantRole.assistant));
      expect(reply.action, isNotNull);
      expect(reply.action!.type, equals('garment_detail'));
      expect(reply.action!.targetGarment, isNotNull);
    });
  });

  group('AiCulturalAssistantScreen Widget Tests', () {
    testWidgets('Renders initial greeting, action chips, and sends live message', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {
                      'text':
                          'Busana Solo Basahan melambangkan penyatuan kanarendran pengantin Jawa.',
                    }
                  ],
                  'role': 'model',
                }
              }
            ]
          }),
          200,
        );
      });

      // Inject mock service into instance
      final customService = AiCulturalAssistantService(
        httpClient: mockClient,
        apiKey: 'test-widget-key',
      );
      AiCulturalAssistantService.instance = customService;

      await tester.pumpWidget(
        const MaterialApp(
          home: AiCulturalAssistantScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Initial greeting from Abdi Pakar Busana
      expect(find.text('Abdi Pakar Busana JAVARA'), findsOneWidget);
      expect(find.textContaining('Sugeng rawuh ing JAVARA'), findsOneWidget);

      // 2. Suggested prompt chips
      expect(find.byType(ActionChip), findsWidgets);
      expect(find.text('Rekomendasi busana pernikahan adat Surakarta'), findsOneWidget);

      // 3. Tap the first chip to send message
      await tester.tap(find.text('Rekomendasi busana pernikahan adat Surakarta'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify user message and assistant reply are rendered in chat
      // Text appears twice: once in the suggested chip and once in the user chat bubble
      expect(find.text('Rekomendasi busana pernikahan adat Surakarta'), findsNWidgets(2));
      expect(find.textContaining('Busana Solo Basahan melambangkan penyatuan'), findsOneWidget);

      // 4. Action card for 3D studio and AI studio is rendered
      expect(find.text('Buka Studio 3D'), findsOneWidget);
      expect(find.text('Coba AI Studio'), findsOneWidget);
    });

    testWidgets('Handles initialQuery parameter automatically on launch', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'Batik Parang Barong adalah motif awisan dalem para raja.'}
                  ],
                  'role': 'model',
                }
              }
            ]
          }),
          200,
        );
      });

      AiCulturalAssistantService.instance = AiCulturalAssistantService(
        httpClient: mockClient,
        apiKey: 'test-key',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: AiCulturalAssistantScreen(
            initialQuery: 'Filosofi motif batik parang',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Filosofi motif batik parang'), findsOneWidget);
      expect(find.textContaining('Batik Parang Barong adalah motif awisan dalem'), findsOneWidget);
    });

    testWidgets('Prevents duplicate submissions while assistant is typing', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      int dispatchCount = 0;
      final completer = Completer<http.Response>();

      final mockClient = MockClient((request) async {
        dispatchCount++;
        return completer.future;
      });

      AiCulturalAssistantService.instance = AiCulturalAssistantService(
        httpClient: mockClient,
        apiKey: 'test-concurrency-key',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: AiCulturalAssistantScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap first prompt chip to initiate request
      await tester.tap(find.byType(ActionChip).first);
      await tester.pump(); // Start typing, request in flight

      expect(dispatchCount, equals(1));
      expect(find.textContaining('Abdi Pakar sedang menimbang'), findsOneWidget);

      // Attempt to tap the send button while typing
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pump();

      // Attempt to tap prompt chip again while typing
      await tester.tap(find.byType(ActionChip).first);
      await tester.pump();

      // Dispatch count remains 1 (prevented concurrent request)
      expect(dispatchCount, equals(1));

      // Resolve the in-flight request
      completer.complete(
        http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [{'text': 'Solo Basahan untuk pernikahan adat.'}],
                  'role': 'model',
                }
              }
            ]
          }),
          200,
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('Solo Basahan untuk pernikahan adat.'), findsOneWidget);
    });
  });
}
