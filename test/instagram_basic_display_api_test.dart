import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:instagram_basic_display_api/instagram_basic_display_api.dart';

void main() {
  const MethodChannel channel = MethodChannel('instagram_basic_display_api');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await InstagramBasicDisplayApi.platformVersion, '42');
  });
}
