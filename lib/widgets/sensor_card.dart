import 'package:flutter/material.dart';

import '../models/greenhouse_data.dart';
import '../models/sensor.dart';

class SensorCard extends StatelessWidget {
  const SensorCard({
    super.key,
    required this.sensor,
    required this.threshold,
    required this.stream,
    required this.onThresholdExceeded,
  });

  final Sensor sensor;
  final SensorThreshold threshold;
  final Stream<SensorReading> stream;
  final ValueChanged<SensorReading> onThresholdExceeded;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<SensorReading>(
          stream: stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const LinearProgressIndicator();
            }
            final reading = snapshot.data!;
            return Text(
              '${sensor.name}: ${reading.value.toStringAsFixed(1)} ${sensor.unit}',
              style: Theme.of(context).textTheme.titleMedium,
            );
          },
        ),
      ),
    );
  }
}
