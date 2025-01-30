import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OAuth2 App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  String _responseData = "Presiona el botón para obtener datos";

  final TextEditingController _textController = TextEditingController();
  String text = '';

  void _showText() {
    text = _textController.text; // Obtener el valor del TextField
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Texto ingresado: $text')),
    );
  }

  Future<void> _fetchData() async {
    try {
      await _authService.authenticateWithClientCredentials();
      final data = await _authService.fetchPublicData();

      List<Map<String, dynamic>> filteredData = data.map((user) {
        return {
          'id': user['id'],
          'login': user['login'],
          'email': user['email'],
          'phone': user['phone'],
          'displayname': user['displayname'],
          'image_url': user['image_url'],
          'first_name': user['first_name'],
          'last_name': user['last_name'],
          'pool_month': user['pool_month'],
          'pool_year': user['pool_year'],
          'wallet': user['wallet'],
        };
      }).toList();

      debugPrint("Datos obtenidos: $filteredData\n");
      setState(() {
        _responseData = filteredData
            .map((e) =>
                "ID: ${e['id']}, Login: ${e['login']}, Email: ${e['email']}, Phone: ${e['phone']}, Displayname: ${e['displayname']}, Image URL: ${e['image_url']}")
            .join("\n");
      });
    } catch (e) {
      setState(() {
        _responseData = "Error: $e";
      });
    }
  }

  Future<void> _fetchUserId(String login) async {
    try {
      await _authService.authenticateWithClientCredentials();

      List<dynamic> allUsers =
          []; /* ****************** eliminar ******************* */
      int page = 1;
      bool hasNextPage = true;
      Map<String, dynamic>? foundUser;

      while (hasNextPage) {
        final List<dynamic> data =
            await _authService.fetchPublicData(page: page);
        debugPrint("Página $page - Datos recibidos: ${data.length} usuarios");

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
          _responseData =
              "ID del Login ${foundUser?['login']}: ${foundUser?['id']}";
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
                onChanged: (value) {
                  text = value;
                },
              ),
            ),
            ElevatedButton(
              // onPressed: _fetchData,
              onPressed: () {
                _fetchUserId(text);
              },
              child: const Text('Obtener Datos'),
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
