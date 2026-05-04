import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dube/core/constants/firestore_paths.dart';
import 'package:dube/features/auth/data/models/app_user.dart';

class AuthRepository {
  final FirebaseAuth      _auth;
  final FirebaseFirestore _db;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db   = db   ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User?         get currentUser      => _auth.currentUser;

  // ── Sign up ────────────────────────────────────────────────────────────────
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String shopName,
    required String phone,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    final appUser = AppUser(
      uid:       cred.user!.uid,
      email:     email,
      shopName:  shopName,
      phone:     phone,
      createdAt: DateTime.now(),
    );

    await _db.doc(FirestorePaths.user(cred.user!.uid))
        .set(appUser.toFirestore());

    return appUser;
  }

  // ── Sign in ────────────────────────────────────────────────────────────────
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return _fetchProfile(cred.user!.uid);
  }

  // ── Sign out ───────────────────────────────────────────────────────────────
  Future<void> signOut() => _auth.signOut();

  // ── Helpers ────────────────────────────────────────────────────────────────
  Future<AppUser> _fetchProfile(String uid) async {
    final doc = await _db.doc(FirestorePaths.user(uid)).get();
    if (!doc.exists) throw Exception('User profile not found');
    return AppUser.fromFirestore(doc);
  }

  Future<AppUser?> getCurrentUserProfile() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    return _fetchProfile(u.uid);
  }
}
