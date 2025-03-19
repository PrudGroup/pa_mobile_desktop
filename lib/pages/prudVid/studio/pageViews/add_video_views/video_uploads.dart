import 'dart:io';

import 'package:flutter/material.dart';
import 'package:prudapp/components/prud_image_picker.dart';
import 'package:prudapp/components/prud_video_picker.dart';
import 'package:prudapp/components/translate_text.dart';
import 'package:prudapp/models/backblaze.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';

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

  @override
  void initState(){
    if(mounted){
      setState((){
        result = {
          "videoUrl": prudStudioNotifier.newVideo.videoType,
          "thrillerVideoUrl": prudStudioNotifier.newVideo.thriller?.videoUrl,
          "videoThumbnail": prudStudioNotifier.newVideo.videoThumbnail,
          "videoLocalFile": prudStudioNotifier.newVideo.videoLocalFile,
          "thrillerLocalFile": prudStudioNotifier.newVideo.thrillerLocalFile,
        };
      });
    }
    super.initState();
  }

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

  void setThrillerDurationGotten(PrudVidDuration duration){
    if(mounted){
      setState(() {
        prudStudioNotifier.newVideo.thriller?.durationInMinutes = int.parse(duration.minutes);
        prudStudioNotifier.newVideo.thriller?.durationInSeconds = int.parse(duration.seconds);
      });
      prudStudioNotifier.saveNewVideoData();
    }
  }

  void setVideoDurationGotten(PrudVidDuration duration){
    if(mounted){
      setState(() {
        prudStudioNotifier.newVideo.videoDuration = duration;
      });
      prudStudioNotifier.saveNewVideoData();
    }
  }

  void setVideoSavedFinished(String url){
    if(mounted){
      setState(() {
        prudStudioNotifier.newVideo.videoUrl = url;
        result ??= {};
        result!["videoUrl"] = url;
      });
      prudStudioNotifier.saveNewVideoData();
    }
  }

  void setThrillerUrl(String url){
    if(mounted){
      setState(() {
        prudStudioNotifier.newVideo.thriller!.videoUrl = url;
        result ??= {};
        result!["thrillerVideoUrl"] = url;
      });
      prudStudioNotifier.saveNewVideoData();
    }
  }

  void setVideoFile(String url){
    if(mounted){
      setState(() {
        prudStudioNotifier.newVideo.videoLocalFile = File(url);
        result ??= {};
        result!["videoLocalFile"] = File(url);
      });
      prudStudioNotifier.saveNewVideoData();
    }
  }

  void setThrillerFile(String url){
    if(mounted){
      setState(() {
        prudStudioNotifier.newVideo.thrillerLocalFile = File(url);
        result ??= {};
        result!["thrillerLocalFile"] = File(url);
      });
      prudStudioNotifier.saveNewVideoData();
    }
  }


  void setThumbnailUrl(String? url){
    if(mounted){
      setState(() {
        prudStudioNotifier.newVideo.videoThumbnail = url;
        result ??= {};
        result!["videoThumbnail"] = url;
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
              onDurationGotten: setVideoDurationGotten,
              onSaveToCloud: setVideoSavedFinished,
              onProgressChanged: setVideoProgressChanged,
              destination: "channels/${prudStudioNotifier.newVideo.channelId}/videos",
              saveToCloud: true,
              onVideoPicked: setVideoFile,
              alreadyUploaded: prudStudioNotifier.newVideo.videoUrl != null,
              hasPartialUpload: prudStudioNotifier.newVideo.saveVideoProgress != null,
              uploadedFilePath: prudStudioNotifier.newVideo.videoLocalFile?.path,
              savedProgress: prudStudioNotifier.newVideo.saveVideoProgress,
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
              isShort: true,
              onDurationGotten: setThrillerDurationGotten,
              onSaveToCloud: setThrillerUrl,
              onProgressChanged: setThrillerProgressChanged,
              destination: "channels/${prudStudioNotifier.newVideo.channelId}/thrillers",
              saveToCloud: true,
              onVideoPicked: setThrillerFile,
              alreadyUploaded: prudStudioNotifier.newVideo.thriller?.videoUrl != null && prudStudioNotifier.newVideo.thriller!.videoUrl.isNotEmpty,
              hasPartialUpload: prudStudioNotifier.newVideo.saveThrillerProgress != null,
              uploadedFilePath: prudStudioNotifier.newVideo.thrillerLocalFile?.path,
              savedProgress: prudStudioNotifier.newVideo.saveThrillerProgress,
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
              destination: "channels/${prudStudioNotifier.newVideo.channelId}/thumbnails",
              saveToCloud: true,
              reset: shouldReset,
              onSaveToCloud: setThumbnailUrl,
              existingUrl: prudStudioNotifier.newVideo.videoThumbnail,
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
            ),
            mediumSpacer.height,
          ],
        ),
      ),
    );
  }
}