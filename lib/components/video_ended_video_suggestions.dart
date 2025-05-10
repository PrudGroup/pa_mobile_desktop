import 'dart:isolate';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:prudapp/models/prud_vid.dart';
import 'package:prudapp/models/theme.dart';
import 'package:prudapp/singletons/i_cloud.dart';
import 'package:prudapp/singletons/tab_data.dart';
    
class VideoEndedVideoSuggestions extends StatefulWidget {
  final String videoId;
  final String channnelId;
  final String title;
  final List<String>? tags;
  final String? category;
  
  const VideoEndedVideoSuggestions({
    super.key, required this.videoId, 
    required this.channnelId, required this.title, 
    this.tags, this.category
  });

  @override
  VideoEndedVideoSuggestionsState createState() => VideoEndedVideoSuggestionsState();
}

class VideoEndedVideoSuggestionsState extends State<VideoEndedVideoSuggestions> {
  List<ChannelVideo> allSuggestions = [];
  bool loading = false;
  List<ChannelVideo> suggestionsFromSameChannel = [];
  List<ChannelVideo> suggestionsFromOtherChannels = [];
  Isolate? sameIsolate;
  Isolate? otherIsolate;
  ReceivePort samePort = ReceivePort();
  ReceivePort otherPort = ReceivePort();

  Future<void> getSuggestionsFromSameChannel() async{
    
  }

  Future<void> getSuggestionsFromOtherChannels() async{

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
            child: Wrap(
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
                                  "${tabData.getFormattedNumber(vid.nonMemberViews + vid.memberViews)}",
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