import 'package:flutter/material.dart';
import 'package:prudapp/pages/prudVid/tabs/search_prud_vid.dart';
import 'package:prudapp/pages/prudVid/tabs/vid_cloud_library.dart';
import 'package:prudapp/pages/prudVid/tabs/vid_liked.dart';
import 'package:prudapp/pages/prudVid/tabs/vid_local_library.dart';
import 'package:prudapp/pages/prudVid/tabs/vid_membership.dart';
import 'package:prudapp/pages/prudVid/tabs/vid_settings.dart';
import 'package:prudapp/pages/prudVid/tabs/vid_subscribe.dart';
import 'package:prudapp/pages/prudVid/tabs/vid_view.dart';
import 'package:prudapp/pages/prudVid/tabs/vid_view_history.dart';
import 'package:prudapp/pages/prudVid/tabs/vid_watch_later.dart';

import '../../models/images.dart';
import '../../models/theme.dart';

class PrudVid extends StatefulWidget {
  final String? affLinkId;
  final int? tab;
  const PrudVid({super.key, this.affLinkId, this.tab,});

  @override
  PrudVidState createState() => PrudVidState();
}

class PrudVidState extends State<PrudVid> with TickerProviderStateMixin {
  late TabController tabCtrl = TabController(
      length: 10, vsync: this
  );

  @override
  void initState(){
    super.initState();
    if(widget.tab != null) {
      tabCtrl.animateTo(widget.tab!);
    } else {
      tabCtrl.animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      body: TabBarView(
        controller: tabCtrl,
        children: [
          VidView(goToTab: (int index) => tabCtrl.animateTo(index)),
          SearchPrudVid(goToTab: (int index) => tabCtrl.animateTo(index)),
          VidMembership(goToTab: (int index) => tabCtrl.animateTo(index)),
          VidSubscribe(goToTab: (int index) => tabCtrl.animateTo(index)),
          VidLocalLibrary(goToTab: (int index) => tabCtrl.animateTo(index)),
          VidLiked(goToTab: (int index) => tabCtrl.animateTo(index)),
          VidCloudLibrary(goToTab: (int index) => tabCtrl.animateTo(index)),
          VidWatchLater(goToTab: (int index) => tabCtrl.animateTo(index)),
          VidViewHistory(goToTab: (int index) => tabCtrl.animateTo(index)),
          VidSettings(goToTab: (int index) => tabCtrl.animateTo(index)),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: tabCtrl,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        splashFactory: NoSplash.splashFactory,
        tabs: [
          Tab(
            icon: Image.asset(prudImages.videoHome, width: 30,),
            text: "Cinema",
          ),
          Tab(
            icon: Image.asset(prudImages.videoSearch, width: 30,),
            text: "Search",
          ),
          Tab(
            icon: Image.asset(prudImages.videoMembership, width: 30,),
            text: "Membership",
          ),
          Tab(
            icon: Image.asset(prudImages.videoAd, width: 30,),
            text: "Subscription",
          ),
          Tab(
            icon: Image.asset(prudImages.localVideoLibrary, width: 30,),
            text: "Library",
          ),
          Tab(
            icon: Image.asset(prudImages.likedVideo, width: 30,),
            text: "Liked",
          ),
          Tab(
            icon: Image.asset(prudImages.mySparks, width: 30,),
            text: "My Collections",
          ),
          Tab(
            icon: Image.asset(prudImages.watchVideo, width: 30,),
            text: "Watch Later",
          ),
          Tab(
            icon: Image.asset(prudImages.history, width: 30,),
            text: "History",
          ),
          Tab(
            icon: Image.asset(prudImages.settings, width: 30,),
            text: "Preferences",
          ),
        ],
      ),
    );
  }
}
