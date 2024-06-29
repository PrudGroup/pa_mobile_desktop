import 'package:flutter/material.dart';
import 'package:prudapp/pages/recharge/tabs/airtime.dart';
import 'package:prudapp/pages/recharge/tabs/data_top_up.dart';
import 'package:prudapp/pages/recharge/tabs/utilities.dart';

import '../../models/images.dart';
import '../../models/theme.dart';

class Recharge extends StatefulWidget {
  final String? affLinkId;
  final int? tab;
  const Recharge({super.key, this.affLinkId, this.tab});

  @override
  RechargeState createState() => RechargeState();
}

class RechargeState extends State<Recharge> with TickerProviderStateMixin {
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
          Airtime(goToTab: (int index) => tabCtrl.animateTo(index)),
          DataTopUp(goToTab: (int index) => tabCtrl.animateTo(index)),
          Utilities(goToTab: (int index) => tabCtrl.animateTo(index)),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: tabCtrl,
        tabs: [
          Tab(
            icon: Image.asset(prudImages.airtime, width: 30,),
            text: "Airtime",
          ),
          Tab(
            icon: Image.asset(prudImages.dataBundle, width: 30,),
            text: "Data Bundles",
          ),
          Tab(
            icon: Image.asset(prudImages.utilities, width: 30,),
            text: "Utility & Bills",
          ),
        ],
      ),
    );
  }
}
