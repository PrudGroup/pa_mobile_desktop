import 'package:flutter/material.dart';
import 'package:prudapp/components/prud_image_picker.dart';
import 'package:prudapp/components/prud_video_picker.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/backblaze.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class VideoUploads extends StatefulWidget {
  final Function(dynamic) onCompleted;
  final Function onPrevious;
  const VideoUploads({super.key, required this.onCompleted, required this.onPrevious});

  @override
  VideoUploadsState createState() => VideoUploadsState();
}

class VideoUploadsState extends State<VideoUploads> {
  Map<String, dynamic>? result;
  bool shouldReset = false;

  void setVideoProgressChanged(SaveVideoResponse progress){
    if(mounted){
      setState(() {
        prudStudioNotifier.newVideo.saveVideoProgress = progress;
      });
      prudStudioNotifier.saveNewVideoData();
    }
  }

  void setThrillerProgressChanged(SaveVideoResponse progress){
    if(mounted){
      setState(() {
        prudStudioNotifier.newVideo.saveThrillerProgress = progress;
      });
      prudStudioNotifier.saveNewVideoData();
    }
  }

  void setVideoSavedFinished(String url){
    if(mounted){
      setState(() {
        prudStudioNotifier.newVideo.videoUrl = url;
      });
      prudStudioNotifier.saveNewVideoData();
    }
  }

  void setThrillerUrl(String url){
    if(mounted){
      setState(() {
        prudStudioNotifier.newVideo.thriller!.videoUrl = url;
      });
      prudStudioNotifier.saveNewVideoData();
    }
  }

  void setThumbnailUrl(String? url){
    if(mounted){
      setState(() {
        prudStudioNotifier.newVideo.videoThumbnail = url;
      });
      prudStudioNotifier.saveNewVideoData();
    }
  }
  
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
          text: "File Upload",
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
              text: "Start the upload process for the intended video. We await the awesome video you are about to upload. We are excited you are doing this.",
              style: prudWidgetStyle.tabTextStyle.copyWith(
                fontSize: 15,
                color: prudColorTheme.textB,
                fontWeight: FontWeight.w500
              ),
              align: TextAlign.center,
            ),
            spacer.height,
            PrudVideoPicker(
              onSaveToCloud: setVideoSavedFinished,
              onProgressChanged: setVideoProgressChanged,
              destination: "channels/${prudStudioNotifier.newVideo.channelId}/videos",
              saveToCloud: true,
              reset: shouldReset,
            ),
            Divider(
              color: prudColorTheme.lineC,
              thickness: 1,
              height: 2,
            ),
            spacer.height,
            Translate(
              text: "You need an intro video (Thriller) that helps captivate viewers towards your content and what you are offerring. This short video must not be more than 2 minutes long. Be sure to put in all your best at this.",
              style: prudWidgetStyle.tabTextStyle.copyWith(
                fontSize: 15,
                color: prudColorTheme.textB,
                fontWeight: FontWeight.w500
              ),
              align: TextAlign.center,
            ),
            spacer.height,
            PrudVideoPicker(
              onSaveToCloud: setThrillerUrl,
              onProgressChanged: setThrillerProgressChanged,
              destination: "channels/${prudStudioNotifier.newVideo.channelId}/thrillers",
              saveToCloud: true,
              reset: shouldReset,
            ),
            Divider(
              color: prudColorTheme.lineC,
              thickness: 1,
              height: 2,
            ),
            spacer.height,
            Translate(
              text: "Now upload a thumbnail image for your video. You need to do your best at this as it will go a long way to draw viewers to your video but be sure its not misleading.",
              style: prudWidgetStyle.tabTextStyle.copyWith(
                fontSize: 15,
                color: prudColorTheme.textB,
                fontWeight: FontWeight.w500
              ),
              align: TextAlign.center,
            ),
            spacer.height,
            PrudImagePicker(
              destination: "studio/${prudStudioNotifier.studio!.id}/images/ads",
              saveToCloud: true,
              reset: shouldReset,
              onSaveToCloud: setThumbnailUrl,
              onError: (err) {
                debugPrint("Picker Error: $err");
              },
            ),
            Divider(
              color: prudColorTheme.lineC,
              thickness: 1,
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                prudWidgetStyle.getShortButton(
                  onPressed: widget.onPrevious, 
                  text: "Previous",
                  makeLight: true,
                  isPill: false
                ),
                prudWidgetStyle.getShortButton(
                  onPressed: () => widget.onCompleted(result), 
                  text: "Next",
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