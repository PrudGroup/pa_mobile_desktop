import 'package:flutter/material.dart';

import '../../../components/translate_text.dart';
import '../../../components/work_in_progress.dart';
import '../../../models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';

class VidCloudLibrary extends StatefulWidget {
  final Function(int)? goToTab;
  const VidCloudLibrary({super.key, this.goToTab});

  @override
  VidCloudLibraryState createState() => VidCloudLibraryState();
}

class VidCloudLibraryState extends State<VidCloudLibrary> {
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
          text: "My Collections",
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
