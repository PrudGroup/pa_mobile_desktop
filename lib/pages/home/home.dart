import 'dart:async';

import 'package:connection_notifier/connection_notifier.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:getwidget/getwidget.dart';
import 'package:prudapp/components/main_menu.dart';
import 'package:prudapp/components/network_issue_component.dart';
import 'package:prudapp/components/prud_showroom.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/pages/influencers/influencers.dart';
import 'package:prudapp/pages/prudStreams/prud_streams.dart';
import 'package:prudapp/pages/prudStreams/studio/prud_stream_studio.dart';
import 'package:prudapp/pages/prudVid/prud_comedy.dart';
import 'package:prudapp/pages/prudVid/prud_learn.dart';
import 'package:prudapp/pages/prudVid/prud_movies.dart';
import 'package:prudapp/pages/prudVid/prud_music.dart';
import 'package:prudapp/pages/prudVid/prud_news.dart';
import 'package:prudapp/pages/prudVid/prud_vid.dart';
import 'package:prudapp/pages/prudVid/prud_vid_studio.dart';
import 'package:prudapp/pages/prudVid/thrillers.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';

import '../../components/prud_container.dart';
import '../../models/images.dart';
import '../../singletons/currency_math.dart';
import '../../singletons/shared_local_storage.dart';
import '../prudVid/prud_cuisine.dart';
import '../settings/settings.dart';
import '../travels/switz_travels.dart';
import 'home_drawer.dart';


// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  String title;

  MyHomePage({super.key, required this.title});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  final _advDrawerController = AdvancedDrawerController();
  bool hasCartContent = false;
  final MethodChannel platform =
  const MethodChannel('reactivestreams.io/resourceResolver');
  final RateMyApp _rateMyApp = RateMyApp(
    preferencesPrefix: 'eLib_',
    minDays: 7,
    minLaunches: 10,
    remindDays: 7,
    remindLaunches: 10,
  );
  StreamSubscription? connectSub;
  StreamSubscription<FGBGType>? subscription;
  StreamSubscription? messageStream;
  double imageHeight = 0;
  List<Widget> carousels = [
    Image.asset(prudImages.front1),
    Image.asset(prudImages.front2),
    Image.asset(prudImages.front3),
    Image.asset(prudImages.front4),
    Image.asset(prudImages.front5),
  ];
  List<Menu> menus = [
    Menu(
        title: 'PrudVid',
        page: const PrudVid(),
        icon: prudImages.prudVid
    ),
    Menu(
        title: 'PrudMovies',
        page: const PrudMovies(),
        icon: prudImages.movie
    ),
    Menu(
        title: 'PrudMusic',
        page: const PrudMusic(),
        icon: prudImages.music
    ),
    Menu(
        title: 'PrudComedy',
        page: const PrudComedy(),
        icon: prudImages.comedy
    ),
    Menu(
        title: 'PrudNews',
        page: const PrudNews(),
        icon: prudImages.news
    ),
    Menu(
        title: 'PrudLearn',
        page: const PrudLearn(),
        icon: prudImages.learn
    ),
    Menu(
        title: 'PrudCuisines',
        page: const PrudCuisine(),
        icon: prudImages.cuisine
    ),
    Menu(
        title: 'PrudStreams',
        page: const PrudStreams(),
        icon: prudImages.streamDark
    ),
    Menu(
        title: 'Thrillers',
        page: const Thrillers(),
        icon: prudImages.thrillerDark
    ),
    Menu(
        title: 'PrudVid Studio',
        page: const PrudVidStudio(),
        icon: prudImages.prudVidStudio
    ),
    Menu(
        title: 'PrudStreams Studio',
        page: const PrudStreamStudio(),
        icon: prudImages.streamStudioDark
    ),
    Menu(
      title: 'SwitzTravels',
      page: const SwitzTravels(),
      icon: prudImages.travel1
    ),
    Menu(
      title: 'Influencers',
      page: const Influencers(),
      icon: prudImages.influencerFemale
    ),
    /*Menu(
      title: 'Ads & Promotions',
      page: const Ads(),
      icon: prudImages.videoAd
    ),*/
    /*Menu(
      title: 'My Account',
      page: const MyAccount(),
      icon: prudImages.account
    ),*/
    Menu(
      title: 'Settings',
      page: const Settings(),
      icon: prudImages.settings
    ),
  ];
  bool prudServiceIsAvailable = true;

  Future<void> changeConnectionStatus() async{
    bool ok = await iCloud.prudServiceIsAvailable();
    if(mounted) setState(() => prudServiceIsAvailable = ok);
  }

  Future<void> _refresh() async {
    await currencyMath.loginAutomatically();
    await changeConnectionStatus();
  }


  @override
  void initState(){
    Future.delayed(Duration.zero, () async {
      await changeConnectionStatus();
    });
    carousels.shuffle();
    super.initState();
    _rateMyApp.init();
    connectSub = ConnectionNotifierTools.onStatusChange.listen((_) async {
      await changeConnectionStatus();
    });
    FGBGEvents fgbg = FGBGEvents.instance;
    subscription = fgbg.stream.listen((event) {
      if(event == FGBGType.background) {

      } else {
        listenForMessages();
      }
    });
  }

  void listenForMessages() async {
    bool hasPermissions = await iCloud.getMessengerPermissions();
    if(hasPermissions){
      messageStream = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        iCloud.addPushMessages(message);
      });
    }
  }

  @override
  void dispose(){
    subscription?.cancel();
    messageStream?.cancel();
    connectSub?.cancel();
    super.dispose();
  }

  void _handleDrawer() => _advDrawerController.toggleDrawer();

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double height = screenSize.height;
    double width = screenSize.width;
    return AdvancedDrawer(
      backdrop: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [prudColorTheme.bgA, prudColorTheme.bgA.withValues(alpha: 0.2)],
          ),
        ),
      ),
      controller: _advDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      drawer: const HomeDrawer(),
      child: Scaffold(
        key: _drawerKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: prudColorTheme.bgC,
        appBar: AppBar(
          elevation: 0,
          leading: Center(
            child: IconButton(
              icon: ValueListenableBuilder<AdvancedDrawerValue>(
                valueListenable: _advDrawerController,
                builder: (_, value, __){
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      value.visible? Icons.clear : Icons.notes,
                      key: ValueKey<bool>(value.visible),
                      color: Colors.white,
                    ),
                  );
                },
              ),
              color: prudTheme.cardColor,
              splashRadius: 20,
              onPressed: _handleDrawer
            ),
          ),
          title: Text(
            widget.title,
            style: tabData.titleStyle,
            textAlign: TextAlign.center,
          ),
          backgroundColor: prudTheme.primaryColor,
          foregroundColor: prudTheme.colorScheme.surface,
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: SizedBox(
            height: height,
            width: width,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  PrudContainer(
                    hasPadding: false,
                    child: GFCarousel(
                        height: 137.0,
                        autoPlay: true,
                        aspectRatio: double.maxFinite,
                        viewportFraction: 1.0,
                        enlargeMainPage: true,
                        enableInfiniteScroll: true,
                        pauseAutoPlayOnTouch: const Duration(seconds: 10),
                        autoPlayInterval: const Duration(seconds: 5),
                        items: carousels
                    ),
                  ),
                  spacer.height,
                  if(!prudServiceIsAvailable) Column(
                    children: [
                      const NetworkIssueComponent(),
                      spacer.height,
                    ],
                  ),
                  PrudContainer(
                      hasPadding: true,
                      child: MainMenu(
                        menus: menus,
                        bgColor: prudColorTheme.bgC,
                        useWrap: true,
                      )
                  ),
                  spacer.height,
                  PrudShowroom(items: iCloud.getShowroom(context)),
                  largeSpacer.height,
                ],
              )
            ),
          ),
        ),
      ),
    );
  }

}
