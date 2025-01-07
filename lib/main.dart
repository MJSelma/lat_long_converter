import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LatLong Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LatLongConverterPage(),
    );
  }
}

class LatLongConverterPage extends StatefulWidget {
  const LatLongConverterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LatLongConverterPageState createState() => _LatLongConverterPageState();
}

class _LatLongConverterPageState extends State<LatLongConverterPage> {
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  String _convertedLat = '';
  String _convertedLong = '';
 LatLng _targetLatLng = const LatLng(14.5619971,121.0554294); // Default position: West Rembo

  late GoogleMapController _mapController;

  // Convert Decimal Degrees to DMS
  String _convertToDMS(double decimal) {
    final degrees = decimal.truncate();
    final minutesDecimal = (decimal - degrees) * 60;
    final minutes = minutesDecimal.truncate();
    final seconds = ((minutesDecimal - minutes) * 60).toStringAsFixed(2);

    return '$degrees° $minutes\' $seconds\"';
  }

  void _convertCoordinates() {
    try {
      final latitude = double.parse(_latitudeController.text);
      final longitude = double.parse(_longitudeController.text);

      setState(() {
        _convertedLat = _convertToDMS(latitude);
        _convertedLong = _convertToDMS(longitude);
        _targetLatLng = LatLng(latitude, longitude);

        // Move the Google Map to the new location
        _mapController.animateCamera(CameraUpdate.newLatLng(_targetLatLng));
      });
    } catch (e) {
      setState(() {
        _convertedLat = 'Invalid Input';
        _convertedLong = 'Invalid Input';
      });
    }
  }
Future<void> _saveCoordinatesToDB(double latitude, double longitude, String dmsLatitude, String dmsLongitude) async {
  final url = Uri.parse('http://10.0.2.2:3000/coords');  // Use 10.0.2.2 for Android emulator
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "notes": "Coordinate saved",  // Optional, you can add any text you want here
      "lat": latitude,  // Match the field name
      "lng": longitude,  // Match the field name
    }),
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coordinates saved successfully!")));
    print('success');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to save coordinates.")));
    print('failed');
  }
}

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latitude and Longitude Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _latitudeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Latitude (Decimal Degrees)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _longitudeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Longitude (Decimal Degrees)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _convertCoordinates,
              child: const Text('Convert Coords'),
            ),
            const SizedBox(height: 16),
            Text(
              'Latitude (DMS): $_convertedLat',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Longitude (DMS): $_convertedLong',
              style: const TextStyle(fontSize: 16),
            ),
             ElevatedButton(
              onPressed: () async {_saveCoordinatesToDB(double.parse(_latitudeController.text), double.parse(_longitudeController.text), _convertedLat, _convertedLong);},
              child: const Text('Save Coords'),
            ),
             Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _targetLatLng,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('target'),
                  position: _targetLatLng,
                  infoWindow: InfoWindow(
                    title: 'Converted Location',
                    snippet:
                        'Lat: ${_targetLatLng.latitude}, Lng: ${_targetLatLng.longitude}',
                  ),
                ),
              },
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
          ),
          ],
        ),
      ),
    );
  }
}
