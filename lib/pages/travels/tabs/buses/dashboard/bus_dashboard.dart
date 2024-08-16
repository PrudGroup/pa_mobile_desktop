import 'package:flutter/material.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/operations/account_operations.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/operations/bus_operations.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/operations/customer_operations.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/operations/journey_operations.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/operations/staff_operations.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/operations/promotion_operations.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/operations/wallet_operations.dart';

import '../../../../../models/images.dart';
import '../../../../../models/theme.dart';

class BusDashboard extends StatefulWidget {
  const BusDashboard({super.key});

  @override
  BusDashboardState createState() => BusDashboardState();
}

class BusDashboardState extends State<BusDashboard> with TickerProviderStateMixin {

  late TabController tabCtrl = TabController(
      length: 7, vsync: this
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prudColorTheme.bgC,
      resizeToAvoidBottomInset: false,
      body: TabBarView(
        controller: tabCtrl,
        children: const [
          BusOperations(),
          JourneyOperations(),
          CustomerOperations(),
          WalletOperations(),
          PromotionOperations(),
          AccountOperations(),
          StaffOperations()
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: tabCtrl,
        isScrollable: true,
        splashFactory: NoSplash.splashFactory,
        tabs: [
          Tab(
            icon: Image.asset(prudImages.transport, width: 30,),
            text: "Buses",
          ),
          Tab(
            icon: Image.asset(prudImages.shipper, width: 30,),
            text: "Journeys",
          ),
          Tab(
            icon: Image.asset(prudImages.newSpark, width: 30,),
            text: "Customers",
          ),
          Tab(
            icon: Image.asset(prudImages.wallet, width: 30,),
            text: "Wallet",
          ),
          Tab(
            icon: Image.asset(prudImages.promotions, width: 30,),
            text: "Promotions",
          ),
          Tab(
            icon: Image.asset(prudImages.account, width: 30,),
            text: "Accounts",
          ),
          Tab(
            icon: Image.asset(prudImages.links, width: 30,),
            text: "Others",
          ),
        ],
      ),
    );
  }
}
