import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:prudapp/components/main_menu.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:prudapp/singletons/tab_data.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';

import '../../models/images.dart';
import '../../singletons/shared_local_storage.dart';
import 'home_drawer.dart';


// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  final _advDrawerController = AdvancedDrawerController();
  String tabTitle = "Prud";
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
  StreamSubscription? subscription;
  StreamSubscription? messageStream;
  final GlobalKey _imageKey = GlobalKey();
  double imageHeight = 0;
  List<Menu> menus = [
  ];

  MyHomePageState({this.tabTitle ="Prud"});

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getSizeAndPosition());
    _rateMyApp.init();
    subscription = FGBGEvents.stream.listen((event) {
      if(event == FGBGType.background) {

      } else {
        listenForMessages();
      }
    });
  }

  getSizeAndPosition() {
    imageHeight = _imageKey.currentContext!.size!.height;
    setState(() {});
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
            colors: [pagadoColorScheme.bgA, pagadoColorScheme.bgA.withOpacity(0.2)],
          ),
        ),
      ),
      controller: _advDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      // openScale: 1.0,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      drawer: const HomeDrawer(),
      child: Scaffold(
        key: _drawerKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: pagadoColorScheme.bgA,
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
          title: Center(
            child: Text('Prud', style: tabData.titleStyle, textAlign: TextAlign.center,),
          ),
          backgroundColor: prudTheme.primaryColor,
          foregroundColor: prudTheme.colorScheme.background,
        ),
        body: Wrap(
          direction: Axis.horizontal,
          children: [
            SizedBox(
              key: _imageKey,
              width: width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Image(
                  image: AssetImage(prudImages.err),
                ),
              )
            ),
            SizedBox(
              width: width,
              height: height - imageHeight,
              child: MainMenu(
                menus: menus,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
