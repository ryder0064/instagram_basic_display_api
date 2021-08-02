# instagram_basic_display_api
A Flutter plugin for integrating [Instagram Basic Display API](https://developers.facebook.com/docs/instagram-basic-display-api/) in iOS and Android applications.

## Platform integration
To access Instagram Basic Display API, you'll need to follow the steps in [getting started](https://developers.facebook.com/docs/instagram-basic-display-api/getting-started).
After create your application step by step, you will get INSTAGRAM_CLIENT_ID、INSTAGRAM_CLIENT_SECRET and REDIRECT_URI. You need set them in your project to use flutter plugin for Instagram Basic Display API.
Often your app will have secret credentials or API keys that you need to have in your app to function but you'd rather not have easily extracted from your app. So we need some way to store these information in our project.

### Android integration
1. For storing secret API keys, we keep them as resource files. First, create a file `secret.properties` in your root directory with the values for different secret keys.
2. Next, add this section to read from this file in your app/build.gradle file. You'll also create compile-time options that will be generated from this file by using the buildConfigField definition.
3. You can now access these fields anywhere within your source code with the BuildConfig object provided by Gradle.

### iOS integration
For manage secrets in iOS App, we use Xcode Configuration Files.
1. Create a configuration settings file with the values for different secret keys.
2. Tap on the project, choose the “Info” tab, and expand the Debug and Release configurations. Then attach the `Secrets.xcconfig` file to each configuration.
3. Update Info.plist with a new Secrets field.
4. You can now access these fields with `Bundle.main.object`.