import 'package:flutter/material.dart';

import '../../../components/translate_text.dart';
import '../../../components/work_in_progress.dart';
import '../../../models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';

class VidLiked extends StatefulWidget {
  final Function(int)? goToTab;
  const VidLiked({super.key, this.goToTab});

  @override
  VidLikedState createState() => VidLikedState();
}

class VidLikedState extends State<VidLiked> {
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
          text: "Liked Videos",
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
