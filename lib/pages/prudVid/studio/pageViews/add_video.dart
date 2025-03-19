import 'package:flutter/material.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/add_video_views/video_category.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/add_video_views/video_cost.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/add_video_views/video_declare.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/add_video_views/video_live.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/add_video_views/video_movie.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/add_video_views/video_music.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/add_video_views/video_policy.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/add_video_views/video_publish_type.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/add_video_views/video_result.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/add_video_views/video_scheduled.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/add_video_views/video_snippets.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/add_video_views/video_target.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/add_video_views/video_titles.dart';
import 'package:prudapp/pages/prudVid/studio/pageViews/add_video_views/video_uploads.dart';
import 'package:prudapp/singletons/prud_studio_notifier.dart';

    
class AddVideo extends StatefulWidget {
  final VidChannel channel;
  final String creatorId;

  const AddVideo({
    super.key, 
    required this.channel, 
    required this.creatorId
  });

  @override
  AddVideoState createState() => AddVideoState();
}

class AddVideoState extends State<AddVideo> {
  AddVideoStep presentStep = prudStudioNotifier.newVideo.lastStep;
  bool succeeded = false;
  String? errorMsg;

  @override
  void initState() {
    if(mounted) {
      setState(() {
        prudStudioNotifier.newVideo.videoType = widget.channel.category;
      });
    }
    super.initState();
  }

  void handlePreviousEvents() async {
    AddVideoStep lastStep = AddVideoStep.policy;
    switch(presentStep){
      case AddVideoStep.policy: {
        Navigator.pop(context);
        break;
      }
      case AddVideoStep.declaration: {
        lastStep = AddVideoStep.policy;
        break;
      }
      case AddVideoStep.category: {
        lastStep = AddVideoStep.declaration;
        break;
      }
      case AddVideoStep.live: {
        lastStep = AddVideoStep.category;
        break;
      }
      case AddVideoStep.uploads: {
        lastStep = AddVideoStep.category;
        if(prudStudioNotifier.newVideo.isLive == true) lastStep = AddVideoStep.live;
        break;
      }
      case AddVideoStep.titles: {
        lastStep = AddVideoStep.uploads;
        if(prudStudioNotifier.newVideo.isLive) lastStep = AddVideoStep.live;
        break;
      }
      case AddVideoStep.target: {
        lastStep = AddVideoStep.titles;
        break;
      }
      case AddVideoStep.publishType: {
        lastStep = AddVideoStep.target;
        break;
      }
      case AddVideoStep.scheduled: {
        lastStep = AddVideoStep.publishType;
        break;
      }
      case AddVideoStep.snippets: {
        lastStep = AddVideoStep.publishType;
        if(prudStudioNotifier.newVideo.scheduledFor != null) lastStep = AddVideoStep.scheduled;
        break;
      }
      case AddVideoStep.movie: {
        lastStep = AddVideoStep.snippets;
        break;
      }
      case AddVideoStep.music: {
        lastStep = AddVideoStep.snippets;
        break;
      }
      case AddVideoStep.cost: {
        lastStep = AddVideoStep.snippets;
        if(prudStudioNotifier.newVideo.videoType?.toLowerCase() == "movies") lastStep = AddVideoStep.movie;
        if(prudStudioNotifier.newVideo.videoType?.toLowerCase() == "music") lastStep = AddVideoStep.music;
        break;
      }
      default: {
        lastStep = AddVideoStep.cost;
        break;
      }
    }
    prudStudioNotifier.newVideo.lastStep = presentStep;
    await prudStudioNotifier.saveNewVideoData();
    if(mounted) setState(() => presentStep = lastStep);
  }

