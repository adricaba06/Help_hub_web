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

  Future<Object?> apply(int opportunityId, String motivation) async {
    applying = true;
    applyError = null;
    appliedOk = false;
    notifyListeners();

    try {
      final res = await _service.applyToOpportunity(
        opportunityId: opportunityId,
        motivationText: motivation.trim(),
      );
      appliedOk = true;
      return res;
    } catch (e) {
      applyError = e.toString();
      return null;
    } finally {
      applying = false;
      notifyListeners();
    }
  }
}
