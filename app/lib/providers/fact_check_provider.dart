import 'package:flutter/foundation.dart';
import '../models/fact_check_result.dart';
import '../services/api_service.dart';

enum CheckState { idle, loading, deepLoading, success, error }

class FactCheckProvider extends ChangeNotifier {
  final _api = ApiService();

  CheckState _state = CheckState.idle;
  FactCheckResult? _result;
  String? _error;

  CheckState get state => _state;
  FactCheckResult? get result => _result;
  String? get error => _error;
  bool get isLoading => _state == CheckState.loading || _state == CheckState.deepLoading;

  Future<void> checkClaim(String claim) async {
    _state = CheckState.loading;
    _result = null;
    _error = null;
    notifyListeners();

    try {
      _result = await _api.quickCheck(claim);
      _state = CheckState.success;
    } catch (e) {
      _error = e.toString();
      _state = CheckState.error;
    }
    notifyListeners();
  }

  Future<void> deepCheckClaim(String claim) async {
    _state = CheckState.deepLoading;
    _error = null;
    notifyListeners();

    try {
      _result = await _api.deepCheck(claim);
      _state = CheckState.success;
    } catch (e) {
      _error = e.toString();
      _state = CheckState.error;
    }
    notifyListeners();
  }

  void reset() {
    _state = CheckState.idle;
    _result = null;
    _error = null;
    notifyListeners();
  }
}
