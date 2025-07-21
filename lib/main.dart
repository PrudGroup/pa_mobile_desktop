import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/register/register.dart';
import 'package:prudapp/router.dart';
import 'package:prudapp/singletons/beneficiary_notifier.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/influencer_notifier.dart';
import 'package:prudapp/singletons/prudio_client.dart';
import 'package:prudapp/singletons/prudvid_notifier.dart';
import 'package:prudapp/singletons/settings_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:get_storage/get_storage.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';

import 'constants.dart';
import 'models/images.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  iCloud.addPushMessages(message);
}

void main() async {
  if (UniversalPlatform.isMacOS) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);
  VideoPlayerMediaKit.ensureInitialized(
    android: true,          // default: false    -    dependency: media_kit_libs_android_video
    iOS: true,              // default: false    -    dependency: media_kit_libs_ios_video
    macOS: true,            // default: false    -    dependency: media_kit_libs_macos_video
    windows: true,          // default: false    -    dependency: media_kit_libs_windows_video
    linux: true,            // default: false    -    dependency: media_kit_libs_linux
  );

  // TODO: take all this to isolate for speed
  if (Firebase.apps.isEmpty) {
    await iCloud.setFirebase(
      Constants.fireApiKey,
      Platform.isAndroid? Constants.fireAndroidAppID :
      (Platform.isIOS? Constants.fireIOSAppID : Constants.fireAppID),
      Constants.fireMessageID
    );
  }
  
  iCloud.setDioHeaders();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await GetStorage.init();
  await myStorage.initializeValues();
  await currencyMath.init();
  await influencerNotifier.initInfluencer();
  await prudioNotifier.connect();
  await beneficiaryNotifier.initBens();
  await localSettings.init();
  await messenger.setAutoInitEnabled(true);
  await prudVidNotifier.init();
  myStorage.setWindowSize(size: const Size(400, 700));

  _setTargetPlatformForDesktop();


  runApp(const ProviderScope(child: MyApp()));
}

/// If the current platform is desktop, override the default platform to
/// a supported platform (iOS for macOS, Android for Linux and Windows).
/// Otherwise, do nothing.
void _setTargetPlatformForDesktop() {
  TargetPlatform targetPlatform  = TargetPlatform.android;
  if (UniversalPlatform.isMacOS) {
    targetPlatform = TargetPlatform.iOS;
  } else if (UniversalPlatform.isLinux || UniversalPlatform.isWindows) {
    targetPlatform = TargetPlatform.android;
  }
  debugDefaultTargetPlatformOverride = targetPlatform;
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {

  const MyApp({super.key});

  Future<bool> _getCredentials({required BuildContext context}) async {
    FlutterNativeSplash.remove();
    final lStore = myStorage.lStore;
    bool isNew = true;
    var res = await lStore.read('isNew');
    isNew = res?? true;
    if(isNew == false){
      await currencyMath.loginAutomatically();
      if(iCloud.affAuthToken == null){
        // ignore: use_build_context_synchronously
        iCloud.showSnackBar("PrudApp Service Unreachable", context);
      }
    }
    return isNew;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _getCredentials(context: context),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            {
              return MaterialApp(
                title: 'Prudapp',
                theme: prudTheme,
                home: Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      image: DecorationImage(
                        image: AssetImage(prudImages.screen),
                        fit: BoxFit.cover,
                      )),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 500.0),
                      child: LoadingComponent(
                        size: 10.0,
                        isShimmer: false,
                        defaultSpinnerType: false,
                        spinnerColor: prudColorTheme.bgA,
                      ),
                    ),
                  ),
                ),
                debugShowCheckedModeBanner: false,
              );
            }
          default:
            {
              bool isNew = snapshot.data?? false;
              return isNew? MaterialApp(
                title: 'Prudapp',
                theme: prudTheme,
                home: const Register(),
                debugShowCheckedModeBanner: false,
              ) : MaterialApp.router(
                debugShowCheckedModeBanner: false,
                theme: prudTheme,
                routerConfig: prudRouter,
              );
            }
        }
      },
    );
  }
}
