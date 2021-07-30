
import 'dart:async';

import 'package:flutter/services.dart';

class InstagramBasicDisplayApi {
  static const MethodChannel _channel =
      const MethodChannel('instagram_basic_display_api');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}