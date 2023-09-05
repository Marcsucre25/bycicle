import 'package:bicycle/tabs/content_tabs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<void> _login() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // ********************************************************//
      final GeolocatorPlatform geolocator = GeolocatorPlatform.instance;
      try {
        Position position = await geolocator.getCurrentPosition();

        double latitude = position.latitude;
        double longitude = position.longitude;

        // Actualiza la ubicación en Firebase Realtime Database.
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userCredential.user?.uid)
            .update({
          'latitude': latitude,
          'longitude': longitude,
        });
        CircularProgressIndicator();
      } catch (e) {
        print("Error al obtener la ubicacion");
      }

      // ********************************************************//
      CircularProgressIndicator();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ContentTabs()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Usuario no registrado'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (e.code == 'wrong-password') {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Contraseña incorrecta'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Bicycle - RUN'),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: Image(
                  image: AssetImage('assets/images/foto.jpg'),
                  width: 200,
                  height: 200,
                )),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Correo Electrónico',
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                FilledButton.tonal(
                  onPressed: _login,
                  child: const Text('Iniciar Sesión'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.cyan),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
