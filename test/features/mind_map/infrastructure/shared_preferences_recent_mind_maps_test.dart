import 'package:flutter_test/flutter_test.dart';
import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/infrastructure/shared_preferences_recent_mind_maps_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists recent entries in shared preferences', () async {
    final repository = await SharedPreferencesRecentMindMapsRepository.create();
    const first = MindMapFile(
      location: MindMapLocation('content://first'),
      displayName: 'first.md',
    );
    const second = MindMapFile(
      location: MindMapLocation('content://second'),
      displayName: 'second.md',
    );

    await repository.record(first);
    await repository.record(second);

    expect((await repository.list()).map((file) => file.displayName), [
      'second.md',
      'first.md',
    ]);
  });

  test('ignores corrupted preference entries', () async {
    SharedPreferences.setMockInitialValues({
      'recent_mind_maps': ['not-json', '{"locationToken":"","displayName":""}'],
    });
    final repository = await SharedPreferencesRecentMindMapsRepository.create();

    expect(await repository.list(), isEmpty);
  });
}
