import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_me/firebase_options.dart';

/// Direct HTTPS writes to Realtime Database when the Flutter SDK stalls.
class RtdbRestService {
  RtdbRestService._();

  static final RtdbRestService instance = RtdbRestService._();

  static const Duration _timeout = Duration(seconds: 30);

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      sendTimeout: _timeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  String _urlForPath(String path) {
    final clean = path.split('/').where((s) => s.isNotEmpty).join('/');
    final base = DefaultFirebaseOptions.databaseUrl.replaceAll(RegExp(r'/$'), '');
    return '$base/$clean.json';
  }

  Future<String> _authQuery() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Not signed in to Firebase.');
    }
    // Cached token first — getIdToken(true) hits securetoken.googleapis.com
    // and fails when the API key blocks Identity Toolkit / GrantToken.
    var token = await user.getIdToken(false);
    if (token == null || token.isEmpty) {
      token = await user.getIdToken(true);
    }
    if (token == null || token.isEmpty) {
      throw StateError('Could not get Firebase auth token.');
    }
    return token;
  }

  Future<void> put(String path, Object? data) async {
    final token = await _authQuery();
    final response = await _dio.put(
      _urlForPath(path),
      queryParameters: {'auth': token},
      data: jsonEncode(data),
    );
    _ensureOk(response, 'PUT', path);
  }

  Future<dynamic> get(String path) async {
    final token = await _authQuery();
    final response = await _dio.get(
      _urlForPath(path),
      queryParameters: {'auth': token},
    );
    final code = response.statusCode ?? 0;
    if (code == 404) {
      return null;
    }
    _ensureOk(response, 'GET', path);
    return response.data;
  }

  Future<void> patch(String path, Map<String, dynamic> data) async {
    final token = await _authQuery();
    final response = await _dio.patch(
      _urlForPath(path),
      queryParameters: {'auth': token},
      data: jsonEncode(data),
    );
    _ensureOk(response, 'PATCH', path);
  }

  void _ensureOk(Response<dynamic> response, String method, String path) {
    final code = response.statusCode ?? 0;
    if (code >= 200 && code < 300) {
      return;
    }
    final body = response.data;
    throw Exception(
      'RTDB $method $path failed ($code): $body. '
      'Check API key AIzaSyCXmkvy… has Realtime Database API enabled (mobile key).',
    );
  }
}
