class MediaItem {
  String id;
  String caption;
  String mediaType;
  String timestamp;
  String permalink;
  String mediaUrl;
  String? thumbnailUrl;

  MediaItem({
    required this.id,
    required this.caption,
    required this.mediaType,
    required this.timestamp,
    required this.permalink,
    required this.mediaUrl,
    required this.thumbnailUrl,});

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json["id"],
      caption: json["caption"],
      mediaType: json["media_type"],
      timestamp: json["timestamp"],
      permalink: json["permalink"],
      mediaUrl: json["media_url"],
      thumbnailUrl: json["thumbnail_url"] ?? null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['caption'] = this.caption;
    data['media_type'] = this.mediaType;
    data['timestamp'] = this.timestamp;
    data['permalink'] = this.permalink;
    data['media_url'] = this.mediaUrl;
    data['thumbnail_url'] = this.thumbnailUrl;

    return data;
  }
}

class AlbumDetailItem {
  String id;
  String mediaType;
  String timestamp;
  String mediaUrl;
  String? thumbnailUrl;

  AlbumDetailItem({
    required this.id,
    required this.mediaType,
    required this.timestamp,
    required this.mediaUrl,
    required this.thumbnailUrl,});

  factory AlbumDetailItem.fromJson(Map<String, dynamic> json) {
    return AlbumDetailItem(
      id: json["id"],
      mediaType: json["media_type"],
      timestamp: json["timestamp"],
      mediaUrl: json["media_url"],
      thumbnailUrl: json["thumbnail_url"] ?? null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['media_type'] = this.mediaType;
    data['timestamp'] = this.timestamp;
    data['media_url'] = this.mediaUrl;
    data['thumbnail_url'] = this.thumbnailUrl;

    return data;
  }
}

enum NativeException {
  NULL_ACTIVITY,
  ASK_TOKEN_INTERRUPT,
  NOT_FOUND_IG_CLIENT,
  TOKEN_EXPIRED,
  TOKEN_EMPTY,
  UNKNOWN_EXCEPTION
}

