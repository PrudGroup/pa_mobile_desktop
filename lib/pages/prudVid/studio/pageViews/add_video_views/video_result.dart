import 'package:flutter/material.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
    
class VideoResult extends StatefulWidget {
  final bool succeeded;
  final String? errorMsg;
  final Function(dynamic) onCompleted;
  final Function onPrevious;

  const VideoResult({
    super.key, required this.onCompleted, 
    required this.onPrevious, this.succeeded = true,
    this.errorMsg
  });

  @override
  VideoResultState createState() => VideoResultState();
}

class VideoResultState extends State<VideoResult> {
  String msg = "Your video was successfully uploaded. Please note that, as claims begin to arise from your video, we"
  "will notify you and if the need arises, we might have to suspend the video. It's very important to make sure your content"
  " and the used assets within it are original and claim-free.";


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
          text: "Video Category",
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  widget.succeeded? prudImages.prudVidStudio : prudImages.err,
                  width: widget.succeeded? 120 : 200,
                  fit: BoxFit.contain,
                ),
                spacer.height,
                Translate(
                  text: widget.succeeded? msg : (widget.errorMsg?? "Unknown Error. Try Again."),
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: widget.succeeded? prudColorTheme.success : prudColorTheme.error,
                  ),
                ),
                spacer.height,
              ],
            ),
            spacer.height,
            Divider(
              color: prudColorTheme.lineC,
              thickness: 1,
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                prudWidgetStyle.getShortButton(
                  onPressed: widget.onPrevious, 
                  text: "Try Again",
                  makeLight: true,
                  isPill: false
                ),
                prudWidgetStyle.getShortButton(
                  onPressed: () => widget.onCompleted(true), 
                  text: "Try Later",
                  makeLight: false,
                  isPill: false
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}