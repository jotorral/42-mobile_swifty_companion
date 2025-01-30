import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static String get clientId => dotenv.env['CLIENT_ID'] ?? 'default_client_id';
  static String get clientSecret =>
      dotenv.env['CLIENT_SECRET'] ?? 'default_client_secret';
  static String get tokenEndpoint =>
      dotenv.env['TOKEN_ENDPOINT'] ?? 'https://api.intra.42.fr/v2/oauth/token';

  String? _accessToken;

  Future<void> authenticateWithClientCredentials() async {
    final response = await http.post(
      Uri.parse(tokenEndpoint),
      body: {
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final tokenData = jsonDecode(response.body);
      _accessToken = tokenData['access_token'];
      debugPrint("Token obtenido: $_accessToken");
    } else {
      throw Exception("Error al obtener el token: ${response.body}");
    }
  }

  Future<List<dynamic>> fetchPublicData({int page = 1}) async {
    if (_accessToken == null) {
      throw Exception("No hay token disponible. Llama a authenticate primero.");
    }

    final response = await http.get(
      // Uri.parse("https://api.intra.42.fr/v2/cursus/42/users"),
      // Uri.parse("https://api.intra.42.fr/v2/flash_users?page[size]=10"),
      Uri.parse("https://api.intra.42.fr/v2/campus/40/users?page=$page&per_page=100"),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception("Error al obtener datos: ${response.body}");
    }
  }
}
