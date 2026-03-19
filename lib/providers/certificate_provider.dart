import 'package:flutter/material.dart';
import '../models/certificate_model.dart';

class CertificateProvider extends ChangeNotifier {
  final List<Certificate> _certificates = [
    Certificate(
      id: 'cert_web_foundations',
      title: 'Web Foundations',
      description: 'Completed the HTML + CSS + JavaScript learning track.',
      track: 'Frontend',
      issuedAt: DateTime.now(),
    ),
    Certificate(
      id: 'cert_react_ready',
      title: 'React Ready',
      description: 'Built React components and state-driven UIs.',
      track: 'Frontend',
      issuedAt: DateTime.now(),
    ),
    Certificate(
      id: 'cert_flutter_build',
      title: 'Flutter Builder',
      description: 'Completed core Flutter lessons and quizzes.',
      track: 'Mobile',
      issuedAt: DateTime.now(),
    ),
  ];

  List<Certificate> get certificates => _certificates;

  Certificate? getById(String id) {
    try {
      return _certificates.firstWhere((cert) => cert.id == id);
    } catch (_) {
      return null;
    }
  }
}
