class OpportunityFilter {
  final String? title;
  final String? city;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? status;

  const OpportunityFilter({
    this.title,
    this.city,
    this.dateFrom,
    this.dateTo,
    this.status,
  });

  static String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Map<String, String> toQueryParameters() {
    final params = <String, String>{};

    if (title != null && title!.trim().isNotEmpty) {
      params['title'] = title!.trim();
    }
    if (city != null && city!.trim().isNotEmpty) {
      params['city'] = city!.trim();
    }
    if (dateFrom != null) {
      params['dateFrom'] = _formatDate(dateFrom!);
    }
    if (dateTo != null) {
      params['dateTo'] = _formatDate(dateTo!);
    }
    if (status != null && status!.trim().isNotEmpty) {
      params['status'] = status!.trim().toUpperCase();
    }

    return params;
  }
}
