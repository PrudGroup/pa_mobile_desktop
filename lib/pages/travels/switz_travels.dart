import 'package:flutter/material.dart';
import 'package:prudapp/pages/travels/tabs/bus_company_dashboard.dart';
import 'package:prudapp/pages/travels/tabs/bus_search.dart';
import 'package:prudapp/pages/travels/tabs/customer_bus_booking.dart';

import '../../models/images.dart';
import '../../models/theme.dart';

class SwitzTravels extends StatefulWidget {
  final int? tab;
  const SwitzTravels({super.key, this.tab, });

  @override
  SwitzTravelsState createState() => SwitzTravelsState();
}

class SwitzTravelsState extends State<SwitzTravels> with TickerProviderStateMixin {
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
          BusSearch(goToTab: (int index) => tabCtrl.animateTo(index)),
          CustomerBusBooking(goToTab: (int index) => tabCtrl.animateTo(index)),
          BusCompanyDashboard(goToTab: (int index) => tabCtrl.animateTo(index)),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: tabCtrl,
        // isScrollable: true,
        tabs: [
          Tab(
            icon: Image.asset(prudImages.transport, width: 30,),
            text: "Journeys",
          ),
          Tab(
            icon: Image.asset(prudImages.bus, width: 30,),
            text: "My Bookings",
          ),
          Tab(
            icon: Icon(Icons.dashboard_outlined, size: 30,),
            text: "Dashboard",
          ),
        ],
      ),
    );
  }
}
