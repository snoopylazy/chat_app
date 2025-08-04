import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _presenceTimer;

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Sign In with Email & Password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user info in Firestore on login
      await _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'isOnline': true,
        'lastActive': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Start presence system
      _startPresenceSystem();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception("Login failed: ${e.message}");
    }
  }

  /// Sign Up with Email & Password
  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'isOnline': true,
        'lastActive': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      });

      // Start presence system
      _startPresenceSystem();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception("Signup failed: ${e.message}");
    }
  }

  /// Sign Out user
  Future<void> signOut() async {
    await setUserOnlineStatus(false);
    _stopPresenceSystem();
    await _auth.signOut();
  }

  /// Update user's online status
  Future<void> setUserOnlineStatus(bool isOnline) async {
    final user = _auth.currentUser;
    if (user != null) {
      final updateData = {
        'isOnline': isOnline,
        'lastActive': FieldValue.serverTimestamp(),
      };

      if (!isOnline) {
        updateData['lastSeen'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection('Users').doc(user.uid).set(
        updateData,
        SetOptions(merge: true),
      );
    }
  }

  /// Start presence system to periodically update user status
  void _startPresenceSystem() {
    _presenceTimer?.cancel();
    _presenceTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setUserOnlineStatus(true);
    });
  }

  /// Stop presence system
  void _stopPresenceSystem() {
    _presenceTimer?.cancel();
    _presenceTimer = null;
  }

  /// Stream of auth state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  /// Get user's last seen time as a formatted string
  String getLastSeenText(Map<String, dynamic> userData) {
    final bool isOnline = userData['isOnline'] ?? false;
    if (isOnline) return 'Online';

    final Timestamp? lastSeen = userData['lastSeen'];
    if (lastSeen == null) return 'Last seen unknown';

    final DateTime lastSeenDate = lastSeen.toDate();
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(lastSeenDate);

    if (difference.inMinutes < 1) {
      return 'Last seen just now';
    } else if (difference.inMinutes < 60) {
      return 'Last seen ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Last seen ${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return 'Last seen ${difference.inDays}d ago';
    } else {
      return 'Last seen long ago';
    }
  }

  /// Check if user was recently active (within 5 minutes)
  bool isRecentlyActive(Map<String, dynamic> userData) {
    final Timestamp? lastActive = userData['lastActive'];
    if (lastActive == null) return false;

    final DateTime lastActiveDate = lastActive.toDate();
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(lastActiveDate);

    return difference.inMinutes <= 5;
  }
}