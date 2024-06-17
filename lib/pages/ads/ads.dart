import 'package:flutter/material.dart';

import '../../models/theme.dart';
import '../../components/translate.dart';
import "../../components/work_in_progress.dart";

class Ads extends StatefulWidget {
  const Ads({super.key});

  @override
  AdsState createState() => AdsState();
}

class AdsState extends State<Ads> {
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
            text: "Ads",
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