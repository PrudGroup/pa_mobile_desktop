import 'package:flutter/material.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/components/work_in_progress.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';

class PrudComedy extends StatefulWidget {
  final String? affLinkId;
  const PrudComedy({super.key, this.affLinkId});

  @override
  State<PrudComedy> createState() => PrudComedyState();
}

class PrudComedyState extends State<PrudComedy> {

  @override
  void initState() {
    super.initState();
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
        title: Translate(
          text: "PrudComedy",
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