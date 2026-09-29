import 'dart:async';
import 'dart:math';

import '../models/greenhouse_data.dart';
import '../models/sensor.dart';
import 'fake_api.dart';
import 'sensor_feed.dart';

class GreenhouseService {
  GreenhouseService({double failureRate = 0.12, Random? random})
      : _failureRate = failureRate,
        _random = random ?? Random(),
        _api = FakeApi(failureRate: failureRate, random: random);

  final double _failureRate;
  final Random _random;
  final FakeApi _api;
  final Map<String, SensorFeed> _feeds = <String, SensorFeed>{};
  bool _paused = false;

  Future<GreenhouseInitialData> loadInitialData() async {
    final results = await Future.wait<Object>([
      _loadSensors(),
      _loadThresholds(),
      _loadDailySummary(),
    ]).timeout(const Duration(seconds: 3));

    return GreenhouseInitialData(
      sensors: results[0] as List<Sensor>,
      thresholds: results[1] as Map<String, SensorThreshold>,
      summary: results[2] as DailySummary,
    );
  }

  Future<List<Sensor>> _loadSensors() => _api.request(
        () => const <Sensor>[
          Sensor(id: 'temperature', name: 'Температура', type: SensorType.temperature, unit: '°C'),
          Sensor(id: 'humidity', name: 'Вологість', type: SensorType.humidity, unit: '%'),
          Sensor(id: 'light', name: 'Освітленість', type: SensorType.light, unit: 'lx'),
        ],
        delayMs: 650,
      );

  Future<Map<String, SensorThreshold>> _loadThresholds() => _api.request(
        () => const <String, SensorThreshold>{
          'temperature': SensorThreshold(min: 18, max: 28),
          'humidity': SensorThreshold(min: 35, max: 75),
          'light': SensorThreshold(min: 250, max: 1000),
        },
        delayMs: 850,
      );

  Future<DailySummary> _loadDailySummary() => _api.request(
        () => const DailySummary(
          averageTemperature: 22.8,
          averageHumidity: 57.2,
          averageLight: 620,
        ),
        delayMs: 750,
      );

  Stream<SensorReading> readingsFor(Sensor sensor) {
    final feed = _feeds.putIfAbsent(
      sensor.id,
      () => SensorFeed(
        sensor: sensor,
        failureRate: _failureRate,
        random: Random(_random.nextInt(1 << 31)),
      ),
    );
    if (!_paused) {
      feed.start();
    }
    return feed.stream;
  }

  void pause() {
    if (_paused) {
      return;
    }
    _paused = true;
    for (final feed in _feeds.values) {
      feed.pause();
    }
  }

  void resume() {
    if (!_paused) {
      return;
    }
    _paused = false;
    for (final feed in _feeds.values) {
      feed.resume();
    }
  }

  Future<void> dispose() async {
    final futures = _feeds.values.map((feed) => feed.dispose()).toList();
    _feeds.clear();
    await Future.wait(futures);
  }
}
