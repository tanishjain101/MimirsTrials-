import 'dart:math';
import 'package:flutter/material.dart';
import '../models/quiz_model.dart';

class QuizProvider extends ChangeNotifier {
  static const int _defaultQuestionCount = 5;
  final Random _random = Random();
  List<Quiz> _quizzes = [];
  Quiz? _currentQuiz;
  int _currentQuestionIndex = 0;
  int _selectedAnswer = -1;
  bool _isAnswered = false;
  int _score = 0;
  Map<String, dynamic>? _lastResult;

  List<Quiz> get quizzes => _quizzes;
  Quiz? get currentQuiz => _currentQuiz;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get selectedAnswer => _selectedAnswer;
  bool get isAnswered => _isAnswered;
  int get score => _score;
  Map<String, dynamic>? get lastResult => _lastResult;

  QuizProvider() {
    _loadQuizzes();
  }

  void _loadQuizzes() {
    _quizzes = [
      Quiz(
        id: 'html_quiz',
        title: 'HTML Basics Quiz',
        description: 'Test your knowledge of HTML basics',
        timeLimit: 600,
        xpReward: 100,
        gemReward: 50,
        category: 'HTML',
        questions: [
          Question(
            text: 'What does HTML stand for?',
            options: [
              'Hyper Text Markup Language',
              'Home Tool Markup Language',
              'Hyperlinks Text ML',
              'High Tech Modern Language',
            ],
            correctAnswerIndex: 0,
            explanation:
                'HTML stands for Hyper Text Markup Language, the standard language for web pages.',
          ),
          Question(
            text: 'Which tag holds document metadata?',
            options: ['<head>', '<header>', '<meta>', '<title>'],
            correctAnswerIndex: 0,
            explanation: 'The <head> element contains metadata and linked resources.',
          ),
          Question(
            text: 'Where does visible page content belong?',
            options: ['<body>', '<head>', '<html>', '<meta>'],
            correctAnswerIndex: 0,
            explanation: 'Visible content is placed inside the <body> element.',
          ),
          Question(
            text: 'What is the correct HTML for creating a hyperlink?',
            options: [
              '<a href="url">link</a>',
              '<link>url</link>',
              '<a>url</a>',
              '<href>url</href>',
            ],
            correctAnswerIndex: 0,
            explanation:
                'Links are created with the <a> tag and the href attribute.',
          ),
          Question(
            text: 'Which attribute provides alternative text for images?',
            options: ['alt', 'title', 'src', 'href'],
            correctAnswerIndex: 0,
            explanation: 'The alt attribute describes the image for accessibility.',
          ),
          Question(
            text: 'Which tag is used for the largest heading?',
            options: ['<h1>', '<heading>', '<h6>', '<head>'],
            correctAnswerIndex: 0,
            explanation: 'The <h1> tag represents the highest-level heading.',
          ),
        ],
      ),
      Quiz(
        id: 'css_quiz',
        title: 'CSS Fundamentals Quiz',
        description: 'Test your knowledge of CSS fundamentals',
        timeLimit: 600,
        xpReward: 75,
        gemReward: 40,
        category: 'CSS',
        questions: [
          Question(
            text: 'What does CSS stand for?',
            options: [
              'Cascading Style Sheets',
              'Computer Style Sheets',
              'Creative Style System',
              'Colorful Style Sheets',
            ],
            correctAnswerIndex: 0,
            explanation: 'CSS stands for Cascading Style Sheets.',
          ),
          Question(
            text: 'Which selector targets elements with class "card"?',
            options: ['.card', '#card', 'card', '*card'],
            correctAnswerIndex: 0,
            explanation: 'Class selectors use a dot prefix, like .card.',
          ),
          Question(
            text: 'Which property is used to change the text color?',
            options: ['color', 'text-color', 'font-color', 'text-style'],
            correctAnswerIndex: 0,
            explanation: 'The color property controls text color.',
          ),
          Question(
            text: 'Which property adds space inside an element border?',
            options: ['padding', 'margin', 'gap', 'border-spacing'],
            correctAnswerIndex: 0,
            explanation: 'Padding adds space inside the border.',
          ),
          Question(
            text: 'The box model order is...',
            options: [
              'Content, padding, border, margin',
              'Margin, border, padding, content',
              'Padding, content, border, margin',
              'Content, border, padding, margin',
            ],
            correctAnswerIndex: 0,
            explanation: 'The box model starts with content, then padding, border, margin.',
          ),
          Question(
            text: 'Which declaration turns a container into a flexbox?',
            options: ['display: flex', 'position: flex', 'flex: 1', 'layout: flex'],
            correctAnswerIndex: 0,
            explanation: 'Use display: flex to enable flexbox layout.',
          ),
        ],
      ),
      Quiz(
        id: 'js_quiz',
        title: 'JavaScript Essentials Quiz',
        description: 'Check your understanding of core JavaScript concepts',
        timeLimit: 700,
        xpReward: 110,
        gemReward: 60,
        category: 'JavaScript',
        questions: [
          Question(
            text: 'Which keyword declares a block-scoped variable?',
            options: ['var', 'let', 'const', 'define'],
            correctAnswerIndex: 1,
            explanation:
                'The let keyword creates a block-scoped, mutable variable.',
          ),
          Question(
            text: 'Which keyword creates a constant binding?',
            options: ['var', 'let', 'const', 'static'],
            correctAnswerIndex: 2,
            explanation: 'const creates a block-scoped binding that cannot be reassigned.',
          ),
          Question(
            text: 'What is the DOM?',
            options: [
              'A JavaScript library',
              'The page structure represented as objects',
              'A CSS preprocessor',
              'A database engine',
            ],
            correctAnswerIndex: 1,
            explanation:
                'The DOM represents the document structure as objects you can manipulate.',
          ),
          Question(
            text: 'Which method selects the first matching element?',
            options: ['querySelector', 'querySelectorAll', 'getElement', 'find'],
            correctAnswerIndex: 0,
            explanation: 'querySelector returns the first matching element.',
          ),
          Question(
            text: 'Which method attaches a click handler?',
            options: ['addEventListener', 'setTimeout', 'appendChild', 'dispatchEvent'],
            correctAnswerIndex: 0,
            explanation: 'addEventListener registers an event handler.',
          ),
          Question(
            text: 'Which data structure stores ordered items?',
            options: ['Array', 'Set', 'Map', 'WeakMap'],
            correctAnswerIndex: 0,
            explanation: 'Arrays store ordered lists of values.',
          ),
        ],
      ),
      Quiz(
        id: 'react_quiz',
        title: 'React Basics Quiz',
        description: 'Validate your knowledge of React fundamentals',
        timeLimit: 700,
        xpReward: 120,
        gemReward: 70,
        category: 'React',
        questions: [
          Question(
            text: 'React is primarily a...',
            options: [
              'Database',
              'UI library',
              'Operating system',
              'Server framework',
            ],
            correctAnswerIndex: 1,
            explanation: 'React is a library for building user interfaces.',
          ),
          Question(
            text: 'What is a component?',
            options: [
              'A reusable UI building block',
              'A CSS selector',
              'A database table',
              'A build tool',
            ],
            correctAnswerIndex: 0,
            explanation: 'Components are reusable pieces of UI.',
          ),
          Question(
            text: 'Props are...',
            options: [
              'Inputs passed into a component',
              'Database queries',
              'CSS variables',
              'Server routes',
            ],
            correctAnswerIndex: 0,
            explanation: 'Props pass data into components.',
          ),
          Question(
            text: 'State represents...',
            options: [
              'Global CSS',
              'Component memory that changes over time',
              'A server process',
              'A build config',
            ],
            correctAnswerIndex: 1,
            explanation: 'State stores local data that triggers re-render.',
          ),
          Question(
            text: 'Which hook manages local state?',
            options: ['useState', 'useFetch', 'useRouter', 'useClass'],
            correctAnswerIndex: 0,
            explanation: 'useState manages component state.',
          ),
          Question(
            text: 'React UI updates when...',
            options: [
              'State or props change',
              'You refresh the page',
              'You edit CSS only',
              'The server restarts',
            ],
            correctAnswerIndex: 0,
            explanation: 'State/props changes trigger re-render.',
          ),
        ],
      ),
      Quiz(
        id: 'node_quiz',
        title: 'Node.js Basics Quiz',
        description: 'Test your Node.js knowledge',
        timeLimit: 700,
        xpReward: 120,
        gemReward: 70,
        category: 'Node.js',
        questions: [
          Question(
            text: 'Node.js is built on which engine?',
            options: ['V8', 'SpiderMonkey', 'Chakra', 'Java'],
            correctAnswerIndex: 0,
            explanation: 'Node.js runs on the V8 JavaScript engine.',
          ),
          Question(
            text: 'Node.js is known for...',
            options: [
              'Blocking I/O',
              'Event-driven, non-blocking I/O',
              'Only client-side code',
              'Static compilation only',
            ],
            correctAnswerIndex: 1,
            explanation: 'Node.js uses event-driven, non-blocking I/O.',
          ),
          Question(
            text: 'Which module reads and writes files?',
            options: ['fs', 'http', 'url', 'path'],
            correctAnswerIndex: 0,
            explanation: 'fs provides file system operations.',
          ),
          Question(
            text: 'Which module is used to create a web server?',
            options: ['http', 'crypto', 'dns', 'os'],
            correctAnswerIndex: 0,
            explanation: 'The http module can create servers.',
          ),
          Question(
            text: 'npm is...',
            options: [
              'A package manager',
              'A database',
              'A web server',
              'A CSS framework',
            ],
            correctAnswerIndex: 0,
            explanation: 'npm manages packages for Node.js.',
          ),
          Question(
            text: 'Which module system does Node.js use?',
            options: ['CommonJS', 'AMD', 'UMD', 'SystemJS'],
            correctAnswerIndex: 0,
            explanation: 'Node.js uses CommonJS modules by default.',
          ),
        ],
      ),
      Quiz(
        id: 'c_quiz',
        title: 'C Fundamentals Quiz',
        description: 'Review core C programming concepts',
        timeLimit: 650,
        xpReward: 110,
        gemReward: 60,
        category: 'C',
        questions: [
          Question(
            text: 'Which header is used for printf in C?',
            options: ['stdio.h', 'stdlib.h', 'string.h', 'math.h'],
            correctAnswerIndex: 0,
            explanation: 'stdio.h provides printf and scanf.',
          ),
          Question(
            text: 'Where does program execution begin in C?',
            options: ['main()', 'start()', 'init()', 'run()'],
            correctAnswerIndex: 0,
            explanation: 'C programs begin execution in main().',
          ),
          Question(
            text: 'What does a pointer store?',
            options: [
              'A value',
              'A memory address',
              'A function name',
              'An array length',
            ],
            correctAnswerIndex: 1,
            explanation: 'Pointers store memory addresses.',
          ),
          Question(
            text: 'Which operator gets the address of a variable?',
            options: ['&', '*', '%', '#'],
            correctAnswerIndex: 0,
            explanation: 'The & operator returns the address of a variable.',
          ),
          Question(
            text: 'Which format specifier prints an int?',
            options: ['%d', '%f', '%s', '%c'],
            correctAnswerIndex: 0,
            explanation: '%d is used for integers.',
          ),
        ],
      ),
      Quiz(
        id: 'cpp_quiz',
        title: 'C++ Basics Quiz',
        description: 'Check your understanding of C++ fundamentals',
        timeLimit: 650,
        xpReward: 120,
        gemReward: 65,
        category: 'C++',
        questions: [
          Question(
            text: 'Which keyword defines a class in C++?',
            options: ['struct', 'object', 'class', 'module'],
            correctAnswerIndex: 2,
            explanation: 'Use the class keyword to define a class.',
          ),
          Question(
            text: 'Which library provides cout and cin?',
            options: ['stdio.h', 'iostream', 'vector', 'string'],
            correctAnswerIndex: 1,
            explanation: 'iostream provides cout and cin.',
          ),
          Question(
            text: 'Constructors are used to...',
            options: [
              'Initialize objects',
              'Delete objects',
              'Compile code',
              'Import headers',
            ],
            correctAnswerIndex: 0,
            explanation: 'Constructors initialize objects when they are created.',
          ),
          Question(
            text: 'Which container is a dynamic array?',
            options: ['std::vector', 'std::list', 'std::map', 'std::set'],
            correctAnswerIndex: 0,
            explanation: 'std::vector is a dynamic contiguous array.',
          ),
          Question(
            text: 'std::cin is used for...',
            options: ['Input', 'Output', 'File delete', 'Threading'],
            correctAnswerIndex: 0,
            explanation: 'std::cin reads input from standard input.',
          ),
        ],
      ),
      Quiz(
        id: 'python_quiz',
        title: 'Python Basics Quiz',
        description: 'Check your Python fundamentals',
        timeLimit: 600,
        xpReward: 90,
        gemReward: 45,
        category: 'Python',
        questions: [
          Question(
            text: 'Which function prints output in Python?',
            options: ['print()', 'echo()', 'console.log()', 'printf()'],
            correctAnswerIndex: 0,
            explanation: 'print() displays output in Python.',
          ),
          Question(
            text: 'What defines a code block in Python?',
            options: ['Braces', 'Indentation', 'Semicolons', 'Parentheses'],
            correctAnswerIndex: 1,
            explanation: 'Indentation defines blocks in Python.',
          ),
          Question(
            text: 'Which statement handles branching?',
            options: ['if/elif/else', 'switch/case', 'select/when', 'choose/end'],
            correctAnswerIndex: 0,
            explanation: 'Python uses if/elif/else for branching.',
          ),
          Question(
            text: 'for loops iterate over...',
            options: ['Sequences', 'Only numbers', 'Only strings', 'Nothing'],
            correctAnswerIndex: 0,
            explanation: 'for loops iterate over sequences like lists.',
          ),
          Question(
            text: 'Which loop repeats while a condition is true?',
            options: ['while', 'for', 'repeat', 'loop'],
            correctAnswerIndex: 0,
            explanation: 'while loops continue while the condition is true.',
          ),
          Question(
            text: 'Which type is an ordered collection?',
            options: ['list', 'set', 'dict', 'tuple'],
            correctAnswerIndex: 0,
            explanation: 'Lists preserve order and are mutable.',
          ),
        ],
      ),
      Quiz(
        id: 'ds_quiz',
        title: 'Data Structures Quiz',
        description: 'Review arrays and linked lists',
        timeLimit: 650,
        xpReward: 100,
        gemReward: 50,
        category: 'Data Structures',
        questions: [
          Question(
            text: 'Array access by index is typically...',
            options: ['O(1)', 'O(n)', 'O(log n)', 'O(n log n)'],
            correctAnswerIndex: 0,
            explanation: 'Arrays provide constant-time index access.',
          ),
          Question(
            text: 'Inserting in the middle of an array is...',
            options: ['O(n)', 'O(1)', 'O(log n)', 'O(n log n)'],
            correctAnswerIndex: 0,
            explanation: 'Elements must be shifted to insert in the middle.',
          ),
          Question(
            text: 'A dynamic array in C++ is...',
            options: ['std::vector', 'std::list', 'std::stack', 'std::set'],
            correctAnswerIndex: 0,
            explanation: 'std::vector is a dynamic contiguous array.',
          ),
          Question(
            text: 'Linked lists store data in...',
            options: ['Contiguous memory', 'Nodes with pointers', 'Hash tables', 'Trees'],
            correctAnswerIndex: 1,
            explanation: 'Each node points to the next element.',
          ),
          Question(
            text: 'Random access in a linked list is...',
            options: ['O(n)', 'O(1)', 'O(log n)', 'O(n log n)'],
            correctAnswerIndex: 0,
            explanation: 'Linked lists require traversal for random access.',
          ),
          Question(
            text: 'A doubly linked list allows...',
            options: [
              'Traversal in both directions',
              'Only forward traversal',
              'Constant-time random access',
              'No insertion',
            ],
            correctAnswerIndex: 0,
            explanation: 'Doubly linked lists can move forward and backward.',
          ),
        ],
      ),
      Quiz(
        id: 'cyber_quiz',
        title: 'Cybersecurity Basics Quiz',
        description: 'Test security fundamentals',
        timeLimit: 600,
        xpReward: 95,
        gemReward: 45,
        category: 'Cybersecurity',
        questions: [
          Question(
            text: 'CIA in security stands for...',
            options: [
              'Confidentiality, Integrity, Availability',
              'Control, Identity, Access',
              'Cyber, Internet, Application',
              'Crypto, Integrity, Access',
            ],
            correctAnswerIndex: 0,
            explanation: 'The CIA triad is confidentiality, integrity, availability.',
          ),
          Question(
            text: 'Confidentiality means...',
            options: [
              'Preventing unauthorized disclosure',
              'Keeping systems online',
              'Speeding up networks',
              'Encrypting everything always',
            ],
            correctAnswerIndex: 0,
            explanation: 'Confidentiality limits access to information.',
          ),
          Question(
            text: 'Integrity focuses on...',
            options: [
              'Preventing improper modification',
              'Increasing performance',
              'Adding more storage',
              'Creating more users',
            ],
            correctAnswerIndex: 0,
            explanation: 'Integrity protects data from unauthorized changes.',
          ),
          Question(
            text: 'Availability ensures...',
            options: [
              'Reliable, timely access',
              'Encryption only',
              'User anonymity',
              'No backups',
            ],
            correctAnswerIndex: 0,
            explanation: 'Availability ensures systems are accessible when needed.',
          ),
          Question(
            text: 'MFA adds security by...',
            options: [
              'Replacing passwords',
              'Adding a second factor',
              'Removing login',
              'Encrypting databases',
            ],
            correctAnswerIndex: 1,
            explanation: 'MFA uses multiple factors for verification.',
          ),
          Question(
            text: 'Authentication verifies...',
            options: [
              'User identity or control of an authenticator',
              'Network speed',
              'File compression',
              'System backups',
            ],
            correctAnswerIndex: 0,
            explanation: 'Authentication verifies identity or authenticator control.',
          ),
        ],
      ),
      Quiz(
        id: 'ai_quiz',
        title: 'AI Basics Quiz',
        description: 'Understand AI fundamentals',
        timeLimit: 600,
        xpReward: 95,
        gemReward: 45,
        category: 'AI Basics',
        questions: [
          Question(
            text: 'AI models learn by...',
            options: ['Guessing', 'Training on data', 'Copying code', 'Random output'],
            correctAnswerIndex: 1,
            explanation: 'AI learns from data during training.',
          ),
          Question(
            text: 'AI systems typically produce...',
            options: [
              'Predictions or recommendations',
              'Only random text',
              'No output',
              'Hardware drivers',
            ],
            correctAnswerIndex: 0,
            explanation: 'AI systems often generate predictions or recommendations.',
          ),
          Question(
            text: 'Inference is...',
            options: [
              'Using a trained model to make outputs',
              'Collecting raw data',
              'Writing training labels',
              'Updating the operating system',
            ],
            correctAnswerIndex: 0,
            explanation: 'Inference uses a trained model to produce outputs.',
          ),
          Question(
            text: 'Model performance depends heavily on...',
            options: ['Data quality', 'Font size', 'Screen brightness', 'Password length'],
            correctAnswerIndex: 0,
            explanation: 'Better data leads to more reliable models.',
          ),
          Question(
            text: 'A good prompt should be...',
            options: ['Vague', 'Specific and structured', 'Very short', 'Only emojis'],
            correctAnswerIndex: 1,
            explanation: 'Specific prompts lead to better results.',
          ),
          Question(
            text: 'Including examples in a prompt can...',
            options: ['Steer style and format', 'Break the model', 'Delete data', 'Disable output'],
            correctAnswerIndex: 0,
            explanation: 'Examples guide the model toward a desired format.',
          ),
        ],
      ),
      Quiz(
        id: 'flutter_quiz',
        title: 'Flutter Essentials Quiz',
        description: 'Test Flutter knowledge',
        timeLimit: 650,
        xpReward: 100,
        gemReward: 50,
        category: 'Flutter',
        questions: [
          Question(
            text: 'Flutter UIs are built with...',
            options: ['Widgets', 'Activities', 'Views', 'Layouts'],
            correctAnswerIndex: 0,
            explanation: 'Flutter uses widgets to build UI.',
          ),
          Question(
            text: 'Hot reload helps by...',
            options: ['Restarting the app', 'Applying changes quickly', 'Clearing caches', 'Publishing builds'],
            correctAnswerIndex: 1,
            explanation: 'Hot reload updates UI quickly without full restart.',
          ),
          Question(
            text: 'Stateless widgets...',
            options: [
              'Do not hold mutable state',
              'Always rebuild from scratch',
              'Manage animations only',
              'Are deprecated',
            ],
            correctAnswerIndex: 0,
            explanation: 'Stateless widgets render from immutable inputs.',
          ),
          Question(
            text: 'Stateful widgets...',
            options: [
              'Hold mutable state in a State object',
              'Cannot rebuild',
              'Are only for lists',
              'Replace MaterialApp',
            ],
            correctAnswerIndex: 0,
            explanation: 'Stateful widgets keep mutable state.',
          ),
          Question(
            text: 'setState() is used to...',
            options: [
              'Trigger a rebuild with new state',
              'Create a new widget tree file',
              'Compile native code',
              'Start an emulator',
            ],
            correctAnswerIndex: 0,
            explanation: 'setState notifies Flutter to rebuild the UI.',
          ),
        ],
      ),
      Quiz(
        id: 'boss_web',
        title: 'Boss Battle: Web Foundations',
        description: 'Mixed challenge across HTML, CSS, and JavaScript.',
        timeLimit: 480,
        xpReward: 180,
        gemReward: 90,
        category: 'Boss Battle',
        questions: [
          Question(
            text: 'Which HTML tag links external CSS?',
            options: ['<link>', '<style>', '<script>', '<meta>'],
            correctAnswerIndex: 0,
            explanation: 'Use <link rel="stylesheet"> for external CSS.',
          ),
          Question(
            text: 'Which CSS property controls layout flow in flex?',
            options: ['flex-direction', 'justify-items', 'float', 'display'],
            correctAnswerIndex: 0,
            explanation: 'flex-direction sets the main axis direction.',
          ),
          Question(
            text: 'Which JS method selects by CSS selector?',
            options: ['querySelector', 'getElement', 'selectAll', 'pick'],
            correctAnswerIndex: 0,
            explanation: 'querySelector returns the first matching element.',
          ),
          Question(
            text: 'Which tag wraps the main page content?',
            options: ['<body>', '<head>', '<html>', '<main>'],
            correctAnswerIndex: 0,
            explanation: 'Visible content lives inside <body>.',
          ),
          Question(
            text: 'Which CSS unit scales with root font size?',
            options: ['rem', 'px', '%', 'vh'],
            correctAnswerIndex: 0,
            explanation: 'rem is relative to the root font size.',
          ),
          Question(
            text: 'Which keyword declares a constant in JS?',
            options: ['const', 'let', 'var', 'static'],
            correctAnswerIndex: 0,
            explanation: 'const creates a constant binding.',
          ),
        ],
      ),
      Quiz(
        id: 'fun_hp_quiz',
        title: 'Wizarding Warm-Up Quiz',
        description: 'A playful Harry Potter themed challenge.',
        timeLimit: 420,
        xpReward: 80,
        gemReward: 40,
        category: 'Harry Potter',
        musicAssetPath: 'music/AUD-20260316-WA0034.mp3',
        questions: [
          Question(
            text: 'Which spell opens locked doors?',
            options: ['Alohomora', 'Accio', 'Lumos', 'Stupefy'],
            correctAnswerIndex: 0,
            explanation: 'Alohomora is the unlocking charm.',
          ),
          Question(
            text: 'Hogwarts has how many main houses?',
            options: ['3', '4', '5', '6'],
            correctAnswerIndex: 1,
            explanation: 'There are four houses at Hogwarts.',
          ),
          Question(
            text: 'Which creature delivers mail in the wizarding world?',
            options: ['Owls', 'Phoenixes', 'Dragons', 'House-elves'],
            correctAnswerIndex: 0,
            explanation: 'Owls deliver letters and parcels.',
          ),
          Question(
            text: 'What does the spell "Expelliarmus" do?',
            options: [
              'Disarms an opponent',
              'Heals injuries',
              'Creates a shield',
              'Summons objects'
            ],
            correctAnswerIndex: 0,
            explanation: 'Expelliarmus is the disarming charm.',
          ),
        ],
      ),
      Quiz(
        id: 'fun_corner_quiz',
        title: 'Fun Corner Quick Quiz',
        description: 'A light mixed quiz for a quick XP boost.',
        timeLimit: 360,
        xpReward: 60,
        gemReward: 25,
        category: 'Fun Corner',
        musicAssetPath: 'music/AUD-20260316-WA0034.mp3',
        questions: [
          Question(
            text: 'Binary numbers are base...',
            options: ['2', '8', '10', '16'],
            correctAnswerIndex: 0,
            explanation: 'Binary uses base 2.',
          ),
          Question(
            text: 'Which symbol starts a single-line comment in JS?',
            options: ['//', '<!--', '#', '/*'],
            correctAnswerIndex: 0,
            explanation: 'Use // for single-line comments in JS.',
          ),
          Question(
            text: 'Which CSS property rounds corners?',
            options: ['border-radius', 'box-shadow', 'outline', 'padding'],
            correctAnswerIndex: 0,
            explanation: 'border-radius rounds element corners.',
          ),
        ],
      ),
    ];
  }

