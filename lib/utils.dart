import 'modules.dart';

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

NativeException getExceptionFromString(String errorType) {
  errorType = 'NativeException.$errorType';
  return NativeException.values.firstWhere((f)=> f.toString() == errorType, orElse: () => NativeException.UNKNOWN_EXCEPTION);
}