import 'package:flutter/material.dart';
import 'package:prudapp/pages/influencers/tabs/influencer_links.dart';
import 'package:prudapp/pages/influencers/tabs/influencer_points.dart';
import 'package:prudapp/pages/influencers/tabs/influencer_promotion.dart';
import 'package:prudapp/pages/influencers/tabs/influencer_wallet.dart';
import 'package:prudapp/pages/influencers/tabs/shareable_income.dart';

import '../../models/images.dart';
import '../../models/theme.dart';

class Influencers extends StatefulWidget {
  const Influencers({super.key});

  @override
  InfluencersState createState() => InfluencersState();
}

class InfluencersState extends State<Influencers> with TickerProviderStateMixin {

  late TabController tabCtrl = TabController(
      length: 5, vsync: this
  );

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      body: TabBarView(
        controller: tabCtrl,
        children: [
          InfluencerLinks(goToTab: (int index) => tabCtrl.animateTo(index)),
          InfluencerPoints(goToTab: (int index) => tabCtrl.animateTo(index)),
          ShareableIncome(goToTab: (int index) => tabCtrl.animateTo(index)),
          InfluencerWallet(goToTab: (int index) => tabCtrl.animateTo(index)),
          InfluencerPromotion(goToTab: (int index) => tabCtrl.animateTo(index)),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: tabCtrl,
        // isScrollable: true,
        tabs: [
          Tab(
            icon: Image.asset(prudImages.links, width: 30,),
            text: "Links",
          ),
          Tab(
            icon: Image.asset(prudImages.points, width: 30,),
            text: "Points",
          ),
          Tab(
            icon: Image.asset(prudImages.income, width: 30,),
            text: "Incomes",
          ),
          Tab(
            icon: Image.asset(prudImages.wallet, width: 30,),
            text: "Wallet",
          ),
          Tab(
            icon: Image.asset(prudImages.promotions, width: 30,),
            text: "Promos",
          ),
        ],
      ),
    );
  }
}