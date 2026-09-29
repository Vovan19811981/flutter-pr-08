enum SensorType { temperature, humidity, light }

class Sensor {
  const Sensor({
    required this.id,
    required this.name,
    required this.type,
    required this.unit,
  });

  final String id;
  final String name;
  final SensorType type;
  final String unit;
}

class SensorReading {
  const SensorReading({
    required this.sensorId,
    required this.value,
    required this.timestamp,
  });

  final String sensorId;
  final double value;
  final DateTime timestamp;
}
