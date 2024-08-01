import 'package:flutter/material.dart';

import '../../models/theme.dart';
import '../../components/translate_text.dart';
import "../../components/work_in_progress.dart";

class Shippers extends StatefulWidget {
  const Shippers({super.key});

  @override
  ShippersState createState() => ShippersState();
}

class ShippersState extends State<Shippers> {
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
          text: "Shippers",
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