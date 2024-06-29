import 'package:flutter/material.dart';
import 'package:prudapp/pages/travels/tabs/buses.dart';
import 'package:prudapp/pages/travels/tabs/flight.dart';
import 'package:prudapp/pages/travels/tabs/hotels.dart';

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
          Buses(goToTab: (int index) => tabCtrl.animateTo(index)),
          Flight(goToTab: (int index) => tabCtrl.animateTo(index)),
          Hotels(goToTab: (int index) => tabCtrl.animateTo(index)),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: tabCtrl,
        // isScrollable: true,
        tabs: [
          Tab(
            icon: Image.asset(prudImages.bus, width: 30,),
            text: "Buses",
          ),
          Tab(
            icon: Image.asset(prudImages.flight, width: 30,),
            text: "Flights",
          ),
          Tab(
            icon: Image.asset(prudImages.hotel, width: 30,),
            text: "Hotels",
          ),
        ],
      ),
    );
  }
}
