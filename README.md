# instagram_basic_display_api
A Flutter plugin for integrating [Instagram Basic Display API](https://developers.facebook.com/docs/instagram-basic-display-api/) in iOS and Android applications.

## Getting Started

To access Instagram Basic Display API, you'll need to follow the steps in [getting started](https://developers.facebook.com/docs/instagram-basic-display-api/getting-started).
After create your application step by step, you will get INSTAGRAM_CLIENT_ID、INSTAGRAM_CLIENT_SECRET and REDIRECT_URI. You need set them in your project to use flutter plugin for Instagram Basic Display API.
Often your app will have secret credentials or API keys that you need to have in your app to function but you'd rather not have easily extracted from your app. So we need some way to store these information in our project.

### Android

1. For storing secret API keys, we keep them as resource files. First, create a file secret.properties in your root directory with the values for different secret keys.
2. Next, add this section to read from this file in your app/build.gradle file. You'll also create compile-time options that will be generated from this file by using the buildConfigField definition.
3. You can now access these fields anywhere within your source code with the BuildConfig object provided by Gradle.

### iOS

For manage secrets in iOS App, we use Xcode Configuration Files.
1. Create a configuration settings file with the values for different secret keys.
2. Tap on the project, choose the “Info” tab, and expand the Debug and Release configurations. Then attach the Secrets.xcconfig file to each configuration.
3. Update Info.plist with a new Secrets field.
4. You can now access these fields with Bundle.main.object.



## Usage

There is a simple app that prints to console to give an example of functionality of this plugin.


### askInstagramToken

You need to sign your instagram to get access token for using instagram base display api. *Make sure your instagram account has added to your instagram base display project as tested user, like here [getting started](https://developers.facebook.com/docs/instagram-basic-display-api/getting-started)*

Example usage:
```
InstagramBasicDisplayApi.askInstagramToken();
```


### getInstagramUser

This will give you a Future which will response the current information of the user.

Example usage:
```
InstagramBasicDisplayApi.getInstagramUser().then((user) {
  print("user = $user");
  print(
      "user id = ${user?.id}, name = ${user?.name}, accountType = ${user?.accountType}");
});
```


### logout

This will logout your instagram account and give you a Future which will response the current information of the user.

Example usage:
```
InstagramBasicDisplayApi.logout().then((user) {
  print("user = $user");
  print(
      "user id = ${user?.id}, name = ${user?.name}, accountType = ${user?.accountType}");
});
```


### getMedias

This will give you a Future which will response the current medias of the user. It will show your account's content, include IMAGE、VIDEO or CAROUSEL ALBUM.

Example usage:
```
InstagramBasicDisplayApi.getMedias().then((medias) {
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
});
```


### getMediaItem

This will give you a Future which will response the media item that you select. It will show your media's content.

Example usage:
```
InstagramBasicDisplayApi.getMediaItem(
    _mediaList![index].id)
    .then((mediaItem) {
  print("\n\nmediaItem = $mediaItem\n\n");
  if (mediaItem == null) {
    return;
  }
  print('\nmediaItem: '
      '\nid = ${mediaItem.id}'
      '\ncaption = ${mediaItem.caption}'
      '\npermalink = ${mediaItem.permalink}'
      '\nmediaType = ${mediaItem.mediaType}'
      '\ntimestamp = ${mediaItem.timestamp}'
      '\nthumbnailUrl = ${mediaItem.thumbnailUrl}'
      '\nmediaUrl = ${mediaItem.mediaUrl}');
});
```


### getAlbumDetail

This will give you a Future which will response the album's detail that you select. It will show your album's content, include IMAGE、VIDEO.

Example usage:
```
InstagramBasicDisplayApi.getAlbumDetail(SELECTED_ALBUM_ID).then((albumDetail) {
  if (albumDetail == null) {
    return;
  }
  albumDetail.forEach(
    (element) {
      print('\nalbumDetailItem: '
          '\nid = ${element.id}'
          '\nmediaType = ${element.mediaType}'
          '\ntimestamp = ${element.timestamp}'
          '\nthumbnailUrl = ${element.thumbnailUrl}'
          '\nmediaUrl = ${element.mediaUrl}');
    },
  );
});
```


### broadcastInstagramUserStream
This is a stream you can listen to, only triggered by the listening for InstagramUser changes.

Example usage:
```
InstagramBasicDisplayApi.broadcastInstagramUserStream?.listen((instagramUser) {
  print('instagramUser = ${instagramUser.id}, ${instagramUser.accountType}, ${instagramUser.name}');
});
```