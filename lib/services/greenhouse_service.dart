import '../models/greenhouse_data.dart';
import '../models/sensor.dart';
import 'fake_api.dart';

class GreenhouseService {
  GreenhouseService({double failureRate = 0.12})
      : _api = FakeApi(failureRate: failureRate);

  final FakeApi _api;

  Future<GreenhouseInitialData> loadInitialData() async {
    final sensors = await _loadSensors();
    final thresholds = await _loadThresholds();
    final summary = await _loadDailySummary();

    return GreenhouseInitialData(
      sensors: sensors,
      thresholds: thresholds,
      summary: summary,
    );
  }

  Future<List<Sensor>> _loadSensors() => _api.request(
        () => const <Sensor>[
          Sensor(id: 'temperature', name: 'Температура', type: SensorType.temperature, unit: '°C'),
          Sensor(id: 'humidity', name: 'Вологість', type: SensorType.humidity, unit: '%'),
          Sensor(id: 'light', name: 'Освітленість', type: SensorType.light, unit: 'lx'),
        ],
      );

  Future<Map<String, SensorThreshold>> _loadThresholds() => _api.request(
        () => const <String, SensorThreshold>{
          'temperature': SensorThreshold(min: 18, max: 28),
          'humidity': SensorThreshold(min: 35, max: 75),
          'light': SensorThreshold(min: 250, max: 1000),
        },
      );

  Future<DailySummary> _loadDailySummary() => _api.request(
        () => const DailySummary(
          averageTemperature: 22.8,
          averageHumidity: 57.2,
          averageLight: 620,
        ),
      );
}
