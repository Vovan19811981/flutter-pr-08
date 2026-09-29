import 'sensor.dart';

class SensorThreshold {
  const SensorThreshold({required this.min, required this.max});

  final double min;
  final double max;

  bool contains(double value) => value >= min && value <= max;
}

class DailySummary {
  const DailySummary({
    required this.averageTemperature,
    required this.averageHumidity,
    required this.averageLight,
  });

  final double averageTemperature;
  final double averageHumidity;
  final double averageLight;
}

class GreenhouseInitialData {
  const GreenhouseInitialData({
    required this.sensors,
    required this.thresholds,
    required this.summary,
  });

  final List<Sensor> sensors;
  final Map<String, SensorThreshold> thresholds;
  final DailySummary summary;
}
