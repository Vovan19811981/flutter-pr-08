import 'package:flutter/material.dart';

import '../models/greenhouse_data.dart';
import '../models/sensor.dart';

class SensorCard extends StatefulWidget {
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
  State<SensorCard> createState() => _SensorCardState();
}

class _SensorCardState extends State<SensorCard> {
  double? _lastAlertValue;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SensorReading>(
      stream: widget.stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildCard(
            context,
            icon: Icons.sensors_off_outlined,
            child: Text(
              'Помилка датчика\n${snapshot.error}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }
        if (!snapshot.hasData) {
          return _buildCard(
            context,
            icon: Icons.sensors,
            child: const LinearProgressIndicator(),
          );
        }

        final reading = snapshot.data!;
        final exceeded = !widget.threshold.contains(reading.value);
        if (exceeded && _lastAlertValue != reading.value) {
          _lastAlertValue = reading.value;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              widget.onThresholdExceeded(reading);
            }
          });
        }
        return _buildCard(
          context,
          icon: _iconFor(widget.sensor.type),
          exceeded: exceeded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${reading.value.toStringAsFixed(widget.sensor.type == SensorType.light ? 0 : 1)} ${widget.sensor.unit}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text('Норма: ${widget.threshold.min.toStringAsFixed(0)}–${widget.threshold.max.toStringAsFixed(0)} ${widget.sensor.unit}'),
              const SizedBox(height: 4),
              Text(
                'Оновлено ${TimeOfDay.fromDateTime(reading.timestamp).format(context)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required Widget child,
    bool exceeded = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: exceeded ? scheme.errorContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: exceeded ? scheme.error : scheme.outlineVariant,
          width: exceeded ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 34),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.sensor.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(SensorType type) => switch (type) {
        SensorType.temperature => Icons.thermostat,
        SensorType.humidity => Icons.water_drop_outlined,
        SensorType.light => Icons.light_mode_outlined,
      };
}
