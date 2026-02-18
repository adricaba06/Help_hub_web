class ApplyRequest {
  final String motivationText;

  ApplyRequest({required this.motivationText});

  Map<String, dynamic> toJson() => {
        'motivationText': motivationText,
      };
}
