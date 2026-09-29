import 'package:flutter_test/flutter_test.dart';
import 'package:greenhouse_monitor/models/greenhouse_data.dart';

void main() {
  test('threshold detects values outside range', () {
    const threshold = SensorThreshold(min: 18, max: 28);
    expect(threshold.contains(23), isTrue);
    expect(threshold.contains(30), isFalse);
  });
}
