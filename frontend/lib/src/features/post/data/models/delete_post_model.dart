class DeletePostModel {
  final String postId;

  const DeletePostModel({required this.postId});

  factory DeletePostModel.fromJson(Map<String, dynamic> json) {
    return DeletePostModel(postId: json['postId'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'postId': postId};
  }

  Map<String, String> toPathParams() {
    return {'postId': postId};
  }
}
