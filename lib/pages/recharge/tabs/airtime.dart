import 'package:flutter/material.dart';

import '../../../components/Translate.dart';
import '../../../models/theme.dart';

class Airtime extends StatefulWidget {
  final String? affLinkId;
  final Function(int)? goToTab;
  const Airtime({super.key, this.affLinkId, this.goToTab});

  @override
  AirtimeState createState() => AirtimeState();
}

class AirtimeState extends State<Airtime> {
  ScrollController scrollCtrl = ScrollController();

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
          text: "Airtime Top-up",
          style: prudWidgetStyle.tabTextStyle.copyWith(
              fontSize: 16,
              color: prudColorTheme.bgA
          ),
        ),
        actions: const [
        ],
      ),
      body: SingleChildScrollView(
        controller: scrollCtrl,
        padding: const EdgeInsets.all(10),
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            spacer.height,

          ],
        ),
      ),
    );
  }
}