  void handleNextEvents(dynamic returnedData) async {
    AddVideoStep step = AddVideoStep.policy;
    switch(presentStep){
      case AddVideoStep.policy: {
        step = AddVideoStep.declaration;
        break;
      }
      case AddVideoStep.declaration: {
        prudStudioNotifier.newVideo.iDeclared = returnedData;
        step = AddVideoStep.category;
        break;
      }
      case AddVideoStep.category: {
        prudStudioNotifier.newVideo.isLive = returnedData;
        if(returnedData == true){
          step = AddVideoStep.live;
        }else{
          step = AddVideoStep.uploads;
        }
        break;
      }
      case AddVideoStep.live: {
        step = AddVideoStep.live;
        if(returnedData != null){
          prudStudioNotifier.newVideo.liveStartsOn = returnedData;
          step = AddVideoStep.uploads;
        }
        break;
      }
      case AddVideoStep.uploads: {
        step = AddVideoStep.uploads;
        if(returnedData != null && returnedData["videoUrl"] != null  && returnedData["thrillerVideoUrl"] != null  && returnedData["videoThumbnail"] != null){
          prudStudioNotifier.newVideo.videoUrl = returnedData["videoUrl"];
          prudStudioNotifier.newVideo.thriller = VideoThriller(videoId: "", videoUrl: returnedData["thrillerVideoUrl"]);
          prudStudioNotifier.newVideo.videoThumbnail = returnedData["videoThumbnail"];
          prudStudioNotifier.newVideo.videoLocalFile = returnedData["videoLocalFile"];
          prudStudioNotifier.newVideo.thrillerLocalFile = returnedData["thrillerLocalFile"];
          step = AddVideoStep.titles;
        }
        break;
      }
      case AddVideoStep.titles: {
        step = AddVideoStep.titles;
        debugPrint("Things go here A");
        if(returnedData != null && returnedData["title"] != null && returnedData["description"] != null) {
          debugPrint("Things go here B");
          prudStudioNotifier.newVideo.title = returnedData["title"];
          prudStudioNotifier.newVideo.description = returnedData["description"];
          step = AddVideoStep.target;
        }
        break;
      }
      case AddVideoStep.target: {
        step = AddVideoStep.target;
        if(
          returnedData != null && returnedData["target"] != null && 
          returnedData["videoTags"] != null && returnedData["videoTags"]!.isNotEmpty && 
          returnedData["thrillerTags"] != null && returnedData["thrillerTags"]!.isNotEmpty
        ) {
          prudStudioNotifier.newVideo.targetAudience = returnedData["target"];
          prudStudioNotifier.newVideo.tags = returnedData["videoTags"];
          prudStudioNotifier.newVideo.thriller!.tags = returnedData["thrillerTags"];
          step = AddVideoStep.publishType;
        }
        break;
      }
      case AddVideoStep.publishType: {
        step = returnedData == true? AddVideoStep.scheduled : AddVideoStep.snippets;
        break;
      }
      case AddVideoStep.scheduled: {
        step = AddVideoStep.scheduled;
        if(returnedData != null && returnedData["scheduledFor"] != null && returnedData["timezone"] != null) {
          prudStudioNotifier.newVideo.scheduledFor = returnedData["scheduledFor"];
          prudStudioNotifier.newVideo.timezone = returnedData["timezone"];
          step = AddVideoStep.snippets;
        }
        break;
      }
      case AddVideoStep.snippets: {
        step = AddVideoStep.snippets;
        if(returnedData["snippets"] != null){
          prudStudioNotifier.newVideo.snippets = returnedData["snippets"];
          if(["movies", "music"].contains(widget.channel.category.toLowerCase())){
            step = widget.channel.category.toLowerCase() == "movies"? AddVideoStep.movie : AddVideoStep.music;
          }else{
            step = AddVideoStep.cost;
          }
        }
        break;
      }
      case AddVideoStep.movie: {
        step = AddVideoStep.movie;
        if(returnedData != null && returnedData["detail"] != null) {
          VideoMovieDetail mov = returnedData["detail"];
          prudStudioNotifier.newVideo.movieDetailId = mov.id;
          prudStudioNotifier.newVideo.movieDetail = mov;
          prudStudioNotifier.newVideo.hasSavedMovieDetails = true;
          step = AddVideoStep.cost;
        }
        break;
      }
      case AddVideoStep.music: {
        step = AddVideoStep.music;
        if(returnedData != null && returnedData["detail"] != null) {
          VideoMusicDetail mus = returnedData["detail"];
          prudStudioNotifier.newVideo.musicDetailId = mus.id;
          prudStudioNotifier.newVideo.musicDetail = mus;
          prudStudioNotifier.newVideo.hasSavedMusicDetails = true;
          step = AddVideoStep.cost;
        }
        break;
      }
      case AddVideoStep.cost: {
        step = AddVideoStep.cost;
        if(mounted){
          setState(() {
            succeeded = returnedData != null && returnedData == true;
            errorMsg = "Unable to save details of uploaded video. Check your network and try again.";
          });
        }
        step = AddVideoStep.result;
        break;
      }
      default: {
        if(succeeded){
          prudStudioNotifier.newVideo = PendingNewVideo(
            thriller: VideoThriller(
              videoId: "", videoUrl: ""
            )
          );
          prudStudioNotifier.clearUnfinishedNewVideoFromCache();
          Navigator.pop(context);
        }else{
          Navigator.pop(context);
        }
        break;
      }
    }
    prudStudioNotifier.newVideo.lastStep = step;
    await prudStudioNotifier.saveNewVideoData();
    if(mounted) setState(() => presentStep = step);
  }
  
