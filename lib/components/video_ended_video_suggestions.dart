import 'dart:isolate';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:prudapp/components/loading_component.dart';
import 'package:prudapp/isolates.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/shared_classes.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/prudvid_notifier.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class VideoEndedVideoSuggestions extends StatefulWidget {
  final String videoId;
  final String channnelId;
  final String title;
  final int? season;
  final int? episode;
  final int? part;
  final String? album;
  final String category;
  
  const VideoEndedVideoSuggestions({
    super.key, required this.videoId, 
    required this.channnelId, required this.title, 
    this.season, required this.category, this.episode, this.part, this.album
  });

  @override
  VideoEndedVideoSuggestionsState createState() => VideoEndedVideoSuggestionsState();
}

class VideoEndedVideoSuggestionsState extends State<VideoEndedVideoSuggestions> {
  List<ChannelVideo> allSuggestions = [];
  bool loading = false;
  Isolate? sameIsolate;
  Isolate? otherIsolate;
  ReceivePort samePort = ReceivePort();
  ReceivePort otherPort = ReceivePort();
  PrudCredential cred = PrudCredential(
    key: prudApiKey, token: iCloud.affAuthToken!
  );

  Future<void> getSuggestionsFromSameChannel() async{
    sameIsolate = await Isolate.spawn(getVideoSuggestionsByChannel, SearchVideosByChannelArg(
      cred: cred, port: samePort.sendPort, criteria: SearchByChannelSchema(
        channelId: widget.channnelId, category: widget.category,
        title: widget.title, limit: 4, offset: 0, albumName: widget.album,
        season: widget.season, episode: widget.episode, part: widget.part
      )
    ), onError: samePort.sendPort, onExit: samePort.sendPort);
    samePort.listen((resp){
      if(resp != null && resp.isNotEmpty){
        List<ChannelVideo> foundVideos = resp.map((vid) => ChannelVideo.fromJson(vid)).toList();
        List<ChannelVideo> unwanted = [];
        for(ChannelVideo vid in foundVideos){
          bool isUnwantedVideo = prudVidNotifier.notInterestedVideos.contains(vid.id);
          if(isUnwantedVideo) unwanted.add(vid); 
        }
        for(ChannelVideo vid in unwanted){
          foundVideos.remove(vid);
        }
        if(mounted) setState(() => allSuggestions.addAll(foundVideos));
      }
    });
  }

  Future<void> getSuggestionsFromOtherChannels() async{
    otherIsolate = await Isolate.spawn(getRelatedVideoService, VideoSearchServiceArg(
      cred: cred, sendPort: otherPort.sendPort, searchType: VideoSearchType.categoryTitleTags,
      category: widget.category, searchText: widget.title, limit: 10, offset: 0
    ), onError: otherPort.sendPort, onExit: otherPort.sendPort);
    otherPort.listen((resp){
      if(resp != null && resp.isNotEmpty){
        List<ChannelVideo> foundVideos = resp.map((vid) => ChannelVideo.fromJson(vid)).toList();
        List<ChannelVideo> unwanted = [];
        for(ChannelVideo vid in foundVideos){
          bool isFromUnwantedChannel = prudVidNotifier.dontRecommend.contains(vid.channelId);
          if(isFromUnwantedChannel) unwanted.add(vid);
          bool isUnwantedVideo = prudVidNotifier.notInterestedVideos.contains(vid.id);
          if(isFromUnwantedChannel == false && isUnwantedVideo) unwanted.add(vid); 
        }
        for(ChannelVideo vid in unwanted){
          foundVideos.remove(vid);
        }
        if(mounted) setState(() => allSuggestions.addAll(foundVideos));
      }
    });
  }

  @override
  void initState() {
    Future.wait([getSuggestionsFromSameChannel(), getSuggestionsFromOtherChannels()]);
    super.initState();
  }

  @override
  void dispose() {
    samePort.close();
    otherPort.close();
    sameIsolate?.kill(priority: Isolate.immediate);
    otherIsolate?.kill(priority: Isolate.immediate);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            physics: BouncingScrollPhysics(),
            child: allSuggestions.isEmpty? Center(
              child: LoadingComponent(
                isShimmer: false,
                defaultSpinnerType: false,
                spinnerColor: prudColorTheme.primary,
                size: 20,
              ),
            ) : Wrap(
              spacing: 10,
              runSpacing: 10,
              children: allSuggestions.map((vid) => InkWell(
                child: SizedBox(
                  width: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 130,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: prudColorTheme.lineC, width: 3),
                          color: prudColorTheme.bgF,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FastCachedImageProvider(
                              iCloud.authorizeDownloadUrl(vid.videoThumbnail),
                            ),
                          ),
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 90),
                        child: Column(
                          children: [
                            SizedBox(
                              child: Text( 
                                tabData.shortenStringWithPeriod(vid.title, length: 40),
                                style: prudWidgetStyle.tabTextStyle.copyWith(
                                  color: prudColorTheme.bgA,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.0
                                ),
                              )
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GFRating(
                                  onChanged: (rate){},
                                  value: vid.getRating(),
                                  color: prudColorTheme.buttonC,
                                  borderColor: prudColorTheme.buttonC,
                                  size: 15,
                                ),
                                Text(
                                  tabData.getFormattedNumber(vid.nonMemberViews + vid.memberViews),
                                  style: prudWidgetStyle.btnTextStyle.copyWith(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w500,
                                    color: prudColorTheme.bgC
                                  )
                                ),
                              ]
                            ),
                          ]
                        ),
                      )
                    ]
                  ),
                ),
              )).toList(),
            ),
          )
        ),
      ],
    );
  }
}