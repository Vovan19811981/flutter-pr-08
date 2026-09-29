import 'dart:async';
import 'dart:math';

import '../models/sensor.dart';

class SensorFeed {
  SensorFeed({
    required this.sensor,
    required this.failureRate,
    Random? random,
  }) : _random = random ?? Random();

  final Sensor sensor;
  final double failureRate;
  final Random _random;
  final StreamController<SensorReading> _controller =
      StreamController<SensorReading>.broadcast();
  Timer? _timer;
  bool _disposed = false;

  Stream<SensorReading> get stream => _controller.stream;

  void start() {
    if (_disposed || _timer != null) {
      return;
    }
    _emit();
    final milliseconds = 1000 + _random.nextInt(1001);
    _timer = Timer.periodic(Duration(milliseconds: milliseconds), (_) => _emit());
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  void resume() => start();

  void _emit() {
    if (_disposed) {
      return;
    }
    if (_random.nextDouble() < failureRate) {
      _controller.addError(StateError('Немає даних від датчика ${sensor.name}'));
      return;
    }
    final base = switch (sensor.type) {
      SensorType.temperature => 23.0,
      SensorType.humidity => 55.0,
      SensorType.light => 650.0,
    };
    final spread = switch (sensor.type) {
      SensorType.temperature => 7.0,
      SensorType.humidity => 25.0,
      SensorType.light => 520.0,
    };
    final value = base + (_random.nextDouble() * 2 - 1) * spread;
    _controller.add(
      SensorReading(
        sensorId: sensor.id,
        value: value,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    await _controller.close();
  }
}
