import 'package:flutter/material.dart';
import 'package:prudapp/pages/giftcards/tabs/gift_market.dart';
import 'package:prudapp/pages/giftcards/tabs/gift_search.dart';
import 'package:prudapp/pages/giftcards/tabs/gift_transaction_history.dart';

import '../../models/images.dart';
import '../../models/theme.dart';

class GiftCards extends StatefulWidget {
  final String? affLinkId;
  const GiftCards({super.key, this.affLinkId});

  @override
  GiftCardsState createState() => GiftCardsState();
}

class GiftCardsState extends State<GiftCards> with TickerProviderStateMixin {
  late TabController tabCtrl = TabController(
      length: 3, vsync: this
  );

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose() {
    tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      body: TabBarView(
        physics: const BouncingScrollPhysics(),
        controller: tabCtrl,
        children: [
          GiftSearch(goToTab: (int index) => tabCtrl.animateTo(index)),
          GiftMarket(goToTab: (int index) => tabCtrl.animateTo(index)),
          GiftTransactionHistory(goToTab: (int index) => tabCtrl.animateTo(index)),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: tabCtrl,
        physics: const BouncingScrollPhysics(),
        splashFactory: NoSplash.splashFactory,
        tabs: [
          Tab(
            icon: Image.asset(prudImages.giftSearch, width: 30,),
            text: "Gift Search",
          ),
          Tab(
            icon: Image.asset(prudImages.gift, width: 30,),
            text: "Gift Mall",
          ),
          Tab(
            icon: Image.asset(prudImages.history, width: 30,),
            text: "Gift History",
          )
        ],
      ),
    );
  }
}
