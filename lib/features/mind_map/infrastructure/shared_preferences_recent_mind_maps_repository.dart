import 'dart:convert';

import 'package:obmind/features/mind_map/domain/repositories/mind_map_storage.dart';
import 'package:obmind/features/mind_map/domain/repositories/recent_mind_maps_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _recentMindMapsKey = 'recent_mind_maps';
const _maxRecentMindMaps = 10;

/// Stores recent mind map entries in platform preferences.
final class SharedPreferencesRecentMindMapsRepository
    implements RecentMindMapsRepository {
  SharedPreferencesRecentMindMapsRepository(this._preferences);

  final SharedPreferences _preferences;

  static Future<SharedPreferencesRecentMindMapsRepository> create() async {
    final preferences = await SharedPreferences.getInstance();
    return SharedPreferencesRecentMindMapsRepository(preferences);
  }

  @override
  Future<List<MindMapFile>> list() async {
    final raw = _preferences.getStringList(_recentMindMapsKey) ?? const [];
    return raw
        .map(_decodeEntry)
        .whereType<MindMapFile>()
        .toList(growable: false);
  }

  @override
  Future<void> record(MindMapFile file) async {
    final current = await list();
    final updated = [
      file,
      ...current.where((entry) => entry.location.token != file.location.token),
    ].take(_maxRecentMindMaps).toList(growable: false);
    await _preferences.setStringList(
      _recentMindMapsKey,
      updated.map(_encodeEntry).toList(growable: false),
    );
  }

  @override
  Future<void> remove(MindMapLocation location) async {
    final current = await list();
    final updated = current
        .where((entry) => entry.location.token != location.token)
        .toList(growable: false);
    await _preferences.setStringList(
      _recentMindMapsKey,
      updated.map(_encodeEntry).toList(growable: false),
    );
  }

  MindMapFile? _decodeEntry(String encoded) {
    try {
      final json = jsonDecode(encoded);
      if (json is! Map<String, dynamic>) {
        return null;
      }
      final token = json['locationToken'];
      final displayName = json['displayName'];
      if (token is! String || token.isEmpty || displayName is! String) {
        return null;
      }
      return MindMapFile(
        location: MindMapLocation(token),
        displayName: displayName,
      );
    } catch (_) {
      return null;
    }
  }

  String _encodeEntry(MindMapFile file) {
    return jsonEncode({
      'locationToken': file.location.token,
      'displayName': file.displayName,
    });
  }
}
