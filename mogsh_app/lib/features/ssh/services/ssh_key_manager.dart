import 'dart:convert';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';

class SshKeyEntry {
  final String id;
  final String label;
  final String publicKey; // OpenSSH format: "ssh-ed25519 AAAA..."

  const SshKeyEntry({required this.id, required this.label, required this.publicKey});
}

class SshKeyManager {
  static const _storage = FlutterSecureStorage();
  static final _localAuth = LocalAuthentication();

  /// Convert a dartssh2 public key object to OpenSSH authorized_keys format.
  /// SSHHostKey is an internal type not exported by dartssh2, so we use dynamic
  /// and parse the type from the SSH wire format (4-byte length + type string).
  static String _toOpenSSH(dynamic hostKey) {
    final Uint8List encoded = hostKey.encode() as Uint8List;
    // SSH wire format: uint32 type_len + type_bytes + ...
    final typeLen = ByteData.sublistView(encoded, 0, 4).getUint32(0);
    final type = utf8.decode(encoded.sublist(4, 4 + typeLen));
    return '$type ${base64.encode(encoded)}';
  }

  /// Key generation requires ssh-keygen which is not available on Android without proot.
  /// Use [importPem] to add an existing key, or generate one externally.
  static Future<SshKeyEntry> generate(String label) async {
    throw UnimplementedError(
      'On-device key generation is not supported yet. '
      'Please generate a key on your computer and import the PEM.',
    );
  }

  /// Import from OpenSSH private key PEM string
  static Future<SshKeyEntry> importPem(
    String pem,
    String label, {
    String? passphrase,
  }) async {
    final keys = SSHKeyPair.fromPem(pem, passphrase);
    if (keys.isEmpty) throw const FormatException('No keys found in PEM data');
    final key = keys.first;
    final id = const Uuid().v4();
    final pubKey = _toOpenSSH(key.toPublicKey());

    await _storage.write(key: 'sshkey_priv_$id', value: pem);
    await _storage.write(key: 'sshkey_pub_$id', value: pubKey);
    await _storage.write(key: 'sshkey_label_$id', value: label);
    await _addKeyIndex(id);

    return SshKeyEntry(id: id, label: label, publicKey: pubKey);
  }

  static Future<List<SshKeyEntry>> listAll() async {
    final indexRaw = await _storage.read(key: 'sshkey_index') ?? '[]';
    final ids = (indexRaw.substring(1, indexRaw.length - 1))
        .split(',')
        .map((s) => s.trim().replaceAll('"', ''))
        .where((s) => s.isNotEmpty)
        .toList();

    final entries = <SshKeyEntry>[];
    for (final id in ids) {
      final pub = await _storage.read(key: 'sshkey_pub_$id');
      final label = await _storage.read(key: 'sshkey_label_$id');
      if (pub != null && label != null) {
        entries.add(SshKeyEntry(id: id, label: label, publicKey: pub));
      }
    }
    return entries;
  }

  /// Get private key — optionally requires biometric auth
  static Future<SSHKeyPair?> getPrivateKey(
    String id, {
    bool requireBiometric = false,
  }) async {
    if (requireBiometric) {
      final authed = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access SSH private key',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (!authed) return null;
    }

    final pem = await _storage.read(key: 'sshkey_priv_$id');
    if (pem == null) return null;
    final keys = SSHKeyPair.fromPem(pem);
    return keys.isEmpty ? null : keys.first;
  }

  static Future<void> delete(String id) async {
    await _storage.delete(key: 'sshkey_priv_$id');
    await _storage.delete(key: 'sshkey_pub_$id');
    await _storage.delete(key: 'sshkey_label_$id');
    await _removeKeyIndex(id);
  }

  static Future<void> _addKeyIndex(String id) async {
    final raw = await _storage.read(key: 'sshkey_index') ?? '[]';
    final list = raw
        .substring(1, raw.length - 1)
        .split(',')
        .map((s) => s.trim().replaceAll('"', ''))
        .where((s) => s.isNotEmpty)
        .toList();
    list.add(id);
    await _storage.write(
        key: 'sshkey_index', value: '["${list.join('","')}"]');
  }

  static Future<void> _removeKeyIndex(String id) async {
    final raw = await _storage.read(key: 'sshkey_index') ?? '[]';
    final list = raw
        .substring(1, raw.length - 1)
        .split(',')
        .map((s) => s.trim().replaceAll('"', ''))
        .where((s) => s.isNotEmpty && s != id)
        .toList();
    await _storage.write(
        key: 'sshkey_index',
        value: list.isEmpty ? '[]' : '["${list.join('","')}"]');
  }
}
