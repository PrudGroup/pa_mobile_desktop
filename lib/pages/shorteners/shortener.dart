import 'package:flutter/material.dart';

import '../../models/theme.dart';
import '../../components/translate_text.dart';
import "../../components/work_in_progress.dart";
import 'package:prudapp/singletons/i_cloud.dart';

class Shortener extends StatefulWidget {
  const Shortener({super.key});

  @override
  ShortenerState createState() => ShortenerState();
}

class ShortenerState extends State<Shortener> {
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
        title: Translate(
          text: "Shortener",
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