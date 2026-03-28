import 'package:tianhaozhou_home/src/rust/api/simple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';

class LocalAiProvider extends ChangeNotifier implements LlmProvider {

  final LocalAi ai;
  List<ChatMessage> _history = [];

  LocalAiProvider(this.ai);

  @override
  Iterable<ChatMessage> get history => _history;

  @override
  set history(Iterable<ChatMessage> history) {
    _history = history.toList();
    notifyListeners();
  }

  @override
  Stream<String> generateStream(String prompt, {Iterable<Attachment>? attachments}) async* {
    _history.add(ChatMessage.user(prompt, []));
    notifyListeners();

    final response = await ai.generate(prompt: prompt, maxTokens: BigInt.from(128));

    _history.add(ChatMessage(origin: MessageOrigin.llm, text: response, attachments: []));
    notifyListeners();
    yield response;

  }

  @override
  Stream<String> sendMessageStream(String prompt, {Iterable<Attachment>? attachments}) async* {
    yield* generateStream(prompt, attachments: attachments);
  }
}

