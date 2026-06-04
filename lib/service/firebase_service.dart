import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:safe_me/firebase_options.dart';

/// Shared Firebase Realtime Database + auth helpers for [safe-a67e3].
class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  static const String loggedInNicKey = 'logged_in_nic';

  /// Single Firebase Auth account used for all app users (RTDB rules need auth).
  static const String firebaseAuthEmail = 'admin@safeme.app';

  /// Firebase requires ≥6 characters. Set the same value on [firebaseAuthEmail] in Console.
  static const String firebaseAuthPassword = 'SafeMe123';

  FirebaseDatabase? _database;

  FirebaseDatabase get database {
    _database ??= FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: DefaultFirebaseOptions.databaseUrl,
    );
    return _database!;
  }

  DatabaseReference get rootRef => database.ref();

  /// One-shot read without an [EventChannel] stream (avoids hot-reload cancel errors).
  Future<DataSnapshot> getOnce(DatabaseReference ref) => ref.get();

  Future<DataSnapshot> getPublicUser(String nic) {
    final nicKey = nic.trim().toUpperCase();
    return rootRef.child('PublicUsers/All/$nicKey').get();
  }

  /// Signs in with the shared admin account (not the user's RTDB password).
  Future<UserCredential> signInAsAdmin() {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: firebaseAuthEmail,
      password: firebaseAuthPassword,
    );
  }

  /// Verifies NIC + password against Realtime Database [PublicUsers].
  Future<bool> validateNicPassword(String nic, String password) async {
    final nicKey = nic.trim().toUpperCase();

    final storedPassword =
        (await rootRef.child('PublicUsers/All/$nicKey/Password').get()).value;

    if (storedPassword == null) {
      return false;
    }

    return password.trim() == storedPassword.toString().trim();
  }

  /// Legacy RTDB users: sign in anonymously, verify NIC/password, then use admin auth.
  Future<bool> migrateLegacyUser(String nic, String password) async {
    final nicKey = nic.trim().toUpperCase();

    try {
      await FirebaseAuth.instance.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      print('Anonymous auth failed (${e.code}): ${e.message}');
      return false;
    }

    try {
      final valid = await validateNicPassword(nicKey, password);
      if (!valid) {
        await signOut();
        return false;
      }

      await signOut();
      await signInAsAdmin();
      return true;
    } catch (e) {
      print(e);
      await signOut();
      return false;
    }
  }

  static const Duration rtdbTimeout = Duration(seconds: 20);

  /// Re-authenticates when the Firebase session expired (RTDB writes need auth).
  Future<void> ensureAuthenticatedForWrite() async {
    if (FirebaseAuth.instance.currentUser != null) {
      return;
    }
    await signInAsAdmin();
  }

  Future<void> ensureAuthenticated() async {
    if (FirebaseAuth.instance.currentUser != null) {
      return;
    }
    throw FirebaseAuthException(
      code: 'not-signed-in',
      message: 'Please log in again.',
    );
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  /// Complaints for the logged-in user (excludes Lost & Found entries in the same node).
  Future<List<Map<String, dynamic>>> fetchMyComplaints(String nic) async {
    await ensureAuthenticatedForWrite();

    final snapshot = await rootRef
        .child('Complaints/All')
        .get()
        .timeout(rtdbTimeout);

    if (!snapshot.exists || snapshot.value == null) {
      return [];
    }

    final nicKey = nic.trim().toUpperCase();
    final items = <Map<String, dynamic>>[];

    void addEntry(dynamic value) {
      if (value is! Map) return;
      final entry = Map<String, dynamic>.from(
        value.map((k, v) => MapEntry(k.toString(), v)),
      );
      final entryNic = entry['NIC']?.toString().trim().toUpperCase() ?? '';
      if (entryNic != nicKey) return;
      final type = entry['Type']?.toString() ?? '';
      if (type == 'Lost And Found') return;
      items.add(entry);
    }

    final raw = snapshot.value;
    if (raw is Map) {
      for (final value in raw.values) {
        addEntry(value);
      }
    } else if (raw is List) {
      for (final value in raw) {
        addEntry(value);
      }
    }

    items.sort((a, b) {
      final aCid = int.tryParse('${a['CID']}') ?? 0;
      final bCid = int.tryParse('${b['CID']}') ?? 0;
      return bCid.compareTo(aCid);
    });

    return items;
  }

  /// SafeMe alerts for the logged-in user.
  Future<List<Map<String, dynamic>>> fetchMySafeMeAlerts(String nic) async {
    await ensureAuthenticatedForWrite();

    final snapshot = await rootRef
        .child('SafeMe/All')
        .get()
        .timeout(rtdbTimeout);

    if (!snapshot.exists || snapshot.value == null) {
      return [];
    }

    final nicKey = nic.trim().toUpperCase();
    final items = <Map<String, dynamic>>[];

    void addEntry(dynamic value) {
      if (value is! Map) return;
      final entry = Map<String, dynamic>.from(
        value.map((k, v) => MapEntry(k.toString(), v)),
      );
      final entryNic = entry['NIC']?.toString().trim().toUpperCase() ?? '';
      if (entryNic != nicKey) return;
      items.add(entry);
    }

    final raw = snapshot.value;
    if (raw is Map) {
      for (final value in raw.values) {
        addEntry(value);
      }
    } else if (raw is List) {
      for (final value in raw) {
        addEntry(value);
      }
    }

    items.sort((a, b) {
      final aSid = int.tryParse('${a['SID']}') ?? 0;
      final bSid = int.tryParse('${b['SID']}') ?? 0;
      return bSid.compareTo(aSid);
    });

    return items;
  }

  Future<void> deleteSafeMeAlert(String sid) async {
    await ensureAuthenticatedForWrite();
    await rootRef
        .child('SafeMe/All/$sid')
        .remove()
        .timeout(rtdbTimeout);
  }

  Future<void> deleteComplaint(String cid) async {
    await ensureAuthenticatedForWrite();
    await rootRef
        .child('Complaints/All/$cid')
        .remove()
        .timeout(rtdbTimeout);
  }

  static String _nicFromEntry(Map<String, dynamic> entry) {
    for (final key in const ['NIC', 'Nic', 'nic', 'NicNo']) {
      final value = entry[key];
      if (value != null && '$value'.trim().isNotEmpty) {
        return '$value'.trim().toUpperCase();
      }
    }
    return '';
  }

  static Map<String, dynamic> _normalizeEntryMap(Map map) {
    return Map<String, dynamic>.from(
      map.map((k, v) => MapEntry(k.toString(), v)),
    );
  }

  /// Parses RTDB appointment nodes (Firebase array `[null, {...}]`, map, or single record).
  List<Map<String, dynamic>> _collectAppointmentEntries(dynamic raw) {
    if (raw == null) return [];

    final items = <Map<String, dynamic>>[];

    void tryAdd(dynamic value) {
      if (value is! Map) return;
      final entry = _normalizeEntryMap(value);
      if (entry.containsKey('AID') ||
          entry.containsKey('AIDP') ||
          entry.containsKey('NIC') ||
          entry.containsKey('Nic') ||
          entry.containsKey('RequestedDate')) {
        items.add(entry);
      }
    }

    if (raw is Map) {
      final map = _normalizeEntryMap(raw);
      if (map.containsKey('AID') ||
          map.containsKey('AIDP') ||
          map.containsKey('RequestedDate')) {
        return [map];
      }
      for (final entry in map.entries) {
        if (entry.key == 'Records' && entry.value is Map) {
          for (final nested in (entry.value as Map).values) {
            tryAdd(nested);
          }
          continue;
        }
        tryAdd(entry.value);
      }
    } else if (raw is List) {
      for (final value in raw) {
        tryAdd(value);
      }
    }

    return items;
  }

  /// Old appointment form saved test NIC [961240999V]; re-link to the logged-in user.
  static const String _legacyTestAppointmentNic = '961240999V';

  Future<void> _migrateLegacyTestAppointment(String nicKey) async {
    if (nicKey == _legacyTestAppointmentNic) return;

    final ref = rootRef.child('Appointments/PublicAppointments');
    final snapshot = await ref.get().timeout(rtdbTimeout);
    if (!snapshot.exists || snapshot.value == null) return;

    final all = _collectAppointmentEntries(snapshot.value);
    final legacy = all
        .where((e) => _nicFromEntry(e) == _legacyTestAppointmentNic)
        .toList();
    if (legacy.isEmpty) return;

    final updates = <String, Object?>{};
    void scan(dynamic raw) {
      if (raw is Map) {
        for (final entry in raw.entries) {
          if (entry.value is! Map) continue;
          final map = _normalizeEntryMap(entry.value as Map);
          if (_nicFromEntry(map) == _legacyTestAppointmentNic) {
            updates['${entry.key}/NIC'] = nicKey;
          }
        }
      } else if (raw is List) {
        for (var i = 0; i < raw.length; i++) {
          if (raw[i] is! Map) continue;
          final map = _normalizeEntryMap(raw[i] as Map);
          if (_nicFromEntry(map) == _legacyTestAppointmentNic) {
            updates['$i/NIC'] = nicKey;
          }
        }
      }
    }

    scan(snapshot.value);
    if (updates.isEmpty) return;

    await ref.update(updates).timeout(rtdbTimeout);
    print(
      'Migrated ${updates.length} legacy appointment(s) to NIC $nicKey',
    );
  }

  List<Map<String, dynamic>> _entriesForNic(
    dynamic raw,
    String nic, {
    bool includeWithoutNic = false,
    String? email,
  }) {
    final nicKey = nic.trim().toUpperCase();
    final emailKey = email?.trim().toLowerCase() ?? '';
    final all = _collectAppointmentEntries(raw);
    final items = <Map<String, dynamic>>[];

    for (final entry in all) {
      final entryNic = _nicFromEntry(entry);
      final entryEmail =
          (entry['Email'] ?? entry['email'] ?? '').toString().trim().toLowerCase();
      final nicMatch = entryNic == nicKey;
      final emailMatch =
          emailKey.isNotEmpty && entryEmail.isNotEmpty && entryEmail == emailKey;

      if (!nicMatch && !emailMatch) continue;
      if (!includeWithoutNic && entryNic.isEmpty && !emailMatch) continue;
      items.add(entry);
    }

    return items;
  }

  Future<List<Map<String, dynamic>>> _fetchAppointmentsAtPath(
    String path,
    String nic, {
    String? email,
  }) async {
    final snapshot = await rootRef.child(path).get().timeout(rtdbTimeout);
    final all = _collectAppointmentEntries(snapshot.value);
    final filtered = _entriesForNic(snapshot.value, nic, email: email);

    // ignore: avoid_print
    print(
      'Appointments $path: exists=${snapshot.exists} '
      'total=${all.length} matched=${filtered.length} '
      'nics=${all.map(_nicFromEntry).where((n) => n.isNotEmpty).toSet()}',
    );

    return filtered;
  }

  Future<List<Map<String, dynamic>>> fetchMyPublicAppointments(
    String nic, {
    String? email,
  }) async {
    await ensureAuthenticatedForWrite();
    final nicKey = nic.trim().toUpperCase();
    await _migrateLegacyTestAppointment(nicKey);
    final paths = [
      'Appointments/PublicAppointments',
      'Appointments/PublicAppointments/Records',
      'Appointments/PublicAppointment',
    ];

    final merged = <Map<String, dynamic>>[];
    final seen = <String>{};

    for (final path in paths) {
      for (final item in await _fetchAppointmentsAtPath(path, nicKey, email: email)) {
        final key = '${item['AID'] ?? item['aid'] ?? item.hashCode}';
        if (seen.add(key)) merged.add(item);
      }
    }

    merged.sort((a, b) {
      final aId = int.tryParse('${a['AID']}') ?? 0;
      final bId = int.tryParse('${b['AID']}') ?? 0;
      return bId.compareTo(aId);
    });
    return merged;
  }

  Future<List<Map<String, dynamic>>> fetchMyPoliceAppointments(
    String nic, {
    String? email,
  }) async {
    await ensureAuthenticatedForWrite();
    final items = await _fetchAppointmentsAtPath(
      'Appointments/PoliceAppointments',
      nic,
      email: email,
    );
    items.sort((a, b) {
      final aId = int.tryParse('${a['AIDP']}') ?? 0;
      final bId = int.tryParse('${b['AIDP']}') ?? 0;
      return bId.compareTo(aId);
    });
    return items;
  }

  /// Reads [Appointments/LastAID] or legacy [lastAID].
  Future<int> nextAppointmentId() async {
    final snapshot = await rootRef.child('Appointments').get().timeout(rtdbTimeout);
    if (!snapshot.exists || snapshot.value is! Map) return 1;

    final map = _normalizeEntryMap(snapshot.value as Map);
    final raw = map['LastAID'] ?? map['lastAID'] ?? map['LastAid'];
    final current = int.tryParse('$raw') ?? 0;
    return current + 1;
  }
}
