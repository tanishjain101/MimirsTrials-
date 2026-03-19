import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../widgets/game_bottom_nav.dart';
import '../../widgets/game_scaffold.dart';

class CodingPlaygroundScreen extends StatefulWidget {
  const CodingPlaygroundScreen({super.key});

  @override
  State<CodingPlaygroundScreen> createState() => _CodingPlaygroundScreenState();
}

class _CodingPlaygroundScreenState extends State<CodingPlaygroundScreen> {
  final Map<String, String> _defaultSnippets = const {
    'Python': 'print("Hello World")',
    'JavaScript': 'console.log("Hello World")',
  };
  late final TextEditingController _codeController;
  String _language = 'Python';
  String _output = 'Output will appear here...';

  @override
  void initState() {
    super.initState();
    _codeController =
        TextEditingController(text: _defaultSnippets['Python']);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      appBar: AppBar(
        title: const Text('Playground'),
      ),
      bottomNavigationBar: GameBottomNav(
        currentIndex: 1,
        onTap: (index) => _handleBottomNav(context, index),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLanguagePicker(),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _codeController,
                maxLines: null,
                expands: true,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  color: AppColors.text,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Write your code here...',
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _runCode,
              child: const Text('Run Code'),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.navBorder),
              ),
              child: Text(
                _output,
                style: const TextStyle(color: AppColors.textLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagePicker() {
    return Row(
      children: [
        const Text(
          'Language:',
          style: TextStyle(color: AppColors.textLight),
        ),
        const SizedBox(width: 12),
        DropdownButton<String>(
          value: _language,
          dropdownColor: AppColors.surface,
          items: const [
            DropdownMenuItem(value: 'Python', child: Text('Python')),
            DropdownMenuItem(value: 'JavaScript', child: Text('JavaScript')),
          ],
          onChanged: (value) {
            if (value != null) {
              final previousDefault =
                  _defaultSnippets[_language]?.trim() ?? '';
              final isDefault =
                  _codeController.text.trim() == previousDefault;
              setState(() => _language = value);
              if (isDefault) {
                _codeController.text =
                    _defaultSnippets[value]?.trim() ?? '';
              }
            }
          },
        ),
      ],
    );
  }

  void _runCode() {
    final code = _codeController.text.trim();
    final result =
        _language == 'JavaScript' ? _runJavaScript(code) : _runPython(code);
    setState(() => _output = result);
  }

  String _runPython(String code) {
    String result = 'Execution complete (mock).';
    final printMatch = RegExp(
      'print\\(\\s*["\\\'](.+?)["\\\']\\s*\\)',
    ).firstMatch(code);
    final mathMatch = RegExp(
      '(\\d+)\\s*([+\\-*/])\\s*(\\d+)',
    ).firstMatch(code);

    if (printMatch != null) {
      result = printMatch.group(1) ?? result;
    } else if (mathMatch != null) {
      final left = int.parse(mathMatch.group(1)!);
      final op = mathMatch.group(2)!;
      final right = int.parse(mathMatch.group(3)!);
      result = _evalBinary(left, right, op);
    }

    return result;
  }

  String _runJavaScript(String code) {
    final variables = <String, dynamic>{};
    final outputs = <String>[];
    final lines = code.split(RegExp(r'[;\n]+'));

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final assignMatch = RegExp(
        r'^(?:const|let|var)\s+([a-zA-Z_]\w*)\s*=\s*(.+)$',
      ).firstMatch(line);
      if (assignMatch != null) {
        final name = assignMatch.group(1)!;
        final valueExpr = assignMatch.group(2)!;
        variables[name] = _evalJsExpression(valueExpr, variables);
        continue;
      }

      final logMatch = RegExp(r'^console\.log\((.*)\)$').firstMatch(line);
      if (logMatch != null) {
        final expr = logMatch.group(1)!.trim();
        final value = _evalJsExpression(expr, variables);
        outputs.add(value.toString());
        continue;
      }
    }

    if (outputs.isNotEmpty) {
      return outputs.join('\n');
    }

    final mathMatch = RegExp(
      '(\\d+)\\s*([+\\-*/])\\s*(\\d+)',
    ).firstMatch(code);
    if (mathMatch != null) {
      final left = int.parse(mathMatch.group(1)!);
      final op = mathMatch.group(2)!;
      final right = int.parse(mathMatch.group(3)!);
      return _evalBinary(left, right, op);
    }

    return 'Execution complete (mock).';
  }

  dynamic _evalJsExpression(String expr, Map<String, dynamic> variables) {
    final trimmed = expr.trim();
    final stringMatch =
        RegExp("^(['\\\"])(.*)\\1\$").firstMatch(trimmed);
    if (stringMatch != null) {
      return stringMatch.group(2) ?? '';
    }
    if (trimmed == 'true') return true;
    if (trimmed == 'false') return false;
    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(trimmed)) {
      return num.parse(trimmed);
    }
    if (variables.containsKey(trimmed)) {
      return variables[trimmed];
    }

    final parts = _splitOnOperator(trimmed, '+');
    if (parts.length > 1) {
      final values =
          parts.map((part) => _evalJsExpression(part, variables)).toList();
      final hasString = values.any((value) => value is String);
      if (hasString) {
        return values.map((value) => value.toString()).join('');
      }
      final nums = values.whereType<num>().toList();
      if (nums.length == values.length) {
        return nums.fold<num>(0, (sum, val) => sum + val);
      }
    }

    final binaryMatch =
        RegExp(r'^(.+?)\s*([+\-*/])\s*(.+)$').firstMatch(trimmed);
    if (binaryMatch != null) {
      final left = _evalJsExpression(binaryMatch.group(1)!, variables);
      final right = _evalJsExpression(binaryMatch.group(3)!, variables);
      if (left is num && right is num) {
        return num.parse(_evalBinary(left, right, binaryMatch.group(2)!));
      }
    }

    return trimmed;
  }

  List<String> _splitOnOperator(String input, String operator) {
    final parts = <String>[];
    final buffer = StringBuffer();
    var inSingle = false;
    var inDouble = false;

    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == "'" && !inDouble) {
        inSingle = !inSingle;
      } else if (char == '"' && !inSingle) {
        inDouble = !inDouble;
      }

      if (char == operator && !inSingle && !inDouble) {
        parts.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    parts.add(buffer.toString());
    return parts;
  }

  String _evalBinary(num left, num right, String op) {
    switch (op) {
      case '+':
        return '${left + right}';
      case '-':
        return '${left - right}';
      case '*':
        return '${left * right}';
      case '/':
        return '${left / right}';
    }
    return '$left';
  }

  void _handleBottomNav(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/learn');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/leaderboard');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }
}
