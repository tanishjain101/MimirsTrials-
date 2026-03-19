import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BackendResult<T> {
  final T? data;
  final String? error;
  bool get isSuccess => error == null;

  BackendResult.success(this.data) : error = null;
  BackendResult.failure(this.error) : data = null;
}

class PostgresBackend {
  PostgresBackend({http.Client? client})
      : _client = client ?? http.Client(),
        _baseUrl = _readEnvSafely('POSTGRES_API_URL');

  final http.Client _client;
  final String? _baseUrl;

  static String? _readEnvSafely(String key) {
    try {
      return dotenv.env[key];
    } catch (_) {
      return null;
    }
  }

  bool get isConfigured => _baseUrl != null && _baseUrl!.isNotEmpty;

  Future<BackendResult<Map<String, dynamic>>> signIn({
    required String email,
    required String password,
    required String role,
  }) async {
    if (!isConfigured) {
      return BackendResult.failure('Postgres backend not configured');
    }
    try {
      final response = await _client
          .post(
        Uri.parse('$_baseUrl/auth/sign-in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
        }),
      )
          .timeout(const Duration(seconds: 6));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return BackendResult.success(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return BackendResult.failure('Sign-in failed (${response.statusCode})');
    } catch (e) {
      return BackendResult.failure(e.toString());
    }
  }

  Future<BackendResult<Map<String, dynamic>>> signUp({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    if (!isConfigured) {
      return BackendResult.failure('Postgres backend not configured');
    }
    try {
      final response = await _client
          .post(
        Uri.parse('$_baseUrl/auth/sign-up'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'displayName': displayName,
          'role': role,
        }),
      )
          .timeout(const Duration(seconds: 6));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return BackendResult.success(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      return BackendResult.failure('Sign-up failed (${response.statusCode})');
    } catch (e) {
      return BackendResult.failure(e.toString());
    }
  }

  Future<BackendResult<void>> syncEvents(List<Map<String, dynamic>> events) async {
    if (!isConfigured) {
      return BackendResult.failure('Postgres backend not configured');
    }
    try {
      final response = await _client
          .post(
        Uri.parse('$_baseUrl/sync/events'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'events': events}),
      )
          .timeout(const Duration(seconds: 6));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return BackendResult.success(null);
      }
      return BackendResult.failure('Sync failed (${response.statusCode})');
    } catch (e) {
      return BackendResult.failure(e.toString());
    }
  }
}
