import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/widgets.dart'; 

class AppUser {
  final String id;
  final String email;

  AppUser({
    required this.id,
    required this.email,
  });

  factory AppUser.fromFirebase(fb.User user) {
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
    );
  }
}

class AuthService extends ChangeNotifier {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  AppUser? _currentUser;
  bool _isLoading = false;
  String _error = '';
  bool _isAuthenticated = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isAuthenticated => _isAuthenticated;

 Future<void> initialize() async {
  _isLoading = true;
  notifyListeners();

  try {
    // check existing user
    final user = _auth.currentUser;
    if (user != null) {
      _currentUser = AppUser.fromFirebase(user);
      _isAuthenticated = true;
    }

    // listen for changes
    _auth.authStateChanges().listen((fb.User? user) {
      if (user != null) {
        _currentUser = AppUser.fromFirebase(user);
        _isAuthenticated = true;
      } else {
        _currentUser = null;
        _isAuthenticated = false;
      }

      // safe notify
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    });
  } catch (e) {
    _error = 'Initialization failed: $e';
  } finally {
    _isLoading = false;
    // safe notify
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}


  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final creds = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = AppUser.fromFirebase(creds.user!);
      _isAuthenticated = true;
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _error = e.message ?? 'Login failed';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final creds = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = AppUser.fromFirebase(creds.user!);
      _isAuthenticated = true;
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _error = e.message ?? 'Signup failed';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
