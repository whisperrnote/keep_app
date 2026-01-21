import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import '../services/appwrite_service.dart';
import 'package:appwrite/models.dart' as models;

class AuthProvider extends ChangeNotifier {
  final AppwriteService _appwrite = AppwriteService();
  models.User? _user;
  bool _isLoading = true;

  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  models.User? get user => _user;

  AuthProvider() {
    init();
  }

  Future<void> init() async {
    try {
      _user = await _appwrite.account.get();
    } catch (e) {
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _appwrite.account.createEmailPasswordSession(
        email: email, 
        password: password
      );
      _user = await _appwrite.account.get();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _appwrite.account.deleteSession(sessionId: 'current');
      _user = null;
      notifyListeners();
    } catch (e) {
      // Even if it fails, we clear local state
      _user = null;
      notifyListeners();
    }
  }
}
