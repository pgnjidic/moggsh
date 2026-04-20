import 'dart:convert';

class ServerProfile {
  final String id;
  String label;
  String host;
  int port;
  String username;
  String? password;
  String? keyId;        // ref to SshKeyManager
  String? startupScript;
  DateTime? lastConnected;

  ServerProfile({
    required this.id,
    required this.label,
    required this.host,
    this.port = 22,
    required this.username,
    this.password,
    this.keyId,
    this.startupScript,
    this.lastConnected,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'host': host,
    'port': port,
    'username': username,
    'password': password,
    'keyId': keyId,
    'startupScript': startupScript,
    'lastConnected': lastConnected?.toIso8601String(),
  };

  factory ServerProfile.fromJson(Map<String, dynamic> j) => ServerProfile(
    id: j['id'],
    label: j['label'],
    host: j['host'],
    port: j['port'] ?? 22,
    username: j['username'],
    password: j['password'],
    keyId: j['keyId'],
    startupScript: j['startupScript'],
    lastConnected: j['lastConnected'] != null
        ? DateTime.parse(j['lastConnected'])
        : null,
  );

  static List<ServerProfile> listFromJson(String raw) =>
      (jsonDecode(raw) as List).map((e) => ServerProfile.fromJson(e)).toList();

  static String listToJson(List<ServerProfile> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());
}
