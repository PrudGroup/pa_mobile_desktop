import 'package:flutter/material.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/operations/bus/add_bus.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/operations/bus/add_bus_features.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/operations/bus/add_bus_images.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/operations/bus/add_bus_seats.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/operations/bus/existing_buses.dart';
import 'package:prudapp/pages/travels/tabs/buses/dashboard/operations/bus/remove_operations.dart';

import '../../../../../../components/inner_menu.dart';
import '../../../../../../components/translate_text.dart';
import '../../../../../../models/images.dart';
import '../../../../../../models/theme.dart';
import '../../../../../../singletons/bus_notifier.dart';

class BusOperations extends StatefulWidget {
  const BusOperations({super.key});

  @override
  BusOperationsState createState() => BusOperationsState();
}

class BusOperationsState extends State<BusOperations> {

  List<InnerMenuItem> tabMenus = [];
  final GlobalKey<InnerMenuState> _key = GlobalKey();

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
          InnerMenuItem(imageIcon: prudImages.bus, title: "Add Bus", menu: const AddBus()),
          InnerMenuItem(icon: Icons.add_photo_alternate_outlined, title: "Add Photo", menu: const AddBusImages()),
          InnerMenuItem(icon: Icons.event_seat_outlined, title: "Add Seats", menu: const AddBusSeats()),
          InnerMenuItem(icon: Icons.add_chart_outlined, title: "Add Features", menu: const AddBusFeatures()),
          InnerMenuItem(icon: Icons.remove_from_queue_outlined, title: "Remove Operations", menu: const RemoveOperations()),
          InnerMenuItem(imageIcon: prudImages.transport, title: "Existing Buses", menu: const ExistingBuses()),
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
          text: "Bus Operations",
          style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 16,
              color: prudColorTheme.bgA
          ),
        ),
        actions: [
          IconButton(
            onPressed: busNotifier.toggleButton,
            icon: Icon(busNotifier.showFloatingButton? Icons.toggle_on : Icons.toggle_off),
            color: prudColorTheme.bgA,
          ),
        ],
      ),
      body: InnerMenu(key: _key, menus: tabMenus, type: 0, hasIcon: true,),
    );
  }
}
