import 'package:equatable/equatable.dart';

enum StoryMediaType { image, video }

class StoryItemEntity extends Equatable {
  final String id;
  final String url;
  final StoryMediaType type;
  final Duration duration;

  const StoryItemEntity({
    required this.id,
    required this.url,
    this.type = StoryMediaType.image,
    this.duration = const Duration(seconds: 5),
  });

  @override
  List<Object?> get props => [id, url, type, duration];
}
