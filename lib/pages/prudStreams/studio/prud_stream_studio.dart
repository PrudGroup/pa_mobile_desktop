import 'package:flutter/material.dart';
import 'package:prudapp/components/work_in_progress.dart';
import 'package:prudapp/singletons/i_cloud.dart';

import '../../../components/translate_text.dart';
import '../../../models/theme.dart';

class PrudStreamStudio extends StatefulWidget {
  final int? tab;
  const PrudStreamStudio({super.key, this.tab, });

  @override
  PrudStreamStudioState createState() => PrudStreamStudioState();
}

class PrudStreamStudioState extends State<PrudStreamStudio> with TickerProviderStateMixin {

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
          text: "PrudStreams Studio",
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