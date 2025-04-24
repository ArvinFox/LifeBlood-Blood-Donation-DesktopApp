import 'package:blood_donation_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Stream<User?> get authStateChanges => _authService.getAuthStateChanges();

  // Reset state
  void resetState() {
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // Login
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (email.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = "Please enter both email and password.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final userCredential = await _authService.signIn(email, password);
      _currentUser = userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
          _errorMessage = "Incorrect email or password.";
          break;
        case 'invalid-email':
          _errorMessage = "Please enter a valid email address.";
          break;
        case 'user-disabled':
          _errorMessage = "This account has been disabled. Contact support.";
          break;
        default:
          _errorMessage = "Something went wrong. Please try again later.";
      }
    } catch (e) {
      _errorMessage = "An unexpected error occurred. Please try again.";
    }

    _isLoading = false;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (email.trim().isEmpty) {
      _errorMessage = "Please enter your email address.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      await _authService.resetPassword(email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = "No account found with this email.";
          break;
        case 'invalid-email':
          _errorMessage = "Please enter a valid email address.";
          break;
        default:
          _errorMessage = "Something went wrong. Please try again later.";
      }
    } catch (e) {
      _errorMessage = "An unexpected error occurred. Please try again.";
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load user data
  void initialize() {
    _authService.getAuthStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }
}