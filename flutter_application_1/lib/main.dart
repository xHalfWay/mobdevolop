import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'address.dart';
import 'gyroscope.dart';
import 'package:sensors_plus/sensors_plus.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laptev D.A',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Laptev D.A'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _latitude = 0.0;
  double _longitude = 0.0;
  String _address = '';
  GyroscopeService _gyroscopeService = GyroscopeService();
  List<double> _gyroscopeValues = [0.0, 0.0, 0.0];

  @override
  void initState() {
    super.initState();
    _gyroscopeService.startListening();
    _gyroscopeService.gyroscopeStream?.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = [event.x, event.y, event.z];
      });
    });
  }

  @override
  void dispose() {
    _gyroscopeService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Адрес: $_address',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            Text(
              'Широта: $_latitude',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            Text(
              'Долгота: $_longitude',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20), 
            Text(
              'Данные гироскопа:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              'X: ${_gyroscopeValues[0]}',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            Text(
              'Y: ${_gyroscopeValues[1]}',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            Text(
              'Z: ${_gyroscopeValues[2]}',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20), 
            ElevatedButton(
              onPressed: _updateData,
              child: Text('Обновить данные'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateData() async {
    bool locationPermission = await _checkLocationPermission();

    if (locationPermission) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      String address = await _getAddress(position.latitude, position.longitude);

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _address = address;
      });
    } else {
      _requestLocationPermission();
    }
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    } else {
      return false;
    }
  }

  void _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      _updateData();
    } else {
      print('Пользователь отказался предоставить разрешение на местоположение.');
    }
  }

  Future<String> _getAddress(double latitude, double longitude) async {
    final addressService = AddressService(apiKey: '1e8ec50502aee79020fdbc76b4079d82dd2cb9a8');
    return await addressService.getAddress(latitude, longitude);
  }
}
