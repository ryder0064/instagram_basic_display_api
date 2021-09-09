import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:instagram_basic_display_api/instagram_basic_display_api.dart';
import 'package:instagram_basic_display_api/modules.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  List<MediaItem>? _mediaList;
  InstagramUser? _instagramUser;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    InstagramBasicDisplayApi.initialize();

    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await InstagramBasicDisplayApi.platformVersion ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    setState(() {
      _platformVersion = platformVersion;
    });

    InstagramBasicDisplayApi.broadcastInstagramUserStream?.listen((instagramUser) {
      print('instagramUser = ${instagramUser.id}, ${instagramUser.accountType}, ${instagramUser.name}');
      if (instagramUser.id.isNotEmpty &&
          instagramUser.name.isNotEmpty &&
          instagramUser.accountType.isNotEmpty){
        setState(() {
          _instagramUser = instagramUser;
        });
      } else {
        print('has logout instagram');
        setState(() {
          _instagramUser = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(
          children: <Widget>[
            Text('Running on: $_platformVersion\n'),
            Text(_instagramUser != null ? "id: ${_instagramUser!.id}\naccountType: ${_instagramUser!.accountType}\nname: ${_instagramUser!.name}\n":"No Instagram log in"),
            ElevatedButton(
                child: Text("get user"),
                onPressed: () {
                  InstagramBasicDisplayApi.getInstagramUser();
                }),
            ElevatedButton(
                child: Text("askToken"),
                onPressed: () {
                  InstagramBasicDisplayApi.askInstagramToken();
                }),
            ElevatedButton(
                child: Text("logout"),
                onPressed: () {
                  InstagramBasicDisplayApi.logout();
                  setState(() {
                    _mediaList = null;
                  });
                }),
            ElevatedButton(
              child: Text("getMedias"),
              onPressed: () {
                InstagramBasicDisplayApi.getMedias().then((medias) {
                  print("\n\nmedias = $medias\n\n");
                  if (medias == null) {
                    return;
                  }
                  medias.forEach(
                    (element) {
                      print('\nmediaItem: '
                          '\nid = ${element.id}'
                          '\ncaption = ${element.caption}'
                          '\npermalink = ${element.permalink}'
                          '\nmediaType = ${element.mediaType}'
                          '\ntimestamp = ${element.timestamp}'
                          '\nthumbnailUrl = ${element.thumbnailUrl}'
                          '\nmediaUrl = ${element.mediaUrl}');
                    },
                  );
                  setState(() {
                    _mediaList = medias;
                  });
                });
              },
            ),
            _mediaList == null || _mediaList!.isEmpty
                ? Container()
                : ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(5.5),
                    itemCount: _mediaList!.length,
                    itemBuilder: _itemBuilder,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return InkWell(
      child: Card(
        child: Column(
          children: [
            Text(
              "${_mediaList![index].id}",
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text("${_mediaList![index].caption}"),
            Text("${_mediaList![index].mediaType}"),
            Text("${_mediaList![index].timestamp}"),
            _mediaList![index].mediaType == "CAROUSEL_ALBUM"
                ? ElevatedButton(
                    child: Text("Log album detail"),
                    onPressed: () {
                      InstagramBasicDisplayApi.getAlbumDetail(
                              _mediaList![index].id)
                          .then((albumDetail) {
                        print("\n\nalbumDetail = $albumDetail\n\n");
                        if (albumDetail == null) {
                          return;
                        }
                        albumDetail.forEach(
                          (element) {
                            print('\n\nalbumDetailItem: '
                                '\nid = ${element.id}'
                                '\nmediaType = ${element.mediaType}'
                                '\ntimestamp = ${element.timestamp}'
                                '\nthumbnailUrl = ${element.thumbnailUrl}'
                                '\nmediaUrl = ${element.mediaUrl}');
                          },
                        );
                      });
                    })
                : Container()
          ],
        ),
      ),
    );
  }
}
