import 'package:flutter/foundation.dart';

import '../../models/credential_model.dart';
import 'autofill_transport.dart';

class AutofillManager extends ChangeNotifier {
  AutofillManager._internal();
  static final AutofillManager _instance = AutofillManager._internal();
  factory AutofillManager() => _instance;

  final AutofillTransport _transport = AutofillTransport.instance;

  bool _isActive = false;
  String _query = '';
  List<Credential> _credentials = [];
  Credential? _lastAutofilled;

  bool get isActive => _isActive;
  String get query => _query;
  List<Credential> get allCredentials => List.unmodifiable(_credentials);
  List<Credential> get filteredCredentials {
    final lower = _query.toLowerCase();
    return _credentials.where((credential) {
      if (lower.isEmpty) return true;
      final matchesTitle = credential.title.toLowerCase().contains(lower);
      final matchesUsername = credential.username.toLowerCase().contains(lower);
      final matchesUrl = (credential.url ?? '').toLowerCase().contains(lower);
      return matchesTitle || matchesUsername || matchesUrl;
    }).toList();
  }

  void updateCredentials(List<Credential> credentials) {
    _credentials = credentials;
    notifyListeners();
  }

  void openOverlay() {
    _query = '';
    _isActive = true;
    notifyListeners();
  }

  void closeOverlay() {
    _isActive = false;
    notifyListeners();
  }

  void updateQuery(String query) {
    _query = query;
    notifyListeners();
  }

  Future<void> autofillCredential(Credential credential) async {
    if (credential.password.isEmpty) return;
    await _transport.performAutofill(credential.password);
    _lastAutofilled = credential;
    closeOverlay();
  }

  Credential? get lastAutofilled => _lastAutofilled;
}
