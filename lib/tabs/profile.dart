import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String? _userName;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Obtener el nombre del usuario desde Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('usuarios').doc(user.uid).get();
      print(user.uid);

      setState(() {
        _user = user;
        _userName = userDoc['name'];
        _email = userDoc['email'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _user == null
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.account_circle,
                    size: 80, // Tamaño grande
                    color:
                        Colors.blue, // Cambia el color según tus preferencias
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Nombre:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10), // Espacio entre "Nombre:" y el valor
                      Text(
                        _userName ?? "Nombre de usuario desconocido",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10), // Espacio adicional
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Email:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10), // Espacio entre "Email:" y el valor
                      Text(
                        _email ?? "Email de usuario desconocido",
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
