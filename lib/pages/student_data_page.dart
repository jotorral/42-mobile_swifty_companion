import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../main.dart';

class StudentData extends StatelessWidget {
  const StudentData({super.key});

  @override
  Widget build(BuildContext context) {
    return const StudentDataPage();
  }
}

class StudentDataPage extends StatefulWidget {
  const StudentDataPage({super.key});

  @override
  State<StudentDataPage> createState() => _StudentDataPageState();
}

class _StudentDataPageState extends State<StudentDataPage> {
  final AuthService _authService = AuthService();
  String _responseData = '';
  String _imageUrl = '';
  String text = '';
  String usualFullName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData(text);
  }

  Future<void> _fetchUserData(String login) async {
    try {
      Map<String, dynamic> data = {};

      try {
        data = await _authService.fetchUserData();
        if (data.isEmpty) {
          setState(() {
            _responseData = "No se encontró el usuario con el login: $login";
          });
          return;
        }
      } catch (e) {
        setState(() {
          _responseData =
              "No se encontró el usuario con el login: $login\nError al obtener datos: $e";
        });
        return;
      }

      _imageUrl = data['image']?['versions']?['small'] ??
          'https://cdn.intra.42.fr/users/849659cfad506ac81c73c6b3228401e8/default.jpg';

      var level = (data['cursus_users'] is List)
          ? (
              // Buscar el primer curso cuyo 'end_at' sea null
              data['cursus_users']
                  .firstWhere((cursus) => cursus['end_at'] == null,
                      orElse: () => data['cursus_users'].firstWhere(
                            (cursus) => cursus['cursus']['kind'] == 'main',
                            orElse: () {
                              return data['cursus_users'].reduce(
                                (a, b) {
                                  if (a['cursus']['end_at']
                                          .compareTo(b['cursus']['end_at']) <
                                      0) {
                                    return a;
                                  } else {
                                    return b;
                                  }
                                },
                              );
                            },
                          ))['level']
                  .toString())
          : 'No disponible';

      String formattedLevel = 'No disponible';

// Intentar convertir el 'level' a un número (double) para poder formatearlo
      if (level != 'No disponible') {
        // Convertir el valor de 'level' a double si es posible
        double? numericLevel = double.tryParse(level.toString());

        if (numericLevel != null) {
          // Si la conversión es exitosa, formatear a 2 decimales
          formattedLevel = numericLevel.toStringAsFixed(2);
        }
      }

      debugPrint("Formatted Level: $formattedLevel");


      // Buscar el curso relevante
      var relevantCursus = data['cursus_users'].firstWhere(
        (cursus) => cursus['end_at'] == null,
        orElse: () => data['cursus_users'].firstWhere(
          (cursus) => cursus['cursus']['kind'] == 'main',
          orElse: () {
            return data['cursus_users'].reduce(
              (a, b) {
                if (a['cursus']['end_at'].compareTo(b['cursus']['end_at']) < 0) {
                  return a;
                } else {
                  return b;
                }
              },
            );
          },
        ),
      );

      // Obtener los skills del curso relevante
      var skills = relevantCursus['skills'];

      // Formatear los skills
      String formattedSkills = skills
          .map((skill) {
            return "- ${skill['name']} (Nivel: ${skill['level'] != null ? (skill['level'] as double).toStringAsFixed(2) : 'Desconocido'} / ${skill['level'] != null ? ((skill['level'] as double) * 10).toStringAsFixed(0) : 'Desconocido'}%)";
          })
          .join('\n');


      usualFullName = """
          Nombre completo: ${data['usual_full_name'] ?? 'No disponible'}
          Login: ${data['login'] ?? 'No disponible'}
          Email: ${data['email'] ?? 'No disponible'}
          URL de imagen: ${data['image']['link'] ?? 'No disponible'}
          Mes de comienzo: ${data['pool_month'] ?? 'No disponible'}
          Año de comienzo: ${data['pool_year'] ?? 'No disponible'}
          Monedero: ${data['wallet'] ?? 'No disponible'}
          Level: $formattedLevel

          Skills:
          $formattedSkills

          Proyectos:
          ${(data['projects_users']?.isNotEmpty ?? false) ? data['projects_users']!.map((project) => "- ${project['project']['name']} (Validado: ${project['validated?'] == true ? 'Sí' : 'No'})").join('\n') : 'No ha realizado.'}
        """;

      setState(() {
        _responseData = usualFullName;
      });
    } catch (e) {
      setState(() {
        _responseData = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OAuth2 App'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            (context.findAncestorStateOfType<PantallaPrincipalState>()!)
                .cambiarPantalla(0);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              if (_imageUrl.isNotEmpty)
                Image.network(
                  _imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error, size: 50, color: Colors.red);
                  },
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
      ),
    );
  }
}
