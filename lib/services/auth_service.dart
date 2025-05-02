import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: 'YOUR_WEB_CLIENT_ID', // Replace with your actual web client ID
  );
  final String _baseUrl = 'YOUR_API_BASE_URL';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final currentUser = _auth.currentUser;
    return currentUser != null;
  }

  Future<UserModel?> getCurrentUser() async {
    // Stub implementation, replace with actual logic
    return null;
  }

  Future<UserModel?> signUpWithEmail(String email, String password) async {
    // Stub implementation, replace with actual logic
    return null;
  }

  Future<void> logout() async {
    await signOut();
  }

  // Get current user data
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return json.decode(userStr);
    }
    return null;
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserData(userCredential.user);
      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserData(userCredential.user);
      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Google sign in aborted';

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _saveUserData(userCredential.user);
      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign in with Facebook
  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!;
        final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.token);
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      _handleAuthError(FirebaseAuthException(code: 'unknown', message: e.toString()));
      return null;
    }
  }

  // Sign in with Discord
  Future<void> signInWithDiscord() async {
    const clientId = 'YOUR_DISCORD_CLIENT_ID';
    const redirectUri = 'YOUR_REDIRECT_URI';
    const scope = 'identify email';
    
    final uri = Uri.https('discord.com', '/api/oauth2/authorize', {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': scope,
    });

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch Discord authentication';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
        FacebookAuth.instance.logOut(),
      ]);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData(User? user) async {
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
      };
      await prefs.setString(_userKey, json.encode(userData));
    }
  }

  // Handle authentication errors
  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'Email is already registered.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'operation-not-allowed':
          return 'This authentication method is not enabled.';
        default:
          return 'Authentication error: ${error.message}';
      }
    }
    return 'An error occurred during authentication.';
  }
}
