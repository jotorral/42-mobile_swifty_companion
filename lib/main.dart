import 'package:flutter/material.dart';

// import 'package:firebase_ui_auth/firebase_ui_auth.dart';
// import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'pages/login_input_page.dart';
import 'pages/student_data_page.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

int studentID = 0;
// final AuthService _authService = AuthService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // Carga las variables de entorno del fichero .env que contienen datos conexión Auth0
 	runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Navegación sin stack',
			theme: ThemeData(
				primarySwatch: Colors.blue,
			),
			home: const PantallaPrincipal(),
		);
	}
}


class PantallaPrincipal extends StatefulWidget {
	const PantallaPrincipal({super.key});

	@override
	PantallaPrincipalState createState() => PantallaPrincipalState();
}


class PantallaPrincipalState extends State<PantallaPrincipal> {
	// Controlamos el estado con un índice para cambiar el contenido
	int _currentIndex = 0;

	// Lista de pantallas que vamos a mostrar, basada en el índice
	final List<Widget> _pantallas = [
		const SearchLogin(),      // Pantalla 0
		const StudentData(),        // Pantalla 1
		// const ProfilePage(),  // Pantalla 2
    // 	const CalendarPage(),    // Pantalla 3
	];

	// Función callback para cambiar el índice desde las pantallas hijas
	void cambiarPantalla(int nuevoIndex) {
    debugPrint('cambiar pantalla lamado con nuevoIndex: $nuevoIndex');
		setState(() {
			_currentIndex = nuevoIndex;  // Cambia la pantalla según el nuevo índice
		});
	}

	@override
	Widget build(BuildContext context) {

		return Scaffold(
			/*appBar: AppBar(title: const Text('Pantalla Principal')),*/
			body: _pantallas[_currentIndex],  // Muestra la pantalla correspondiente
/*      bottomNavigationBar: BottomNavigationBar(
				currentIndex: _currentIndex,
				onTap: (int index) {
					cambiarPantalla(index);  // Usamos el callback para cambiar la pantalla
				},
				items: const [
					BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Pantalla 1'),
					BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Pantalla 2'),
					BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Pantalla 3'),
				],
			),
*/    );
	}
}
