import 'package:flutter/material.dart';

import '../../../components/translate.dart';
import '../../../components/work_in_progress.dart';
import '../../../models/theme.dart';

class InfluencerWallet extends StatefulWidget {
  final Function(int)? goToTab;
  const InfluencerWallet({super.key, this.goToTab});

  @override
  InfluencerWalletState createState() => InfluencerWalletState();
}

class InfluencerWalletState extends State<InfluencerWallet> {

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
        backgroundColor: prudColorTheme.primary,
        title: Translate(
          text: "Influencer Wallet",
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
