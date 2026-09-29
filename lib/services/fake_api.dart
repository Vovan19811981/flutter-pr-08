import 'dart:math';

class FakeApi {
  FakeApi({this.failureRate = 0.12, Random? random}) : _random = random ?? Random();

  final double failureRate;
  final Random _random;

  Future<T> request<T>(T Function() respond, {int delayMs = 700}) async {
    await Future<void>.delayed(Duration(milliseconds: delayMs));
    if (_random.nextDouble() < failureRate) {
      throw StateError('Сервер недоступний');
    }
    return respond();
  }
}
