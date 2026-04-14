import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/server_profile.dart';

class ServerProfileService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'server_profiles_v1';

  Future<List<ServerProfile>> loadAll() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return [];
    return ServerProfile.listFromJson(raw);
  }

  Future<void> saveAll(List<ServerProfile> profiles) async {
    await _storage.write(key: _key, value: ServerProfile.listToJson(profiles));
  }

  Future<ServerProfile> add({
    required String label,
    required String host,
    required String username,
    int port = 22,
    String? password,
    String? keyId,
    String? startupScript,
  }) async {
    final profiles = await loadAll();
    final profile = ServerProfile(
      id: const Uuid().v4(),
      label: label,
      host: host,
      port: port,
      username: username,
      password: password,
      keyId: keyId,
      startupScript: startupScript,
    );
    profiles.add(profile);
    await saveAll(profiles);
    return profile;
  }

  Future<void> update(ServerProfile updated) async {
    final profiles = await loadAll();
    final idx = profiles.indexWhere((p) => p.id == updated.id);
    if (idx >= 0) profiles[idx] = updated;
    await saveAll(profiles);
  }

  Future<void> delete(String id) async {
    final profiles = await loadAll();
    profiles.removeWhere((p) => p.id == id);
    await saveAll(profiles);
  }

  /// Export all profiles as JSON string (no sensitive keys)
  Future<String> export() async {
    final profiles = await loadAll();
    return jsonEncode(profiles.map((p) => {
      ...p.toJson(),
      'password': null, // strip passwords on export
    }).toList());
  }

  /// Import from JSON string
  Future<void> import(String json) async {
    final imported = ServerProfile.listFromJson(json);
    final existing = await loadAll();
    final existingIds = existing.map((p) => p.id).toSet();
    for (final p in imported) {
      if (!existingIds.contains(p.id)) existing.add(p);
    }
    await saveAll(existing);
  }
}
