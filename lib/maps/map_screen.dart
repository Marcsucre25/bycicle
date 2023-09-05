import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(),
    );
  }
}

class User {
  final String id;
  final double latitude;
  final double longitude;
  final String name;

  User({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.name,
  });
}

class MapWidget extends StatefulWidget {
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  void _startLocationTracking() {
    _locationSubscription =
        _location.onLocationChanged.listen((LocationData locationData) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Actualiza la ubicación en Firebase
        final userLocation = {
          'latitude': locationData.latitude,
          'longitude': locationData.longitude,
        };
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid) // Utiliza el UID del usuario autenticado
            .update(userLocation);
      }

      // Actualiza el mapa con la nueva ubicación
      setState(() {
        // Actualiza el centro del mapa con la ubicación actual
        // Esto supone que tienes acceso a la ubicación actual del usuario
        // Puedes usar locationData.latitude y locationData.longitude aquí
      });
    });
  }

  @override
  void initState() {
    super.initState();

    // Inicia el seguimiento de ubicación en tiempo real
    _initializeLocation();
    _startLocationTracking();
  }

  @override
  void dispose() {
    // Detiene el seguimiento de ubicación cuando se elimina el widget
    //_stopLocationTracking();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    final locationStatus = await _location.requestPermission();
    if (locationStatus == PermissionStatus.granted) {
      _startLocationTracking();
    } else {
      print('Seguimiento negado');
    }
  }

  void _stopLocationTracking() {
    if (_locationSubscription != null) {
      _locationSubscription?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.black,
            ),
          );
        }

        List<User> userCoordinates = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final latitude = data['latitude'] as double;
          final longitude = data['longitude'] as double;
          final userName = data['name'] as String;
          return User(
            id: doc.id,
            latitude: latitude,
            longitude: longitude,
            name: userName,
          );
        }).toList();

        return FlutterMap(
          options: MapOptions(
            center:
                LatLng(-0.2231, -78.5256), // Cambiar esto según tus necesidades
            minZoom: 5,
            maxZoom: 25,
            zoom: 18,
          ),
          nonRotatedChildren: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName:
                  'net.tlserver6y.flutter_map_location_marker.example',
              maxZoom: 19,
            ),
            MarkerLayer(
              markers: userCoordinates.map((user) {
                return Marker(
                  point: LatLng(user.latitude, user.longitude),
                  builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(user.name),
                          backgroundColor: Colors.green,
                        ));
                      },
                      child: Container(
                        child: const Icon(
                          Icons.person_pin,
                          color: Colors.blueAccent,
                          size: 40,
                        ),
                      ),
                    );
                    /*
                    return Container(
                      child: const Icon(
                        Icons.person_pin,
                        color: Colors.blueAccent,
                        size: 40,
                      ),
                    );
                    */
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
