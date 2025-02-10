import 'package:flutter/material.dart';
import 'package:prudapp/pages/prudVid/studio/studio_channel.dart';
import 'package:prudapp/pages/prudVid/studio/studio_creators.dart';
import 'package:prudapp/pages/prudVid/studio/studio_wallet.dart';

import '../../models/images.dart';
import '../../models/theme.dart';

class PrudVidStudio extends StatefulWidget {
  final String? affLinkId;
  final int? tab;
  const PrudVidStudio({super.key, this.affLinkId, this.tab});

  @override
  PrudVidStudioState createState() => PrudVidStudioState();
}

class PrudVidStudioState extends State<PrudVidStudio> with TickerProviderStateMixin {
  late TabController tabCtrl = TabController(
      length: 3, vsync: this
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
          StudioChannel(goToTab: (int index) => tabCtrl.animateTo(index)),
          StudioCreators(goToTab: (int index) => tabCtrl.animateTo(index)),
          StudioWallet(goToTab: (int index) => tabCtrl.animateTo(index)),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: tabCtrl,
        // isScrollable: true,
        // tabAlignment: TabAlignment.start,
        splashFactory: NoSplash.splashFactory,
        tabs: [
          Tab(
            icon: Image.asset(prudImages.studio, width: 30,),
            text: "Channels",
          ),
          Tab(
            icon: Image.asset(prudImages.prudVider, width: 30,),
            text: "Creators",
          ),
          Tab(
            icon: Image.asset(prudImages.wallet, width: 30,),
            text: "Wallet",
          ),
        ],
      ),
    );
  }
}
