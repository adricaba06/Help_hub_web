import 'package:flutter/foundation.dart';
import '../../../core/models/opportunity_response.dart';
import '../../../core/services/opportunity_service.dart';

class OpportunityProvider extends ChangeNotifier {
  final OpportunityService _service = OpportunityService();

  List<OpportunityResponse> _opportunities = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OpportunityResponse> get opportunities => _opportunities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> searchOpportunities(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _opportunities = await _service.searchOpportunities(query);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _opportunities = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
