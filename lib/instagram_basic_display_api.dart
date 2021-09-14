import 'dart:async';

import 'package:flutter/services.dart';
import 'package:instagram_basic_display_api/utils.dart';

import 'modules.dart';

class InstagramUser {
  final String id;
  final String name;
  final String accountType;

  InstagramUser(this.id, this.name, this.accountType);
}

class InstagramBasicDisplayApi {
  static const MethodChannel _channel =
      const MethodChannel('instagram_basic_display_api');

  //ignore: close_sinks
  static StreamController<InstagramUser> _userUpdated =
      StreamController<InstagramUser>();

  //ignore: close_sinks
  static StreamController<List<MediaItem>> _mediasUpdated =
      StreamController<List<MediaItem>>();

  //ignore: close_sinks
  static StreamController<List<AlbumDetailItem>> _albumDetailUpdated =
      StreamController<List<AlbumDetailItem>>();

  //ignore: close_sinks
  static StreamController<MediaItem> _mediaItemUpdated =
  StreamController<MediaItem>();

  static Stream<InstagramUser>? broadcastInstagramUserStream;

  static Stream<List<MediaItem>>? _broadcastMediasStream;

  static Stream<List<AlbumDetailItem>>? _broadcastAlbumDetailStream;

  static Stream<MediaItem>? _broadcastMediaItemStream;

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<InstagramUser?> getInstagramUser() async {
    print('getInstagramUser');
    _channel.invokeMethod('getInstagramUser');
    return broadcastInstagramUserStream?.first;
  }

  static Future<InstagramUser?> logout() async {
    print('logout');
    _channel.invokeMethod('logout');
    return broadcastInstagramUserStream?.first;
  }

  static Future<void> askInstagramToken() {
    return _channel.invokeMethod('askInstagramToken');
  }

  static Future<List<MediaItem>?> getMedias() async {
    print('getMedias');
    _channel.invokeMethod('getMedias');
    return _broadcastMediasStream?.first;
  }

  static Future<List<AlbumDetailItem>?> getAlbumDetail(String albumId) async {
    print('getAlbumDetail albumId = $albumId');
    _channel.invokeMethod('getAlbumDetail', {"albumId": albumId});
    return _broadcastAlbumDetailStream?.first;
  }

  static Future<MediaItem?> getMediaItem(String mediaId) async {
    print('getMediaItem mediaId = $mediaId');
    _channel.invokeMethod('getMediaItem', {"mediaId": mediaId});
    return _broadcastMediaItemStream?.first;
  }

  static void initialize() {
    var completer = new Completer<void>();
    broadcastInstagramUserStream = _userUpdated.stream.asBroadcastStream();
    _broadcastMediasStream = _mediasUpdated.stream.asBroadcastStream();
    _broadcastAlbumDetailStream =
        _albumDetailUpdated.stream.asBroadcastStream();
    _broadcastMediaItemStream =
        _mediaItemUpdated.stream.asBroadcastStream();

    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "userUpdated":
          print("userUpdated id = ${call.arguments["ID"]}");
          InstagramUser user = InstagramUser(call.arguments["ID"],
              call.arguments["USER_NAME"], call.arguments["ACCOUNT_TYPE"]);
          _userUpdated.sink.add(user);
          break;
        case "errorUpdated":
          String errorType = call.arguments["ERROR_TYPE"];
          print("errorUpdated ${getExceptionFromString(errorType)}");
          break;
        case "mediasUpdated":
          var medias = extractMedias(call.arguments["DATA"] as List);
          _mediasUpdated.sink.add(medias);
          break;
        case "albumDetailUpdated":
          var albumDetail = extractAlbumDetail(call.arguments["DATA"] as List);
          _albumDetailUpdated.sink.add(albumDetail);
          break;
        case "mediaItemUpdated":
          var mediaItem = MediaItem.fromJson(Map<String, dynamic>.from(call.arguments));
          _mediaItemUpdated.sink.add(mediaItem);
          break;
      }
      completer.complete();
    });
  }
}
