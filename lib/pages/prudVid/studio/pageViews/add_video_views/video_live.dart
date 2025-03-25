import 'package:flutter/material.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
    
class VideoLive extends StatefulWidget {
  final Function(dynamic) onCompleted;
  final Function onPrevious;
  const VideoLive({super.key, required this.onCompleted, required this.onPrevious});

  @override
  VideoLiveState createState() => VideoLiveState();
}

class VideoLiveState extends State<VideoLive> {
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
          text: "Livestream",
          style: prudWidgetStyle.tabTextStyle.copyWith(
            fontSize: 16,
            color: prudColorTheme.bgA
          ),
        ),
        actions: const [
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            spacer.height,
            Translate(
              text: "We are actively working on delivering livestream services. Thanks for your patience. ",         
              style: prudWidgetStyle.tabTextStyle.copyWith(
                fontSize: 15,
                color: prudColorTheme.textB,
                fontWeight: FontWeight.w500
              ),
              align: TextAlign.center,
            ),
            spacer.height,
            Divider(
              color: prudColorTheme.lineC,
              thickness: 1,
              height: 10,
            ),
            prudWidgetStyle.getLongButton(
              onPressed: () => iCloud.goBack(context), 
              text: "Close",
              makeLight: false,
              shape: 1
            ),
          ],
        ),
      ),
    );
  }
}