import 'package:flutter/foundation.dart';

class AppStateProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _hasSeenOnboarding = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  void setHasSeenOnboarding(bool value) {
    _hasSeenOnboarding = value;
    notifyListeners();
  }
}