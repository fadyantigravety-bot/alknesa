import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/prayer_models.dart';
import '../data/repositories/prayer_repository.dart';
import '../../../core/network/dio_client.dart';

final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  return PrayerRepository(ref.watch(dioProvider));
});

final prayerDefinitionsProvider = FutureProvider<List<PrayerDefinitionModel>>((ref) async {
  return ref.watch(prayerRepositoryProvider).getDefinitions();
});

final todayPrayersProvider = FutureProvider<List<PrayerLogModel>>((ref) async {
  return ref.watch(prayerRepositoryProvider).getMyToday();
});
