import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../main.dart';

class SearchLogin extends StatelessWidget {
  const SearchLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return const SearchLoginPage();
  }
}

class SearchLoginPage extends StatefulWidget {
  const SearchLoginPage({super.key});

  @override
  State<SearchLoginPage> createState() => _SearchLoginPageState();
}

class _SearchLoginPageState extends State<SearchLoginPage> {
  final AuthService _authService = AuthService();


  final TextEditingController _textController = TextEditingController();
  String text = '';
  bool _isLoading = false;
  String _responseData = "Presiona el botón para obtener datos";


  Future<void> _fetchUserId(String login) async {
    setState((){ _isLoading = true; });
    try {
      // await _authService.ensureAValidToken();

      int page = 1;
      bool hasNextPage = true;
      Map<String, dynamic>? foundUser;

      while (hasNextPage) {
        final List<dynamic> data =
            await _authService.fetchPublicData(page: page);
        debugPrint("Página $page - Datos recibidos: ${data.length} usuarios");

        setState(() {
          _responseData = "Buscando en página $page (${data.length} usuarios)\n";          
        });

        foundUser = data.firstWhere(
          (user) => user['login'] == login,
          orElse: () => null,
        );

        if (foundUser != null) {
          debugPrint("Usuario encontrado: $foundUser");
          break;
        }

        hasNextPage = data.length == 100;
        debugPrint("¿Hay más páginas? $hasNextPage");
        page++;
        await Future.delayed(Duration(milliseconds: 510));
      }

      if (foundUser != null) {
        debugPrint("Usuario encontrado: $foundUser");
        setState(() {
          studentID = foundUser?['id'];
        //   _responseData =
        //       "ID del Login ${foundUser?['login']}: ${foundUser?['id']}";
        (context.findAncestorStateOfType<PantallaPrincipalState>()!).cambiarPantalla(1);
        });
      } else {
        setState(() {
          _responseData = "Usuario '$login' no encontrado";
        });
      }
    } catch (e) {
      setState(() {
        _responseData = "Error: $e";
      });
    } finally {
      setState((){ _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OAuth2 App')),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Ingresa un login',
                ),
                autofocus: false,
                onChanged: (value) {
                  text = value;
                },
              ),
            ),
            ElevatedButton(
              // onPressed: _fetchData,
              onPressed: _isLoading
              ? null
              : () {
                _fetchUserId(text);
              },
              child: _isLoading
              ? const CircularProgressIndicator(color: Colors.black54)
              : const Text('Obtener Datos'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                    children: _responseData
                        .split("\n")
                        .map((line) =>
                            Text(line, style: const TextStyle(fontSize: 16)))
                        .toList()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
