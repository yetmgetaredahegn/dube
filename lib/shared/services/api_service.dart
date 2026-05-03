import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class ApiService {
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<dynamic> get(String path, {Map<String, String>? headers}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final resp = await client.get(uri, headers: headers);
    return _processResponse(resp);
  }

  Future<dynamic> post(String path, {Map<String, String>? headers, Object? body}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final reqHeaders = <String, String>{'Content-Type': 'application/json'};
    if (headers != null) reqHeaders.addAll(headers);
    final resp = await client.post(uri, headers: reqHeaders, body: body == null ? null : jsonEncode(body));
    return _processResponse(resp);
  }

  dynamic _processResponse(http.Response resp) {
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body == null || resp.body.isEmpty) return null;
      return jsonDecode(resp.body);
    }
    throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
  }
}
