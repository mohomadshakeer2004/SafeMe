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
}
