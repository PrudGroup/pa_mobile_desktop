import 'package:flutter/material.dart';

import '../../../components/Translate.dart';
import '../../../components/work_in_progress.dart';
import '../../../models/theme.dart';

class Hotels extends StatefulWidget {
  final String? affLinkId;
  final Function(int)? goToTab;
  const Hotels({super.key, this.affLinkId, this.goToTab});

  @override
  HotelsState createState() => HotelsState();
}

class HotelsState extends State<Hotels> {

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
        title: Translate(
          text: "Hotels & Bookings",
          style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 16,
              color: prudColorTheme.bgA
          ),
        ),
        actions: const [
        ],
      ),
      body: const WorkInProgress(),
    );
  }
}
