import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/register/register.dart';
import 'package:prudapp/router.dart';
import 'package:prudapp/singletons/beneficiary_notifier.dart';
import 'package:prudapp/singletons/currency_math.dart';
import 'package:prudapp/singletons/gift_card_notifier.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:get_storage/get_storage.dart';

import 'constants.dart';
import 'models/images.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await iCloud.setFirebase(
      Constants.fireApiKey,
      Platform.isAndroid? Constants.fireAndroidAppID :
      (Platform.isIOS? Constants.fireIOSAppID : Constants.fireAppID),
      Constants.fireMessageID
  );
  iCloud.addPushMessages(message);
}

void main() async {
  if (UniversalPlatform.isMacOS) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  WidgetsFlutterBinding.ensureInitialized();
  await iCloud.setFirebase(
      Constants.fireApiKey,
      Platform.isAndroid? Constants.fireAndroidAppID :
      (Platform.isIOS? Constants.fireIOSAppID : Constants.fireAppID),
      Constants.fireMessageID
  );
  iCloud.setDioHeaders();
  await GetStorage.init();
  await myStorage.initializeValues();
  await currencyMath.init();
  await giftCardNotifier.initGiftCard();
  await beneficiaryNotifier.initBens();
  // await messenger.setAutoInitEnabled(true);
  myStorage.setWindowSize(size: const Size(400, 700));

  _setTargetPlatformForDesktop();


  runApp(const MyApp());
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

  Future<bool> _getCredentials({required context}) async {
    await precacheImage( AssetImage(prudImages.prudIcon), context);
    await precacheImage( AssetImage(prudImages.intro), context);
    await precacheImage( AssetImage(prudImages.intro4), context);
    await precacheImage( AssetImage(prudImages.intro5), context);
    await precacheImage( AssetImage(prudImages.intro1), context);
    await precacheImage( AssetImage(prudImages.intro2), context);
    await precacheImage( AssetImage(prudImages.intro3), context);
    await precacheImage( AssetImage(prudImages.bg), context);
    await precacheImage( AssetImage(prudImages.screen), context);
    await precacheImage( AssetImage(prudImages.user), context);
    await precacheImage( AssetImage(prudImages.err), context);

    final lStore = myStorage.lStore;
    bool isNew = true;
    var res = await lStore.read('isNew');
    isNew = res?? true;
    if(isNew == false){
      await currencyMath.loginAutomatically();
      if(iCloud.affAuthToken == null){
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
                      padding: const EdgeInsets.only(top: 400.0),
                      child: SpinKitFadingCircle(
                        size: 40.0,
                        color: prudColorTheme.bgA,
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
