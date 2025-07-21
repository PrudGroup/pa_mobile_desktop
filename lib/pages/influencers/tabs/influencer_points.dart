import 'package:flutter/material.dart';
import 'package:prudapp/singletons/i_cloud.dart';

import '../../../components/translate_text.dart';
import '../../../components/work_in_progress.dart';
import '../../../models/theme.dart';

class InfluencerPoints extends StatefulWidget {
  final Function(int)? goToTab;
  const InfluencerPoints({super.key, this.goToTab});

  @override
  InfluencerPointsState createState() => InfluencerPointsState();
}

class InfluencerPointsState extends State<InfluencerPoints> {

  void gotoTab(int index){
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
          onPressed: () => iCloud.goBack(context),
          splashRadius: 20,
        ),
        backgroundColor: prudColorTheme.primary,
        title: Translate(
          text: "Influencer Points",
          style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 16,
              color: prudColorTheme.bgA
          ),
        ),
        actions: const [],
      ),
      body: const WorkInProgress(),
    );
  }
}
