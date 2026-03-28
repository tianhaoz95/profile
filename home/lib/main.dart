import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'local_ai_provider.dart';
import 'package:http/http.dart' as http;
import 'package:tianhaozhou_home/src/rust/api/simple.dart' as rust_api;
import 'package:tianhaozhou_home/src/rust/frb_generated.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  bool rustInitialized = false;
  try {
    debugPrint('WASM: Initiating RustLib.init()...');
    await RustLib.init();
    debugPrint('WASM: RustLib.init() SUCCESS');
    
    // Quick bridge test
    try {
      final pong = await rust_api.ping(input: "Bridge Check");
      debugPrint('WASM: Bridge PONG: $pong');
      rustInitialized = true;
    } catch (e) {
      debugPrint('WASM: Bridge active but ping failed: $e');
      rustInitialized = true; 
    }
  } catch (e) {
    debugPrint('WASM: RustLib.init() FAILURE: $e');
  }



  runApp(MyApp(rustAvailable: rustInitialized));
}

class MyApp extends StatelessWidget {
  final bool rustAvailable;

  const MyApp({super.key, required this.rustAvailable});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', rustAvailable: rustAvailable),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.rustAvailable});

  final String title;
  final bool rustAvailable;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _showChat = true;
  LlmProvider? _provider;

  bool _isLoading = false;
  String _loadingStatus = '';

  @override
  void initState() {
    super.initState();
    if (widget.rustAvailable) {
      _initLocalAi();
    } else {
      _loadingStatus = 'Local AI unavailable (WASM failed to initialize)';
    }
  }

  Future<void> _initLocalAi() async {
    setState(() {
      _isLoading = true;
      _loadingStatus = 'Downloading model...';
    });

    try {
      final modelUrl = Uri.parse('https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q2_K.gguf');
      final tokenizerUrl = Uri.parse('https://huggingface.co/TinyLlama/TinyLlama-1.1B-Chat-v1.0/resolve/main/tokenizer.json');



      final modelRes = await http.get(modelUrl);
      setState(() {
        _loadingStatus = 'Downloading tokenizer...';
      });
      final tokenizerRes = await http.get(tokenizerUrl);

      setState(() {
        _loadingStatus = 'Initializing local AI...';
      });
      final ai = await rust_api.LocalAi(
        weightsBytes: modelRes.bodyBytes,
        tokenizerBytes: tokenizerRes.bodyBytes,
      );

      setState(() {
        _provider = LocalAiProvider(ai);
        _isLoading = false;
      });


    } catch (e) {
      setState(() {
        _isLoading = false;
        _loadingStatus = 'Error initializing AI: $e';
      });
      debugPrint('Error: $e');
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _toggleChat() {
    setState(() {
      _showChat = !_showChat;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _toggleChat,
            icon: Icon(_showChat ? Icons.chat : Icons.chat_outlined),
            tooltip: 'Toggle Chat',
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('You have pushed the button this many times:'),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          ),
          if (_showChat) ...[
            const VerticalDivider(width: 1),
            SizedBox(
              width: 350,
              child: _isLoading || _provider == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoading) const CircularProgressIndicator(),
                          if (!_isLoading && !widget.rustAvailable)
                            const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(_loadingStatus, textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    )
                  : LlmChatView(
                      provider: _provider!,
                    ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

