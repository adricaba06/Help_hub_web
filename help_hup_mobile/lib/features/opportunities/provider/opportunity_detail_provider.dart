import 'package:flutter/foundation.dart';
import '../../../core/models/opportunity_detail_response.dart';
import '../../../core/services/opportunity_service.dart';

class OpportunityDetailProvider extends ChangeNotifier {
  final OpportunityService _service = OpportunityService();

  OpportunityDetailResponse? detail;
  bool isLoading = false;
  String? errorMessage;
  bool applying = false;
  String? applyError;
  bool appliedOk = false;

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

  Future<bool> apply(int opportunityId, String motivation) async {
    applying = true;
    applyError = null;
    appliedOk = false;
    notifyListeners();

    try {
      await _service.apply(opportunityId, motivation);
      await load(opportunityId);
      appliedOk = true;
      return true;
    } catch (e) {
      applyError = e.toString();
      return false;
    } finally {
      applying = false;
      notifyListeners();
    }
  }
}
