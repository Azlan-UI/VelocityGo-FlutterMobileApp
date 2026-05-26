import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile');

        return await _auth.signInWithPopup(googleProvider);
      }

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User cancelled
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-google-auth-token',
          message:
              'Google did not return an auth token. Check Firebase Google sign-in setup.',
        );
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Create or update user document in Firestore
  Future<void> createUserDocument(User user, String role) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        final userModel = UserModel(
          uid: user.uid,
          username: user.displayName ?? 'User',
          email: user.email ?? '',
          role: role,
          rating: 5.0,
          totalRides: 0,
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());
      } else {
        await _firestore.collection('users').doc(user.uid).update({
          'role': role,
        });
      }

      // If driver, also create driver document.
      if (role == 'driver') {
        await ensureDriverDocument(user);
      }
    } catch (e) {
      debugPrint('Error creating user document: $e');
      rethrow;
    }
  }

  // Create the driver profile if the user role says driver but the document is missing.
  Future<DriverModel> ensureDriverDocument(User user) async {
    try {
      final driverRef = _firestore.collection('drivers').doc(user.uid);
      final driverDoc = await driverRef.get();

      if (driverDoc.exists) {
        return DriverModel.fromMap(driverDoc.data()!);
      }

      final driverModel = DriverModel(
        uid: user.uid,
        username: user.displayName ?? 'Driver',
        latitude: 33.6844,
        longitude: 73.0479,
        available: true,
        locationIndex: 0,
        rating: 5.0,
        totalTrips: 0,
        earnings: 0.0,
      );

      await driverRef.set(driverModel.toMap());
      return driverModel;
    } catch (e) {
      debugPrint('Error ensuring driver document: $e');
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  // Get driver data from Firestore
  Future<DriverModel?> getDriverData(String uid) async {
    try {
      final doc = await _firestore.collection('drivers').doc(uid).get();
      if (doc.exists) {
        return DriverModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting driver data: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  // Update user rating
  Future<void> updateUserRating(String uid, double newRating) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'rating': newRating,
      });
    } catch (e) {
      debugPrint('Error updating rating: $e');
    }
  }

  // Increment total rides
  Future<void> incrementTotalRides(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'totalRides': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error incrementing rides: $e');
    }
  }
}
