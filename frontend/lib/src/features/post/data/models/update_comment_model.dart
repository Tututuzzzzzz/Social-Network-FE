class UpdateCommentModel {
  final String content;

  const UpdateCommentModel({required this.content});

  Map<String, dynamic> toJson() {
    return {'content': content.trim()};
  }
}
