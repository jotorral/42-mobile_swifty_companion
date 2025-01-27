import 'package:flutter/material.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthScreen(),
    );
  }
}

class AuthScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Swifty Companion")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await _authService.authenticate();
              final data = await _authService.fetchPublicData();
              print("Datos públicos: $data");
            } catch (e) {
              print("Error durante la autenticación: $e");
            }
          },
          child: const Text("Autenticarse con 42 API"),
        ),
      ),
    );
  }
}
