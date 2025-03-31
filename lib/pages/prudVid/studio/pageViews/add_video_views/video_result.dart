import 'package:flutter/material.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/images.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
    
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
  " will notify you and if the need arises, we might have to suspend the video. It's very important to make sure your content"
  " and the used assets within it are original and claim-free.";
  bool succeeded = prudStudioNotifier.newVideo.savedVideo != null || prudStudioNotifier.newVideo.hasSavedVideo;

  @override
  void initState(){
    super.initState();
    if (!succeeded && mounted) setState(() => widget.succeeded);
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
          text: "Video",
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
                  succeeded? prudImages.prudVidStudio : prudImages.err,
                  width: succeeded? 100 : 200,
                  fit: BoxFit.contain,
                ),
                spacer.height,
                Translate(
                  text: succeeded? msg : (widget.errorMsg?? "Unknown Error. Try Again."),
                  style: prudWidgetStyle.tabTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: succeeded? prudColorTheme.textA : prudColorTheme.error,
                  ),
                  align: TextAlign.center,
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
                succeeded? spacer.width : prudWidgetStyle.getShortButton(
                  onPressed: widget.onPrevious, 
                  text: "Try Again",
                  makeLight: true,
                  isPill: false
                ),
                prudWidgetStyle.getShortButton(
                  onPressed: () => widget.onCompleted(true), 
                  text: succeeded? "Finish" : "Try Later",
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