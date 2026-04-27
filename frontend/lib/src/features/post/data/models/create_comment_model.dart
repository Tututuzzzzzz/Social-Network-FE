class CreateCommentModel {
  final String content;
  final String? parentCommentId;

  const CreateCommentModel({required this.content, this.parentCommentId});

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      if (parentCommentId != null && parentCommentId!.trim().isNotEmpty)
        'parentCommentId': parentCommentId!.trim(),
    };
  }
}