  @override
  Widget build(BuildContext context) {
    return presentStep == AddVideoStep.policy?
     VideoPolicy(
      onCompleted: handleNextEvents, 
      onPrevious: handlePreviousEvents,
     ) 
     : 
     (
      presentStep == AddVideoStep.declaration?
      VideoDeclare(
        onCompleted: handleNextEvents, 
        onPrevious: handlePreviousEvents,
      )
      :
      (
        presentStep == AddVideoStep.category?
        VideoCategory(
          onCompleted: handleNextEvents, 
          onPrevious: handlePreviousEvents,
        )
        :
        (
          presentStep == AddVideoStep.live?
          VideoLive(
            onCompleted: handleNextEvents, 
            onPrevious: handlePreviousEvents,
          )
          :
          (
            presentStep == AddVideoStep.uploads?
            VideoUploads(
              onCompleted: handleNextEvents, 
              onPrevious: handlePreviousEvents,
            )
            :
            (
              presentStep == AddVideoStep.titles?
              VideoTitles(
                onCompleted: handleNextEvents, 
                onPrevious: handlePreviousEvents,
              )
              :
              (
                presentStep == AddVideoStep.target?
                VideoTarget(
                  onCompleted: handleNextEvents, 
                  onPrevious: handlePreviousEvents,
                )
                :
                (
                  presentStep == AddVideoStep.publishType?
                  VideoPublishType(
                    onCompleted: handleNextEvents, 
                    onPrevious: handlePreviousEvents,
                  )
                  :
                  (
                    presentStep == AddVideoStep.scheduled?
                    VideoScheduled(
                      onCompleted: handleNextEvents, 
                      onPrevious: handlePreviousEvents,
                    )
                    :
                    (
                      presentStep == AddVideoStep.snippets?
                      VideoSnippets(
                        onCompleted: handleNextEvents, 
                        onPrevious: handlePreviousEvents,
                      )
                      :
                      (
                        presentStep == AddVideoStep.movie?
                        VideoMovie(
                          onCompleted: handleNextEvents, 
                          onPrevious: handlePreviousEvents,
                        )
                        :
                        (
                          presentStep == AddVideoStep.music?
                          VideoMusic(
                            onCompleted: handleNextEvents, 
                            onPrevious: handlePreviousEvents,
                          )
                          :
                          (
                            presentStep == AddVideoStep.cost?
                            VideoCost(
                              channel: widget.channel,
                              creatorId: widget.creatorId,
                              onCompleted: handleNextEvents, 
                              onPrevious: handlePreviousEvents,
                            )
                            :
                            VideoResult(
                              succeeded: succeeded,
                              errorMsg: errorMsg,
                              onCompleted: handleNextEvents, 
                              onPrevious: handlePreviousEvents,
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      )
     );
  }
}