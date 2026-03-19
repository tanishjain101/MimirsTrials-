import 'package:flutter/material.dart';
import '../utils/gemini_client.dart';

class AIProvider extends ChangeNotifier {
  final GeminiClient _geminiClient = GeminiClient();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, String>> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isGeminiReady => _geminiClient.isConfigured;

  Future<void> sendMessage(String message, String context) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Add user message
      _messages.add({'role': 'user', 'content': message});
      notifyListeners();

      // Prepare prompt with context
      final systemPrompt = '''
Context: The user is learning $context. They are a beginner.
User question: $message

Provide a helpful, educational response with:
1. Clear explanation
2. Code examples if relevant
3. Practice suggestions
''';

      String aiResponse;
      if (_geminiClient.isConfigured) {
        aiResponse = await _geminiClient.generateChat(
          messages: _messages,
          systemPrompt: systemPrompt,
        );
      } else {
        aiResponse = _localTutorResponse(message, context);
      }

      // Add AI response
      _messages.add({'role': 'assistant', 'content': aiResponse});

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _messages.add({
        'role': 'assistant',
        'content': _localTutorResponse(message, context),
      });
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }

  Future<String> generatePractice(String topic) async {
    try {
      if (_geminiClient.isConfigured) {
        return await _geminiClient.generateChat(
          messages: [
            {
              'role': 'user',
              'content':
                  'Create a short beginner practice exercise about $topic. Include a prompt and 2 hints.',
            }
          ],
          systemPrompt:
              'You are a helpful coding tutor creating practice exercises.',
        );
      }
      return _demoPractice(topic);
    } catch (e) {
      return _demoPractice(topic);
    }
  }

  Future<Map<String, dynamic>> explainCode(String code) async {
    try {
      if (_geminiClient.isConfigured) {
        final response = await _geminiClient.generateChat(
          messages: [
            {
              'role': 'user',
              'content':
                  'Explain this code step-by-step and suggest improvements:\n$code',
            }
          ],
          systemPrompt: 'You are a patient coding tutor.',
        );
        return {'explanation': response};
      }
      return {'explanation': _demoExplain(code)};
    } catch (e) {
      return {'explanation': _demoExplain(code)};
    }
  }

  List<String> localHints(String code, String language) {
    final hints = <String>[];
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      return ['Add code so I can analyze it.'];
    }

    final openParen = '('.allMatches(code).length;
    final closeParen = ')'.allMatches(code).length;
    if (openParen != closeParen) {
      hints.add('Check parentheses: you may have a missing ) or (.');
    }
    final openBrace = '{'.allMatches(code).length;
    final closeBrace = '}'.allMatches(code).length;
    if (openBrace != closeBrace) {
      hints.add('Check braces: you may have an extra or missing { }.');
    }
    final openBracket = '['.allMatches(code).length;
    final closeBracket = ']'.allMatches(code).length;
    if (openBracket != closeBracket) {
      hints.add('Check brackets: you may have a missing ] or [.');
    }

    if (language == 'JavaScript' || language == 'Dart') {
      final lines = code.split('\n');
      for (final line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) continue;
        final endsWithSemicolon = trimmedLine.endsWith(';');
        final likelyStatement = trimmedLine.startsWith('const ') ||
            trimmedLine.startsWith('let ') ||
            trimmedLine.startsWith('var ') ||
            trimmedLine.startsWith('final ') ||
            trimmedLine.startsWith('print') ||
            trimmedLine.startsWith('console.log') ||
            trimmedLine.contains('=');
        final endsWithBlock = trimmedLine.endsWith('{') || trimmedLine.endsWith('}');
        if (likelyStatement && !endsWithSemicolon && !endsWithBlock) {
          hints.add('Possible missing semicolon in: "$trimmedLine"');
          break;
        }
      }

      final assignmentInIf = RegExp(r'if\\s*\\([^\\)]*=[^=][^\\)]*\\)');
      if (assignmentInIf.hasMatch(code)) {
        hints.add('Possible assignment inside if(). Did you mean == or ===?');
      }
    }

    if (language == 'Python') {
      if (code.contains(';')) {
        hints.add('Python does not require semicolons.');
      }
      final indentMismatch = RegExp(r'^\\s{1,3}\\S', multiLine: true);
      if (indentMismatch.hasMatch(code)) {
        hints.add('Check indentation: Python blocks need consistent spacing.');
      }
    }

    if (hints.isEmpty) {
      hints.add('No obvious syntax issues found. Check logic or expected output.');
    }
    return hints;
  }

  List<String> localErrorTags(String code, String language) {
    final tags = <String>[];
    final openParen = '('.allMatches(code).length;
    final closeParen = ')'.allMatches(code).length;
    if (openParen != closeParen) tags.add('unbalanced_parentheses');
    final openBrace = '{'.allMatches(code).length;
    final closeBrace = '}'.allMatches(code).length;
    if (openBrace != closeBrace) tags.add('unbalanced_braces');
    final openBracket = '['.allMatches(code).length;
    final closeBracket = ']'.allMatches(code).length;
    if (openBracket != closeBracket) tags.add('unbalanced_brackets');
    if (language == 'JavaScript' || language == 'Dart') {
      final assignmentInIf = RegExp(r'if\\s*\\([^\\)]*=[^=][^\\)]*\\)');
      if (assignmentInIf.hasMatch(code)) tags.add('assignment_in_condition');
    }
    return tags;
  }

  Future<String> debugCodeHybrid(String code, String language) async {
    final local = localHints(code, language);
    final aiResponse = await debugCode(code, language);
    final buffer = StringBuffer();
    buffer.writeln('Local Mentor Suggestions:');
    for (final hint in local) {
      buffer.writeln('- $hint');
    }
    buffer.writeln('');
    buffer.writeln('AI Mentor:');
    buffer.writeln(aiResponse);
    return buffer.toString();
  }

  Future<String> debugCode(String code, String language) async {
    try {
      if (_geminiClient.isConfigured) {
        return await _geminiClient.generateChat(
          messages: [
            {
              'role': 'user',
              'content':
                  'Debug this $language code. Explain the issue and show a corrected version:\n$code',
            }
          ],
          systemPrompt: 'You are a precise code debugger.',
        );
      }
      return _demoDebug(language);
    } catch (e) {
      return _demoDebug(language);
    }
  }

  Future<String> generateProjectPlan({
    required String prompt,
    required String stack,
  }) async {
    try {
      if (_geminiClient.isConfigured) {
        return await _geminiClient.generateChat(
          messages: [
            {
              'role': 'user',
              'content':
                  'Create a project plan for: $prompt. Tech stack: $stack.',
            }
          ],
          systemPrompt:
              'You are a product-minded engineering lead. Provide milestones, features, and stretch goals.',
        );
      }
      return _demoProjectPlan(prompt, stack);
    } catch (e) {
      return _demoProjectPlan(prompt, stack);
    }
  }

  String _localTutorResponse(String message, String context) {
    final lower = message.toLowerCase();
    final topic = context.toLowerCase();
    if (lower.contains('recursion')) {
      return '''
Recursion is when a function calls itself to solve smaller parts of a problem.

Key rules:
1) Always have a base case to stop.
2) Each call should get closer to that base case.

Example (JavaScript):
function factorial(n) {
  if (n <= 1) return 1;
  return n * factorial(n - 1);
}

Try: write a recursive function to sum 1..n.
''';
    }
    if (topic.contains('html') || lower.contains('html')) {
      return '''
HTML structures content on the page using elements (tags).

Core building blocks:
- Headings: <h1> to <h6>
- Paragraphs: <p>
- Links: <a href="...">
- Images: <img src="..." alt="...">

Mini practice:
Create a page with a title, a paragraph, and a link.
''';
    }
    if (topic.contains('css') || lower.contains('css')) {
      return '''
CSS controls styling (colors, layout, spacing).

Core concepts:
- Selectors (.class, #id, element)
- Box model (margin, border, padding, content)
- Flexbox for layout

Mini practice:
Style a card with padding, border radius, and a shadow.
''';
    }
    if (topic.contains('javascript') || lower.contains('js')) {
      return '''
JavaScript adds interactivity and logic.

Core concepts:
- Variables (let/const)
- Functions
- DOM manipulation

Mini practice:
Make a button that changes text when clicked.
''';
    }
    if (topic.contains('react') || lower.contains('react')) {
      return '''
React builds UI with reusable components.

Core concepts:
- Components
- Props and state
- useEffect for side effects

Mini practice:
Build a counter component with + and - buttons.
''';
    }
    if (topic.contains('python') || lower.contains('python')) {
      return '''
Python is great for scripting and data tasks.

Core concepts:
- Variables
- Functions
- Lists and loops

Mini practice:
Write a loop that prints even numbers from 1 to 20.
''';
    }
    if (topic.contains('flutter') || lower.contains('flutter')) {
      return '''
Flutter builds cross‑platform apps with widgets.

Core concepts:
- StatelessWidget vs StatefulWidget
- Layout with Row/Column
- setState for updates

Mini practice:
Create a card with an icon, title, and subtitle.
''';
    }

    return '''
Here’s a clear path to answer your question:
1) Identify the core concept.
2) Start with a tiny example.
3) Expand it step by step.

Tell me the topic or paste code, and I’ll guide you.
''';
  }

  String _demoPractice(String topic) {
    return '''
Demo practice for $topic:
Prompt: Build a tiny example that uses one core $topic concept.
Hint 1: Start with the simplest syntax you know.
Hint 2: Add one extra feature (styling or logic) after it works.
''';
  }

  String _demoExplain(String code) {
    return '''
Demo explanation:
1) This code runs top to bottom.
2) Identify variables and inputs first.
3) Look for functions and their outputs.

Suggestion: Add clear variable names and small helper functions.
''';
  }

  String _demoDebug(String language) {
    return '''
Demo debug response for $language:
- Check for syntax errors (missing brackets, commas, semicolons).
- Ensure variables are declared before use.
- Print intermediate values to locate the failure.

To enable real debugging, set GEMINI_API_KEY.
''';
  }

  String _demoProjectPlan(String prompt, String stack) {
    return '''
Demo project plan for: $prompt
Stack: $stack

Milestones:
1) Define requirements and user flows
2) Build core UI screens
3) Implement data models and storage
4) Add authentication and analytics
5) QA, polish, and deploy

Stretch goals:
- Offline mode
- Real-time sync
- Advanced analytics

Set GEMINI_API_KEY to generate real plans.
''';
  }
}
