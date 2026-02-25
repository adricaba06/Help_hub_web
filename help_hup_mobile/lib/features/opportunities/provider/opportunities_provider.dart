import 'package:flutter/foundation.dart';
import '../../../core/models/opportunity_response.dart';
import '../../../core/services/opportunity_service.dart';

class OpportunitiesProvider extends ChangeNotifier {
  final OpportunityService _service = OpportunityService();

  List<OpportunityResponse> opportunities = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> search({String? query}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      opportunities = await _service.searchOpportunities(query: query);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      opportunities = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
