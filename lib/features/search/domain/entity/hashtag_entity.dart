import 'package:auto_route/auto_route.dart';

import 'package:colibri/features/search/data/models/hashtags_response.dart';

class HashTagEntity {
  final String id;
  final String name;
  final String totalPosts;

  HashTagEntity._(
      {@required this.id, @required this.name, @required this.totalPosts});

  factory HashTagEntity.fromHashTag(HashTag item ){
    return HashTagEntity._(id: item.id.toString(), name: item.hashtag, totalPosts: item.total);
  }
}
