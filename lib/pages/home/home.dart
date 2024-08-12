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
import 'package:prudapp/pages/giftcards/gift_cards.dart';
import 'package:prudapp/pages/influencers/influencers.dart';
import 'package:prudapp/pages/shippers/shippers.dart';
import 'package:prudapp/pages/shorteners/shortener.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';

import '../../components/prud_container.dart';
import '../../models/images.dart';
import '../../singletons/shared_local_storage.dart';
import '../account/my_account.dart';
import '../ads/ads.dart';
import '../recharge/recharge.dart';
import '../settings/settings.dart';
import '../switzstores/switz_stores.dart';
import '../travels/switz_travels.dart';
import '../viewsparks/view_spark.dart';
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
        title: 'Gift Cards',
        page: const GiftCards(),
        icon: prudImages.gift
    ),
    Menu(
      title: 'Airtime',
      page: const Recharge(tab: 0,),
      icon: prudImages.airtime
    ),
    Menu(
      title: 'Data Bundles',
      page: const Recharge(tab: 1,),
      icon: prudImages.dataBundle
    ),
    Menu(
      title: 'Bills & Utilities',
      page: const Recharge(tab: 2,),
      icon: prudImages.smartTv1
    ),
    Menu(
      title: 'SwitzTravels',
      page: const SwitzTravels(),
      icon: prudImages.travel1
    ),
    Menu(
      title: 'Flights',
      page: const SwitzTravels(tab: 1,),
      icon: prudImages.flight
    ),
    Menu(
      title: 'Buses',
      page: const SwitzTravels(tab: 0,),
      icon: prudImages.transport
    ),
    Menu(
      title: 'Hotels',
      page: const SwitzTravels(tab: 2,),
      icon: prudImages.resort
    ),
    Menu(
      title: 'Switz Stores',
      page: const SwitzStores(),
      icon: prudImages.stores
    ),
    Menu(
      title: 'View Sparks',
      page: const ViewSpark(),
      icon: prudImages.watchVideo
    ),
    Menu(
      title: 'Influencers',
      page: const Influencers(),
      icon: prudImages.influencerFemale
    ),
    Menu(
      title: 'Ads & Promotions',
      page: const Ads(),
      icon: prudImages.videoAd
    ),
    Menu(
      title: 'Shippers',
      page: const Shippers(),
      icon: prudImages.shipper
    ),
    Menu(
      title: 'Url Shortener',
      page: const Shortener(),
      icon: prudImages.shortener
    ),
    Menu(
      title: 'My Account',
      page: const MyAccount(),
      icon: prudImages.account
    ),
    Menu(
      title: 'Settings',
      page: const Settings(),
      icon: prudImages.settings
    ),
  ];
  List<Widget> showroom = [];
  bool prudServiceIsAvailable = true;

  Future<void> changeConnectionStatus() async{
    bool ok = await iCloud.prudServiceIsAvailable();
    if(mounted) setState(() => prudServiceIsAvailable = ok);
  }


  @override
  void initState(){
    Future.delayed(Duration.zero, () async {
      await changeConnectionStatus();
    });
    carousels.shuffle();
    showroom = [
      InkWell(
        onTap: () => iCloud.goto(context, const ViewSpark()),
        child: PrudContainer(
            hasPadding: false,
            child: Image.asset(
                prudImages.front7
            )
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const ViewSpark()),
        child: PrudContainer(
          hasPadding: false,
          hasTitle: true,
          title: "Get Views/Sparks",
          child: Image.asset(
              prudImages.front4
          ),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const Ads()),
        child: PrudContainer(
            hasPadding: false,
            child: Image.asset(
                prudImages.front1
            )
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const Ads()),
        child: PrudContainer(
          hasPadding: false,
          child: Image.asset(
            prudImages.front6
          ),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const SwitzStores()),
        child: PrudContainer(
          hasPadding: false,
          hasTitle: true,
          title: "Best Marketplace",
          child: Image.asset(
            prudImages.front13
          ),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const SwitzStores()),
        child: PrudContainer(
          hasPadding: false,
          child: Image.asset(
            prudImages.front12
          ),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const Shippers()),
        child: PrudContainer(
          hasPadding: false,
          hasTitle: true,
          title: "Shippers",
          child: Image.asset(
            prudImages.front15
          ),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const SwitzStores()),
        child: PrudContainer(
          hasPadding: false,
          child: Image.asset(
            prudImages.front10
          ),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const SwitzStores()),
        child: PrudContainer(
          hasPadding: false,
          hasTitle: true,
          title: "Switz Stores",
          child: Image.asset(
            prudImages.front2
          ),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const SwitzStores()),
        child: PrudContainer(
          hasPadding: false,
          child: Image.asset(
            prudImages.front11
          ),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const Shippers()),
        child: PrudContainer(
          hasPadding: false,
          hasTitle: true,
          titleAlignment: MainAxisAlignment.end,
          title: "Shipping Easily",
          child: Image.asset(
            prudImages.front14
          ),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const SwitzStores()),
        child: PrudContainer(
          hasPadding: false,
          hasTitle: true,
          title: "Shopping",
          child: Image.asset(
            prudImages.front9
          ),
        ),
      ),
      InkWell(
        onTap: () => iCloud.goto(context, const SwitzStores()),
        child: PrudContainer(
          hasPadding: false,
          child: Image.asset(
            prudImages.front8
          ),
        ),
      ),
    ];
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
            colors: [prudColorTheme.bgA, prudColorTheme.bgA.withOpacity(0.2)],
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
        body: SizedBox(
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
    );
  }

}
