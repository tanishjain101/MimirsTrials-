import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../models/lesson_model.dart' hide LessonType;
import '../models/quiz_model.dart';

class CourseProvider extends ChangeNotifier {
  List<Course> _courses = [];
  Course? _currentCourse;
  List<Lesson> _lessons = [];
  final List<Quiz> _quizzes = [];
  bool _isLoading = false;
  String? _error;

  List<Course> get courses => _courses;
  Course? get currentCourse => _currentCourse;
  List<Lesson> get lessons => _lessons;
  List<Quiz> get quizzes => _quizzes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCourses() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Mock implementation - demo course map
      _courses = [
        Course(
          id: 'web_path',
          title: 'Web Development',
          description: 'Build modern websites step by step.',
          language: 'Web',
          totalLessons: 14,
          totalXp: 1285,
          nodes: [
            LessonNode(
              id: 'html_intro',
              title: 'HTML',
              type: LessonType.lesson,
              position: NodePosition(x: 0.5, y: 0.05),
              prerequisites: const [],
              xpReward: 50,
              duration: 12,
              isLocked: false,
              isCurrent: true,
            ),
            LessonNode(
              id: 'html_quiz',
              title: 'HTML Quiz',
              type: LessonType.quiz,
              position: NodePosition(x: 0.7, y: 0.12),
              prerequisites: const ['html_intro'],
              xpReward: 80,
              duration: 10,
            ),
            LessonNode(
              id: 'css_basics',
              title: 'CSS',
              type: LessonType.lesson,
              position: NodePosition(x: 0.4, y: 0.19),
              prerequisites: const ['html_quiz'],
              xpReward: 60,
              duration: 15,
            ),
            LessonNode(
              id: 'css_quiz',
              title: 'CSS Quiz',
              type: LessonType.quiz,
              position: NodePosition(x: 0.65, y: 0.26),
              prerequisites: const ['css_basics'],
              xpReward: 90,
              duration: 10,
            ),
            LessonNode(
              id: 'js_intro',
              title: 'JavaScript',
              type: LessonType.lesson,
              position: NodePosition(x: 0.5, y: 0.33),
              prerequisites: const ['css_quiz'],
              xpReward: 75,
              duration: 20,
            ),
            LessonNode(
              id: 'js_quiz',
              title: 'JavaScript Quiz',
              type: LessonType.quiz,
              position: NodePosition(x: 0.7, y: 0.4),
              prerequisites: const ['js_intro'],
              xpReward: 110,
              duration: 10,
            ),
            LessonNode(
              id: 'react_intro',
              title: 'React',
              type: LessonType.lesson,
              position: NodePosition(x: 0.4, y: 0.47),
              prerequisites: const ['js_quiz'],
              xpReward: 90,
              duration: 25,
            ),
            LessonNode(
              id: 'react_quiz',
              title: 'React Quiz',
              type: LessonType.quiz,
              position: NodePosition(x: 0.62, y: 0.54),
              prerequisites: const ['react_intro'],
              xpReward: 120,
              duration: 10,
            ),
            LessonNode(
              id: 'node_intro',
              title: 'Node.js',
              type: LessonType.lesson,
              position: NodePosition(x: 0.45, y: 0.61),
              prerequisites: const ['react_quiz'],
              xpReward: 90,
              duration: 25,
            ),
            LessonNode(
              id: 'node_quiz',
              title: 'Node.js Quiz',
              type: LessonType.quiz,
              position: NodePosition(x: 0.65, y: 0.68),
              prerequisites: const ['node_intro'],
              xpReward: 120,
              duration: 10,
            ),
            LessonNode(
              id: 'c_intro',
              title: 'C',
              type: LessonType.lesson,
              position: NodePosition(x: 0.42, y: 0.75),
              prerequisites: const ['node_quiz'],
              xpReward: 80,
              duration: 18,
            ),
            LessonNode(
              id: 'c_quiz',
              title: 'C Quiz',
              type: LessonType.quiz,
              position: NodePosition(x: 0.62, y: 0.82),
              prerequisites: const ['c_intro'],
              xpReward: 110,
              duration: 10,
            ),
            LessonNode(
              id: 'cpp_intro',
              title: 'C++',
              type: LessonType.lesson,
              position: NodePosition(x: 0.45, y: 0.89),
              prerequisites: const ['c_quiz'],
              xpReward: 90,
              duration: 20,
            ),
            LessonNode(
              id: 'cpp_quiz',
              title: 'C++ Quiz',
              type: LessonType.quiz,
              position: NodePosition(x: 0.65, y: 0.96),
              prerequisites: const ['cpp_intro'],
              xpReward: 120,
              duration: 10,
            ),
          ],
        ),
        Course(
          id: 'flutter_path',
          title: 'Flutter Development',
          description: 'Build beautiful apps with Flutter.',
          language: 'Flutter',
          totalLessons: 3,
          totalXp: 245,
          nodes: [
            LessonNode(
              id: 'flutter_overview',
              title: 'Flutter Overview',
              type: LessonType.lesson,
              position: NodePosition(x: 0.5, y: 0.12),
              prerequisites: const [],
              xpReward: 75,
              duration: 18,
              isLocked: false,
              isCurrent: true,
            ),
            LessonNode(
              id: 'flutter_quiz',
              title: 'Flutter Quiz',
              type: LessonType.quiz,
              position: NodePosition(x: 0.7, y: 0.45),
              prerequisites: const ['flutter_overview'],
              xpReward: 100,
              duration: 10,
            ),
            LessonNode(
              id: 'flutter_stateful',
              title: 'Stateful Widgets',
              type: LessonType.lesson,
              position: NodePosition(x: 0.45, y: 0.72),
              prerequisites: const ['flutter_quiz'],
              xpReward: 70,
              duration: 16,
            ),
          ],
        ),
        Course(
          id: 'python_path',
          title: 'Python Programming',
          description: 'Start coding with Python.',
          language: 'Python',
          totalLessons: 3,
          totalXp: 220,
          nodes: [
            LessonNode(
              id: 'python_intro',
              title: 'Python Basics',
              type: LessonType.lesson,
              position: NodePosition(x: 0.5, y: 0.12),
              prerequisites: const [],
              xpReward: 60,
              duration: 12,
              isLocked: false,
              isCurrent: true,
            ),
            LessonNode(
              id: 'python_quiz',
              title: 'Python Quiz',
              type: LessonType.quiz,
              position: NodePosition(x: 0.7, y: 0.45),
              prerequisites: const ['python_intro'],
              xpReward: 90,
              duration: 10,
            ),
            LessonNode(
              id: 'python_flow',
              title: 'Control Flow',
              type: LessonType.lesson,
              position: NodePosition(x: 0.45, y: 0.72),
              prerequisites: const ['python_quiz'],
              xpReward: 70,
              duration: 14,
            ),
          ],
        ),
        Course(
          id: 'ds_path',
          title: 'Data Structures',
          description: 'Master arrays, lists, and more.',
          language: 'DSA',
          totalLessons: 3,
          totalXp: 250,
          nodes: [
            LessonNode(
              id: 'ds_arrays',
              title: 'Arrays',
              type: LessonType.lesson,
              position: NodePosition(x: 0.5, y: 0.12),
              prerequisites: const [],
              xpReward: 70,
              duration: 14,
              isLocked: false,
              isCurrent: true,
            ),
            LessonNode(
              id: 'ds_quiz',
              title: 'DS Quiz',
              type: LessonType.quiz,
              position: NodePosition(x: 0.68, y: 0.45),
              prerequisites: const ['ds_arrays'],
              xpReward: 100,
              duration: 10,
            ),
            LessonNode(
              id: 'ds_linked_list',
              title: 'Linked Lists',
              type: LessonType.lesson,
              position: NodePosition(x: 0.42, y: 0.72),
              prerequisites: const ['ds_quiz'],
              xpReward: 80,
              duration: 16,
            ),
          ],
        ),
        Course(
          id: 'cyber_path',
          title: 'Cybersecurity',
          description: 'Protect apps and users.',
          language: 'Security',
          totalLessons: 3,
          totalXp: 235,
          nodes: [
            LessonNode(
              id: 'cyber_intro',
              title: 'Security Basics',
              type: LessonType.lesson,
              position: NodePosition(x: 0.5, y: 0.12),
              prerequisites: const [],
              xpReward: 65,
              duration: 12,
              isLocked: false,
              isCurrent: true,
            ),
            LessonNode(
              id: 'cyber_quiz',
              title: 'Security Quiz',
              type: LessonType.quiz,
              position: NodePosition(x: 0.7, y: 0.45),
              prerequisites: const ['cyber_intro'],
              xpReward: 95,
              duration: 10,
            ),
            LessonNode(
              id: 'cyber_auth',
              title: 'Authentication',
              type: LessonType.lesson,
              position: NodePosition(x: 0.45, y: 0.72),
              prerequisites: const ['cyber_quiz'],
              xpReward: 75,
              duration: 15,
            ),
          ],
        ),
        Course(
          id: 'ai_path',
          title: 'AI Basics',
          description: 'Learn the foundations of AI.',
          language: 'AI',
          totalLessons: 3,
          totalXp: 235,
          nodes: [
            LessonNode(
              id: 'ai_intro',
              title: 'AI Intro',
              type: LessonType.lesson,
              position: NodePosition(x: 0.5, y: 0.12),
              prerequisites: const [],
              xpReward: 65,
              duration: 12,
              isLocked: false,
              isCurrent: true,
            ),
            LessonNode(
              id: 'ai_quiz',
              title: 'AI Quiz',
              type: LessonType.quiz,
              position: NodePosition(x: 0.7, y: 0.45),
              prerequisites: const ['ai_intro'],
              xpReward: 95,
              duration: 10,
            ),
            LessonNode(
              id: 'ai_prompting',
              title: 'Prompting',
              type: LessonType.lesson,
              position: NodePosition(x: 0.45, y: 0.72),
              prerequisites: const ['ai_quiz'],
              xpReward: 75,
              duration: 14,
            ),
          ],
        ),
      ];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCourse(String courseId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentCourse = _courses.firstWhere(
        (course) => course.id == courseId,
        orElse: () => _courses.first,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLessons(List<String> lessonIds) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Mock implementation - no Firebase
      _lessons = [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> downloadLessonForOffline(String lessonId) async {
    try {
      // Mock implementation - no Firebase
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Lesson? getLessonById(String id) {
    try {
      return _lessons.firstWhere((l) => l.id == id);
    } catch (e) {
      return null;
    }
  }

  Quiz? getQuizById(String id) {
    try {
      return _quizzes.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateNodeProgress(String nodeId, bool completed) {
    if (_currentCourse == null) return;

    final index = _currentCourse!.nodes.indexWhere((n) => n.id == nodeId);
    if (index != -1) {
      _currentCourse!.nodes[index].isCompleted = completed;
      notifyListeners();
    }
  }

  void unlockNextNodes(String nodeId) {
    if (_currentCourse == null) return;

    final nodeIndex = _currentCourse!.nodes.indexWhere((n) => n.id == nodeId);
    if (nodeIndex == -1) return;

    for (var i = nodeIndex + 1; i < _currentCourse!.nodes.length; i++) {
      final node = _currentCourse!.nodes[i];
      if (node.prerequisites.contains(nodeId)) {
        node.isLocked = false;
      }
    }
    notifyListeners();
  }
}
