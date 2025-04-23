import 'package:flutter/material.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/components/work_in_progress.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
    
class LiveBroadcast extends StatefulWidget {
  final VidChannel? channel;
  const LiveBroadcast({super.key, this.channel});

  @override
  LiveBroadcastState createState() => LiveBroadcastState();
}

class LiveBroadcastState extends State<LiveBroadcast> {
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
          text: "Live Broadcast",
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