import 'package:flutter/material.dart';
import 'package:prudapp/components/work_in_progress.dart';

import '../../../components/translate_text.dart';
import '../../../models/theme.dart';

class Thrillers extends StatefulWidget {
  final int? tab;
  const Thrillers({super.key, this.tab, });

  @override
  ThrillersState createState() => ThrillersState();
}

class ThrillersState extends State<Thrillers> with TickerProviderStateMixin {

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
          text: "Thrillers",
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