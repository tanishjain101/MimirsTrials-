import 'package:flutter/material.dart';
import '../models/career_model.dart';

class CareerProvider extends ChangeNotifier {
  final List<CareerPath> _paths = [
    CareerPath(
      id: 'frontend',
      title: 'Frontend Developer',
      description: 'Build delightful user interfaces and web apps.',
      milestones: [
        'HTML & CSS Foundations',
        'JavaScript Essentials',
        'React Projects',
        'Portfolio Launch',
      ],
      courseIds: [
        'web_path',
      ],
      skills: [
        'HTML',
        'CSS',
        'JavaScript',
        'React',
      ],
    ),
    CareerPath(
      id: 'backend',
      title: 'Backend Developer',
      description: 'Design APIs, databases, and scalable services.',
      milestones: [
        'Node.js Fundamentals',
        'REST APIs',
        'Database Design',
        'Deploy to Cloud',
      ],
      courseIds: [
        'web_path',
        'python_path',
        'ds_path',
      ],
      skills: [
        'Node.js',
        'JavaScript',
        'Python',
        'Data Structures',
      ],
    ),
    CareerPath(
      id: 'ai_engineer',
      title: 'AI Engineer',
      description: 'Build intelligent apps with ML and AI APIs.',
      milestones: [
        'Python Basics',
        'Data Processing',
        'Model Deployment',
        'AI Product MVP',
      ],
      courseIds: [
        'python_path',
        'ai_path',
      ],
      skills: [
        'Python',
        'AI Basics',
        'Data Structures',
      ],
    ),
  ];

  String? _activePathId;

  List<CareerPath> get paths => _paths;
  String? get activePathId => _activePathId;

  void setActivePath(String id) {
    _activePathId = id;
    notifyListeners();
  }
}
