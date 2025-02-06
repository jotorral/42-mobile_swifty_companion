import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../main.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  static String get clientId => dotenv.env['CLIENT_ID'] ?? 'default_client_id';
  static String get clientSecret =>
      dotenv.env['CLIENT_SECRET'] ?? 'default_client_secret';
  static String get tokenEndpoint =>
      dotenv.env['TOKEN_ENDPOINT'] ?? 'https://api.intra.42.fr/v2/oauth/token';

  String? _accessToken;
  DateTime? _tokenExpiryDate;

  Future<void> _authenticateWithClientCredentials() async {
    debugPrint("🔄 Solicitando nuevo token...");

    final response = await http.post(
      Uri.parse(tokenEndpoint),
      body: {
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      Map tokenData = jsonDecode(response.body);
      _accessToken = tokenData['access_token'];
      var expiresIn = tokenData['expires_in'] ?? 7200; // Valor por defecto 2 h.
      _tokenExpiryDate = DateTime.now().add(Duration(seconds: expiresIn));

      debugPrint("✅ Token obtenido: $_accessToken");
      debugPrint("⏳ Expira en: $_tokenExpiryDate");
    } else {
      throw Exception("❌ Error al obtener el token: ${response.body}");
    }
  }

  /// 🔹 Verifica si el token es válido, si no, obtiene uno nuevo
  Future<void> _ensureAValidToken() async {
    if (_accessToken == null || _tokenExpiryDate == null || DateTime.now().isAfter(_tokenExpiryDate!.subtract(Duration(minutes: 5)))) {
      await _authenticateWithClientCredentials();
    }
  }

  Future<List<dynamic>> fetchPublicData({int page = 1}) async {
    await _ensureAValidToken();

    final response = await http.get(
      // Uri.parse("https://api.intra.42.fr/v2/cursus/42/users"),
      // Uri.parse("https://api.intra.42.fr/v2/flash_users?page[size]=10"),
      Uri.parse("https://api.intra.42.fr/v2/campus/40/users?page=$page&per_page=100"),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception("❌ Error al obtener datos: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    await _ensureAValidToken();

    final response = await http.get(
      // Uri.parse("https://api.intra.42.fr/v2/cursus/42/users"),
      // Uri.parse("https://api.intra.42.fr/v2/flash_users?page[size]=10"),
      Uri.parse("https://api.intra.42.fr/v2/users/$studentID"),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("❌ Error al obtener datos: ${response.body}");
    }
  }

  Future<List<dynamic>> fetchUserProjects() async {
    await _ensureAValidToken();

    final response = await http.get(
      // Uri.parse("https://api.intra.42.fr/v2/cursus/42/users"),
      // Uri.parse("https://api.intra.42.fr/v2/flash_users?page[size]=10"),
      Uri.parse("https://api.intra.42.fr/v2/users/$studentID/projects_users"),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception("❌ Error al obtener datos: ${response.body}");
    }
  }

  Future<List<dynamic>> fetchUserSkills() async {
    await _ensureAValidToken();

    final response = await http.get(
      // Uri.parse("https://api.intra.42.fr/v2/cursus/42/users"),
      // Uri.parse("https://api.intra.42.fr/v2/flash_users?page[size]=10"),
      Uri.parse("https://api.intra.42.fr/v2/users/$studentID/experiences"),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception("❌ Error al obtener datos: ${response.body}");
    }
  }

}
