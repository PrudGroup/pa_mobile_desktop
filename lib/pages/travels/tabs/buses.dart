import 'package:flutter/material.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/pages/travels/tabs/buses/bus_company_dashboard.dart';
import 'package:prudapp/pages/travels/tabs/buses/bus_search.dart';
import 'package:prudapp/pages/travels/tabs/buses/customer_bus_booking.dart';

import '../../../components/inner_menu.dart';
import '../../../components/translate_text.dart';
import '../../../models/theme.dart';

class Buses extends StatefulWidget {
  final String? affLinkId;
  final Function(int)? goToTab;
  const Buses({super.key, this.affLinkId, this.goToTab});

  @override
  BusesState createState() => BusesState();
}

class BusesState extends State<Buses> {

  List<InnerMenuItem> tabMenus = [];
  final GlobalKey<InnerMenuState> _key = GlobalKey();

  void gotoTab(index){
    if(widget.goToTab != null) widget.goToTab!(index);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void moveTo(int index){
    if(_key.currentState != null){
      _key.currentState!.changeWidget(_key.currentState!.widget.menus[index].menu, index);
    }
  }

  @override
  void initState() {
    super.initState();
    if(mounted){
      setState(() {
        tabMenus = [
          InnerMenuItem(title: "Journeys", menu: const BusSearch(), imageIcon: prudImages.transport),
          InnerMenuItem(title: "My Bookings", menu: const CustomerBusBooking(), icon: Icons.bookmark_added_outlined),
          InnerMenuItem(title: "Dashboard", menu: const BusCompanyDashboard(), icon: Icons.dashboard_outlined),
        ];
      });
    }
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
        title: Translate(
          text: "Buses & Bookings",
          style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 16,
              color: prudColorTheme.bgA
          ),
        ),
        actions: const [
        ],
      ),
      body: InnerMenu(key: _key, menus: tabMenus, type: 0, hasIcon: true,),
    );
  }
}
