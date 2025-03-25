import 'package:flutter/material.dart';
import 'package:prudapp/components/work_in_progress.dart';
import 'package:prudapp/singletons/i_cloud.dart';

import '../../../components/translate_text.dart';
import '../../../models/theme.dart';

class InfluencerPromotion extends StatefulWidget {
  final Function(int)? goToTab;
  const InfluencerPromotion({super.key, this.goToTab});

  @override
  InfluencerPromotionState createState() => InfluencerPromotionState();
}

class InfluencerPromotionState extends State<InfluencerPromotion> {
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
          onPressed: () => iCloud.goBack(context),
          splashRadius: 20,
        ),
        backgroundColor: prudColorTheme.primary,
        title: Translate(
          text: "Influencer Promotions",
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
