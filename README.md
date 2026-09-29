# Greenhouse Monitor

## Запуск

```bash
flutter pub get
flutter analyze
flutter run
```

## Асинхронні механізми

| Механізм | Де реалізовано |
|---|---|
| `Future.wait` + тайм-аут 3 с | `lib/services/greenhouse_service.dart`, `loadInitialData()` |
| `StreamController` та таймери | `lib/services/sensor_feed.dart` |
| `FutureBuilder` / `StreamBuilder` | `lib/screens/greenhouse_screen.dart`, `lib/widgets/sensor_card.dart` |
| Закриття ресурсів | `GreenhouseScreen.dispose()` → `GreenhouseService.dispose()` |
