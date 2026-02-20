import 'package:flutter/foundation.dart';
import '../../../core/models/opportunity_detail_response.dart';
import '../../../core/services/opportunity_service.dart';

class OpportunityDetailProvider extends ChangeNotifier {
  final OpportunityService _service = OpportunityService();

  OpportunityDetailResponse? detail;
  bool isLoading = false;
  String? errorMessage;

  Future<void> load(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      detail = await _service.getOpportunityDetail(id);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      detail = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