  bool addQuiz(Quiz quiz) {
    final exists = _quizzes.any((q) => q.id == quiz.id);
    if (exists) return false;
    _quizzes.insert(0, quiz);
    notifyListeners();
    return true;
  }

  Quiz? getQuizById(String id) {
    try {
      return _quizzes.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  void startQuiz(String quizId) {
    final baseQuiz =
        getQuizById(quizId) ?? (_quizzes.isNotEmpty ? _quizzes.first : null);
    if (baseQuiz == null) {
      _currentQuiz = null;
      _currentQuestionIndex = 0;
      _selectedAnswer = -1;
      _isAnswered = false;
      _score = 0;
      _lastResult = null;
      notifyListeners();
      return;
    }

    final questions = List<Question>.from(baseQuiz.questions);
    questions.shuffle(_random);
    final selectedCount = min(_defaultQuestionCount, questions.length);

    _currentQuiz = Quiz(
      id: baseQuiz.id,
      title: baseQuiz.title,
      description: baseQuiz.description,
      timeLimit: baseQuiz.timeLimit,
      xpReward: baseQuiz.xpReward,
      gemReward: baseQuiz.gemReward,
      category: baseQuiz.category,
      musicAssetPath: baseQuiz.musicAssetPath,
      questions: questions.take(selectedCount).toList(),
      isCompleted: baseQuiz.isCompleted,
    );
    _currentQuestionIndex = 0;
    _selectedAnswer = -1;
    _isAnswered = false;
    _score = 0;
    _lastResult = null;
    notifyListeners();
  }

  void selectAnswer(int answerIndex) {
    if (!_isAnswered && _currentQuiz != null) {
      _selectedAnswer = answerIndex;
      _isAnswered = true;

      if (answerIndex ==
          _currentQuiz!.questions[_currentQuestionIndex].correctAnswerIndex) {
        _score += 10;
      }
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (_currentQuiz != null &&
        _currentQuestionIndex < _currentQuiz!.questions.length - 1) {
      _currentQuestionIndex++;
      _selectedAnswer = -1;
      _isAnswered = false;
      notifyListeners();
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    if (_currentQuiz == null) return;

    final totalQuestions = _currentQuiz!.questions.length;
    final score = _score ~/ 10;
    final passed = score >= (totalQuestions * 0.6);
    final perfect = score == totalQuestions;

    _lastResult = {
      'score': score,
      'totalQuestions': totalQuestions,
      'xpEarned': _currentQuiz!.xpReward,
      'gemEarned': _currentQuiz!.gemReward,
      'passed': passed,
      'perfect': perfect,
      'quizId': _currentQuiz!.id,
    };

    notifyListeners();
  }

  void resetQuiz() {
    _currentQuiz = null;
    _currentQuestionIndex = 0;
    _selectedAnswer = -1;
    _isAnswered = false;
    _score = 0;
    _lastResult = null;
    notifyListeners();
  }
}
