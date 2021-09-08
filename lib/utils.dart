import 'modules.dart';
import 'dart:convert';

List<MediaItem> extractMedias(List result) {
  List<MediaItem> list = (result)
      .map((item) {
    print("${item.runtimeType.toString()}");
    return MediaItem.fromJson(Map<String, dynamic>.from(item));
  }).toList();

  return list;
}

List<AlbumDetailItem> extractAlbumDetail(List result) {
  List<AlbumDetailItem> list = (result)
      .map((item) {
    print("${item.runtimeType.toString()}");
    return AlbumDetailItem.fromJson(Map<String, dynamic>.from(item));
  }).toList();

  return list;
}