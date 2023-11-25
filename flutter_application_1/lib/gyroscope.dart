import 'package:sensors_plus/sensors_plus.dart';

class GyroscopeService {
  Stream<GyroscopeEvent>? gyroscopeStream;

  void startListening() {
    gyroscopeStream = gyroscopeEvents;
  }

  void stopListening() {
    gyroscopeStream = null;
  }
}
