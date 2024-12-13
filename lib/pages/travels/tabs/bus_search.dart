import 'package:flutter/material.dart';
import 'package:prudapp/components/work_in_progress.dart';

import '../../../components/translate_text.dart';
import '../../../models/theme.dart';

class BusSearch extends StatefulWidget {
  final String? affLinkId;
  final Function(int)? goToTab;
  const BusSearch({super.key, this.affLinkId, this.goToTab});

  @override
  BusSearchState createState() => BusSearchState();
}

class BusSearchState extends State<BusSearch> {

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
          text: "SwitzTravels",
          style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 16,
              color: prudColorTheme.bgA
          ),
        ),
        actions: const [
        ],
      ),
      body: WorkInProgress(),
    );
  }
}
