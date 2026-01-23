import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import '../services/appwrite_service.dart';
import '../services/ecosystem_auth_service.dart';
import 'package:appwrite/models.dart' as models;
import '../constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  final AppwriteService _appwrite = AppwriteService();
  final EcosystemAuthService _ecosystem = EcosystemAuthService();
  models.User? _user;
  bool _isLoading = true;

  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  models.User? get user => _user;

  AuthProvider() {
    init();
  }

  Future<void> init() async {
    if (AppConstants.useMockMode) {
      _user = models.User(
        $id: "mock_user",
        $createdAt: DateTime.now().toIso8601String(),
        $updatedAt: DateTime.now().toIso8601String(),
        name: "Mock User",
        registration: DateTime.now().toIso8601String(),
        status: true,
        passwordUpdate: DateTime.now().toIso8601String(),
        email: "mock@example.com",
        phone: "",
        emailVerification: true,
        phoneVerification: true,
        prefs: models.Preferences(data: {}),
        accessedAt: DateTime.now().toIso8601String(),
      );
      _isLoading = false;
      notifyListeners();
      return;
    }
    try {
      _user = await _appwrite.account.get();
    } catch (e) {
      // If not logged in locally, check the Ecosystem Vault
      final inherited = await _ecosystem.getSession();
      if (inherited != null) {
        try {
          await _appwrite.account.createSession(
            userId: inherited['userId']!,
            secret: inherited['secret']!,
          );
          _user = await _appwrite.account.get();
        } catch (_) {
          _user = null;
        }
      } else {
        _user = null;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final session = await _appwrite.account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      // Save to Ecosystem Vault for other apps to inherit
      await _ecosystem.saveSession(session.userId, session.secret);

      _user = await _appwrite.account.get();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _appwrite.account.deleteSession(sessionId: 'current');
      await _ecosystem.clearSession(); // Also clear the vault
      _user = null;
      notifyListeners();
    } catch (e) {
      // Even if it fails, we clear local state
      await _ecosystem.clearSession();
      _user = null;
      notifyListeners();
    }
  }
}
