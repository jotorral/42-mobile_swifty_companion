import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;

class AuthService {
  static const String clientId = "YOUR_CLIENT_ID";
  static const String clientSecret = "YOUR_CLIENT_SECRET";
  static const String authorizationEndpoint = "https://api.intra.42.fr/oauth/authorize";
  static const String tokenEndpoint = "https://api.intra.42.fr/oauth/token";
  static const String redirectUrl = "com.example.mobile_swifty_companion:/oauth2redirect";

  late oauth2.Client _client;

  Future<void> authenticate() async {
    final authorizationCodeGrant = oauth2.AuthorizationCodeGrant(
      clientId,
      Uri.parse(authorizationEndpoint),
      Uri.parse(tokenEndpoint),
      secret: clientSecret,
    );

    final authorizationUrl = authorizationCodeGrant.getAuthorizationUrl(Uri.parse(redirectUrl));

    // Abre el navegador para la autenticación (esto puede variar según la plataforma).
    print("Visita esta URL para autenticarte: $authorizationUrl");

    // Simulación: el usuario ingresa el código de autorización.
    print("Introduce el código de autorización:");
    final String authorizationCode = stdin.readLineSync()!;

    // Solicitar token de acceso.
    _client = await authorizationCodeGrant.handleAuthorizationCode(authorizationCode);
    print("Token de acceso obtenido: ${_client.credentials.accessToken}");
  }

  Future<Map<String, dynamic>> fetchPublicData() async {
    final response = await _client.get(Uri.parse("https://api.intra.42.fr/v2/cursus"));
    return jsonDecode(response.body);
  }
}
