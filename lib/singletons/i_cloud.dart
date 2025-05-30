import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_to_pdf/flutter_to_pdf.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/home/home.dart';
import 'package:prudapp/pages/prud_predict/prud_predict.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/shared_local_storage.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:prudapp/singletons/tab_data.dart';
import '../components/page_transitions/scale.dart';
import '../components/prud_container.dart';
import '../constants.dart';
import '../models/images.dart';
import '../models/shared_classes.dart';
import '../models/user.dart';
import '../pages/ads/ads.dart';
import '../pages/influencers/influencers.dart';
import '../pages/prudStreams/studio/prud_stream_studio.dart';
import '../pages/prudVid/prud_cuisine.dart';
import '../pages/prudVid/prud_learn.dart';
import '../pages/prudVid/prud_movies.dart';
import '../pages/prudVid/prud_music.dart';
import '../pages/prudVid/prud_news.dart';
import '../pages/prudVid/prud_vid.dart';
import '../pages/prudVid/prud_vid_studio.dart';
import '../pages/prudVid/thrillers.dart';

enum RegisterState {
  first,
  second,
  third,
  success,
  failed,
}

enum AuthTask {
  login,
  linkTo,
  doAll,
}

enum BoardLoginState { existingOperator, newOperator, newFirm }

class ICloud extends ChangeNotifier {
  static final ICloud _iCloud = ICloud._internal();
  static get iCloud => _iCloud;
  RegisterState registerState = RegisterState.first;
  String? affAuthToken;
  String mapKey = " ";
  bool serviceEnabled = false;
  bool isRealTimeConnected = false;
  bool clearDigitInput = false;
  bool showInnerTabsAndMenus = true;
  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'prudNotice', // id
    'PrudVid', // name
    description: 'PrudApp',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('slow_spring_board'),
    enableVibration: true,
  );

  //init local notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  factory ICloud() {
    return _iCloud;
  }

  void displayNotification(RemoteNotification notification) {
    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            color: const Color.fromARGB(255, 253, 2, 14),
            importance: Importance.max,
            playSound: true,
            sound:
                const RawResourceAndroidNotificationSound('slow_spring_board'),
            icon: '@drawable/ic_stat_notice',
          ),
        ));
  }

  Future<bool> checkNetwork() async => await InternetConnection().hasInternetAccess;
    

  Future<pdf.Document> exportToPdf(String id) async {
    return await exportDelegate.exportToPdfDocument(id);
  }

  void initRegisterState() async {
    int dState = (await myStorage.getFromStore(key: 'registerState')) ?? -1;
    registerState = dState == -1
        ? RegisterState.first
        : (dState == 3
            ? RegisterState.second
            : intToRegisterState(state: dState));
    notifyListeners();
  }

  void toggleFooterMenu() {
    showInnerTabsAndMenus = !showInnerTabsAndMenus;
    notifyListeners();
  }

  void changeRegisterState({required RegisterState state}) async {
    registerState = state;
    await myStorage.addToStore(
        key: 'registerState', value: translateRegisterState(state: state));
    notifyListeners();
  }

  void getRegisterStateFromStore() {
    dynamic rst = myStorage.getFromStore(key: 'registerState') ?? 0;
    registerState = intToRegisterState(state: rst);
    notifyListeners();
  }

  int translateRegisterState({required RegisterState state}) {
    switch (state) {
      case RegisterState.first:
        return 0;
      case RegisterState.second:
        return 1;
      case RegisterState.third:
        return 2;
      case RegisterState.success:
        return 3;
      default:
        return 4;
    }
  }

  void scrollTop(ScrollController ctrl) {
    ctrl.animateTo(0,
        duration: const Duration(milliseconds: 500), //duration of scroll
        curve: Curves.fastOutSlowIn //scroll type
        );
  }

  RegisterState intToRegisterState({required int state}) {
    switch (state) {
      case 0:
        return RegisterState.first;
      case 1:
        return RegisterState.second;
      case 2:
        return RegisterState.third;
      case 3:
        return RegisterState.success;
      default:
        return RegisterState.failed;
    }
  }

  Future<List<dynamic>> getSparkCost(String url) async {
    try {
      Response res = await prudDio.get(url);
      if (res.statusCode == 200) {
        return [res.data, true];
      } else {
        return [null, false];
      }
    } catch (ex) {
      debugPrint("Dio Error: $ex");
      return [null, false];
    }
  }

  Future<String?> sendCodeToEmail(String codeUrl, String email) async {
    Response res =
        await prudDio.get(codeUrl, queryParameters: {"email": email});
    if (res.statusCode == 200) {
      return res.data;
    } else {
      return null;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    String codeUrl = "$prudApiUrl/affiliates/password/reset";
    Response res = await prudDio.get(codeUrl,
        queryParameters: {"email": email, "password": newPassword});
    if (res.statusCode == 200) {
      return res.data;
    } else {
      return false;
    }
  }

  Future<String?> saveFileToCloud(XFile file, String destination) async {
    String codeUrl = "$prudApiUrl/files/single/";
    var formData = FormData.fromMap({
      'upload': await MultipartFile.fromFile(file.path, filename: file.name),
      "destination": "prudapp/$destination",
    });
    Response res = await prudDio.post(codeUrl, data: formData);
    if (res.statusCode == 201) {
      if (res.data != null && res.data["simple"] != null && res.data["uploaded"]) {
        return res.data["simple"];
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<String?> getFileDownloadUrl(String fileName) async {
    String codeUrl = "$prudApiUrl/files/download_url";
    Response res = await prudDio.get(codeUrl, queryParameters: {"file_name": fileName});
    if (res.statusCode == 200) {
      if (res.data != null && res.data != false) {
        return res.data;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  String authorizeDownloadUrl(String url) {
    return b2DownloadToken != null
        ? "$url?Authorization=$b2DownloadToken"
        : url;
  }

  Future<bool> deleteFileFromCloud(String url) async {
    String codeUrl = "$prudApiUrl/files/single/delete";
    Response res = await prudDio.get(codeUrl, queryParameters: {"file": url});
    if (res.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<List> logAffiliateIn(String url) async {
    String? storedUser = myStorage.getFromStore(key: "user");
    if (storedUser != null) {
      User user = User.fromJson(jsonDecode(storedUser));
      if (user.email != null && user.password != null) {
        try {
          Response res = await prudDio.get(url, queryParameters: {
            "email": user.email,
            "password": user.password,
          });
          if (res.statusCode == 200) {
            return [res.data, true];
          } else {
            return [null, false];
          }
        } catch (ex) {
          return [null, false];
        }
      } else {
        return [null, false];
      }
    } else {
      return [null, false];
    }
  }

  Future<bool> checkIfAffLoggedIn(String url) async {
    bool loggedIn = false;
    if (lastAuthTokenGottenAt != null) {
      int minutes =
          myStorage.dateDifference(dDate: lastAuthTokenGottenAt!, inWhat: 1);
      if (minutes > 20) {
        affAuthToken = null;
      }
    }
    if (affAuthToken != null) {
      loggedIn = true;
    } else {
      List logged = await logAffiliateIn(url);
      loggedIn = logged[1];
      if (loggedIn) {
        affAuthToken = 'Bearer PrudApp ${logged[0]["authToken"]}';
        lastAuthTokenGottenAt = DateTime.now();
        await setB2Tokens();
        await prudStudioNotifier.initPrudStudio();
      }
    }
    prudDio.options.headers.clear();
    prudDio.options.headers.addAll({
      "Authorization": affAuthToken,
      "AppCredential": prudApiKey,
    });
    return loggedIn;
  }

  List<Widget> getShowroom(BuildContext context, {int? showroomItems}) {
    List<Widget> showroom = [
      InkWell(
        onTap: () => iCloud.goto(context, const PrudVidStudio()),
        child: PrudContainer(hasPadding: false, child: Image.asset(prudImages.front1)),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const Ads()),
        child: PrudContainer(
          hasPadding: false,
          child: Image.asset(prudImages.front6),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const PrudCuisine()),
        child: PrudContainer(
          hasPadding: false,
          hasTitle: true,
          title: "Cuisines",
          child: Image.asset(prudImages.front13),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const PrudLearn()),
        child: PrudContainer(
          hasPadding: false,
          child: Image.asset(prudImages.front12),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const PrudNews()),
        child: PrudContainer(
          hasPadding: false,
          child: Image.asset(prudImages.front10),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const PrudStreamStudio()),
        child: PrudContainer(
          hasPadding: false,
          hasTitle: true,
          title: "PrudStream Studio",
          child: Image.asset(prudImages.front2),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const PrudMusic()),
        child: PrudContainer(
          hasPadding: false,
          child: Image.asset(prudImages.front11),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const PrudPredict()),
        child: PrudContainer(
          hasPadding: false,
          hasTitle: true,
          titleAlignment: MainAxisAlignment.end,
          title: "PrudPredict",
          child: Image.asset(prudImages.front14),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const PrudMovies()),
        child: PrudContainer(
          hasPadding: false,
          hasTitle: true,
          title: "Latest Movies & Series",
          child: Image.asset(prudImages.front9),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const PrudNews()),
        child: PrudContainer(
          hasPadding: false,
          child: Image.asset(prudImages.front8),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const Thrillers()),
        child: PrudContainer(
          hasPadding: false,
          hasTitle: true,
          title: "Movie Thrillers",
          child: Image.asset(prudImages.front3),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const PrudVidStudio()),
        child: PrudContainer(
          hasPadding: false,
          child: Image.asset(prudImages.front4),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const Influencers()),
        child: PrudContainer(
          hasPadding: false,
          hasTitle: true,
          title: "Affiliate Marketing",
          child: Image.asset(prudImages.front5),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const PrudVid()),
        child: PrudContainer(
          hasPadding: false,
          child: Image.asset(prudImages.front7),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const PrudPredict()),
        child: PrudContainer(
          hasPadding: false,
          hasTitle: true,
          title: "Predit & Win",
          child: Image.asset(prudImages.front16),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const PrudPredict()),
        child: PrudContainer(
          hasPadding: false,
          hasTitle: true,
          title: "PrudPredict",
          child: Image.asset(prudImages.front17),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const PrudPredict()),
        child: PrudContainer(
          hasPadding: false,
          hasTitle: true,
          title: "Fun Life",
          child: Image.asset(prudImages.front18),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const PrudPredict()),
        child: PrudContainer(
          hasPadding: false,
          hasTitle: true,
          title: "Win Big",
          child: Image.asset(prudImages.front19),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const PrudPredict()),
        child: PrudContainer(
          hasPadding: false,
          hasTitle: true,
          title: "Shopping Spray",
          child: Image.asset(prudImages.front20),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const PrudPredict()),
        child: PrudContainer(
          hasPadding: false,
          hasTitle: true,
          title: "Power To Purchase",
          child: Image.asset(prudImages.front21),
        ),
      ),
    ];
    List<Widget> results = [];
    showroom.shuffle();
    if (showroomItems != null) {
      for (int i = 0; i < showroomItems; i++) {
        results.add(showroom[i]);
      }
    }
    return showroomItems != null ? results : showroom;
  }

  Future<Response> addAffiliate(String url, User newUser) async =>
      await prudDio.post(url, data: newUser.toJson());

  Future<Response> verifyAffiliateEmail(String url) async =>
      await prudDio.get(url);

  Future<Response> deleteAffiliate(String deleteUrl, String email) async {
    String url = "$deleteUrl/$email";
    return await prudDio.get(url);
  }

  Future<bool> getMessengerPermissions() async {
    bool supported = false;
    try {
      supported = await messenger.isSupported();
      if (supported == false) {
        NotificationSettings settings = await messenger.requestPermission(
          announcement: true,
          criticalAlert: true,
          provisional: true,
        );
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          supported = true;
        } else {
          supported = false;
        }
      }
    } catch (ex) {
      debugPrint("Messenger Error: $ex");
    }
    return supported;
  }

  void addPushMessages(RemoteMessage message) {
    RemoteNotification? notice;
    Map<String, dynamic> msg = message.data;
    if (message.notification != null) {
      notice = message.notification;
      displayNotification(notice!);
    }
    pushMessages.add(PushMessage(msg, notice));
  }

  Future<FirebaseApp> setFirebase(
      String apiKey, String appId, String msgID) async {
    FirebaseApp? fireApp;
    if (Platform.isAndroid || Platform.isIOS) {
      fireApp = await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: msgID,
          projectId: 'prudapp',
        ),
      );
    } else {
      fireApp = await Firebase.initializeApp();
    }
    await FirebaseMessaging.instance.getToken();
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint("_messaging onMessageOpenedApp: $message");
      iCloud.addPushMessages(message);
    });
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      debugPrint("_messaging getInitialMessage: $value");
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("_messaging onMessage: $message");
      iCloud.addPushMessages(message);
    });
    return fireApp;
  }

  void setDioHeaders() {
    prudDio.options.headers.addAll({
      "AppCredential": prudApiKey,
    });
  }

  /// Shows snackbar for messaging
  /// @param msg the message to be displayed
  /// @param context the builder context
  /// @param title the title of the message
  /// @param type 0 - indicates help message, 1 - warning, 2 - Success, 3 - Failure
  void showSnackBar(String msg, BuildContext context,
      {String title = 'Oops!', int type = 0}) {
    ContentType contentType = getType(type);
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: msg,
        messageTextStyle: prudWidgetStyle.tabTextStyle,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  ContentType getType(int value) {
    switch (value) {
      case 0:
        return ContentType.help;
      case 1:
        return ContentType.warning;
      case 2:
        return ContentType.success;
      default:
        return ContentType.failure;
    }
  }

  Future<bool> addReferralMetric(String referralId, double increaseBy) async {
    bool hasAdded = false;
    try {
      if (affAuthToken != null && myStorage.installReferralCode != null) {
        String metricUrl = "$apiEndPoint/link_metric/";
        Map<String, dynamic> metricDetails = {
          "metric_id": referralId,
          "increase_amount_by": increaseBy,
        };
        Response res = await prudDio.post(metricUrl, data: metricDetails);
        debugPrint("Gift Link Metric Result: $res : updated_data: ${res.data}");
        if (res.data != null) {
          hasAdded = true;
        }
      }
    } catch (ex) {
      debugPrint("addMetricForAppInstallReferral: $ex");
    }
    return hasAdded;
  }

  Future<bool> addMetricForAppInstallReferral(
      double increaseBy, String fieldName) async {
    bool hasAdded = false;
    try {
      if (affAuthToken != null && myStorage.installReferralCode != null) {
        String metricUrl = "$apiEndPoint/airm_metric/";
        Map<String, dynamic> metricDetails = {
          "referral_id": myStorage.installReferralCode,
          "field_name": fieldName,
          "increase_by": increaseBy
        };
        Response res = await prudDio.post(metricUrl, data: metricDetails);
        debugPrint("Install Metric Result: $res : updated_data: ${res.data}");
        if (res.data != null) {
          hasAdded = true;
        }
      }
    } catch (ex) {
      debugPrint("addMetricForAppInstallReferral: $ex");
    }
    return hasAdded;
  }

  Future<bool> setB2Tokens() async {
    bool hasAdded = false;
    try {
      if (affAuthToken != null) {
        String apiUrl = "$apiEndPoint/files/download_token";
        Response res = await prudDio.get(apiUrl);
        if (res.data != null && res.data!["download_token"] != null) {
          b2DownloadToken = res.data!["download_token"];
          b2AccToken = res.data!["account_token"];
          b2AuthKey = res.data!["auth_key"];
          b2ApiUrl = res.data!["api_url"];
          hasAdded = true;
        }
      }
    } catch (ex) {
      debugPrint("setB2Tokens: $ex");
    }
    return hasAdded;
  }

  void go(BuildContext context, String route, Map<String, dynamic>? qParam) {
    GoRouter.of(context)
        .go(Uri(path: route, queryParameters: qParam).toString());
  }

  void goByName(BuildContext context, String routeName,
      Map<String, String> pParam, Map<String, dynamic>? qParam) {
    if (qParam != null) {
      context.goNamed(routeName,
          pathParameters: pParam, queryParameters: qParam);
    } else {
      context.goNamed(routeName, pathParameters: pParam);
    }
  }

  void goto(BuildContext context, Widget where) =>
      Navigator.push(context, ScaleRoute(page: where));

  void goBack(BuildContext context){
    tryOnly("goBack", (){
      if(Navigator.of(context).canPop()){
        Navigator.pop(context);
      } else {
        goto(context, MyHomePage(title: "Prudapp",));
      }
    });
  }

  Future<bool> prudServiceIsAvailable() async {
    bool isConnected = await checkNetwork();
    bool loggedIn = affAuthToken != null;
    return isConnected && loggedIn;
  }

  ICloud._internal();
}

String? b2DownloadToken;
String? b2AccToken;
String? b2AuthKey;
String? b2ApiUrl;
const String prudWeb = "https://www.prudapp.com/";
const String shareImageUrl = "https://shorturl.at/uMOHL";
const bool isProduction = Constants.envType == "production";
const String prudApiUrl = Constants.prudApiUrl;
const String localApiUrl = Constants.localApiUrl;
const String prudApiKey = Constants.prudApiKey;
const String apiEndPoint = isProduction ? prudApiUrl : localApiUrl;
const String waveApiUrl = "https://api.flutterwave.com/v3";
const String paystackSecret = Constants.apiStatues == 'production'? Constants.paystackSecretLive : Constants.paystackSecretTest;
const String paystackPublic = Constants.apiStatues == 'production'? Constants.paystackPublicLive : Constants.paystackPublicTest;
const String paystackCallUrl = "$prudApiUrl/payments/paystack_call";
const String paystackHook = "$prudApiUrl/payments/paystack_hook";
const double waveVat = 0.07;
const bool paymentIsInTestMode = isProduction ? false : true;
List<PushMessage> pushMessages = [];
const reloadlySmsFee = 300.0;
const installReferralCommission = 0.25;
const referralCommission = 0.25;
const merchantReferralCommission = 0.25;
DateTime? lastAuthTokenGottenAt;
final ExportDelegate exportDelegate = ExportDelegate(
  options: const ExportOptions(pageFormatOptions: PageFormatOptions(pageFormat: PageFormat.a4, marginAll: 10.0)),
  ttfFonts: {
    'Autobus': 'assets/fonts/Autobus.ttf',
    'Lato-Italic': 'assets/fonts/Lato-Italic.ttf',
    'Cherione': 'assets/fonts/cherione.ttf',
    'Champagne': 'assets/fonts/Champagne.ttf',
    'Champagne-Bold': 'assets/fonts/Champagne-Bold.ttf',
    'NexaDemo-Bold': 'assets/fonts/NexaDemo-Bold.ttf',
    'NexaDemo-Light': 'assets/fonts/NexaDemo-Light.ttf',
    'OpenSans-Bold': 'assets/fonts/OpenSans-Bold.ttf',
    'Revans': 'assets/fonts/revans.ttf',
    'OpenSans-Regular': 'assets/fonts/OpenSans-Regular.ttf',
    'OpenSans-SemiBold': 'assets/fonts/OpenSans-SemiBold.ttf',
    'Oswald-Regular': 'assets/fonts/Oswald-Regular.ttf',
    'Valeria': 'assets/fonts/valeria.ttf',
    'Qhinanttika': 'assets/fonts/Qhinanttika.otf',
    'Proxima-Light': 'assets/fonts/Proxima-Light.otf',
    "Tamil Sangam MN": "assets/fonts/tamil-sangam-mn.otf"
  },
);
FirebaseMessaging messenger = FirebaseMessaging.instance;
String? prudIOConnectID;
Dio prudDio = Dio(BaseOptions(
    receiveDataWhenStatusError: true,
    connectTimeout: const Duration(seconds: 60), // 60 seconds
    receiveTimeout: const Duration(seconds: 60),
    validateStatus: (statusCode) {
      if (statusCode != null) {
        if (statusCode == 422) {
          return true;
        }
        if (statusCode >= 200 && statusCode <= 300) {
          return true;
        }
        return false;
      } else {
        return false;
      }
    }
  )
)..interceptors.add(PrettyDioLogger());
final iCloud = ICloud();
