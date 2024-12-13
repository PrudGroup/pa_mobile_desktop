import 'package:flutter/material.dart';
import '../../../../../models/images.dart';
import '../../../../../models/theme.dart';
import '../../../singletons/bus_notifier.dart';
import 'operations/account_operations.dart';
import 'operations/bus_operations.dart';
import 'operations/customer_operations.dart';
import 'operations/journey_operations.dart';
import 'operations/promotion_operations.dart';
import 'operations/staff_operations.dart';
import 'operations/wallet_operations.dart';

class BusDashboard extends StatefulWidget {
  const BusDashboard({super.key});

  @override
  BusDashboardState createState() => BusDashboardState();
}

class BusDashboardState extends State<BusDashboard> with TickerProviderStateMixin {
  String role = busNotifier.busBrandRole!.toLowerCase();
  late TabController tabCtrl = TabController(
      length: getLength(),
      vsync: this
  );

  int getLength() {
    switch(busNotifier.busBrandRole!.toLowerCase()){
      case "admin": return 4;
      case "driver": return 2;
      default: return 7;
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
          if(role == "super") const StaffOperations(),
          const BusOperations(),
          const JourneyOperations(),
          if(role == "super" || role == "admin") const CustomerOperations(),
          if(role == "super") const WalletOperations(),
          if(role == "super" || role == "admin") const PromotionOperations(),
          if(role == "super") const AccountOperations(),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: tabCtrl,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        splashFactory: NoSplash.splashFactory,
        tabs: [
          Tab(
            icon: Image.asset(prudImages.operators, width: 30,),
            text: "Staff",
          ),
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
        ],
      ),
    );
  }
}
