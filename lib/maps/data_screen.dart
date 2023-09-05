import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({Key? key}) : super(key: key);

  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator(); // Muestra un indicador de carga mientras se cargan los datos.
          }
          var documentos = snapshot.data?.docs;

          // Construye la lista de elementos a mostrar.
          var elementos = documentos?.map((documento) {
            var data = documento.data() as Map<String, dynamic>;
            var nombre = data['name'];
            return ListTile(
              title: Text(nombre),
              textColor: Colors.black,
            );
          }).toList();

          return ListView(
            children: elementos!
                .map<Widget>((listTile) => listTile as Widget)
                .toList(),
          );
        },
      ),
    );
  }
}
