class ReportPostModel {
  final String reason;
  final String description;

  const ReportPostModel({
    required this.reason,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
      'description': description,
    };
  }
}
