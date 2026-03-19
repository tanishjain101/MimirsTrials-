import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../models/micro_lesson_step.dart';

class LessonProvider extends ChangeNotifier {
  List<Lesson> _lessons = [];
  final Map<String, double> _progress = {};
  final Map<String, List<MicroLessonStep>> _microSteps = {};

  List<Lesson> get lessons => _lessons;
  Map<String, double> get progress => _progress;
  List<MicroLessonStep> getMicroSteps(String lessonId) =>
      _microSteps[lessonId] ?? [];

  LessonProvider() {
    _loadLessons();
  }

  void _loadLessons() {
    _lessons = [
      Lesson(
        id: 'html_intro',
        title: 'Introduction to HTML',
        description: 'Structure web pages with semantic HTML elements.',
        type: LessonType.lesson,
        category: 'HTML',
        difficulty: 'Beginner',
        duration: 12,
        content: '''
1) Goal: Understand what HTML is and why it structures content.
2) Identify elements, tags, and attributes.
3) Recognize the basic document skeleton: doctype, html, head, body.
4) Use headings, paragraphs, and lists to organize content.
5) Add links and images with href, src, and alt attributes.
6) Practice: build a simple page with a title, hero text, and link.
        ''',
        resources: const [
          'https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Structuring_content/HTML_basics',
          'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference',
        ],
        xpReward: 50,
      ),
      Lesson(
        id: 'css_basics',
        title: 'CSS Fundamentals',
        description: 'Style web pages with selectors and the box model.',
        type: LessonType.lesson,
        category: 'CSS',
        difficulty: 'Beginner',
        duration: 15,
        content: '''
1) Goal: Style HTML with CSS rules.
2) Use selectors (type, class, id) to target elements.
3) Write declarations with property: value pairs.
4) Apply typography and color with font and color properties.
5) Understand the box model: content, padding, border, margin.
6) Practice: style a card with spacing and a border.
        ''',
        resources: const [
          'https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Styling_basics/Basic_selectors',
          'https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Styling_basics/Box_model',
        ],
        xpReward: 60,
      ),
      Lesson(
        id: 'js_intro',
        title: 'JavaScript Basics',
        description: 'Add logic and interactivity with JavaScript.',
        type: LessonType.lesson,
        category: 'JavaScript',
        difficulty: 'Intermediate',
        duration: 20,
        content: '''
1) Goal: Use JavaScript to add behavior to pages.
2) Declare variables with let/const and basic types.
3) Write functions to reuse logic.
4) Use if statements and loops for control flow.
5) Work with objects and arrays to store data.
6) Practice: write a function that greets a user.
        ''',
        resources: const [
          'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide',
        ],
        xpReward: 75,
      ),
      Lesson(
        id: 'html_semantics',
        title: 'Semantic HTML: Article & Section',
        description: 'Use semantic elements to make content meaningful.',
        type: LessonType.lesson,
        category: 'HTML',
        difficulty: 'Beginner',
        duration: 14,
        content: '''
1) Goal: Give structure meaning with semantic HTML.
2) Use <header>, <nav>, <main>, and <footer> for page regions.
3) Use <article> for self-contained content.
4) Use <section> for themed groupings with headings.
5) Use <aside> for related or secondary content.
6) Practice: outline a blog page with semantic regions.
        ''',
        resources: const [
          'https://developer.mozilla.org/en-US/docs/Learn_web_development/Core/Structuring_content/Structuring_a_page_of_content',
          'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference',
        ],
        xpReward: 60,
      ),
      Lesson(
        id: 'css_flexbox',
        title: 'CSS Flexbox Essentials',
        description: 'Build flexible layouts with a single layout axis.',
        type: LessonType.lesson,
        category: 'CSS',
        difficulty: 'Beginner',
        duration: 16,
        content: '''
1) Goal: Build one-dimensional layouts with flexbox.
2) Set display: flex on a container to create flex items.
3) Understand main axis vs cross axis and flex-direction.
4) Align items with justify-content and align-items.
5) Use flex-wrap to wrap items on smaller screens.
6) Practice: create a responsive row of cards.
        ''',
        resources: const [
          'https://developer.mozilla.org/docs/Web/CSS/CSS_Flexible_Box_Layout/Basic_Concepts_of_Flexbox',
          'https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_flexible_box_layout',
        ],
        xpReward: 70,
      ),
      Lesson(
        id: 'js_dom_basics',
        title: 'DOM Basics',
        description: 'Use the DOM to read and update web pages.',
        type: LessonType.lesson,
        category: 'JavaScript',
        difficulty: 'Beginner',
        duration: 18,
        content: '''
1) Goal: Read and update the DOM tree.
2) Use document.querySelector/querySelectorAll to select nodes.
3) Update text with textContent or innerHTML.
4) Change styles or classes with classList.
5) Add event listeners to respond to user actions.
6) Practice: toggle a class on button click.
        ''',
        resources: const [
          'https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model/Introduction',
          'https://developer.mozilla.org/en-US/docs/Glossary/DOM',
        ],
        xpReward: 70,
      ),
      Lesson(
        id: 'flutter_overview',
        title: 'Flutter Overview',
        description: 'Understand Flutter’s widget-first approach.',
        type: LessonType.lesson,
        category: 'Flutter',
        difficulty: 'Beginner',
        duration: 18,
        content: '''
1) Goal: Understand Flutter’s widget-based UI system.
2) Everything is a widget; UIs are built by composing widgets.
3) Widgets describe configuration; the framework renders them.
4) Use Material/Cupertino widgets for platform styling.
5) Hot reload speeds iteration during development.
6) Practice: sketch a widget tree for a login screen.
        ''',
        resources: const [
          'https://docs.flutter.dev/ui/widgets-intro',
          'https://docs.flutter.dev/get-started/flutter-for',
        ],
        xpReward: 75,
      ),
      Lesson(
        id: 'flutter_stateful',
        title: 'Stateful vs Stateless Widgets',
        description: 'Choose the right widget for the job.',
        type: LessonType.lesson,
        category: 'Flutter',
        difficulty: 'Beginner',
        duration: 16,
        content: '''
1) Goal: Pick stateless vs stateful widgets correctly.
2) Stateless widgets render from immutable inputs.
3) Stateful widgets keep mutable state in a State object.
4) Call setState() to rebuild when state changes.
5) Keep state close to where it is used.
6) Practice: build a counter that increments on tap.
        ''',
        resources: const [
          'https://docs.flutter.dev/ui/interactive',
          'https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html',
        ],
        xpReward: 70,
      ),
      Lesson(
        id: 'react_intro',
        title: 'React Foundations',
        description: 'Build UI from reusable components.',
        type: LessonType.lesson,
        category: 'React',
        difficulty: 'Beginner',
        duration: 18,
        content: '''
1) Goal: Build UI with reusable React components.
2) Components receive data through props.
3) State stores component memory and triggers re-render.
4) Use hooks like useState for local state.
5) UI updates when state changes.
6) Practice: create a profile card with props.
        ''',
        resources: const [
          'https://react.dev/learn/passing-props-to-a-component',
          'https://react.dev/learn/state-a-components-memory',
        ],
        xpReward: 80,
      ),
      Lesson(
        id: 'node_intro',
        title: 'Node.js Foundations',
        description: 'Run JavaScript on the server.',
        type: LessonType.lesson,
        category: 'Node.js',
        difficulty: 'Beginner',
        duration: 18,
        content: '''
1) Goal: Run JavaScript outside the browser with Node.js.
2) Node.js uses the V8 JavaScript engine.
3) Event-driven, non-blocking I/O enables concurrency.
4) Use built-in modules like http and fs.
5) npm provides reusable packages.
6) Practice: build a simple HTTP server.
        ''',
        resources: const [
          'https://nodejs.org/en/learn/getting-started/introduction-to-nodejs',
        ],
        xpReward: 80,
      ),
      Lesson(
        id: 'c_intro',
        title: 'C Programming Basics',
        description: 'Understand C syntax, memory, and basic I/O.',
        type: LessonType.lesson,
        category: 'C',
        difficulty: 'Beginner',
        duration: 18,
        content: '''
1) Goal: Learn C program structure and basic I/O.
2) Programs start in main() and return an int status.
3) Use #include <stdio.h> for printf/scanf.
4) Declare variables with explicit types.
5) Pointers store memory addresses.
6) Practice: read two integers and print their sum.
        ''',
        resources: const [
          'https://en.cppreference.com/w/c/language/main_function',
          'https://docs.cppreference.com/w/c/io/printf.html',
        ],
        xpReward: 80,
      ),
      Lesson(
        id: 'cpp_intro',
        title: 'C++ Fundamentals',
        description: 'Learn classes, objects, and STL basics.',
        type: LessonType.lesson,
        category: 'C++',
        difficulty: 'Beginner',
        duration: 20,
        content: '''
1) Goal: Understand C++ classes and standard library basics.
2) Define classes to bundle data and behavior.
3) Constructors initialize objects when they are created.
4) Use <iostream> for std::cout and std::cin.
5) std::vector stores a dynamic contiguous array.
6) Practice: create a class and store instances in a vector.
        ''',
        resources: const [
          'https://en.cppreference.com/w/cpp/language/constructors',
          'https://en.cppreference.com/w/cpp/io/cout',
          'https://en.cppreference.com/w/cpp/container/vector',
        ],
        xpReward: 90,
      ),
      Lesson(
        id: 'python_intro',
        title: 'Python Basics',
        description: 'Write your first Python programs.',
        type: LessonType.lesson,
        category: 'Python',
        difficulty: 'Beginner',
        duration: 12,
        content: '''
1) Goal: Write simple Python programs.
2) Use print() to display output.
3) Variables bind to values without type declarations.
4) Use numbers, strings, and lists as core types.
5) Indentation defines code blocks.
6) Practice: compute the area of a rectangle.
        ''',
        resources: const [
          'https://docs.python.org/3/tutorial/index.html',
        ],
        xpReward: 60,
      ),
      Lesson(
        id: 'python_flow',
        title: 'Python Control Flow',
        description: 'Use if statements and loops.',
        type: LessonType.lesson,
        category: 'Python',
        difficulty: 'Beginner',
        duration: 14,
        content: '''
1) Goal: Use control flow with if, for, and while.
2) if/elif/else selects a branch based on conditions.
3) for loops iterate over sequences.
4) while loops repeat while a condition is true.
5) Use break and continue to control loops.
6) Practice: count pass/fail scores in a list.
        ''',
        resources: const [
          'https://docs.python.org/3/tutorial/controlflow.html',
        ],
        xpReward: 70,
      ),
      Lesson(
        id: 'ds_arrays',
        title: 'Data Structures: Arrays',
        description: 'Store ordered data efficiently.',
        type: LessonType.lesson,
        category: 'Data Structures',
        difficulty: 'Beginner',
        duration: 14,
        content: '''
1) Goal: Understand arrays and dynamic arrays.
2) Arrays store elements contiguously for fast index access.
3) Access by index is O(1); inserts in the middle cost O(n).
4) Dynamic arrays (e.g., std::vector) grow as needed.
5) Capacity vs size affects performance.
6) Practice: compute the max value in an array.
        ''',
        resources: const [
          'https://en.cppreference.com/w/cpp/container/vector',
          'https://en.cppreference.com/w/cpp/container/array',
        ],
        xpReward: 70,
      ),
      Lesson(
        id: 'ds_linked_list',
        title: 'Data Structures: Linked Lists',
        description: 'Connect nodes with pointers.',
        type: LessonType.lesson,
        category: 'Data Structures',
        difficulty: 'Beginner',
        duration: 16,
        content: '''
1) Goal: Understand linked lists and node pointers.
2) Nodes store data and link to the next (and optionally previous).
3) Insert/remove can be O(1) when position is known.
4) Random access requires traversal.
5) Doubly-linked lists allow bidirectional traversal.
6) Practice: draw nodes for A -> B -> C.
        ''',
        resources: const [
          'https://en.cppreference.com/w/cpp/container/list',
        ],
        xpReward: 80,
      ),
      Lesson(
        id: 'cyber_intro',
        title: 'Cybersecurity Basics',
        description: 'Understand threats and defenses.',
        type: LessonType.lesson,
        category: 'Cybersecurity',
        difficulty: 'Beginner',
        duration: 12,
        content: '''
1) Goal: Learn the CIA triad foundations.
2) Confidentiality limits unauthorized access.
3) Integrity protects against improper modification.
4) Availability ensures reliable access to systems.
5) Threats target people, processes, and technology.
6) Practice: identify risks in a weak password policy.
        ''',
        resources: const [
          'https://csrc.nist.gov/glossary/term/confidentiality',
          'https://csrc.nist.gov/glossary/term/integrity',
          'https://csrc.nist.gov/glossary/term/availability',
        ],
        xpReward: 65,
      ),
      Lesson(
        id: 'cyber_auth',
        title: 'Authentication Essentials',
        description: 'Protect accounts with smart login flows.',
        type: LessonType.lesson,
        category: 'Cybersecurity',
        difficulty: 'Beginner',
        duration: 15,
        content: '''
1) Goal: Understand digital identity and authentication.
2) Digital identity guidelines cover proofing, authentication, and federation.
3) Authentication verifies control of an authenticator.
4) Multi-factor authentication reduces risk.
5) Secure flows include recovery and lockout handling.
6) Practice: sketch a two-step login flow.
        ''',
        resources: const [
          'https://csrc.nist.gov/publications/detail/sp/800-63-4/draft',
        ],
        xpReward: 75,
      ),
      Lesson(
        id: 'ai_intro',
        title: 'AI Basics',
        description: 'Learn what AI is and what it can do.',
        type: LessonType.lesson,
        category: 'AI Basics',
        difficulty: 'Beginner',
        duration: 12,
        content: '''
1) Goal: Define AI and identify common use cases.
2) AI systems use data to produce predictions or recommendations.
3) Models learn patterns during training, then run inference.
4) Data quality affects model performance.
5) AI can classify, summarize, or recommend.
6) Practice: describe an AI use case with inputs and outputs.
        ''',
        resources: const [
          'https://csrc.nist.gov/glossary/term/artificial_intelligence',
          'https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.100-1.pdf',
        ],
        xpReward: 65,
      ),
      Lesson(
        id: 'ai_prompting',
        title: 'Prompting for Developers',
        description: 'Craft prompts that get better results.',
        type: LessonType.lesson,
        category: 'AI Basics',
        difficulty: 'Beginner',
        duration: 14,
        content: '''
1) Goal: Write effective prompts for AI systems.
2) Give clear instructions and constraints.
3) Provide context and desired output format.
4) Use examples to steer style or structure.
5) Iterate and refine based on results.
6) Practice: prompt an AI to summarize an article in bullets.
        ''',
        resources: const [
          'https://platform.openai.com/docs/guides/prompt-engineering',
        ],
        xpReward: 75,
      ),
    ];

    _microSteps
      ..clear()
      ..addAll({
        'html_intro': [
          const MicroLessonStep(
            id: 'html_mcq',
            type: MicroLessonType.mcq,
            title: 'HTML Basics',
            prompt: 'HTML stands for?',
            options: [
              'Hyper Text Markup Language',
              'Home Tool Markup Language',
              'Hyperlinks Text ML',
              'High Tech Modern Language',
            ],
            answer: 'Hyper Text Markup Language',
          ),
          const MicroLessonStep(
            id: 'html_fill',
            type: MicroLessonType.fillBlank,
            title: 'Headings',
            prompt: 'The largest heading tag is ____.',
            answer: '<h1>',
            hints: ['Starts with h', 'It is heading level 1'],
          ),
          const MicroLessonStep(
            id: 'html_drag',
            type: MicroLessonType.dragDrop,
            title: 'Document Structure',
            prompt: 'Reorder the tags to form a valid page skeleton.',
            tokens: ['<head>', '<body>', '</body>', '</head>'],
            correctOrder: ['<head>', '</head>', '<body>', '</body>'],
          ),
          const MicroLessonStep(
            id: 'html_output',
            type: MicroLessonType.output,
            title: 'Output Prediction',
            prompt: 'What shows on the page?',
            code: '<p>Hello</p>',
            options: ['Hello', '<p>', 'Paragraph', 'Nothing'],
            answer: 'Hello',
          ),
        ],
        'css_basics': [
          const MicroLessonStep(
            id: 'css_mcq',
            type: MicroLessonType.mcq,
            title: 'CSS Color',
            prompt: 'Which property changes text color?',
            options: ['color', 'text-color', 'font-color', 'text-style'],
            answer: 'color',
          ),
          const MicroLessonStep(
            id: 'css_output',
            type: MicroLessonType.output,
            title: 'Style Output',
            prompt: 'What color is the text?',
            code: '.title { color: red; }',
            options: ['Red', 'Blue', 'Black', 'No change'],
            answer: 'Red',
          ),
        ],
        'js_intro': [
          const MicroLessonStep(
            id: 'js_fill',
            type: MicroLessonType.fillBlank,
            title: 'Variables',
            prompt: 'Use ____ to declare a block-scoped variable.',
            answer: 'let',
            hints: ['It is newer than var', 'Three letters'],
          ),
          const MicroLessonStep(
            id: 'js_output',
            type: MicroLessonType.output,
            title: 'Console Output',
            prompt: 'What is the output?',
            code: 'console.log(2 + 3)',
            options: ['5', '23', 'Error', 'undefined'],
            answer: '5',
          ),
        ],
        'react_intro': [
          const MicroLessonStep(
            id: 'react_mcq',
            type: MicroLessonType.mcq,
            title: 'React Concepts',
            prompt: 'React is primarily a...',
            options: ['Database', 'UI library', 'Operating system', 'Server'],
            answer: 'UI library',
          ),
          const MicroLessonStep(
            id: 'react_fill',
            type: MicroLessonType.fillBlank,
            title: 'Props',
            prompt: 'Props are ____ passed into a component.',
            answer: 'data',
            hints: ['Starts with d', 'Used to configure UI'],
          ),
        ],
        'node_intro': [
          const MicroLessonStep(
            id: 'node_mcq',
            type: MicroLessonType.mcq,
            title: 'Node.js Engine',
            prompt: 'Node.js runs on which engine?',
            options: ['V8', 'SpiderMonkey', 'Chakra', 'Java'],
            answer: 'V8',
          ),
        ],
      });
  }

  void updateProgress(String lessonId, double progressValue) {
    _progress[lessonId] = progressValue;
    notifyListeners();
  }

  double? getProgress(String lessonId) {
    return _progress[lessonId];
  }

  List<Lesson> getLessonsByCategory(String category) {
    if (category == 'All' || category == 'all') return _lessons;
    return _lessons
        .where((l) => l.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  Lesson? getLessonById(String id) {
    try {
      return _lessons.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }

  void toggleOfflineAvailability(String lessonId) {
    final index = _lessons.indexWhere((l) => l.id == lessonId);
    if (index != -1) {
      _lessons[index].isOfflineAvailable = !_lessons[index].isOfflineAvailable;
      notifyListeners();
    }
  }

  void markLessonCompleted(String lessonId) {
    final index = _lessons.indexWhere((l) => l.id == lessonId);
    if (index != -1) {
      _lessons[index].isCompleted = true;
      _progress[lessonId] = 1.0;
      notifyListeners();
    }
  }

  bool addLesson(Lesson lesson) {
    final exists = _lessons.any((l) => l.id == lesson.id);
    if (exists) return false;
    _lessons.insert(0, lesson);
    _progress[lesson.id] = 0.0;
    notifyListeners();
    return true;
  }
}
