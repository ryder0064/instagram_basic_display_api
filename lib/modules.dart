class MediaItem {
  String id;
  String caption;
  String mediaType;
  String timestamp;
  String permalink;

  MediaItem({
    required this.id,
    required this.caption,
    required this.mediaType,
    required this.timestamp,
    required this.permalink,});

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json["id"],
      caption: json["caption"],
      mediaType: json["media_type"],
      timestamp: json["timestamp"],
      permalink: json["permalink"],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['caption'] = this.caption;
    data['media_type'] = this.mediaType;
    data['timestamp'] = this.timestamp;
    data['permalink'] = this.permalink;

    return data;
  }
}