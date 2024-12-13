import 'package:flutter/material.dart';

import '../../../../../../components/inner_menu.dart';
import '../../../../../../components/translate_text.dart';
import '../../../../../../models/images.dart';
import '../../../../../../models/theme.dart';
import '../../../../../../singletons/bus_notifier.dart';
import 'journey/active_journey.dart';
import 'journey/boarding_journey.dart';
import 'journey/cancelled_journey.dart';
import 'journey/completed_journey.dart';
import 'journey/create_journey.dart';
import 'journey/halted_boarding_journey.dart';
import 'journey/halted_journey.dart';
import 'journey/pending_journey.dart';

class JourneyOperations extends StatefulWidget {
  const JourneyOperations({super.key});

  @override
  JourneyOperationsState createState() => JourneyOperationsState();
}

class JourneyOperationsState extends State<JourneyOperations> {
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
          InnerMenuItem(imageIcon: prudImages.journeyCreate, title: "Create", menu: const CreateJourney()),
          InnerMenuItem(imageIcon: prudImages.journeyPending, title: "Pending", menu: const PendingJourney()),
          InnerMenuItem(imageIcon: prudImages.journeyActive, title: "Active", menu: const ActiveJourney()),
          InnerMenuItem(icon: Icons.family_restroom, title: "Boarding", menu: const BoardingJourney()),
          InnerMenuItem(icon: Icons.stroller_outlined, title: "Halted", menu: const HaltedJourney()),
          InnerMenuItem(icon: Icons.elderly_outlined, title: "Re-boarding", menu: const HaltedBoardingJourney()),
          InnerMenuItem(icon: Icons.cancel_outlined, title: "Cancelled", menu: const CancelledJourney()),
          InnerMenuItem(imageIcon: prudImages.journeyCompleted, title: "Completed", menu: const CompletedJourney()),
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
          text: "Journey Operations",
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
