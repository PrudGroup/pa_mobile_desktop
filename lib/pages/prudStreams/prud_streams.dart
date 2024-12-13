import 'package:flutter/material.dart';
import 'package:prudapp/components/work_in_progress.dart';

import '../../../components/translate_text.dart';
import '../../../models/theme.dart';

class PrudStreams extends StatefulWidget {
  final int? tab;
  const PrudStreams({super.key, this.tab, });

  @override
  PrudStreamsState createState() => PrudStreamsState();
}

class PrudStreamsState extends State<PrudStreams> with TickerProviderStateMixin {

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
          text: "PrudStreams",
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