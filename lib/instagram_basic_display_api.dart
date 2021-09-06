
import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';

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
  static StreamController<InstagramUser> _userUpdated = StreamController<InstagramUser>();
  //ignore: close_sinks
  static StreamController<bool> _isTokenValid = StreamController<bool>();
  //ignore: close_sinks
  static StreamController<List<MediaItem>> _mediasUpdated = StreamController<List<MediaItem>>();

  static Stream<InstagramUser>? _broadcastInstagramUserStream;

  static Stream<List<MediaItem>>? _broadcastMediasStream;

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool?> get isInstagramTokenValid async {
    print('isInstagramTokenValid');
    final bool isInstagramTokenValid =
    await _channel.invokeMethod('isInstagramTokenValid');
    return isInstagramTokenValid;
    // _channel.invokeMethod('isInstagramTokenValid');
    // return _broadcastTokenValidStream?.first;
  }

  static Future<InstagramUser?> getInstagramUser() async {
    print('getInstagramUser');
    _channel.invokeMethod('getInstagramUser');
    return _broadcastInstagramUserStream?.first;
  }

  static Future<InstagramUser?> logout() async {
    print('logout');
    _channel.invokeMethod('logout');
    return _broadcastInstagramUserStream?.first;
  }

  static Future<void> askInstagramToken() {
    return _channel.invokeMethod('askInstagramToken');
  }

  static Future<List<MediaItem>?> getMedias() async {
    print('getMedias');
    _channel.invokeMethod('getMedias');
    return _broadcastMediasStream?.first;
  }

  static void initialize() {
    var completer = new Completer<void>();
    _broadcastInstagramUserStream = _userUpdated.stream.asBroadcastStream();
    _broadcastMediasStream = _mediasUpdated.stream.asBroadcastStream();

    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "userUpdated":
          print("Ryder userUpdated id = ${call.arguments["ID"]}");
          InstagramUser user = InstagramUser(call.arguments["ID"],
              call.arguments["USER_NAME"], call.arguments["ACCOUNT_TYPE"]);
          _userUpdated.sink.add(user);
          break;
        case "isInstagramTokenValid":
          bool isTokenValid = call.arguments["IS_TOKEN_VALID"];
          print("Ryder isInstagramTokenValid $isTokenValid");
          _isTokenValid.sink.add(isTokenValid);
          break;
        case "errorUpdated":
          String errorType = call.arguments["ERROR_TYPE"];
          print("Ryder errorUpdated $errorType");
          break;
        case "mediasUpdated":
          print("\n\n\nRyder mediasUpdated\n${call.arguments["DATA"]}");

          List<MediaItem> temp = (call.arguments["DATA"] as List)
              .map((item) {
                print("${item.runtimeType.toString()}");
            return MediaItem.fromJson(Map<String, dynamic>.from(item));
          }).toList();

          _mediasUpdated.sink.add(temp);
          break;
      }
      completer.complete();
    });
  }
}
