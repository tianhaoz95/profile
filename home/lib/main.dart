import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:firebase_ai/firebase_ai.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _showChat = true;

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
              child: LlmChatView(
                provider: FirebaseProvider(
                  model: FirebaseAI.vertexAI().generativeModel(
                        model: 'gemini-1.5-flash',
                      ),
                ),
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
