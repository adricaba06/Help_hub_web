import 'package:flutter/foundation.dart';
import '../../../core/models/opportunity_response.dart';
import '../../../core/services/opportunity_service.dart';

class OpportunityProvider extends ChangeNotifier {
  final OpportunityService _service = OpportunityService();

  List<OpportunityResponse> _opportunities = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCity;
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;
  String _searchQuery = '';

  List<OpportunityResponse> get opportunities => _opportunities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCity => _selectedCity;
  DateTime? get filterDateFrom => _filterDateFrom;
  DateTime? get filterDateTo => _filterDateTo;

  Future<void> searchOpportunities(String query) async {
    _searchQuery = query;
    await _performSearch();
  }

  Future<void> setCity(String? city) async {
    _selectedCity = city;
    await _performSearch();
  }

  Future<void> setDateRange(DateTime? from, DateTime? to) async {
    _filterDateFrom = from;
    _filterDateTo = to;
    await _performSearch();
  }

  Future<void> clearFilters() async {
    _selectedCity = null;
    _filterDateFrom = null;
    _filterDateTo = null;
    await _performSearch();
  }

  Future<void> _performSearch() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _opportunities = await _service.searchOpportunities(
        query: _searchQuery.isEmpty ? null : _searchQuery,
        city: _selectedCity,
        dateFrom: _filterDateFrom,
        dateTo: _filterDateTo,
      );
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
