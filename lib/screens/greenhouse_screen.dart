import 'dart:async';

import 'package:flutter/material.dart';

import '../models/greenhouse_data.dart';
import '../models/sensor.dart';
import '../services/greenhouse_service.dart';
import '../widgets/sensor_card.dart';

class GreenhouseScreen extends StatefulWidget {
  const GreenhouseScreen({super.key});

  @override
  State<GreenhouseScreen> createState() => _GreenhouseScreenState();
}

class _GreenhouseScreenState extends State<GreenhouseScreen> {
  late final GreenhouseService _service;
  late Future<GreenhouseInitialData> _initialLoad;
  final Map<String, DateTime> _lastAlerts = <String, DateTime>{};
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _service = GreenhouseService(failureRate: 0.12);
    _initialLoad = _service.loadInitialData();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  void _retry() {
    setState(() {
      _initialLoad = _service.loadInitialData();
    });
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
    if (_paused) {
      _service.pause();
    } else {
      _service.resume();
    }
  }

  void _showThresholdAlert(Sensor sensor, SensorReading reading) {
    final now = DateTime.now();
    final previous = _lastAlerts[sensor.id];
    if (previous != null && now.difference(previous) < const Duration(seconds: 10)) {
      return;
    }
    _lastAlerts[sensor.id] = now;
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${sensor.name}: значення ${reading.value.toStringAsFixed(1)} ${sensor.unit} поза порогом'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Розумна теплиця'),
        actions: [
          TextButton.icon(
            onPressed: _togglePause,
            icon: Icon(_paused ? Icons.play_arrow : Icons.pause),
            label: Text(_paused ? 'Продовжити' : 'Пауза'),
          ),
        ],
      ),
      body: FutureBuilder<GreenhouseInitialData>(
        future: _initialLoad,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Завантаження даних теплиці…'),
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            final timeout = snapshot.error is TimeoutException;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 64),
                    const SizedBox(height: 16),
                    Text(timeout ? 'Сервер не відповів за 3 секунди' : 'Не вдалося завантажити дані'),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Повторити'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          if (data.sensors.isEmpty) {
            return const Center(child: Text('Датчики не знайдено'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _initialLoad = _service.loadInitialData());
              try {
                await _initialLoad;
              } catch (_) {}
              if (!mounted) {
                return;
              }
              setState(() {});
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _SummaryCard(summary: data.summary),
                const SizedBox(height: 12),
                for (final sensor in data.sensors) ...[
                  SensorCard(
                    sensor: sensor,
                    threshold: data.thresholds[sensor.id]!,
                    stream: _service.readingsFor(sensor),
                    onThresholdExceeded: (reading) => _showThresholdAlert(sensor, reading),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Підсумок за добу', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                Text('Температура: ${summary.averageTemperature.toStringAsFixed(1)} °C'),
                Text('Вологість: ${summary.averageHumidity.toStringAsFixed(1)} %'),
                Text('Світло: ${summary.averageLight.toStringAsFixed(0)} lx'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
