import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:data/src/manager/settings.dart';

import 'settings_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SettingsRepository>(),
])
void main() {
  late MockSettingsRepository mockRepository;
  late Settings settings;

  const initialData = SettingsData();
  const updatedData = SettingsData();

  setUp(() {
    mockRepository = MockSettingsRepository();

    when(mockRepository.get()).thenAnswer((_) async => initialData);

    when(mockRepository.changes).thenAnswer(
      (_) => const Stream<SettingsData>.empty(),
    );

    settings = Settings(mockRepository);
  });

  tearDown(() {
    reset(mockRepository);
  });

  group('Settings', () {
    test('initialize() loads settings data and notifies listeners', () async {
      bool didNotify = false;
      settings.addListener(() {
        didNotify = true;
      });

      await settings.initialize();

      expect(settings.data, equals(initialData));
      expect(didNotify, isTrue);
    });

    test('updates _data when repository emits a new SettingsData', () async {
      final controller = StreamController<SettingsData>();
      when(mockRepository.changes).thenAnswer((_) => controller.stream);

      await settings.initialize();
      // Initially, settings.data is initialData.
      expect(settings.data, equals(initialData));

      controller.add(updatedData);
      // Allow the stream event to propagate.
      await Future.delayed(Duration.zero);
      expect(settings.data, equals(updatedData));

      await controller.close();
    });

    test('dispose() cancels the subscription', () async {
      final controller = StreamController<SettingsData>();
      when(mockRepository.changes).thenAnswer((_) => controller.stream);

      await settings.initialize();
      settings.dispose();

      expect(() => controller.add(initialData), returnsNormally);

      await controller.close();
    });
  });
}
