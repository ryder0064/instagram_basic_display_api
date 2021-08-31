import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:instagram_basic_display_api/instagram_basic_display_api.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await InstagramBasicDisplayApi.platformVersion ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> checkInstagramToken() async {
    bool isInstagramTokenValid;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      isInstagramTokenValid =
      await InstagramBasicDisplayApi.isInstagramTokenValid;
    } on PlatformException {
      isInstagramTokenValid = false;
    }
    print('isInstagramTokenValid $isInstagramTokenValid');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Text('Running on: $_platformVersion\n'),
            TextButton(
                onPressed: () {
                  checkInstagramToken();
                },
                child: Text('isTokenValid'))
          ],
        ),
      ),
    );
  }
}
