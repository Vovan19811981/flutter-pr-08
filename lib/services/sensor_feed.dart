import 'dart:async';
import 'dart:math';

import '../models/sensor.dart';

class SensorFeed {
  SensorFeed({required this.sensor, Random? random}) : _random = random ?? Random();

  final Sensor sensor;
  final Random _random;
  final StreamController<SensorReading> _controller = StreamController<SensorReading>.broadcast();
  Timer? _timer;

  Stream<SensorReading> get stream => _controller.stream;

  void start() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      final base = sensor.type == SensorType.temperature ? 23.0 : 55.0;
      _controller.add(
        SensorReading(
          sensorId: sensor.id,
          value: base + _random.nextDouble() * 4 - 2,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void pause() {
    // Спочатку пауза реалізовувалась тільки на рівні екрана.
  }
}
