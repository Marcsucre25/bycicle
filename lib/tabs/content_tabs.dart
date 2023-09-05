import 'package:bicycle/main.dart';
import 'package:bicycle/maps/data_screen.dart';
import 'package:bicycle/maps/map_screen.dart';
import 'package:bicycle/tabs/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContentTabs extends StatelessWidget {
  const ContentTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            tabBarTheme: TabBarTheme(
          labelColor: Colors.brown.shade50,
        )),
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(tabs: [
                Tab(icon: Icon(Icons.map_outlined)),
                Tab(icon: Icon(Icons.person)),
                Tab(icon: Icon(Icons.account_circle)),
              ]),
              title: const Text('Mapa RUN'),
              backgroundColor: Colors.black87,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.logout),
                  color: Colors.red, // Icono de cierre de sesión
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => MyApp(),
                        ),
                      );
                    } catch (e) {
                      print("Error al cerrar sesión: $e");
                    }
                  },
                ),
              ],
            ),
            body: TabBarView(
              children: [
                MapScreen(),
                DataScreen(),
                Profile(),
              ],
            ),
          ),
        ));
  }
}
