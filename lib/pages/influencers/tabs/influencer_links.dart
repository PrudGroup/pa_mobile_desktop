import 'package:flutter/material.dart';
import 'package:prudapp/pages/influencers/tabs/link_tabs/ads_links.dart';
import 'package:prudapp/pages/influencers/tabs/link_tabs/spark_links.dart';
import 'package:prudapp/pages/influencers/tabs/link_tabs/switz_store_links.dart';

import '../../../components/inner_menu.dart';
import '../../../components/translate.dart';
import '../../../models/theme.dart';

class InfluencerLinks extends StatefulWidget {
  final Function(int)? goToTab;
  const InfluencerLinks({super.key, this.goToTab});

  @override
  InfluencerLinksState createState() => InfluencerLinksState();
}

class InfluencerLinksState extends State<InfluencerLinks> {
  final List<InnerMenuItem> tabMenus = [
    InnerMenuItem(title: "Sparks", menu: const SparkLinks()),
    InnerMenuItem(title: "Ads", menu: const AdsLinks()),
    InnerMenuItem(title: "Switz Stores", menu: const SwitzStoreLinks()),
  ];

  void gotoTab(index){
    if(widget.goToTab != null) widget.goToTab!(index);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      appBar:  AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: prudColorTheme.bgA,),
          onPressed: () => Navigator.pop(context),
          splashRadius: 20,
        ),
        backgroundColor: prudColorTheme.primary,
        title: Translate(
          text: "Influencer Links",
          style: prudWidgetStyle.tabTextStyle.copyWith(
            fontSize: 16,
            color: prudColorTheme.bgA
          ),
        ),
        actions: const [],
      ),
      body: InnerMenu(menus: tabMenus, type: 0,),
    );
  }
}
